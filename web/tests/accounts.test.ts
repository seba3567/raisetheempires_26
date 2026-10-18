/**
 * Accounts, friendships and progress against a real SQLite file.
 */
import { beforeEach, describe, expect, test } from "bun:test";

import {
  addFriend,
  createUser,
  findById,
  findByUsername,
  findByZid,
  friendshipStatus,
  getProgress,
  isAdmin,
  listFriends,
  normalizeUsername,
  recentActivity,
  recordActivity,
  removeFriend,
  setRole,
  suggestFriends,
  updateProgress,
  UsernameTaken,
  verifyPassword,
  type Role,
} from '#lib/server/models/accounts';
import { zidForUser } from '#lib/ids';
import { resetDb } from "./helpers.ts";

// The returned promise is the whole point: resetDb is async, and a hook that
// ignores it lets the test body run while the TRUNCATE is still in flight. That
// surfaced as "username already registered: ana" against a table the hook was
// busy emptying.
beforeEach(async () => {
  await resetDb();
});

describe("createUser", () => {
  test("stores an argon2id hash, never the password", async () => {
    const user = await createUser("ana", "hunter2hunter2");
    const stored = await findByUsername("ana");

    expect(stored).not.toBeNull();
    expect(stored?.password_hash).not.toContain("hunter2");
    expect(stored?.password_hash.startsWith("$argon2id$")).toBe(true);
    expect(user).not.toHaveProperty("password_hash");
  });

  test("verifies the right password and rejects the wrong one", async () => {
    await createUser("ana", "hunter2hunter2");
    const user = await findByUsername("ana");
    if (!user) throw new Error("setup failed");

    expect(await verifyPassword(user, "hunter2hunter2")).toBe(true);
    expect(await verifyPassword(user, "hunter2hunter3")).toBe(false);
  });

  test("assigns a zid derived from the account id", async () => {
    const user = await createUser("ana", "hunter2hunter2");
    expect(user.zid).toBe(zidForUser(user.id));
  });

  test("gives every account a distinct zid", async () => {
    const zids = new Set<string>();
    for (const name of ["ana", "beto", "cami", "dani"]) {
      const user = await createUser(name, "hunter2hunter2");
      zids.add(user.zid);
    }
    expect(zids.size).toBe(4);
  });

  test("rejects a duplicate username regardless of case", async () => {
    await createUser("ana", "hunter2hunter2");
    await expect(createUser("ANA", "hunter2hunter2")).rejects.toBeInstanceOf(UsernameTaken);
    await expect(createUser("  Ana  ", "hunter2hunter2")).rejects.toBeInstanceOf(UsernameTaken);
  });

  test("enforces length rules", async () => {
    await expect(createUser("ab", "hunter2hunter2")).rejects.toBeInstanceOf(RangeError);
    await expect(createUser("a".repeat(25), "hunter2hunter2")).rejects.toBeInstanceOf(RangeError);
    await expect(createUser("valid", "short")).rejects.toBeInstanceOf(RangeError);
  });

  test("seeds a progress row so a fresh account is immediately playable", async () => {
    const user = await createUser("ana", "hunter2hunter2");
    const progress = await getProgress(user.id);

    expect(progress).not.toBeNull();
    expect(progress?.level).toBe(1);
    expect(progress?.xp).toBe(0);
    expect(progress?.world_name.length).toBeGreaterThan(0);
  });

  test("finds a user by the zid the gateway will be given", async () => {
    const user = await createUser("ana", "hunter2hunter2");
    expect((await findByZid(user.zid))?.username).toBe("ana");
  });

  test("normalizeUsername folds case and surrounding space", () => {
    expect(normalizeUsername("  Ana  ")).toBe("ana");
  });
});

describe("progress", () => {
  test("patches only the fields given", async () => {
    const user = await createUser("ana", "hunter2hunter2");
    const before = await getProgress(user.id);
    if (!before) throw new Error("createUser must seed a progress row");

    const after = await updateProgress(user.id, { level: 12 });

    expect(after.level).toBe(12);
    expect(after.xp).toBe(before.xp);
    expect(after.world_name).toBe(before.world_name);
  });

  test("throws for a user with no progress row", async () => {
    // updateProgress is async, so the rejection arrives as a promise: a
    // synchronous toThrow() would watch a call that never fails on its own.
    await expect(updateProgress(9999, { level: 2 })).rejects.toThrow();
  });
});

