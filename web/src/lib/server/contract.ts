/**
 * The runtime contract: the facts the gateway and this service have to agree on.
 *
 * Why this exists
 * ---------------
 * The project runs two programs in two languages: the Python AMF0 gateway (the
 * repo root) and this SvelteKit front door. They meet over HTTP, over one
 * PostgreSQL database, and over the identity of the player. Every value that
 * crossed one of those seams used to be written down twice -- once per
 * language -- with nothing checking that the two copies still matched.
 *
 * That is not a style problem. The front door bound port 3000 while the origin
 * compiled into its build said 8080, so every page loaded and every form was
 * refused with 403 "Cross-site POST form submissions are forbidden", the login
 * included, and neither language had anything to say about the disagreement.
 *
 * So the values live in one place now: `contract/runtime.json`, at the root of
 * the repository. The Python side reads it through `contract.py`; this module
 * is the TypeScript view of the same file. Both test suites read it and assert
 * that what each runtime resolved matches what is written there, so a value
 * that drifts fails the build instead of the game.
 *
 * Environment variables still win over the file. The file is where the
 * defaults live, not where a deployment is configured.
 */
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';

/** The shape of `contract/runtime.json`. */
export type RuntimeContract = {
	database: { host: string; port: number; user: string; password: string; name: string };
	gateway: { host: string; port: number };
	public: { host: string; port: number };
	headers: { playerZid: string; playerRole: string };
	adminPaths: { exact: string[]; prefixes: string[] };
	snapi: { userKeys: string[]; payloadKeys: string[] };
	playerState: { keys: string[] };
	resources: { order: string[] };
	zid: { divisor: number; maxSafe: number };
	env: {
		databaseUrl: string;
		publicOrigin: string;
		gatewayOrigin: string;
		aliases: Record<string, string[]>;
	};
};

/**
 * Parse the contract and reject anything that is not the shape both runtimes
 * expect.
 *
 * Split out from the file lookup so it can be tested on its own. A contract
 * missing a key has to fail here, loudly, and not halfway through a request
 * with an undefined value where a port used to be.
 */
export function parseContract(raw: string): RuntimeContract {
	const data = JSON.parse(raw) as Partial<RuntimeContract>;

	const database = data.database;
	const gateway = data.gateway;
	const publicSection = data.public;
	const headers = data.headers;
	const zid = data.zid;
	const adminPaths = data.adminPaths ?? { exact: [], prefixes: [] };
	const env = data.env;
	const snapi = data.snapi;
	const playerState = data.playerState;
	const resources = data.resources;

	if (
		!database ||
		!gateway ||
		!publicSection ||
		!headers ||
		!zid ||
		!env ||
		!snapi ||
		!playerState ||
		!resources
	) {
		throw new TypeError(
			'The runtime contract is missing one of: database, gateway, public, headers, ' +
				'zid, env, snapi, playerState, resources.'
		);
	}

	for (const [name, value] of [
		['database.host', database.host],
		['database.port', database.port],
		['database.user', database.user],
		['database.password', database.password],
		['database.name', database.name],
		['gateway.host', gateway.host],
		['gateway.port', gateway.port],
		['public.host', publicSection.host],
		['public.port', publicSection.port],
		['headers.playerZid', headers.playerZid],
		['headers.playerRole', headers.playerRole],
		['zid.divisor', zid.divisor],
		['zid.maxSafe', zid.maxSafe],
		['env.databaseUrl', env.databaseUrl],
		['env.publicOrigin', env.publicOrigin],
		['env.gatewayOrigin', env.gatewayOrigin]
	] as const) {
		if (value === undefined || value === null || value === '') {
			throw new TypeError(`The runtime contract has no ${name}.`);
		}
	}

	const aliases = env.aliases ?? {};
	const aliasMap: Record<string, string[]> = {};
	for (const [name, list] of Object.entries(aliases)) {
		if (Array.isArray(list)) aliasMap[name] = list.map((alias) => String(alias));
	}

	return {
		database: {
			host: String(database.host),
			port: Number(database.port),
			user: String(database.user),
			password: String(database.password),
			name: String(database.name)
		},
		gateway: {
			host: String(gateway.host),
			port: Number(gateway.port)
		},
		public: {
			host: String(publicSection.host),
			port: Number(publicSection.port)
		},
		headers: { playerZid: String(headers.playerZid), playerRole: String(headers.playerRole) },
		adminPaths: {
			exact: (adminPaths.exact ?? []).map(String),
			prefixes: (adminPaths.prefixes ?? []).map(String)
		},
		snapi: {
			userKeys: (snapi.userKeys ?? []).map(String),
			payloadKeys: (snapi.payloadKeys ?? []).map(String)
		},
		playerState: { keys: (playerState.keys ?? []).map(String) },
		resources: { order: (resources.order ?? []).map(String) },
		zid: { divisor: Number(zid.divisor), maxSafe: Number(zid.maxSafe) },
		env: {
			databaseUrl: String(env.databaseUrl),
			publicOrigin: String(env.publicOrigin),
			gatewayOrigin: String(env.gatewayOrigin),
			aliases: aliasMap
		}
	};
}

/** This directory and every parent of it, nearest first, up to the drive root. */
export function parents(start: string): string[] {
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

/**
 * Where the contract may be, most likely first.
 *
 * The file lives at the root of the repository, and this package is a
 * subdirectory of it, so the search walks up from the working directory the
 * same way the `.env` lookup does. An explicit path wins outright, so a
 * deployment can point somewhere else.
 */
function contractCandidates(): string[] {
	const explicit = process.env['RTE_CONTRACT_FILE'];
	if (explicit) return [explicit];
	return [process.cwd(), ...parents(process.cwd())].map((dir) =>
		join(dir, 'contract', 'runtime.json')
	);
}

/**
 * The contract, read once.
 *
 * Required, not optional. A missing contract means this service and the
 * gateway would silently disagree about where the database is or what the
 * player's id header is called, and that failure surfaces as a broken game
 * rather than as an error -- exactly the class of failure this file exists to
 * remove.
 */
export function loadContract(): RuntimeContract {
	const tried: string[] = [];
	for (const candidate of contractCandidates()) {
		tried.push(candidate);
		let raw: string;
		try {
			raw = readFileSync(candidate, 'utf8');
		} catch {
			continue;
		}
		return parseContract(raw);
	}

	throw new Error(
		'The runtime contract is missing. It is the single place this service and the ' +
			'gateway agree on the database, the gateway address and the player\'s id ' +
			'header, so neither can be configured without it.\nLooked in:\n  ' +
			tried.join('\n  ') +
			'\nSet RTE_CONTRACT_FILE to point at it.'
	);
}

/** The contract as written, for the tests that pin both runtimes to it. */
export const contract: RuntimeContract = loadContract();

/** The database URL, in the dialect this service's driver speaks. */
export function databaseUrl(contractValue: RuntimeContract = contract): string {
	const { host, port, user, password, name } = contractValue.database;
	return `postgres://${user}:${password}@${host}:${port}/${name}`;
}

/** Where the AMF0 gateway listens. */
export function gatewayOrigin(contractValue: RuntimeContract = contract): string {
	return `http://${contractValue.gateway.host}:${contractValue.gateway.port}`;
}

/**
 * The value of an environment variable, honouring its deprecated aliases.
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
export function envValue(
	name: string,
	environ: Record<string, string | undefined> = process.env
): string | undefined {
	const value = environ[name];
	if (value !== undefined) return value;
	for (const alias of contract.env.aliases[name] ?? []) {
		const aliased = environ[alias];
		if (aliased !== undefined) return aliased;
	}
	return undefined;
}
