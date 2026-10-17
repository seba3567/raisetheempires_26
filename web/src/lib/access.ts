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
  "/save-editor",
  "/gazillionaire",
  "/deprogress",
  "/list_session",
  "/language_editor",
];

/** Prefixes, for routes that carry a parameter after them. */
const ADMIN_ONLY_PREFIXES: readonly string[] = [
  "/patch/",
  "/unlock_quest/",
  "/complete_quest/",
  "/remove_quest/",
  "/seed/",
  // This service's own replacement for /save-editor. It is a route here rather
  // than a gateway path, but it changes game state just the same, so it gets
  // the same policy as everything above.
  "/admin/",
];

export type GatewayAccess = "open" | "admin";

/** True when the path may only be reached by an account with the admin role. */
export function accessDenied(pathname: string): boolean {
  if (ADMIN_ONLY_EXACT.includes(pathname)) return true;
  return ADMIN_ONLY_PREFIXES.some((prefix) => pathname.startsWith(prefix));
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