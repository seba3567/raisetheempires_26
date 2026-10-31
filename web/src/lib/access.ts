/**
 * Which gateway paths are open, and which need an admin.
 *
 * The gateway predates accounts: its debugging routes (`/gazillionaire`,
 * `/patch/...`, `/save-editor`) are reachable by anyone who has a game session,
 * and `/list_session` will hand over every player's session id. Now that this
 * service owns real accounts, the role check belongs here rather than in the
 * gateway, because this is the only layer that knows who is signed in.
 *
 * The rule applied is deliberately narrow: restrict what changes game state or
 * exposes another player's data, and leave everything else alone. A broad
 * denylist over gateway routes would quietly break the client the first time it
 * asks for a path nobody remembered to allow.
 */

/** Exact paths that mutate the game or leak other players' data. */
const ADMIN_ONLY_EXACT: readonly string[] = [
  // Deletes any save row. Must be strictly admin-only.
  "/save",
  "/save-editor",
  "/gazillionaire",
  "/deprogress",
  "/list_session",
  "/language_editor",
  // Destroys the save outright. It was reachable by anyone holding a game
  // session, which used to be the same thing as being a player.
  "/wipe_session",
  // The raw-paste endpoint behind the editor. It replaces this session's
  // user_object, battle and fleets wholesale, so an ungated player could POST
  // a hand-built save and grant themselves any empire. It only ever touches
  // the caller's own session, which is exactly why that was not obvious.
  "/editor/save",
  "/editor/restore",
  // The 2013 standalone launcher URLs. /juego is the player; these only
  // redirect to it, and the template behind them is deleted. Listed anyway so a
  // redirect can never become a rendered page again without this being revisited.
  "/ruffle.html",
  "/nodebug.html",
  // The 2013 avatar picker. /registro does not offer a choice yet, so this
  // stays rather than losing the capability; it is owner-only until the
  // account form grows an avatar step.
  "/new.html",
];

/** Prefixes, for routes that carry a parameter after them. */
const ADMIN_ONLY_PREFIXES: readonly string[] = [
  // Internal server-to-server endpoints (must not be callable externally through the proxy)
  "/api/",
  "/patch/",
  "/unlock_quest/",
  "/complete_quest/",
  "/remove_quest/",
  "/seed/",
  // Writes the caller's profilePic, so it belongs with the rest of the 2013
  // owner tools.
  "/chooseavatar/",
  // This service's own replacement for /save-editor. It is a route here rather
  // than a gateway path, but it changes game state just the same, so it gets
  // the same policy as everything above.
  "/admin/",
];

export type GatewayAccess = "open" | "admin";

/**
 * Decode a path until it stops changing, so an encoded route cannot walk past
 * the gate.
 *
 * `event.url.pathname` is the **raw** path: it still has `%61` where the
 * player typed `a`. Werkzeug, which routes the request on the other side,
 * **decodes** it before matching a rule. So `/gazillionaire` was refused and
 * `/%67azillionaire` was not, and the second one reached the route that adds
 * ten thousand coins to the caller's empire. The same trick read every
 * player's session id out of `/list%5Fsession`, and replaced a save outright
 * through `/editor%2Fsave`.
 *
 * The gate compares what the route matcher will see, so it has to decode too.
 * Decoding stops when it reaches a fixed point, with a bound on the passes:
 * `%252F` is `%25` encoded twice, and a bounded number of rounds still lands
 * on the same string the matcher sees.
 *
 * A path that will not decode is refused. A rule that cannot be read cannot
 * be classified, and the safe reading of "cannot tell" is "no".
 */
export function safeDecodePath(pathname: string): string | null {
	let current = pathname;
	for (let pass = 0; pass < 3; pass += 1) {
		let next: string;
		try {
			next = decodeURIComponent(current);
		} catch {
			return null;
		}
		if (next === current) break;
		current = next;
	}
	return current;
}

/** True when the path may only be reached by an account with the admin role. */
export function accessDenied(pathname: string): boolean {
	// Undecodable is admin-only: the gate cannot tell what it is, so it says
	// no.
	const decoded = safeDecodePath(pathname);
	if (decoded === null) return true;
	if (ADMIN_ONLY_EXACT.includes(decoded)) return true;
	return ADMIN_ONLY_PREFIXES.some((prefix) => decoded.startsWith(prefix));
}

/** The admin-only paths, for the operator CLI and for the admin UI. */
export function adminOnlyPaths(): string[] {
  return [...ADMIN_ONLY_EXACT, ...ADMIN_ONLY_PREFIXES.map((p) => `${p}…`)];
}

/**
 * What to do with a request to an admin-only path.
 *
 * Kept separate from the hook so the policy is testable without standing up
 * SvelteKit, and so hooks.server.ts stays a straight line of reading.
 */
export type AdminDecision = "allow" | "redirect-login" | "forbid";

export function adminDecision(
  pathname: string,
  user: { role: string } | null,
): AdminDecision {
  if (!accessDenied(pathname)) return "allow";
  // Anonymous is sent to log in rather than shown a wall: the route is behind
  // a login, not behind a ban.
  if (!user) return "redirect-login";
  return user.role === "admin" ? "allow" : "forbid";
}