/**
 * The public routes: SSR pages, registration, login and sessions.
 */
import { beforeEach, describe, expect, test } from "bun:test";

import { handle, ownsPath } from "../src/router.ts";
import { createUser, findByUsername } from "../src/models/accounts.ts";
import { createSessionValue } from "../src/session.ts";
import { cookieValue, resetDb } from "./helpers.ts";

const ORIGIN = "http://localhost:8080";

beforeEach(() => {
  resetDb();
});

function form(fields: Record<string, string>): RequestInit {
  const body = new URLSearchParams(fields).toString();
  return {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body,
  };
}

describe("ownsPath", () => {
  test("claims this service's routes", () => {
    for (const path of ["/", "/entrar", "/registro", "/salir", "/cuenta", "/amigos/agregar"]) {
      expect(ownsPath(path)).toBe(true);
    }
  });

  test("leaves every gateway path alone", () => {
    // These belong to the Python gateway. If this service ever claimed one, it
    // would shadow the game.
    for (const path of [
      "/home.html",
      "/ruffle.html",
      "/assets/game/main.swf",
      "/flashservices/gateway.php",
      "/record_stats.php",
      "/en_US.xml",
      "/questSettings.xml",
      "/img/avatars/blank.png",
      "/socket.io/",
    ]) {
      expect(ownsPath(path)).toBe(false);
    }
  });
});

describe("SSR pages", () => {
  test("the landing page renders for an anonymous visitor", async () => {
    const res = await handle(new Request(`${ORIGIN}/`));
    const html = await res.text();

    expect(res.status).toBe(200);
    expect(res.headers.get("content-type")).toContain("text/html");
    expect(html).toContain("Raise the Empires");
    expect(html).toContain("Crear cuenta");
  });

  test("the landing page greets a signed-in player", async () => {
    const user = await createUser("ana", "hunter2hunter2");
    const cookie = await createSessionValue(user.id);

    const html = await (
      await handle(new Request(`${ORIGIN}/`, { headers: { cookie: `rte_session=${cookie}` } }))
    ).text();

    expect(html).toContain("ana");
    expect(html).toContain("Salir");
  });

  test("the login and register pages render", async () => {
    expect(await (await handle(new Request(`${ORIGIN}/entrar`))).text()).toContain("Entrar");
    expect(await (await handle(new Request(`${ORIGIN}/registro`))).text()).toContain("Crear cuenta");
  });

  test("escapes HTML so a username cannot inject markup", async () => {
    // Short enough to satisfy the 3-24 character rule, still full of markup.
    const evil = "<img src=x>";
    const user = await createUser(evil, "hunter2hunter2");
    const cookie = await createSessionValue(user.id);

    const html = await (
      await handle(new Request(`${ORIGIN}/`, { headers: { cookie: `rte_session=${cookie}` } }))
    ).text();

    expect(html).not.toContain(evil);
    expect(html).toContain("&lt;img src=x&gt;");
  });
});

describe("registration", () => {
  test("creates an account and redirects into the game", async () => {
    const res = await handle(
      new Request(`${ORIGIN}/registro`, form({ username: "ana", password: "hunter2hunter2" })),
    );

    expect(res.status).toBe(303);
    // The player, never home.html: that one is the 2012 Facebook frame with a
    // dead Flash embed.
    expect(res.headers.get("location")).toBe("/ruffle.html");
    expect(cookieValue(res.headers.get("set-cookie"))).toBeTruthy();
    expect(findByUsername("ana")).not.toBeNull();
  });

  test("no page in this service links to the legacy Facebook frame", async () => {
    // home.html still exists in the gateway and is still reachable, but the
    // site must never send a player there.
    const user = await createUser("ana", "hunter2hunter2");
    const cookie = `rte_session=${await createSessionValue(user.id)}`;

    for (const path of ["/", "/cuenta"]) {
      const html = await (
        await handle(new Request(`${ORIGIN}${path}`, { headers: { cookie } }))
      ).text();
      expect(`${path}: ${html.includes('href="/home.html"')}`).toBe(`${path}: false`);
      expect(`${path}: ${html.includes('href="/ruffle.html"')}`).toBe(`${path}: true`);
    }
  });

  test("omits Secure over plain HTTP so the browser keeps the cookie", async () => {
    // Regression: the cookie was marked Secure whenever the server bound
    // 0.0.0.0, which made every client drop it over HTTP. That looks exactly
    // like "login does not stick".
    const res = await handle(
      new Request(`${ORIGIN}/registro`, form({ username: "ana", password: "hunter2hunter2" })),
    );
    expect(res.headers.get("set-cookie")).not.toContain("Secure");
  });

  test("marks Secure behind an HTTPS proxy", async () => {
    const res = await handle(
      new Request("https://game.example.com/registro", {
        ...form({ username: "beto", password: "hunter2hunter2" }),
        headers: {
          "content-type": "application/x-www-form-urlencoded",
          "x-forwarded-proto": "https",
        },
      }),
    );
    expect(res.headers.get("set-cookie")).toContain("Secure");
  });

  test("reads Secure from the request scheme when there is no proxy header", async () => {
    const res = await handle(
      new Request("https://game.example.com/registro", form({ username: "cami", password: "hunter2hunter2" })),
    );
    expect(res.headers.get("set-cookie")).toContain("Secure");
  });

  test("reports a taken username without creating anything", async () => {
    await createUser("ana", "hunter2hunter2");
    const res = await handle(
      new Request(`${ORIGIN}/registro`, form({ username: "ana", password: "hunter2hunter2" })),
    );

    expect(res.status).toBe(409);
    expect(await res.text()).toContain("ya est");
  });

  test("rejects a short password", async () => {
    const res = await handle(
      new Request(`${ORIGIN}/registro`, form({ username: "ana", password: "corto" })),
    );
    expect(res.status).toBe(400);
    expect(findByUsername("ana")).toBeNull();
  });

  test("rejects empty fields", async () => {
    const res = await handle(new Request(`${ORIGIN}/registro`, form({ username: "", password: "" })));
    expect(res.status).toBe(400);
  });
});

