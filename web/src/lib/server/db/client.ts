/**
 * Database access.
 *
 * PostgreSQL 18, through Bun's SQL client.
 */
import { SQL } from 'bun';
import { readFileSync, readdirSync } from 'node:fs';
import { join } from 'node:path';

import { config } from '../config.ts';

export type MigrationMap = Record<string, string>;

/** A parameter, in the order the query binds them. */
export type Params = Array<string | number | boolean | null | Date>;

/**
 * Migration SQL, keyed by filename.
 *
 * Vite inlines these into the bundle, and that is the only way they reach
 * production: after a build, `import.meta.dir` points at the compiled chunk
 * directory, not at the source tree, so reading the files at runtime fails with
 * ENOENT. `bun test` runs outside Vite and takes the filesystem path instead.
 */
function loadMigrations(): MigrationMap {
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

/**
 * The name a migration is recorded under.
 *
 * The glob and the readdir fallback produce different keys -- the first is a
 * path, the second a bare filename -- so the name is the last segment of
 * either, with either separator.
 */
function migrationName(path: string): string {
	return path.split(/[/\\]/).pop() ?? path;
}

/**
 * Apply any migration whose filename has not been recorded yet.
 *
 * The SQL is executed. It used to be only *recorded*: the schema lived in an
 * inline copy of the same DDL, and the files in migrations/ were never run. A
 * migration added to the directory did nothing at all while still being marked
 * as applied, so the directory described the schema instead of building it.
 *
 * Each migration runs in its own transaction together with the row that
 * records it. PostgreSQL's DDL is transactional, so a migration that fails
 * leaves nothing behind and is retried whole on the next start, instead of
 * being half-applied and marked as done.
 *
 * The gateway's own tables -- `saves` and `save_backups` -- are not here. They
 * belong to the save store, which owns them through schema.sql and creates
 * them when the store is built. Nothing on this side reads or writes them.
 */
export async function migrate(sql: SQL): Promise<string[]> {
	await sql.unsafe(
		'CREATE TABLE IF NOT EXISTS schema_migrations (' +
			'name VARCHAR(191) NOT NULL PRIMARY KEY, ' +
			'applied_at TIMESTAMP NOT NULL' +
			')'
	);

	const applied = new Set(
		((await sql.unsafe('SELECT name FROM schema_migrations')) as any[]).map((row) => row.name)
	);
	const migrations = Object.entries(loadMigrations())
		.map(([path, statement]) => [migrationName(path), statement] as const)
		// By codepoint, not by locale. `localeCompare` is ICU collation, which
		// weighs punctuation differently depending on the machine's locale: the
		// same set of migrations could then apply in a different order on a
		// developer's box than on CI, and the order is load-bearing --
		// `004_clans.sql` references `users(id)`.
		.sort((a, b) => (a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0));

	const ran: string[] = [];
	for (const [name, statement] of migrations) {
		if (applied.has(name)) continue;
		await sql.begin(async (tx) => {
			await tx.unsafe(statement);
			await tx.unsafe('INSERT INTO schema_migrations (name, applied_at) VALUES ($1, $2)', [
				name,
				new Date()
			]);
		});
		ran.push(name);
	}
	return ran;
}

async function ensureDatabase(url: string): Promise<void> {
	const withoutDatabase = url.replace(/\/([^/?]+)(\?|$)/, '/postgres$2');
	const bootstrap = new SQL(withoutDatabase);
	try {
		const exists = await bootstrap.unsafe(
			'SELECT 1 FROM pg_database WHERE datname = $1',
			[config.database.name]
		);
		if (!exists || (exists as any[]).length === 0) {
			await bootstrap.unsafe(`CREATE DATABASE "${config.database.name}"`);
		}
	} finally {
		await bootstrap.close();
	}
}

/**
 * The in-flight initialisation, not the connection.
 *
 * `db()` is async and this used to cache the connection, so two callers that
 * arrived before the first finished both saw `undefined` and both ran the
 * migrations -- the second one then failed on a duplicate key in
 * schema_migrations. Caching the promise closes that window: the second caller
 * awaits the first one's work rather than starting its own.
 */
let opening: Promise<SQL> | null = null;

async function openConnection(url: string): Promise<SQL> {
	await ensureDatabase(url);

	const sql = new SQL(url);
	await migrate(sql);
	return sql;
}

/** Open (once) and migrate the configured database. */
export function db(): Promise<SQL> {
	if (!opening) {
		opening = openConnection(config.database.url).catch((error) => {
			opening = null;
			throw error;
		});
	}
	return opening;
}

/** Close the shared handle. Used by tests. */
export async function closeDb(): Promise<void> {
	if (opening) {
		const sql = await opening.catch(() => null);
		await sql?.close();
	}
	opening = null;
}

/* ---------------------------------------------------------------- queries -- */

import { AsyncLocalStorage } from 'node:async_hooks';

const txStorage = new AsyncLocalStorage<any>();

async function current(): Promise<any> {
	return txStorage.getStore() ?? (await db());
}

function formatQuery(query: string): string {
	let paramIdx = 1;
	return query.replace(/'(?:[^'\\]|\\.)*'|\?/g, (match) => {
		if (match === '?') {
			return `$${paramIdx++}`;
		}
		return match;
	});
}

export async function all<T>(sql: string, ...params: Params): Promise<T[]> {
	return (await (await current()).unsafe(formatQuery(sql), params as any)) as T[];
}

export async function one<T>(sql: string, ...params: Params): Promise<T | null> {
	const rows = await (await current()).unsafe(formatQuery(sql), params as any);
	return (rows[0] as T) ?? null;
}

export async function run(sql: string, ...params: Params): Promise<void> {
	await (await current()).unsafe(formatQuery(sql), params as any);
}

/**
 * Run `fn` inside a transaction.
 *
 * Uses AsyncLocalStorage to ensure concurrent transactions in different
 * async execution contexts do not collide or share transaction handles.
 */
export async function transact<T>(fn: () => Promise<T> | T): Promise<T> {
	if (txStorage.getStore()) {
		throw new Error('transact() called inside another transact()');
	}
	const sql = await db();
	return (await sql.begin(async (tx: any) => {
		return await txStorage.run(tx, () => fn());
	})) as T;
}

/**
 * A timestamp formatted for PostgreSQL TIMESTAMP columns.
 */
export function now(): string {
	return new Date().toISOString().replace('T', ' ').slice(0, 19);
}
