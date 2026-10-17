/**
 * Accounts, friendships and progress.
 *
 * Identity rule: the account id is assigned by the database sequence and the
 * game's ``zid`` is derived from it (see ids.ts). It is *not* derived from a
 * session cookie, which is what the Python server still does and why a cookie
 * rotation there can split one player's save in two.
 */
import { all, now, one, run, transact } from "../db/client.ts";
import { zidForUserAsNumber } from "../../ids.ts";

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
 * `zid` is carried as a string even though the column is INTEGER. SQLite hands
 * back a JS number, and the value is safe today, but routing every identity
 * through one string representation removes a whole class of precision bug
 * from the JSON boundary.
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

export async function createUser(
  username: string,
  password: string,
  role: Role = "player",
): Promise<PublicUser> {
  const trimmed = username.trim();
  const usernameKey = normalizeUsername(username);

  if (trimmed.length < 3 || trimmed.length > 24) {
    throw new RangeError("username must be 3-24 characters");
  }
  if (password.length < 8) {
    throw new RangeError("password must be at least 8 characters");
  }

  const existing = one<{ id: number }>(
    "SELECT id FROM users WHERE username_key = ?",
    usernameKey,
  );
  if (existing) throw new UsernameTaken(trimmed);

  const passwordHash = await Bun.password.hash(password, {
    algorithm: "argon2id",
  });

  return transact(() => {
    // The id has to exist before zid is derived from it, so insert then update.
    run(
      `INSERT INTO users (zid, username, username_key, password_hash, role, created_at)
       VALUES (0, ?, ?, ?, ?, ?)`,
      trimmed,
      usernameKey,
      passwordHash,
      role,
      now(),
    );
    const created = one<{ id: number }>(
      "SELECT id FROM users WHERE username_key = ?",
      usernameKey,
    );
    if (!created) throw new Error("user insert did not persist");

    const id = created.id;
    run("UPDATE users SET zid = ? WHERE id = ?", zidForUserAsNumber(id), id);
    run(
      `INSERT INTO progress (user_id, level, xp, world_name, updated_at)
       VALUES (?, 1, 0, ?, ?)`,
      id,
      defaultWorldName(trimmed),
      now(),
    );

    const user = findById(id);
    if (!user) throw new Error("user insert did not persist");
    return publicUser(user);
  });
}

export function findById(id: number): User | null {
  return one<User>("SELECT * FROM users WHERE id = ?", id);
}

export function findByUsername(username: string): User | null {
  return one<User>("SELECT * FROM users WHERE username_key = ?", normalizeUsername(username));
}

export function findByZid(zid: string | number): User | null {
  return one<User>("SELECT * FROM users WHERE zid = ?", zid);
}

export async function verifyPassword(user: User, password: string): Promise<boolean> {
  return Bun.password.verify(password, user.password_hash);
}

