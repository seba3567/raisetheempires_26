/**
 * Routes owned by this service.
 *
 * Everything not listed here is proxied to the Python gateway, so the game
 * itself keeps working without this service knowing anything about AMF0.
 */
import {
  addFriend,
  createUser,
  findById,
  findByUsername,
  getProgress,
  listFriends,
  publicUser,
  recordActivity,
  removeFriend,
  suggestFriends,
  touchLastSeen,
  updateProgress,
  verifyPassword,
  UsernameTaken,
} from "./models/accounts.ts";
import { clearSessionCookie, isSecureRequest, readSession, sessionCookie } from "./session.ts";
import { accountPage, homePage, loginPage, registerPage } from "./views.ts";

function html(body: string, status = 200, headers: HeadersInit = {}): Response {
  return new Response(body, {
    status,
    headers: { "content-type": "text/html; charset=utf-8", ...headers },
  });
}

function redirect(location: string, headers: HeadersInit = {}): Response {
  return new Response(null, { status: 303, headers: { location, ...headers } });
}

/** Paths this service accepts only via POST. */
const POST_ONLY = new Set(["/salir", "/amigos/agregar", "/amigos/eliminar"]);

/**
 * Read a form once.
 *
 * A Request body is a single-use stream: calling formData() twice throws
 * "Body already used". Parse it here and pass the result around.
 */
async function formFields(req: Request): Promise<Record<string, string>> {
  const contentType = req.headers.get("content-type") ?? "";
  if (!contentType.includes("application/x-www-form-urlencoded")) return {};

  const form = await req.formData();
  const fields: Record<string, string> = {};
  for (const [name, value] of form) {
    if (typeof value === "string") fields[name] = value.trim();
  }
  return fields;
}

/** True when this path belongs to this service rather than the gateway. */
export function ownsPath(pathname: string): boolean {
  return (
    pathname === "/" ||
    pathname === "/entrar" ||
    pathname === "/registro" ||
    pathname === "/salir" ||
    pathname === "/cuenta" ||
    pathname === "/amigos/agregar" ||
    pathname === "/amigos/eliminar" ||
    pathname === "/api/salud"
  );
}

export async function handle(req: Request): Promise<Response> {
  const url = new URL(req.url);
  const path = url.pathname;
  const method = req.method.toUpperCase();

  if (path === "/api/salud") {
    return Response.json({ status: "ok", service: "raisetheempires-web" });
  }

  if (POST_ONLY.has(path) && method !== "POST") {
    return new Response("method not allowed", { status: 405 });
  }

  if (path === "/salir") {
    return redirect("/", { "set-cookie": clearSessionCookie() });
  }

  if ((path === "/entrar" || path === "/registro") && method === "POST") {
    const isLogin = path === "/entrar";
    const fields = await formFields(req);
    const username = fields["username"] ?? "";
    const password = fields["password"] ?? "";

    if (username === "" || password === "") {
      return html((isLogin ? loginPage : registerPage)("Completa ambos campos."), 400);
    }

    try {
      let userId: number;

      if (isLogin) {
        const user = findByUsername(username);
        if (!user || !(await verifyPassword(user, password))) {
          // Same message either way, so the form does not confirm which
          // usernames exist.
          recordActivity(null, "login.failed", username.slice(0, 24));
          return html(loginPage("Usuario o contraseña incorrectos."), 401);
        }
        userId = user.id;
        recordActivity(userId, "login");
      } else {
        const user = await createUser(username, password);
        userId = user.id;
        recordActivity(userId, "register");
      }

      touchLastSeen(userId);
      return redirect("/home.html", {
        "set-cookie": await sessionCookie(userId, isSecureRequest(req)),
      });
    } catch (error) {
      if (error instanceof UsernameTaken) {
        return html(registerPage(`El usuario "${error.username}" ya está registrado.`), 409);
      }
      if (error instanceof RangeError) {
        return html(registerPage(error.message), 400);
      }
      throw error;
    }
  }

  if (path === "/cuenta") {
    const userId = await readSession(req);
    if (!userId) return redirect("/entrar");

    const user = findById(userId);
    if (!user) return redirect("/entrar", { "set-cookie": clearSessionCookie() });
    touchLastSeen(userId);

    const progress = getProgress(userId);
    return html(
      accountPage(
        {
          username: user.username,
          zid: String(user.zid),
          level: progress?.level ?? 1,
          xp: progress?.xp ?? 0,
          worldName: progress?.world_name ?? user.username,
          friends: listFriends(userId),
          suggestions: suggestFriends(userId),
        },
        null,
      ),
    );
  }

  if ((path === "/amigos/agregar" || path === "/amigos/eliminar") && method === "POST") {
    const userId = await readSession(req);
    if (!userId) return redirect("/entrar");

    const fields = await formFields(req);
    const username = fields["friend"] ?? "";
    const friend = findByUsername(username);
    if (!friend) return redirect("/cuenta");

    if (path === "/amigos/agregar") {
      addFriend(userId, friend.id);
      recordActivity(userId, "friend.add", friend.username);
    } else {
      removeFriend(userId, friend.id);
      recordActivity(userId, "friend.remove", friend.username);
    }
    return redirect("/cuenta");
  }

  // GET-only page routes.
  if (method !== "GET" && method !== "HEAD") {
    return new Response("method not allowed", { status: 405 });
  }

  const userId = await readSession(req);
  const user = userId === null ? null : findById(userId);

  if (path === "/") return html(homePage(user ? { username: user.username } : null));
  if (path === "/entrar") return html(loginPage(null));
  if (path === "/registro") return html(registerPage(null));

  // Unreachable: ownsPath() gates this handler.
  return html("<h1>Not found</h1>", 404);
}

/** Response used when a logged-in visitor hits the landing page. */
export { publicUser, updateProgress };