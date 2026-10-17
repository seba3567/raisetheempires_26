/**
 * Database access.
 *
 * Everything above this file talks in plain SQL with ``?`` placeholders and a
 * small set of helpers. That is deliberate: swapping SQLite for Postgres later
 * is a new driver behind this interface, not a rewrite of the queries.
 */
import { Database, type SQLQueryBindings } from 'bun:sqlite';
import { mkdirSync, readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';

import { config } from '../config.ts';

export type MigrationMap = Record<string, string>;

/**
 * Migration SQL, keyed by filename.
 *
 * Vite inlines these into the bundle, and that is the only way they reach
 * production: after a build, `import.meta.dir` points at the compiled chunk
 * directory, not at the source tree, so reading the files at runtime fails with
 * ENOENT. `bun test` runs outside Vite and takes the filesystem path instead.
 */
function loadMigrations(): MigrationMap {
	// The call has to be a literal: Vite rewrites this expression at build time,
	// and anything wrapping it (optional chaining included) is left alone, which
	// silently falls through to the filesystem branch below and then fails with
	// ENOENT because the compiled chunk has no migrations directory next to it.
	let bundled: MigrationMap | undefined;
	try {
		bundled = import.meta.glob('./migrations/*.sql', {
			query: '?raw',
			import: 'default',
			eager: true
		}) as MigrationMap;
	} catch {
		bundled = undefined;
	}

	// bun test runs outside Vite, where the glob yields nothing.
	if (bundled && Object.keys(bundled).length > 0) {
		return bundled;
	}

	const dir = join(import.meta.dir, 'migrations');
	const map: MigrationMap = {};
	for (const name of readdirSync(dir)) {
		if (name.endsWith('.sql')) map[name] = readFileSync(join(dir, name), 'utf8');
	}
	return map;
}

/** Apply any migration whose filename has not been recorded yet. */
export function migrate(db: Database): string[] {
	db.exec(
		'CREATE TABLE IF NOT EXISTS schema_migrations (name TEXT PRIMARY KEY, applied_at TEXT NOT NULL)'
	);
	const applied = new Set(
		db
			.query<{ name: string }, []>('SELECT name FROM schema_migrations')
			.all()
			.map((r) => r.name)
	);

	const migrations = Object.entries(loadMigrations())
		// Normalise the key to a bare filename. Vite's glob yields
		// "./migrations/001_init.sql" while the filesystem branch yields
		// "001_init.sql", and recording both made the same migration run twice:
		// the second run re-executed 001 and then 002 tried to add a column that
		// already existed.
		.map(([path, sql]) => [path.split('/').pop() ?? path, sql] as const)
		.sort(([a], [b]) => a.localeCompare(b));

	const ran: string[] = [];
	for (const [name, sql] of migrations) {
		if (applied.has(name)) continue;
		// Each migration is atomic: either the whole file applies or none of it.
		db.transaction(() => {
			db.exec(sql);
			db
				.query('INSERT INTO schema_migrations (name, applied_at) VALUES (?, ?)')
				.run(name, new Date().toISOString());
		})();
		ran.push(name);
	}
	return ran;
}

let instance: Database | null = null;

function ensureParentDir(file: string): void {
	const parent = dirname(file);
	if (parent && parent !== '.') mkdirSync(parent, { recursive: true });
}

/** Open (once) and migrate the configured database. */
export function db(): Database {
	if (instance) return instance;

	const file = config.database.file;
	ensureParentDir(file);

	const database = new Database(file, { create: true });
	database.exec('PRAGMA journal_mode = WAL');
	database.exec('PRAGMA foreign_keys = ON');
	database.exec('PRAGMA busy_timeout = 5000');

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