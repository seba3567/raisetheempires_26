/**
 * Database access.
 *
 * MariaDB, through Bun's own SQL client. Everything above this file talks in
 * plain SQL with ``?`` placeholders and a small set of helpers -- which was the
 * point of the original bun:sqlite version: changing the engine is a driver
 * swap underneath, not a rewrite of the queries. Every query below is unchanged
 * from when this was SQLite.
 *
 * Two things did change underneath:
 *
 * bun:sqlite handed back a query object with ``.all()``/``.get()``/``.run()``
 * on it. Bun's client returns plain arrays of row objects, so ``one`` reads the
 * first row and ``run`` returns nothing rather than a row-count nobody used.
 *
 * And the connection is a network one, so everything is async. Holding a
 * synchronous handle open across a round trip is not something to do.
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

/**
 * Split a migration file into statements.
 *
 * ``--`` comment lines go first: a semicolon inside one would otherwise cut a
 * statement in half and the server would reject the fragment, which points at
 * the schema rather than at the comment.
 */
function splitStatements(script: string): string[] {
	return script
		.split('\n')
		.filter((line) => !line.trimStart().startsWith('--'))
		.join('\n')
		.split(';')
		.map((statement) => statement.trim())
		.filter(Boolean);
}

/** Apply any migration whose filename has not been recorded yet. */
export async function migrate(sql: SQL): Promise<string[]> {
	await sql.unsafe(
		'CREATE TABLE IF NOT EXISTS schema_migrations (' +
			'name VARCHAR(191) NOT NULL PRIMARY KEY, ' +
			'applied_at DATETIME NOT NULL' +
			') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4'
	);

	const applied = new Set(
		((await sql.unsafe('SELECT name FROM schema_migrations')) as any[]).map((row) => row.name)
	);

	const migrations = Object.entries(loadMigrations())
		// Normalise the key to a bare filename. Vite's glob yields
		// "./migrations/001_init.sql" while the filesystem branch yields
		// "001_init.sql", and recording both made the same migration run twice.
		.map(([path, content]) => [path.split('/').pop() ?? path, content] as const)
		.sort(([a], [b]) => a.localeCompare(b));

	const ran: string[] = [];
	for (const [name, content] of migrations) {
		if (applied.has(name)) continue;
		for (const statement of splitStatements(content)) {
			await sql.unsafe(statement);
		}
		await sql.unsafe('INSERT INTO schema_migrations (name, applied_at) VALUES (?, ?)', [
			name,
			new Date()
		]);
		ran.push(name);
	}
	return ran;
}

async function ensureDatabase(url: string): Promise<void> {
	/**
	 * CREATE DATABASE cannot run inside the database it creates, so this opens a
	 * second connection with no database named. Every deploy pointing at a fresh
	 * MariaDB hits this once.
	 */
	const withoutDatabase = url.replace(/\/([^/?]+)(\?|$)/, '/$2');
	const bootstrap = new SQL(withoutDatabase);
	try {
		await bootstrap.unsafe(
			`CREATE DATABASE IF NOT EXISTS \`${config.database.name}\` ` +
				'CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci'
		);
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
			// A failed open must not be cached, or one transient failure would
			// poison every later request for the life of the process.
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

/**
 * The transaction currently in flight, if any.
 *
 * Every helper below routes through here rather than through ``db()`` directly.
 * Without it a caller inside ``transact`` would silently write on the shared
 * connection instead of inside its transaction: those writes would commit
 * immediately, and a failure halfway through would leave half a user created.
 * Bun's ``begin`` hands the transaction to the callback, but the model
 * functions never see it, so it is parked here for the duration.
 */
let activeTx: any = null;

async function current(): Promise<any> {
	return activeTx ?? (await db());
}

export async function all<T>(sql: string, ...params: Params): Promise<T[]> {
	return (await (await current()).unsafe(sql, params as any)) as T[];
}

export async function one<T>(sql: string, ...params: Params): Promise<T | null> {
	// Both awaits matter. The first gets the connection; the second gets the
	// rows out of the promise `unsafe` returns. Without the second, `rows[0]` is
	// `undefined` on a Promise and this silently answers null for every lookup --
	// which is how createUser reported "user insert did not persist" about a row
	// that was sitting there the whole time.
	const rows = await (await current()).unsafe(sql, params as any);
	return (rows[0] as T) ?? null;
}

export async function run(sql: string, ...params: Params): Promise<void> {
	await (await current()).unsafe(sql, params as any);
}

/**
 * Run `fn` inside a transaction.
 *
 * Bun's client opens one with a callback and commits when the callback returns,
 * which is the same shape bun:sqlite's `transaction()` had -- so the call sites
 * read the same, but the body has to be async.
 */
export async function transact<T>(fn: () => Promise<T> | T): Promise<T> {
	if (activeTx) {
		// Bun has no nested transactions. Reusing the outer one silently would
		// be a lie about the scope the caller asked for.
		throw new Error('transact() called inside another transact()');
	}
	const sql = await db();
	return (await sql.begin(async (tx: any) => {
		activeTx = tx;
		try {
			return await fn();
		} finally {
			activeTx = null;
		}
	})) as T;
}

/**
 * A timestamp for a DATETIME column.
 *
 * ISO-8601 with a `T` and a `Z` -- what `toISOString()` gives -- is rejected by
 * MariaDB with error 1292. This is the spelling both engines take.
 */
export function now(): string {
	return new Date().toISOString().replace('T', ' ').slice(0, 19);
}