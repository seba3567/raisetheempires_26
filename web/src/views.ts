/**
 * Server-rendered views.
 *
 * Plain template functions, no client framework: the public surface is a
 * landing page, an account area and the game itself, and the game is the SWF.
 */

const ESCAPES: Record<string, string> = {
  "&": "&amp;",
  "<": "&lt;",
  ">": "&gt;",
  '"': "&quot;",
  "'": "&#39;",
};

/** Escape for HTML text and double-quoted attribute contexts. */
export function esc(value: unknown): string {
  return String(value).replace(/[&<>"']/g, (c) => ESCAPES[c] ?? c);
}

interface LayoutOptions {
  title: string;
  user?: { username: string } | null;
  body: string;
}

export function layout({ title, user, body }: LayoutOptions): string {
  const nav = user
    ? `<a href="/cuenta">${esc(user.username)}</a><a href="/salir">Salir</a>`
    : `<a href="/entrar">Entrar</a><a href="/registro">Crear cuenta</a>`;

  return `<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${esc(title)}</title>
<style>
  :root { color-scheme: dark; --bg:#0b0f14; --panel:#141b24; --line:#243040;
          --text:#e6edf3; --muted:#8b98a9; --accent:#e0a13a; }
  * { box-sizing: border-box; }
  body { margin:0; background:var(--bg); color:var(--text);
         font:16px/1.6 system-ui,-apple-system,"Segoe UI",sans-serif; }
  header { border-bottom:1px solid var(--line); }
  .bar { max-width:68rem; margin:0 auto; padding:1rem 1.25rem;
         display:flex; align-items:center; gap:1.5rem; }
  .brand { font-weight:700; letter-spacing:.02em; color:var(--text);
           text-decoration:none; margin-right:auto; }
  .brand span { color:var(--accent); }
  a { color:var(--accent); text-decoration:none; }
  a:hover { text-decoration:underline; }
  main { max-width:68rem; margin:0 auto; padding:2.5rem 1.25rem 4rem; }
  h1 { font-size:clamp(2rem,5vw,3rem); line-height:1.15; margin:0 0 1rem; }
  h2 { font-size:1.25rem; margin:2.5rem 0 1rem; }
  p { color:var(--muted); max-width:44rem; }
  .panel { background:var(--panel); border:1px solid var(--line);
           border-radius:.75rem; padding:1.5rem; }
  .grid { display:grid; gap:1rem; grid-template-columns:repeat(auto-fit,minmax(14rem,1fr)); }
  .btn { display:inline-block; background:var(--accent); color:#1a1206;
         padding:.7rem 1.4rem; border-radius:.5rem; font-weight:600;
         border:0; cursor:pointer; font-size:1rem; }
  .btn:hover { filter:brightness(1.08); text-decoration:none; }
  label { display:block; margin:1rem 0 .35rem; font-size:.9rem; color:var(--muted); }
  input { width:100%; padding:.7rem .8rem; border-radius:.5rem;
          border:1px solid var(--line); background:#0d1319; color:var(--text);
          font-size:1rem; }
  input:focus { outline:2px solid var(--accent); outline-offset:1px; }
  .error { background:#3a1d1d; border:1px solid #6b2f2f; color:#ffb4b4;
           padding:.75rem 1rem; border-radius:.5rem; margin-bottom:1rem; }
  .ok { background:#16301f; border:1px solid #2f5c3c; color:#a6e3bb;
        padding:.75rem 1rem; border-radius:.5rem; margin-bottom:1rem; }
  table { width:100%; border-collapse:collapse; margin-top:.5rem; }
  th, td { text-align:left; padding:.6rem .5rem; border-bottom:1px solid var(--line); }
  th { color:var(--muted); font-weight:600; font-size:.8rem;
       text-transform:uppercase; letter-spacing:.05em; }
  footer { border-top:1px solid var(--line); color:var(--muted); font-size:.85rem; }
  footer .bar { padding-top:1.5rem; padding-bottom:1.5rem; }
  .tag { display:inline-block; background:#1d2632; border:1px solid var(--line);
         color:var(--muted); border-radius:999px; padding:.15rem .6rem;
         font-size:.75rem; margin-left:.5rem; }
</style>
</head>
<body>
<header>
  <div class="bar">
    <a class="brand" href="/">Raise the <span>Empires</span></a>
    ${nav}
  </div>
</header>
<main>
${body}
</main>
<footer>
  <div class="bar">
    Preservación jugable de <em>Empires &amp; Allies</em> (Gazillion, 2011-2013).
    Sin Flash, sin Facebook. Cliente original bajo Ruffle; gateway AMF0 original en Python.
  </div>
</footer>
</body>
</html>`;
}

export function homePage(user: { username: string } | null): string {
  const action = user
    ? `<a class="btn" href="/ruffle.html">Entrar al juego</a>`
    : `<a class="btn" href="/registro">Crear cuenta gratis</a>`;

  return layout({
    title: "Raise the Empires — preservation server",
    user,
    body: `
<h1>Raise the Empires</h1>
<p>Un servidor público y jugable para <em>Empires &amp; Allies</em>, el juego que
Gazillion cerró en 2013. El cliente es el SWF original; lo que faltaba era un
servidor que todavía respondiera.</p>
<p>${action}</p>

<h2>Qué cambió</h2>
<div class="grid">
  <div class="panel">
    <strong>Cuentas propias</strong>
    <p>Registro y progreso guardados aquí, sin Facebook y sin OAuth.</p>
  </div>
  <div class="panel">
    <strong>Amigos reales</strong>
    <p>La lista de vecinos viene de jugadores con cuenta, no de islas horneadas.</p>
  </div>
  <div class="panel">
    <strong>Identidad estable</strong>
    <p>Tu <code>zid</code> se deriva de la cuenta, no de una cookie: cerrar sesión
    ya no parte la partida en dos.</p>
  </div>
  <div class="panel">
    <strong>Ruffle pineado</strong>
    <p>Emulador fijado a la versión 0.7.1 con hash SRI. No hay tag móvil que rompa el cliente.</p>
  </div>
</div>

<h2>Cómo se juega</h2>
<p>Crea una cuenta, entra al juego y todo lo que hagas —nivel, tropas, territorio—
se guarda contra esa cuenta. Puedes cerrar el navegador y volver cuando quieras.</p>`,
  });
}

function authForm(
  mode: "login" | "register",
  error: string | null,
): string {
  const isLogin = mode === "login";
  return layout({
    title: isLogin ? "Entrar — Raise the Empires" : "Crear cuenta — Raise the Empires",
    body: `
<h1>${isLogin ? "Entrar" : "Crear cuenta"}</h1>
${error ? `<p class="error">${esc(error)}</p>` : ""}
<form method="post" action="${isLogin ? "/entrar" : "/registro"}" class="panel" style="max-width:24rem">
  <label for="username">Usuario</label>
  <input id="username" name="username" autocomplete="username" required minlength="3" maxlength="24">
  <label for="password">Contraseña</label>
  <input id="password" name="password" type="password"
         autocomplete="${isLogin ? "current-password" : "new-password"}" required
         minlength="${isLogin ? 1 : 8}">
  <div style="margin-top:1.5rem">
    <button class="btn" type="submit">${isLogin ? "Entrar" : "Crear cuenta"}</button>
  </div>
</form>
<p style="margin-top:1rem">${
      isLogin
        ? '¿No tienes cuenta? <a href="/registro">Crea una</a>.'
        : '¿Ya tienes cuenta? <a href="/entrar">Entra</a>.'
    }</p>`,
  });
}

export function loginPage(error: string | null): string {
  return authForm("login", error);
}

export function registerPage(error: string | null): string {
  return authForm("register", error);
}

interface DashboardData {
  username: string;
  zid: string;
  role: string;
  level: number;
  xp: number;
  worldName: string;
  friends: Array<{ username: string; status: string; level: number | null }>;
  suggestions: Array<{ username: string; level: number | null }>;
}

export function accountPage(data: DashboardData, notice: string | null): string {
  const friendRows =
    data.friends.length === 0
      ? `<tr><td colspan="3" style="color:var(--muted)">Todavía no tienes amigos.</td></tr>`
      : data.friends
          .map(
            (f) =>
              `<tr><td>${esc(f.username)}</td><td>${f.level ?? "—"}</td>
               <td><form method="post" action="/amigos/eliminar"><input type="hidden" name="friend" value="${esc(f.username)}">
               <button class="btn" style="padding:.3rem .8rem;font-size:.85rem">Quitar</button></form></td></tr>`,
          )
          .join("");

  const suggestionRows =
    data.suggestions.length === 0
      ? ""
      : data.suggestions
          .map(
            (s) =>
              `<tr><td>${esc(s.username)}</td><td>${s.level ?? "—"}</td>
               <td><form method="post" action="/amigos/agregar"><input type="hidden" name="friend" value="${esc(s.username)}">
               <button class="btn" style="padding:.3rem .8rem;font-size:.85rem">Agregar</button></form></td></tr>`,
          )
          .join("");

  const adminBlock =
    data.role === "admin"
      ? `<h2>Administración <span class="tag">${esc(data.role)}</span></h2>
<div class="panel">
  <p>Estas herramientas cambian el estado del juego o exponen datos de otros
  jugadores, así que solo una cuenta con rol <code>admin</code> puede abrirlas.</p>
  <p><a class="btn" href="/save-editor">Abrir el editor de imperio</a></p>
  <p style="margin-top:1rem"><a href="/gazillionaire">Añadir 10.000 Empire Points a mi partida</a>
  &nbsp;·&nbsp; <a href="/list_session">Ver sesiones guardadas</a></p>
</div>`
      : "";

  return layout({
    title: `Mi cuenta — Raise the Empires`,
    user: { username: data.username },
    body: `
<h1>${esc(data.username)}${data.role === "admin" ? ' <span class="tag">admin</span>' : ""}</h1>
${notice ? `<p class="ok">${esc(notice)}</p>` : ""}
<div class="grid" style="margin-bottom:2rem">
  <div class="panel"><div style="color:var(--muted);font-size:.8rem;text-transform:uppercase">Nivel</div>
    <div style="font-size:2rem;font-weight:700">${data.level}</div></div>
  <div class="panel"><div style="color:var(--muted);font-size:.8rem;text-transform:uppercase">XP</div>
    <div style="font-size:2rem;font-weight:700">${data.xp}</div></div>
  <div class="panel"><div style="color:var(--muted);font-size:.8rem;text-transform:uppercase">Mundo</div>
    <div style="font-size:1.2rem;font-weight:600">${esc(data.worldName)}</div>
    <div style="color:var(--muted);font-size:.8rem;margin-top:.5rem">zid ${esc(data.zid)}</div></div>
</div>
<p><a class="btn" href="/ruffle.html">Entrar al juego</a></p>

${adminBlock}

<h2>Amigos</h2>
<table>
  <thead><tr><th>Jugador</th><th>Nivel</th><th></th></tr></thead>
  <tbody>${friendRows}</tbody>
</table>

${
  suggestionRows
    ? `<h2>Sugerencias</h2>
<table>
  <thead><tr><th>Jugador</th><th>Nivel</th><th></th></tr></thead>
  <tbody>${suggestionRows}</tbody>
</table>`
    : ""
}
`,
  });
}