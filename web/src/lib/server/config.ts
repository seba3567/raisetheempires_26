/**
 * Runtime configuration.
 *
 * Everything is overridable by environment variable so the same build runs in
 * development (Bun on 8080 -> Flask on 5005) and in production behind a proxy.
 */
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

import { contract, databaseUrl, gatewayOrigin, parents } from './contract.ts';

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
 * in between -- the last one because each directory in the chain is probed both
 * for its own `.env` and for the `web/.env` inside it.
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
		: dotEnvCandidates();

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
 * Every place a `.env` may be, most likely first.
 *
 * The walk up from the working directory finds `web/.env` when the process was
 * started from `web/` or from anywhere inside it. It does **not** find it when
 * the process was started from the repository root: `web/` is a child of the
 * root, so walking up never reaches it, and the service came up with every
 * setting silently falling back to its built-in default -- including an empty
 * `SESSION_SECRET`, which is a 500 on every page.
 *
 * So each directory in the chain is probed twice: for its own `.env` and for
 * the `.env` of the `web/` package inside it.
 */
function dotEnvCandidates(): string[] {
	const chain = [process.cwd(), ...parents(process.cwd())];
	return chain.flatMap((dir) => [join(dir, '.env'), join(dir, 'web', '.env')]);
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
export { parents };

const dotEnv = loadDotEnv();

function fromFile(name: string): string | undefined {
	const value = dotEnv[name];
	return value === undefined || value === "" ? undefined : value;
}

function env(name: string, fallback: string): string {
	return process.env[name] ?? fromFile(name) ?? fallback;
}

/**
 * A setting, read from the environment or from `.env`, honouring the
 * deprecated aliases the contract lists.
 *
 * One deployment configures both halves of this project, so a fact that
 * crosses the seam has to have one name. It used to have two: the gateway
 * called the database `SAVE_STORE_PATH` and the front door called it
 * `RTE_DB_URL`; the front door called the origin `PUBLIC_ORIGIN` and the
 * gateway called it `WEB_ORIGIN`. An operator who set one of each pair left
 * the two halves pointing at different places.
 *
 * The order is: the process environment first, the `.env` second. A shell
 * that sets a variable beats a file that sets it, whichever name each of them
 * uses. The alias is there so that an existing deployment keeps working, not
 * so that it keeps being written down.
 */
function envWithAliases(name: string, fallback: string): string {
	const direct = process.env[name];
	if (direct !== undefined) return direct;
	for (const alias of contract.env.aliases[name] ?? []) {
		const aliased = process.env[alias];
		if (aliased !== undefined) return aliased;
	}

	const fromTheFile = fromFile(name);
	if (fromTheFile !== undefined) return fromTheFile;
	for (const alias of contract.env.aliases[name] ?? []) {
		const aliased = fromFile(alias);
		if (aliased !== undefined) return aliased;
	}

	return fallback;
}

function envInt(name: string, fallback: number): number {
	const raw = process.env[name] ?? fromFile(name);
	if (raw === undefined) return fallback;
	const parsed = Number.parseInt(raw, 10);
	return Number.isFinite(parsed) ? parsed : fallback;
}

/**
 * A size in bytes, written the way a human writes one.
 *
 * `parseInt` is not enough: `Number.parseInt("5MB", 10)` is **5**, not five
 * megabytes. The shipped `.env.example` writes `GATEWAY_MAX_BODY=5MB`, so a
 * clean checkout that follows the documented convention got a five-byte limit
 * and the proxy answered 413 "payload too large" to every AMF0 request -- the
 * whole game dead, with a limit nobody could see.
 *
 * The suffixes match the ones the Bun adapter already understands for
 * `BODY_SIZE_LIMIT`, so both settings are written the same way.
 */
export function parseBytes(raw: string): number | undefined {
	const match = /^\s*(\d+(?:\.\d+)?)\s*(b|k|kb|kib|m|mb|mib|g|gb|gib)?\s*$/i.exec(raw);
	if (!match) return undefined;

	const amount = Number.parseFloat(match[1]);
	if (!Number.isFinite(amount)) return undefined;

	const unit = (match[2] ?? 'b').toLowerCase();
	const factors: Record<string, number> = {
		b: 1,
		k: 1024,
		kb: 1024,
		kib: 1024,
		m: 1024 ** 2,
		mb: 1024 ** 2,
		mib: 1024 ** 2,
		g: 1024 ** 3,
		gb: 1024 ** 3,
		gib: 1024 ** 3
	};
	const factor = factors[unit];
	if (factor === undefined) return undefined;
	return Math.floor(amount * factor);
}

function envBytes(name: string, fallback: number): number {
	const raw = process.env[name] ?? fromFile(name);
	if (raw === undefined) return fallback;
	return parseBytes(raw) ?? fallback;
}

/**
 * The origin the browser uses, and the one every form POST is validated
 * against.
 *
 * It is not cosmetic, and it cannot be left to chance. The Bun adapter
 * rewrites every incoming request onto this origin before SvelteKit sees it
 * (see `normalize_request` in the adapter). SvelteKit then compares the
 * request's `Origin` header with the origin of the rewritten URL, and refuses
 * the request when they differ.
 *
 * So when the origin baked into the build is not the origin the browser
 * actually used, every form submission is rejected with 403 "Cross-site POST
 * form submissions are forbidden" -- the login and the registration included,
 * while every GET keeps working. The symptom reads like a CSRF problem and
 * not like the port being wrong, which is what makes it expensive to
 * diagnose.
 *
 * The port and this origin therefore have to come from the same place, and
 * `PORT` has to be the port of the origin: `vite.config.ts` reads this
 * module, so the build and the runtime cannot disagree.
 */
export function resolvePublicOrigin(publicOrigin: string | undefined, port: number): string {
	return publicOrigin ?? `http://localhost:${port}`;
}

/**
 * The origin to use for a request that is being handled right now.
 *
 * Two things need it and they must be the same value: the `Host` header the
 * proxy sends upstream, which is what Flask builds the SWF's `app_url` out of,
 * and the `app_url` in the FlashVars. If they disagree, the game talks to the
 * gateway directly and skips this service, with no error anywhere to notice.
 *
 * So there is one function, and both callers use it. It used to be written out
 * twice -- once in the request pipeline and once in the page that builds the
 * FlashVars -- each reading `process.env` on its own, which meant the two
 * could answer differently.
 *
 * The configured origin wins when there is one, because a TLS-terminating
 * proxy rewrites the Host the browser sent. Otherwise it is the origin the
 * browser actually used.
 */
export function resolveRequestOrigin(
	requestUrl: URL,
	override: string | undefined = config.publicOriginOverride
): string {
	return (override ?? requestUrl.origin).replace(/\/$/, '');
}

/**
 * The origins allowed to POST a form to this app even though they are not the
 * one baked into the build.
 *
 * The adapter rewrites every request onto the baked origin, so reaching the
 * site under a different name -- `127.0.0.1` instead of `localhost`, say --
 * leaves the `Origin` header pointing somewhere else, and the form is
 * refused. The loopback aliases of a loopback origin are the same machine
 * talking to itself, so they are trusted. Nothing else is: a public
 * deployment has to name its own extra origins explicitly.
 */
export function resolveTrustedOrigins(
	publicOrigin: string,
	extra: string[] = []
): string[] {
	const trusted = new Set(extra);
	let parsed: URL;
	try {
		parsed = new URL(publicOrigin);
	} catch {
		return [...trusted];
	}

	const host = parsed.hostname;
	const isLoopback = host === 'localhost' || host === '127.0.0.1' || host === '[::1]';
	if (isLoopback) {
		for (const alias of ['localhost', '127.0.0.1', '[::1]']) {
			trusted.add(`${parsed.protocol}//${alias}:${parsed.port || '80'}`);
		}
	}

	return [...trusted];
}

/**
 * The listen options the Bun adapter falls back to.
 *
 * The adapter reads `PORT` and `HOST` from the process environment and, when
 * they are not there, binds port 3000 on every interface. That default is
 * what put the server on a different port than the origin the build had
 * baked, and the origin is not something the adapter can be told about later:
 * it is compiled in. These options make the two agree by construction.
 */
export function adapterServerOptions(port: number, host: string) {
	return { port, hostname: host };
}

const port = envInt("PORT", contract.public.port);
const host = env("HOST", contract.public.host);
// The canonical names come from the contract, so this service and the gateway
// read the same variables. `WEB_ORIGIN` and `SAVE_STORE_PATH` still work as
// aliases; see `envWithAliases`.
const publicOriginOverride =
	process.env[contract.env.publicOrigin] ??
	process.env['WEB_ORIGIN'] ??
	fromFile(contract.env.publicOrigin) ??
	fromFile('WEB_ORIGIN');
const publicOrigin = resolvePublicOrigin(publicOriginOverride, port);
const trustedOrigins = resolveTrustedOrigins(
	publicOrigin,
	(process.env["PUBLIC_TRUSTED_ORIGINS"] ?? fromFile("PUBLIC_TRUSTED_ORIGINS") ?? "")
		.split(",")
		.map((value) => value.trim())
		.filter((value) => value.length > 0)
);

export const config = {
  /** Public port for this Bun service. */
  port,
  host,
  /**
   * The origin the browser uses. It is baked into the build, and it has to
   * be the origin the player actually types. See `resolvePublicOrigin`.
   */
  publicOrigin,
  /**
   * The origin an explicit `PUBLIC_ORIGIN` pins the site to, or undefined when
   * the site follows the Host the browser sent. See `resolveRequestOrigin`.
   */
  publicOriginOverride,
  /**
   * Origins allowed to POST a form besides `publicOrigin`. See
   * `resolveTrustedOrigins`.
   */
  trustedOrigins,

  /**
   * The AMF0 gateway. It stays in Python because the SWF's AMF0 payload format
   * is a fixed contract (pyamf reference semantics, dense arrays) and must not
   * be reimplemented. It listens on loopback only; this service is its front
   * door and is the only thing that should ever be exposed.
   */
  gateway: {
    origin: envWithAliases(contract.env.gatewayOrigin, gatewayOrigin()),
    /** Longest AMF0 request we will buffer, matching the Flask MAX_FORM_MEMORY_SIZE. */
    maxBodyBytes: envBytes("GATEWAY_MAX_BODY", 5 * 1024 * 1024),
  },
  fastapi: {
    origin: process.env.FASTAPI_ORIGIN ?? fromFile("FASTAPI_ORIGIN") ?? "http://127.0.0.1:5006",
  },

  /**
   * The account/friends/progress store.
   *
   * PostgreSQL 18, like the gateway's save store: one database for the whole project.
   * The variable is named `RTE_DB_URL` on both sides, so a deployment that sets
   * it points both halves at the same server. Created on first connect if it is
   * not there yet.
   */
  database: {
    url: envWithAliases(contract.env.databaseUrl, databaseUrl()),
    /** Bare name, for the CREATE DATABASE that runs before the connection. */
    name: env("RTE_DB_NAME", contract.database.name),
  },

  /**
   * The headers the two runtimes agree on.
   *
   * The player id travels in `playerZid`: the front door sets it and the
   * gateway reads it. The gateway trusts it only because it is loopback-only
   * and this service is its sole door. See `contract/runtime.json`.
   */
  headers: {
    playerZid: contract.headers.playerZid,
    playerRole: contract.headers.playerRole
  },

  session: {
    cookieName: env("SESSION_COOKIE", "rte_session"),
    /** 10 years, matching the game client cookie so a login survives. */
    maxAgeSeconds: envInt("SESSION_MAX_AGE", 60 * 60 * 24 * 365 * 10),
    secret: env("SESSION_SECRET", ""),
  },
} as const;

export type Config = typeof config;