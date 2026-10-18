/**
 * Runtime configuration.
 *
 * Everything is overridable by environment variable so the same build runs in
 * development (Bun on 8080 -> Flask on 5005) and in production behind a proxy.
 */
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';

/**
 * `.env`, loaded once, for anything the process itself did not provide.
 *
 * The project's own `.gitignore` lists `/web/.env`, so a `.env` file is the
 * documented way to configure this service -- but Vite does not put `.env` into
 * `process.env`. It goes into `import.meta.env`, under VITE_-prefixed names only,
 * which is a different thing entirely and would mean renaming every setting.
 * `bun run dev` starting the server did not bridge it either.
 *
 * The result was a clean checkout following the documented convention and getting
 * `SESSION_SECRET is not set` on every page: a 500 with no hint that the file it
 * had just been given was the problem.
 *
 * Process wins over file, so exporting a variable still overrides the file, and
 * this only fills gaps. Production sets real environment variables and is
 * unaffected.
 *
 * The file is found by walking up from the working directory, not from this
 * module. Two things ruled out the tidier options: `import.meta.dir` is a Bun
 * extension that Vite's SSR transform does not preserve, and assuming the working
 * directory is the package root is an assumption about whoever launched the
 * server rather than about the project. Walking up finds web/.env whether the
 * process was started from web/, from the repository root, or from anywhere else
 * in between.
 *
 * The one trap: a failure here looks exactly like "there is no .env", so it has
 * to stay silent about which candidate it tried. `bun run dev` on this package
 * did find the file and still answered 500, and the only way to tell that apart
 * from a missing file is to try the next candidate instead of giving up.
 */
function loadDotEnv(): Record<string, string> {
	// An explicit path wins outright, so a deployment can point somewhere else.
	const explicit = process.env.RTE_ENV_FILE;
	const candidates = explicit
		? [explicit]
		: [process.cwd(), ...parents(process.cwd())].map((dir) => join(dir, '.env'));

	for (const candidate of candidates) {
		let raw: string;
		try {
			raw = readFileSync(candidate, 'utf8');
		} catch {
			continue;
		}

		return parseDotEnv(raw);
	}

	// No .env anywhere up the tree is the normal case in production.
	return {};
}

/**
 * Parse the text of a `.env` into key/value pairs.
 *
 * Split out from the file lookup so it can be tested on its own, because the
 * line-ending detail below is exactly the kind of thing that a later edit undoes
 * without anyone noticing.
 */
export function parseDotEnv(raw: string): Record<string, string> {
	const values: Record<string, string> = {};
	// CRLF matters more than it looks. In JavaScript `.` matches everything
	// except a line terminator, and `\r` is one -- so a file written with Windows
	// line endings made `(.*)$` unable to reach the end of the line, every single
	// entry failed to match, and the file parsed as if it were empty. Not an
	// exotic file either: PowerShell writes CRLF by default.
	// The trailing `\r` has to be gone before the pattern sees the line.
	for (const line of raw.split(/\r?\n/)) {
		const match = /^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$/.exec(line);
		// Blank lines, `#` comments, and anything that is not a KEY=VALUE pair.
		if (!match) continue;
		// One layer of quoting, and nothing else: `.env` is not shell, so there
		// is no expansion to do and a `#` inside a value is just a `#`.
		let value = match[2].trim();
		if (
			(value.startsWith('"') && value.endsWith('"') && value.length > 1) ||
			(value.startsWith("'") && value.endsWith("'") && value.length > 1)
		) {
			value = value.slice(1, -1);
		}
		values[match[1]] = value;
	}
	return values;
}

/** This directory and every parent of it, nearest first, up to the drive root. */
function parents(start: string): string[] {
	const chain: string[] = [];
	let current = start;
	for (let depth = 0; depth < 6; depth += 1) {
		const parent = dirname(current);
		if (parent === current) break;
		chain.push(parent);
		current = parent;
	}
	return chain;
}

const dotEnv = loadDotEnv();

function fromFile(name: string): string | undefined {
	const value = dotEnv[name];
	return value === undefined || value === "" ? undefined : value;
}

function env(name: string, fallback: string): string {
	return process.env[name] ?? fromFile(name) ?? fallback;
}

function envInt(name: string, fallback: number): number {
	const raw = process.env[name] ?? fromFile(name);
	if (raw === undefined) return fallback;
	const parsed = Number.parseInt(raw, 10);
	return Number.isFinite(parsed) ? parsed : fallback;
}

export const config = {
  /** Public port for this Bun service. */
  port: envInt("PORT", 8080),
  host: env("HOST", "0.0.0.0"),

  /**
   * The AMF0 gateway. It stays in Python because the SWF's AMF0 payload format
   * is a fixed contract (pyamf reference semantics, dense arrays) and must not
   * be reimplemented. It listens on loopback only; this service is its front
   * door and is the only thing that should ever be exposed.
   */
  gateway: {
    origin: env("GATEWAY_ORIGIN", "http://127.0.0.1:5005"),
    /** Longest AMF0 request we will buffer, matching the Flask MAX_FORM_MEMORY_SIZE. */
    maxBodyBytes: envInt("GATEWAY_MAX_BODY", 5 * 1024 * 1024),
  },

  /**
   * The account/friends/progress store.
   *
   * MariaDB, like the gateway's save store: one database for the whole project.
   * `url` is the same shape as the Python side's SAVE_STORE_PATH so there is one
   * format to learn. Created on first connect if it is not there yet.
   */
  database: {
    url: env("RTE_DB_URL", "mysql://root:2001@127.0.0.1:3306/raisetheempires"),
    /** Bare name, for the CREATE DATABASE that runs before the connection. */
    name: env("RTE_DB_NAME", "raisetheempires"),
  },

  session: {
    cookieName: env("SESSION_COOKIE", "rte_session"),
    /** 10 years, matching the game client cookie so a login survives. */
    maxAgeSeconds: envInt("SESSION_MAX_AGE", 60 * 60 * 24 * 365 * 10),
    secret: env("SESSION_SECRET", ""),
  },
} as const;

export type Config = typeof config;