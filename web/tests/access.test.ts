/**
 * The admin gate on the gateway's cheat and editing routes.
 *
 * These routes existed before accounts: with nothing but a Flask game session,
 * anyone could hand themselves 10,000 Empire Points or open another player's
 * save. Now that this service owns accounts, the gate is asserted here.
 */
import { beforeEach, describe, expect, test } from "bun:test";

import { accessDenied, adminOnlyPaths } from "../src/access.ts";
import { run } from "../src/db/client.ts";
import { checkAdminAccess, ownsPath } from "../src/router.ts";
import { createUser } from "../src/models/accounts.ts";
import { createSessionValue } from "../src/session.ts";
import { resetDb } from "./helpers.ts";

const ORIGIN = "http://localhost:8080";

beforeEach(() => {
  resetDb();
});

async function as(username: string, role: "player" | "admin" = "player") {
  const user = await createUser(username, "hunter2hunter2", role);
  return { user, cookie: `rte_session=${await createSessionValue(user.id)}` };
}

describe("accessDenied classification", () => {
  test("gates every route that mutates game state", () => {
    for (const path of [
      "/save-editor",
      "/gazillionaire",
      "/deprogress",
      "/list_session",
      "/language_editor",
      "/unlock_quest/quest_0100",
      "/complete_quest/quest_0100",
      "/remove_quest/quest_0100",
      "/patch/player/name/string/bob",
      "/seed/w/3/z/2",
    ]) {
      expect(`${path}: ${accessDenied(path)}`).toBe(`${path}: true`);
    }
  });

  test("leaves the whole game reachable", () => {
    // A client that asks for a path nobody remembered to allow must still work.
    for (const path of [
      "/",
      "/home.html",
      "/ruffle.html",
      "/flashservices/gateway.php",
      "/record_stats.php",
      "/en_US.xml",
      "/questSettings.xml",
      "/gameSettings.xml",
      "/changelog.txt",
      "/assets/game/main.swf",
      "/js/empires.js",
      "/css/zbar.css",
      "/img/avatars/blank.png",
      "/socket.io/",
      "/wipe_session",
      "/new.html",
      "/releases.html",
    ]) {
      expect(`${path}: ${accessDenied(path)}`).toBe(`${path}: false`);
    }
  });

  test("does not gate a prefix that merely looks similar", () => {
    expect(accessDenied("/patchery")).toBe(false);
    expect(accessDenied("/unlock_quests")).toBe(false);
    expect(accessDenied("/save-editor-help")).toBe(false);
  });

  test("keeps the gate disjoint from this service's own routes", () => {
    for (const path of adminOnlyPaths()) {
      expect(ownsPath(path.replace("…", ""))).toBe(false);
    }
  });
});

describe("checkAdminAccess", () => {
  test("lets an anonymous visitor through to a login prompt", async () => {
    const res = await checkAdminAccess(new Request(`${ORIGIN}/save-editor`));
    expect(res).not.toBeNull();
    expect(res?.status).toBe(401);
    expect(await res?.text()).toContain("Entrar");
  });

  test("refuses a normal account with 403", async () => {
    const { cookie } = await as("ana");
    const res = await checkAdminAccess(
      new Request(`${ORIGIN}/save-editor`, { headers: { cookie } }),
    );

    expect(res?.status).toBe(403);
    const html = await res?.text();
    expect(html).toContain("Sin permisos");
    // It says who you are, but never what is behind the wall.
    expect(html).toContain("ana");
    expect(html).not.toContain("Empire Points");
  });

  test("lets an admin through", async () => {
    const { cookie } = await as("root", "admin");
    const res = await checkAdminAccess(
      new Request(`${ORIGIN}/save-editor`, { headers: { cookie } }),
    );
    expect(res).toBeNull();
  });

  test("a forged cookie does not grant admin", async () => {
    const res = await checkAdminAccess(
      new Request(`${ORIGIN}/save-editor`, {
        headers: { cookie: "rte_session=1.forged" },
      }),
    );
    expect(res?.status).toBe(401);
  });

  test("demoting an admin takes effect on the next request", async () => {
    const { user, cookie } = await as("root", "admin");
    expect(await checkAdminAccess(new Request(`${ORIGIN}/save-editor`, { headers: { cookie } }))).toBeNull();

    run("UPDATE users SET role = 'player' WHERE id = ?", user.id);

    const after = await checkAdminAccess(
      new Request(`${ORIGIN}/save-editor`, { headers: { cookie } }),
    );
    expect(after?.status).toBe(403);
  });
});