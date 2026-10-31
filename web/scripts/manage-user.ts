/**
 * Operator CLI for accounts.
 *
 *   bun run scripts/manage-user.ts create-admin     # reads ADMIN_USER / ADMIN_PASS
 *   bun run scripts/manage-user.ts list-admins
 *   bun run scripts/manage-user.ts promote <username>
 *   bun run scripts/manage-user.ts demote  <username>
 *   bun run scripts/manage-user.ts delete   <username>
 *
 * The password is read from the environment so it never lands in a shell
 * history entry, a log line, or this file.
 *
 * This ran against the old synchronous database API and had been broken ever
 * since the queries became promises: `db().query is not a function`, and
 * `findByUsername()` returned a promise, so "does this user exist" was always
 * false and the script reported that every username was already taken. Since
 * this is the documented way to create the first admin, the server had no
 * working way in at all.
 */
import { config } from '#lib/server/config';
import { all, one, run } from '#lib/server/db/client';
import {
  createUser,
  findByUsername,
  isAdmin,
  setRole,
  UsernameTaken
} from '#lib/server/models/accounts';

const [command, argument] = process.argv.slice(2);

function requireAdminUsername(): string {
  const username = process.env["ADMIN_USER"]?.trim();
  if (!username) {
    console.error("Set ADMIN_USER (and ADMIN_PASS) in the environment.");
    process.exit(2);
  }
  return username;
}

async function createAdmin(): Promise<void> {
  const username = requireAdminUsername();
  const password = process.env["ADMIN_PASS"];

  if (!password) {
    console.error("Set ADMIN_PASS in the environment. It is never echoed.");
    process.exit(2);
  }

  const existing = await findByUsername(username);
  if (existing) {
    // Never print a role a stranger could not already infer, and never touch a
    // password from here: that is a deliberate decision, not a CLI flag.
    console.log(`User "${username}" already exists (role: ${existing.role}).`);
    if (existing.role !== "admin") {
      await setRole(existing.id, "admin");
      console.log(`Promoted "${username}" to admin.`);
    }
    return;
  }

  try {
    const user = await createUser(username, password, "admin");
    console.log(`Created admin "${user.username}" (id ${user.id}, zid ${user.zid}).`);
  } catch (error) {
    if (error instanceof UsernameTaken) {
      console.error(`Username "${username}" is taken.`);
      process.exit(1);
    }
    throw error;
  }
}

async function listAdmins(): Promise<void> {
  const rows = await all<{ id: number; username: string; zid: number; created_at: string }>(
    "SELECT id, username, zid, created_at FROM users WHERE role = 'admin' ORDER BY id",
  );

  if (rows.length === 0) {
    console.log("No admins yet. Run: bun run scripts/manage-user.ts create-admin");
    return;
  }
  for (const row of rows) {
    console.log(`  #${row.id}  ${row.username}  zid=${row.zid}  since ${row.created_at.slice(0, 10)}`);
  }
}

async function changeRole(role: "admin" | "player"): Promise<void> {
  if (!argument) {
    console.error(`Usage: bun run scripts/manage-user.ts promote|demote <username>`);
    process.exit(2);
  }
  const target = await findByUsername(argument);
  if (!target) {
    console.error(`No such user: ${argument}`);
    process.exit(1);
  }
  if ((await isAdmin(target)) === (role === "admin")) {
    console.log(`"${target.username}" is already a ${role}.`);
    return;
  }
  await setRole(target.id, role);
  console.log(`"${target.username}" is now a ${role}.`);
}

async function deleteUser(): Promise<void> {
  if (!argument) {
    console.error("Usage: bun run scripts/manage-user.ts delete <username>");
    process.exit(2);
  }
  const target = await findByUsername(argument);
  if (!target) {
    console.log(`No such user: ${argument}`);
    return;
  }
  if (await isAdmin(target)) {
    const admins = await one<{ n: number }>("SELECT COUNT(*) AS n FROM users WHERE role = 'admin'");
    if ((admins?.n ?? 0) <= 1) {
      console.error('Refusing to delete the last admin. Demote or create another first.');
      process.exit(1);
    }
  }

  // friends, progress and activity all cascade from users.
  await run("DELETE FROM users WHERE id = ?", target.id);
  console.log(`Deleted "${target.username}" (id ${target.id}).`);
}

switch (command) {
  case "create-admin":
    await createAdmin();
    break;
  case "list-admins":
    await listAdmins();
    break;
  case "promote":
    await changeRole("admin");
    break;
  case "demote":
    await changeRole("player");
    break;
  case "delete":
    await deleteUser();
    break;
  default:
    console.error(
      "Usage: bun run scripts/manage-user.ts <create-admin|list-admins|promote|demote|delete> [username]",
    );
    process.exit(2);
}

console.log(`(database: ${config.database.name})`);