export function touchLastSeen(id: number): void {
  run("UPDATE users SET last_seen_at = ? WHERE id = ?", now(), id);
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
export function setRole(userId: number, role: Role): void {
  if (!ROLES.includes(role)) throw new RangeError(`unknown role: ${role}`);

  if (role !== "admin") {
    const admins = one<{ n: number }>(
      "SELECT COUNT(*) AS n FROM users WHERE role = 'admin'",
    );
    const target = findById(userId);
    if (target?.role === "admin" && (admins?.n ?? 0) <= 1) {
      throw new Error("cannot remove the last admin");
    }
  }

  run("UPDATE users SET role = ? WHERE id = ?", role, userId);
}

export function getProgress(userId: number): Progress | null {
  return one<Progress>("SELECT * FROM progress WHERE user_id = ?", userId);
}

export function updateProgress(
  userId: number,
  patch: { level?: number; xp?: number; world_name?: string },
): Progress {
  const current = getProgress(userId);
  if (!current) throw new Error(`no progress row for user ${userId}`);

  run(
    `UPDATE progress
        SET level = ?, xp = ?, world_name = ?, updated_at = ?
      WHERE user_id = ?`,
    patch.level ?? current.level,
    patch.xp ?? current.xp,
    patch.world_name ?? current.world_name,
    now(),
    userId,
  );

  const updated = getProgress(userId);
  if (!updated) throw new Error(`progress update lost for user ${userId}`);
  return updated;
}

export function recordActivity(userId: number | null, kind: string, detail?: string): void {
  // `id` is left to the column's rowid alias. On Postgres the migration needs
  // GENERATED BY DEFAULT AS IDENTITY instead; nothing else in this file changes.
  run(
    "INSERT INTO activity (user_id, kind, detail, created_at) VALUES (?, ?, ?, ?)",
    userId,
    kind,
    detail ?? null,
    now(),
  );
}

export function recentActivity(userId: number, limit = 20): Array<{
  kind: string;
  detail: string | null;
  created_at: string;
}> {
  return all<{ kind: string; detail: string | null; created_at: string }>(
    "SELECT kind, detail, created_at FROM activity WHERE user_id = ? ORDER BY id DESC LIMIT ?",
    userId,
    limit,
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
export function friendshipStatus(
  viewer: number,
  other: number,
): { status: "none" | "pending" | "accepted" | "blocked"; outgoing: boolean } {
  const mine = one<FriendRow>(
    "SELECT * FROM friendships WHERE user_id = ? AND friend_id = ?",
    viewer,
    other,
  );
  const theirs = one<FriendRow>(
    "SELECT * FROM friendships WHERE user_id = ? AND friend_id = ?",
    other,
    viewer,
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
export function addFriend(requesterId: number, targetId: number): "pending" | "accepted" {
  if (requesterId === targetId) throw new RangeError("cannot befriend yourself");

  const target = findById(targetId);
  if (!target) throw new Error(`no such user: ${targetId}`);

  const stamp = now();

  // The current state has to be read inside the transaction. A prior version
  // read it before opening one and then always wrote "pending" on the second
  // call, so accepting a request could never take effect.
  return transact(() => {
    const current = friendshipStatus(requesterId, targetId);

    if (current.status === "accepted") return "accepted";
    if (current.status === "blocked") throw new Error("friendship is blocked");

    // They already asked us, so this is an acceptance rather than a new request.
    const isAcceptance = current.status === "pending" && !current.outgoing;
    const status = isAcceptance ? "accepted" : "pending";
    const acceptedAt = isAcceptance ? stamp : null;

    const upsert = `
      INSERT INTO friendships (user_id, friend_id, status, requested_by, created_at, accepted_at)
      VALUES (?, ?, ?, ?, ?, ?)
      ON CONFLICT (user_id, friend_id)
      DO UPDATE SET status = excluded.status,
                    requested_by = excluded.requested_by,
                    accepted_at = excluded.accepted_at`;

    run(upsert, requesterId, targetId, status, requesterId, stamp, acceptedAt);
    run(upsert, targetId, requesterId, status, requesterId, stamp, acceptedAt);

    return status;
  });
}

export function removeFriend(userId: number, otherId: number): void {
  transact(() => {
    run("DELETE FROM friendships WHERE user_id = ? AND friend_id = ?", userId, otherId);
    run("DELETE FROM friendships WHERE user_id = ? AND friend_id = ?", otherId, userId);
  });
}

export function listFriends(userId: number): FriendView[] {
  return all<FriendView>(
    `SELECT u.username, u.zid, f.status, p.level, p.world_name, u.last_seen_at
       FROM friendships f
       JOIN users u ON u.id = f.friend_id
       LEFT JOIN progress p ON p.user_id = u.id
      WHERE f.user_id = ? AND f.status = 'accepted'
      ORDER BY u.username`,
    userId,
  );
}

/** Players worth suggesting: accounts with progress that are not yet friends. */
export function suggestFriends(userId: number, limit = 10): FriendView[] {
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
    limit,
  );
}