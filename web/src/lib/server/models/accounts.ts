/**
 * Accounts, friendships and progress.
 *
 * Identity rule: the account id is assigned by the application from a stable
 * source (see ids.ts) and the game's ``zid`` is derived from it. It is *not*
 * derived from a session cookie, which is what the Python server still does and
 * why a cookie rotation there can split one player's save in two.
 *
 * Everything here is async. That is not a stylistic choice: PostgreSQL 18 is reached
 * over a socket through Bun's SQL client, and holding a synchronous handle open
 * across a round trip is not something to do. The helpers in db/client keep the
 * SQL and the ``?`` placeholders unchanged, so this file reads the way it did
 * when it was talking to SQLite.
 */
import { all, now, one, run, transact } from "../db/client.ts";
import { config } from "../config.ts";
import { zidForUserAsNumber } from "../ids.ts";

export type Role = "player" | "admin";

export const ROLES: readonly Role[] = ["player", "admin"];

export interface User {
  id: number;
  /** Integer in the database; see PublicUser for why the API exposes a string. */
  zid: number;
  username: string;
  username_key: string;
  password_hash: string;
  role: Role;
  created_at: string;
  last_seen_at: string | null;
}

export interface Progress {
  user_id: number;
  level: number;
  xp: number;
  world_name: string;
  updated_at: string;
}

export interface FriendRow {
  user_id: number;
  friend_id: number;
  status: string;
  requested_by: number;
  created_at: string;
  accepted_at: string | null;
}

/** Strip the password hash before anything reaches a view or a response. */
type UserWithoutHash = Omit<User, "password_hash" | "zid">;

/**
 * A user as the outside world sees it.
 *
 * `zid` is carried as a string even though the column is BIGINT. PostgreSQL
 * hands back a JS number or bigint when it fits, and the value is
 * safe today, but routing every identity through one string representation
 * removes a whole class of precision bug from the JSON boundary.
 */
export interface PublicUser extends UserWithoutHash {
  zid: string;
}

export function publicUser(user: User): PublicUser {
  const { password_hash: _ignored, zid, ...rest } = user;
  return { ...rest, zid: String(zid) };
}

export function normalizeUsername(username: string): string {
  return username.trim().toLowerCase();
}

export class UsernameTaken extends Error {
  constructor(readonly username: string) {
    super(`username already registered: ${username}`);
    this.name = "UsernameTaken";
  }
}

/** Deterministic world name for a fresh account. */
function defaultWorldName(username: string): string {
  const cleaned = username.trim();
  if (cleaned.length === 0) return "New Empire";
  return `${cleaned[0]?.toUpperCase()}${cleaned.slice(1)}'s Empire`;
}

/**
 * The next account id.
 *
 * Not AUTO_INCREMENT: the id is assigned by the application so it comes from a
 * stable source and a regenerated id can never orphan a save. MAX(id)+1 inside
 * the transaction is safe here because the caller holds the write lock and a
 * duplicate raises rather than colliding silently.
 */
async function nextUserId(): Promise<number> {
  const row = await one<{ n: number | null }>("SELECT MAX(id) AS n FROM users");
  return (row?.n ?? 0) + 1;
}