describe("login", () => {
  test("accepts the right password", async () => {
    await createUser("ana", "hunter2hunter2");
    const res = await handle(
      new Request(`${ORIGIN}/entrar`, form({ username: "ana", password: "hunter2hunter2" })),
    );

    expect(res.status).toBe(303);
    expect(res.headers.get("location")).toBe("/ruffle.html");
  });

  test("is case-insensitive on the username", async () => {
    await createUser("ana", "hunter2hunter2");
    const res = await handle(
      new Request(`${ORIGIN}/entrar`, form({ username: "ANA", password: "hunter2hunter2" })),
    );
    expect(res.status).toBe(303);
  });

  test("rejects the wrong password without revealing which field was wrong", async () => {
    await createUser("ana", "hunter2hunter2");

    const wrongPassword = await handle(
      new Request(`${ORIGIN}/entrar`, form({ username: "ana", password: "nope" })),
    );
    const wrongUser = await handle(
      new Request(`${ORIGIN}/entrar`, form({ username: "ghost", password: "hunter2hunter2" })),
    );

    expect(wrongPassword.status).toBe(401);
    expect(wrongUser.status).toBe(401);
    expect(await wrongPassword.text()).toBe(await wrongUser.text());
  });
});

describe("sessions", () => {
  test("a forged cookie is refused", async () => {
    const res = await handle(
      new Request(`${ORIGIN}/cuenta`, { headers: { cookie: "rte_session=9999.deadbeef" } }),
    );
    expect(res.status).toBe(303);
    expect(res.headers.get("location")).toBe("/entrar");
  });

  test("a tampered payload is refused even with a valid-looking shape", async () => {
    const user = await createUser("ana", "hunter2hunter2");
    const good = await createSessionValue(user.id);
    const [payload, mac] = good.split(".") as [string, string];
    // Swap the account id but keep the original signature.
    const forgedPayload = Buffer.from("1.abc").toString("base64url");

    const res = await handle(
      new Request(`${ORIGIN}/cuenta`, {
        headers: { cookie: `rte_session=${forgedPayload}.${mac}` },
      }),
    );
    expect(res.headers.get("location")).toBe("/entrar");
    expect(forgedPayload).not.toBe(payload);
  });

  test("logging out clears the cookie", async () => {
    const res = await handle(new Request(`${ORIGIN}/salir`, { method: "POST" }));
    expect(res.status).toBe(303);
    expect(res.headers.get("set-cookie")).toContain("Max-Age=0");
  });

  test("the account page requires a session", async () => {
    const res = await handle(new Request(`${ORIGIN}/cuenta`));
    expect(res.headers.get("location")).toBe("/entrar");
  });

  test("the account page shows the player's identity and progress", async () => {
    const user = await createUser("ana", "hunter2hunter2");
    const cookie = `rte_session=${await createSessionValue(user.id)}`;

    const html = await (await handle(new Request(`${ORIGIN}/cuenta`, { headers: { cookie } }))).text();

    expect(html).toContain("ana");
    expect(html).toContain(String(user.zid));
  });
});

describe("friendship actions", () => {
  test("adding a friend redirects back to the account page", async () => {
    const ana = await createUser("ana", "hunter2hunter2");
    await createUser("beto", "hunter2hunter2");
    const cookie = `rte_session=${await createSessionValue(ana.id)}`;

    const res = await handle(
      new Request(`${ORIGIN}/amigos/agregar`, {
        ...form({ friend: "beto" }),
        headers: { "content-type": "application/x-www-form-urlencoded", cookie },
      }),
    );

    expect(res.status).toBe(303);
    expect(res.headers.get("location")).toBe("/cuenta");
  });

  test("requires a session", async () => {
    const res = await handle(
      new Request(`${ORIGIN}/amigos/agregar`, form({ friend: "beto" })),
    );
    expect(res.headers.get("location")).toBe("/entrar");
  });
});

describe("health", () => {
  test("answers JSON", async () => {
    const res = await handle(new Request(`${ORIGIN}/api/salud`));
    expect(await res.json()).toEqual({ status: "ok", service: "raisetheempires-web" });
  });
});

describe("method handling", () => {
  test("a GET on a POST-only route is not silently accepted", async () => {
    const res = await handle(new Request(`${ORIGIN}/salir`));
    expect(res.status).toBe(405);
  });
});