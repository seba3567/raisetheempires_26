/**
 * Database access.
 *
 * Everything above this file talks in plain SQL with ``?`` placeholders and a
 * small set of helpers. That is deliberate: swapping SQLite for Postgres later
 * is a new driver behind this interface, not a rewrite of the queries.
 */
import { Database, type SQLQueryBindings } from "bun:sqlite";
import { mkdirSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";

import { config } from "../config.ts";

/** Every migration file, applied in filename order exactly once. */
const MIGRATION_DIR = join(import.meta.dir, "migrations");

let instance: Database | null = null;

function ensureParentDir(file: string): void {
  const parent = dirname(file);
  if (parent && parent !== ".") mkdirSync(parent, { recursive: true });
}

/** Apply any migration whose filename has not been recorded yet. */
export function migrate(db: Database): string[] {
  db.exec(
    "CREATE TABLE IF NOT EXISTS schema_migrations (name TEXT PRIMARY KEY, applied_at TEXT NOT NULL)",
  );
  const applied = new Set(
    db.query<{ name: string }, []>("SELECT name FROM schema_migrations").all().map((r) => r.name),
  );

  const files = [...new Bun.Glob("*.sql").scanSync(MIGRATION_DIR)].sort();
  const ran: string[] = [];
  for (const name of files) {
    if (applied.has(name)) continue;
    const sql = readFileSync(join(MIGRATION_DIR, name), "utf8");
    // Each migration is atomic: either the whole file applies or none of it.
    db.transaction(() => {
      db.exec(sql);
      db.query("INSERT INTO schema_migrations (name, applied_at) VALUES (?, ?)").run(
        name,
        new Date().toISOString(),
      );
    })();
    ran.push(name);
  }
  return ran;
}

/** Open (once) and migrate the configured database. */
export function db(): Database {
  if (instance) return instance;

  const file = config.database.file;
  ensureParentDir(file);

  const database = new Database(file, { create: true });
  database.exec("PRAGMA journal_mode = WAL");
  database.exec("PRAGMA foreign_keys = ON");
  database.exec("PRAGMA busy_timeout = 5000");

  migrate(database);
  instance = database;
  return instance;
}

/** Close the shared handle. Used by tests. */
export function closeDb(): void {
  instance?.close();
  instance = null;
}

/* ---------------------------------------------------------------- queries -- */

export function all<T>(sql: string, ...params: SQLQueryBindings[]): T[] {
  return db()
    .query<T, SQLQueryBindings[]>(sql)
    .all(...params);
}

export function one<T>(sql: string, ...params: SQLQueryBindings[]): T | null {
  return (
    db()
      .query<T, SQLQueryBindings[]>(sql)
      .get(...params) ?? null
  );
}

export function run(sql: string, ...params: SQLQueryBindings[]): void {
  db()
    .query(sql)
    .run(...params);
}

/** Run `fn` inside a transaction. */
export function transact<T>(fn: () => T): T {
  return db().transaction(fn)();
}

export function now(): string {
  return new Date().toISOString();
}