export async function createUser(
  username: string,
  password: string,
  role: Role = "player"
): Promise<PublicUser> {
  const trimmed = username.trim();
  const usernameKey = normalizeUsername(username);

  if (trimmed.length < 3 || trimmed.length > 24) {
    throw new RangeError("username must be 3-24 characters");
  }
  if (password.length < 8) {
    throw new RangeError("password must be at least 8 characters");
  }

  const existing = await one<{ id: number }>(
    "SELECT id FROM users WHERE username_key = ?",
    usernameKey
  );
  if (existing) throw new UsernameTaken(trimmed);

  const passwordHash = await Bun.password.hash(password, { algorithm: "argon2id" });

  return transact(async () => {
    const id = await nextUserId();
    const zid = zidForUserAsNumber(id);
    await run(
      `INSERT INTO users (id, zid, username, username_key, password_hash, role, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      id,
      zid,
      trimmed,
      usernameKey,
      passwordHash,
      role,
      now()
    );
    await run(
      `INSERT INTO progress (user_id, level, xp, world_name, updated_at)
       VALUES (?, 1, 0, ?, ?)`,
      id,
      defaultWorldName(trimmed),
      now()
    );

    const user = await findById(id);
    if (!user) throw new Error("user insert did not persist");
    return publicUser(user);
  });
}

export async function findById(id: number): Promise<User | null> {
  return one<User>("SELECT * FROM users WHERE id = ?", id);
}

export async function findByUsername(username: string): Promise<User | null> {
  return one<User>("SELECT * FROM users WHERE username_key = ?", normalizeUsername(username));
}

export async function findByZid(zid: string | number): Promise<User | null> {
  return one<User>("SELECT * FROM users WHERE zid = ?", zid);
}

export async function verifyPassword(user: User, password: string): Promise<boolean> {
  return Bun.password.verify(password, user.password_hash);
}

export async function touchLastSeen(id: number): Promise<void> {
  await run("UPDATE users SET last_seen_at = ? WHERE id = ?", now(), id);
}

export function isAdmin(user: Pick<User, "role"> | null | undefined): boolean {
  return user?.role === "admin";
}

/**
 * Change a role, refusing to remove the last admin.
 *
 * Without that guard it is one call away from locking every moderator out of
 * their own server.
 */
export async function setRole(userId: number, role: Role): Promise<void> {
  if (!ROLES.includes(role)) throw new RangeError(`unknown role: ${role}`);

  if (role !== "admin") {
    const admins = await one<{ n: number }>(
      "SELECT COUNT(*) AS n FROM users WHERE role = 'admin'"
    );
    const target = await findById(userId);
    if (target?.role === "admin" && (admins?.n ?? 0) <= 1) {
      throw new Error("cannot remove the last admin");
    }
  }

  await run("UPDATE users SET role = ? WHERE id = ?", role, userId);
}

export async function getProgress(userId: number): Promise<Progress | null> {
  const row = await one<Progress>("SELECT * FROM progress WHERE user_id = ?", userId);
  if (!row) return null;
  return {
    ...row,
    level: Number(row.level),
    xp: Number(row.xp),
  };
}

export async function updateProgress(
  userId: number,
  patch: { level?: number; xp?: number; world_name?: string }
): Promise<Progress> {
  const current = await getProgress(userId);
  if (!current) {
    await run(
      `INSERT INTO progress (user_id, level, xp, world_name, updated_at)
       VALUES (?, ?, ?, ?, ?)
       ON CONFLICT (user_id) DO UPDATE
       SET level = EXCLUDED.level, xp = EXCLUDED.xp, world_name = EXCLUDED.world_name, updated_at = EXCLUDED.updated_at`,
      userId,
      patch.level ?? 1,
      patch.xp ?? 0,
      patch.world_name ?? 'Mi Imperio',
      now()
    );
  } else {
    await run(
      `UPDATE progress
          SET level = ?, xp = ?, world_name = ?, updated_at = ?
        WHERE user_id = ?`,
      patch.level ?? current.level,
      patch.xp ?? current.xp,
      patch.world_name ?? current.world_name,
      now(),
      userId
    );
  }

  const updated = await getProgress(userId);
  if (!updated) throw new Error(`progress update lost for user ${userId}`);
  return updated;
}

export async function recordActivity(
  userId: number | null,
  kind: string,
  detail?: string
): Promise<void> {
  // `id` is left to AUTO_INCREMENT. The original relied on the column's rowid
  // alias, which was SQLite-only and has no MariaDB equivalent.
  await run(
    "INSERT INTO activity (user_id, kind, detail, created_at) VALUES (?, ?, ?, ?)",
    userId,
    kind,
    detail ?? null,
    now()
  );
}

export async function recentActivity(
  userId: number,
  limit = 20
): Promise<Array<{ kind: string; detail: string | null; created_at: string }>> {
  return all<{ kind: string; detail: string | null; created_at: string }>(
    "SELECT kind, detail, created_at FROM activity WHERE user_id = ? ORDER BY id DESC LIMIT ?",
    userId,
    limit
  );
}

/* ------------------------------------------------------------- friendships -- */

export interface FriendView {
  username: string;
  zid: number;
  status: string;
  level: number | null;
  world_name: string | null;
  last_seen_at: string | null;
}

/**
 * Symmetric friendship state between `viewer` and `other`.
 *
 * Rows are stored in both directions, so a lookup is one indexed read and the
 * status can never disagree between the two players.
 */
export async function friendshipStatus(
  viewer: number,
  other: number,
  lock = false
): Promise<{ status: "none" | "pending" | "accepted" | "blocked"; outgoing: boolean }> {
  // `lock` adds FOR UPDATE, and is what the writer uses.
  //
  // Without it the two SELECTs inside a transaction take shared locks and the
  // upsert that follows needs an exclusive one on the same rows. MariaDB rejects
  // that with "Record has changed since last read in table 'friendships'; try
  // restarting transaction" -- a real deadlock report, not a formatting
  // complaint. Locking up front is what makes read-then-write safe here.
  const suffix = lock ? " FOR UPDATE" : "";

  const mine = await one<FriendRow>(
    `SELECT * FROM friendships WHERE user_id = ? AND friend_id = ?${suffix}`,
    viewer,
    other
  );
  const theirs = await one<FriendRow>(
    `SELECT * FROM friendships WHERE user_id = ? AND friend_id = ?${suffix}`,
    other,
    viewer
  );

  if (mine?.status === "blocked" || theirs?.status === "blocked") {
    return { status: "blocked", outgoing: mine !== null };
  }
  if (!mine && !theirs) return { status: "none", outgoing: false };
  if (mine?.status === "accepted" && theirs?.status === "accepted") {
    return { status: "accepted", outgoing: false };
  }
  if (mine && theirs) {
    // Both directions are pending, so only requested_by says who asked.
    return { status: "pending", outgoing: mine.requested_by === viewer };
  }
  if (mine) return { status: "pending", outgoing: true };
  return { status: "pending", outgoing: false };
}

/** Send or accept a friend request. Both directions are written together. */
export async function addFriend(
  requesterId: number,
  targetId: number
): Promise<"pending" | "accepted"> {
  if (requesterId === targetId) throw new RangeError("cannot befriend yourself");

  const target = await findById(targetId);
  if (!target) throw new Error(`no such user: ${targetId}`);

  const stamp = now();

  // The current state has to be read inside the transaction. A prior version
  // read it before opening one and then always wrote "pending" on the second
  // call, so accepting a request could never take effect.
  return transact(async () => {
    // Locked, because this one is about to write to both rows.
    const current = await friendshipStatus(requesterId, targetId, true);

    if (current.status === "accepted") return "accepted";
    if (current.status === "blocked") throw new Error("friendship is blocked");

    // They already asked us, so this is an acceptance rather than a new request.
    const isAcceptance = current.status === "pending" && !current.outgoing;
    const status = isAcceptance ? "accepted" : "pending";
    const acceptedAt = isAcceptance ? stamp : null;

    const isPostgres = config.database.url.startsWith("postgres");
    const upsert = isPostgres
      ? `
      INSERT INTO friendships (user_id, friend_id, status, requested_by, created_at, accepted_at)
      VALUES (?, ?, ?, ?, ?, ?)
      ON CONFLICT (user_id, friend_id) DO UPDATE SET
        status = EXCLUDED.status,
        requested_by = EXCLUDED.requested_by,
        accepted_at = EXCLUDED.accepted_at`
      : `
      INSERT INTO friendships (user_id, friend_id, status, requested_by, created_at, accepted_at)
      VALUES (?, ?, ?, ?, ?, ?)
      ON DUPLICATE KEY UPDATE status = VALUES(status),
                               requested_by = VALUES(requested_by),
                               accepted_at = VALUES(accepted_at)`;

    await run(upsert, requesterId, targetId, status, requesterId, stamp, acceptedAt);
    await run(upsert, targetId, requesterId, status, requesterId, stamp, acceptedAt);

    return status;
  });
}

export async function removeFriend(userId: number, otherId: number): Promise<void> {
  await transact(async () => {
    await run("DELETE FROM friendships WHERE user_id = ? AND friend_id = ?", userId, otherId);
    await run("DELETE FROM friendships WHERE user_id = ? AND friend_id = ?", otherId, userId);
  });
}

export async function listFriends(userId: number): Promise<FriendView[]> {
  return all<FriendView>(
    `SELECT u.username, u.zid, f.status, p.level, p.world_name, u.last_seen_at
       FROM friendships f
       JOIN users u ON u.id = f.friend_id
       LEFT JOIN progress p ON p.user_id = u.id
      WHERE f.user_id = ? AND f.status = 'accepted'
      ORDER BY u.username`,
    userId
  );
}

/** Players worth suggesting: accounts with progress that are not yet friends. */
export async function suggestFriends(userId: number, limit = 10): Promise<FriendView[]> {
  return all<FriendView>(
    `SELECT u.username, u.zid, 'none' AS status, p.level, p.world_name, u.last_seen_at
       FROM users u
       JOIN progress p ON p.user_id = u.id
      WHERE u.id <> ?
        AND NOT EXISTS (
          SELECT 1 FROM friendships f
           WHERE f.user_id = ? AND f.friend_id = u.id
        )
      ORDER BY p.level DESC, u.username
      LIMIT ?`,
    userId,
    userId,
    limit
  );
}

export interface PendingRequestView {
  userId: number;
  username: string;
  zid: number;
  level: number | null;
  world_name: string | null;
  created_at: string;
}

/** Peticiones de amistad recibidas que están pendientes de respuesta. */
export async function listPendingIncoming(userId: number): Promise<PendingRequestView[]> {
  return all<PendingRequestView>(
    `SELECT u.id AS "userId", u.username, u.zid, p.level, p.world_name, f.created_at
       FROM friendships f
       JOIN users u ON u.id = f.requested_by
       LEFT JOIN progress p ON p.user_id = u.id
      WHERE f.user_id = ? AND f.status = 'pending' AND f.requested_by <> ?
      ORDER BY f.created_at DESC`,
    userId,
    userId
  );
}

/** Peticiones de amistad enviadas por el usuario que esperan aceptación. */
export async function listPendingOutgoing(userId: number): Promise<PendingRequestView[]> {
  return all<PendingRequestView>(
    `SELECT u.id AS "userId", u.username, u.zid, p.level, p.world_name, f.created_at
       FROM friendships f
       JOIN users u ON u.id = f.friend_id
       LEFT JOIN progress p ON p.user_id = u.id
      WHERE f.user_id = ? AND f.status = 'pending' AND f.requested_by = ?
      ORDER BY f.created_at DESC`,
    userId,
    userId
  );
}

/** Búsqueda de comandantes en vivo por nombre de usuario. */
export async function searchUsers(
  query: string,
  excludeUserId: number,
  limit = 10
): Promise<FriendView[]> {
  const cleaned = query.trim().toLowerCase();
  if (!cleaned) return [];
  return all<FriendView>(
    `SELECT u.username, u.zid, COALESCE(f.status, 'none') AS status, p.level, p.world_name, u.last_seen_at
       FROM users u
       LEFT JOIN progress p ON p.user_id = u.id
       LEFT JOIN friendships f ON f.user_id = ? AND f.friend_id = u.id
      WHERE u.id <> ? AND u.username_key LIKE ?
      ORDER BY p.level DESC, u.username
      LIMIT ?`,
    excludeUserId,
    excludeUserId,
    `%${cleaned}%`,
    limit
  );
}

export interface BattleHistoryItem {
  id: number;
  kind: string;
  opponent: string;
  role: 'attack' | 'defense';
  won: boolean;
  xpGained: number;
  coinsGained: number;
  date: string;
  summary: string;
}

/** Registro de resultado de combate PvP entre comandantes. */
export async function recordBattleActivity(
  userId: number,
  opponentUsername: string,
  won: boolean,
  details: {
    role?: 'attack' | 'defense';
    xpGained?: number;
    coinsGained?: number;
    summary?: string;
    playerCasualties?: number;
    opponentCasualties?: number;
  } = {}
): Promise<void> {
  const role = details.role ?? 'attack';
  const kind =
    role === 'defense'
      ? won
        ? 'pvp.defense_victory'
        : 'pvp.defense_defeat'
      : won
        ? 'pvp.victory'
        : 'pvp.defeat';

  await recordActivity(
    userId,
    kind,
    JSON.stringify({ opponent: opponentUsername, won, role, ...details })
  );
}

/** Historial de batallas y enfrentamientos PvP recientes. */
export async function getRecentBattles(userId: number, limit = 10): Promise<BattleHistoryItem[]> {
  const rows = await all<{ id: number; kind: string; detail: string | null; created_at: string }>(
    `SELECT id, kind, detail, created_at FROM activity
      WHERE user_id = ? AND kind IN ('pvp.victory', 'pvp.defeat', 'pvp.defense_victory', 'pvp.defense_defeat')
      ORDER BY id DESC LIMIT ?`,
    userId,
    limit
  );

  return rows.map((r) => {
    let opponent = 'Comandante Rival';
    let won = r.kind === 'pvp.victory' || r.kind === 'pvp.defense_victory';
    let role: 'attack' | 'defense' = r.kind.startsWith('pvp.defense_') ? 'defense' : 'attack';
    let xpGained = 0;
    let coinsGained = 0;
    let summary = '';
    try {
      if (r.detail) {
        const parsed = JSON.parse(r.detail);
        opponent = parsed.opponent ?? opponent;
        won = parsed.won ?? won;
        role = parsed.role ?? role;
        xpGained = parsed.xpGained ?? 0;
        coinsGained = parsed.coinsGained ?? 0;
        summary = parsed.summary ?? '';
      }
    } catch {
      opponent = r.detail ?? 'Comandante Rival';
    }
    return {
      id: r.id,
      kind: r.kind,
      opponent,
      role,
      won,
      xpGained,
      coinsGained,
      date: r.created_at,
      summary
    };
  });
}

export interface LeaderboardEntry {
  rank: number;
  id: number;
  zid: string;
  username: string;
  level: number;
  xp: number;
  worldName: string;
}

export interface PvPLeaderboardEntry {
  rank: number;
  id: number;
  zid: string;
  username: string;
  level: number;
  wins: number;
  losses: number;
  pvpScore: number;
}

export async function getLeaderboard(limit = 20): Promise<LeaderboardEntry[]> {
  const rows = await all<{
    id: number;
    zid: string;
    username: string;
    level: number;
    xp: number;
    world_name: string;
  }>(
    `SELECT u.id, u.zid, u.username, COALESCE(p.level, 1) as level, COALESCE(p.xp, 0) as xp, COALESCE(p.world_name, u.username) as world_name
       FROM users u
       LEFT JOIN progress p ON p.user_id = u.id
      ORDER BY xp DESC, level DESC
      LIMIT ?`,
    limit
  );

  return rows.map((r, i) => ({
    rank: i + 1,
    id: r.id,
    zid: String(r.zid),
    username: r.username,
    level: Number(r.level),
    xp: Number(r.xp),
    worldName: r.world_name
  }));
}

export async function getPvPLeaderboard(limit = 20): Promise<PvPLeaderboardEntry[]> {
  const rows = await all<{
    id: number;
    zid: string;
    username: string;
    level: number;
    wins: string | number;
    losses: string | number;
  }>(
    `SELECT u.id, u.zid, u.username, COALESCE(p.level, 1) as level,
            COUNT(a.id) FILTER (WHERE a.kind IN ('pvp.victory', 'pvp.defense_victory')) as wins,
            COUNT(a.id) FILTER (WHERE a.kind IN ('pvp.defeat', 'pvp.defense_defeat')) as losses
       FROM users u
       LEFT JOIN progress p ON p.user_id = u.id
       LEFT JOIN activity a ON a.user_id = u.id
      GROUP BY u.id, u.zid, u.username, p.level
      ORDER BY wins DESC, p.level DESC
      LIMIT ?`,
    limit
  );

  return rows.map((r, i) => {
    const wins = Number(r.wins);
    const losses = Number(r.losses);
    const level = Number(r.level);
    const pvpScore = wins * 250 - losses * 50 + level * 100;
    return {
      rank: i + 1,
      id: r.id,
      zid: String(r.zid),
      username: r.username,
      level,
      wins,
      losses,
      pvpScore: Math.max(0, pvpScore)
    };
  });
}