describe("friendships", () => {
  async function twoUsers() {
    const ana = await createUser("ana", "hunter2hunter2");
    const beto = await createUser("beto", "hunter2hunter2");
    return { ana, beto };
  }

  test("starts as none", async () => {
    const { ana, beto } = await twoUsers();
    expect(await friendshipStatus(ana.id, beto.id)).toEqual({ status: "none", outgoing: false });
  });

  test("a request is pending and one-directional in status", async () => {
    const { ana, beto } = await twoUsers();
    // Value matchers compare the resolved value, so the await belongs *inside*
    // expect(). `await expect(promise).toBe(x)` asserts on the promise itself.
    expect(await addFriend(ana.id, beto.id)).toBe("pending");

    expect(await friendshipStatus(ana.id, beto.id)).toEqual({ status: "pending", outgoing: true });
    expect(await friendshipStatus(beto.id, ana.id)).toEqual({ status: "pending", outgoing: false });
  });

  test("the reverse request accepts rather than duplicating", async () => {
    const { ana, beto } = await twoUsers();
    await addFriend(ana.id, beto.id);
    expect(await addFriend(beto.id, ana.id)).toBe("accepted");

    expect((await friendshipStatus(ana.id, beto.id)).status).toBe("accepted");
    expect((await friendshipStatus(beto.id, ana.id)).status).toBe("accepted");
  });

  test("accepting is idempotent", async () => {
    const { ana, beto } = await twoUsers();
    await addFriend(ana.id, beto.id);
    await addFriend(beto.id, ana.id);
    expect(await addFriend(ana.id, beto.id)).toBe("accepted");
  });

  test("only accepted friends show up in the list", async () => {
    const { ana, beto } = await twoUsers();
    await addFriend(ana.id, beto.id);
    expect(await listFriends(ana.id)).toHaveLength(0);

    await addFriend(beto.id, ana.id);
    expect((await listFriends(ana.id)).map((f) => f.username)).toEqual(["beto"]);
    expect((await listFriends(beto.id)).map((f) => f.username)).toEqual(["ana"]);
  });

  test("removing clears both directions", async () => {
    const { ana, beto } = await twoUsers();
    await addFriend(ana.id, beto.id);
    await addFriend(beto.id, ana.id);
    await removeFriend(ana.id, beto.id);

    expect((await friendshipStatus(ana.id, beto.id)).status).toBe("none");
    expect(await listFriends(ana.id)).toHaveLength(0);
    expect(await listFriends(beto.id)).toHaveLength(0);
  });

  test("cannot befriend yourself", async () => {
    const { ana } = await twoUsers();
    await expect(addFriend(ana.id, ana.id)).rejects.toThrow();
  });

  test("rejects an unknown target", async () => {
    const { ana } = await twoUsers();
    await expect(addFriend(ana.id, 9999)).rejects.toThrow();
  });

  test("suggestions exclude yourself and existing friends", async () => {
    const { ana, beto } = await twoUsers();
    await createUser("cami", "hunter2hunter2");

    expect((await suggestFriends(ana.id)).map((s) => s.username)).toEqual(["beto", "cami"]);

    await addFriend(ana.id, beto.id);
    await addFriend(beto.id, ana.id);
    expect((await suggestFriends(ana.id)).map((s) => s.username)).toEqual(["cami"]);
  });
});

describe("roles", () => {
  test("new accounts are players by default", async () => {
    const user = await createUser("ana", "hunter2hunter2");
    expect(user.role).toBe("player");
    expect(isAdmin(await findByUsername("ana"))).toBe(false);
  });

  test("an account can be created as admin directly", async () => {
    const user = await createUser("root", "hunter2hunter2", "admin");
    expect(user.role).toBe("admin");
    expect(isAdmin(await findByUsername("root"))).toBe(true);
  });

  test("setRole promotes and demotes", async () => {
    // A second admin has to exist, otherwise ana is the last one and the
    // guard below correctly refuses to demote her.
    await createUser("root", "hunter2hunter2", "admin");
    const user = await createUser("ana", "hunter2hunter2");

    await setRole(user.id, "admin");
    expect(isAdmin(await findById(user.id))).toBe(true);

    await setRole(user.id, "player");
    expect(isAdmin(await findById(user.id))).toBe(false);
  });

  test("the last admin cannot be demoted", async () => {
    // Otherwise one call locks every moderator out of their own server.
    const only = await createUser("root", "hunter2hunter2", "admin");
    await expect(setRole(only.id, "player")).rejects.toThrow("last admin");

    const second = await createUser("other", "hunter2hunter2", "admin");
    await expect(setRole(second.id, "player")).resolves.toBeUndefined();
    await expect(setRole(only.id, "player")).rejects.toThrow("last admin");
  });

  test("rejects an unknown role", async () => {
    const user = await createUser("ana", "hunter2hunter2");
    await expect(setRole(user.id, "root" as Role)).rejects.toThrow("unknown role");
  });
});

describe("activity", () => {
  test("records and reads back newest first", async () => {
    const user = await createUser("ana", "hunter2hunter2");
    await recordActivity(user.id, "login");
    await recordActivity(user.id, "friend.add", "beto");

    const rows = await recentActivity(user.id);
    expect(rows).toHaveLength(2);
    expect(rows[0]?.kind).toBe("friend.add");
    expect(rows[0]?.detail).toBe("beto");
  });

  test("records anonymous activity with no user", async () => {
    await recordActivity(null, "login.failed", "ghost");
    // Anonymous rows must not leak into any player's feed.
    expect(await recentActivity(12345)).toHaveLength(0);
  });
});