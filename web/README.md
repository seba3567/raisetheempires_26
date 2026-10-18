# web/ — la puerta pública

Servicio **SvelteKit 3 + Svelte 5** sobre **Bun**, con el adaptador oficial
`@sveltejs/adapter-bun`. Es lo que el jugador ve: la landing, las cuentas, los
amigos, el progreso y **el juego, con el SWF embebido en la página**. Todo lo
demás lo sirve el servidor Python, al que este proceso hace de proxy.

```
navegador ──► web/ (SvelteKit, :8080)  ──► empires-server.py (Flask, 127.0.0.1:5005)
                landing, cuentas,            /ruffle.html, /assets, /js,
                amigos, progreso,           /flashservices/gateway.php  (AMF0)
                JUEGO (Ruffle embebido)
```

## Por qué el gateway sigue en Python

El SWF habla AMF0 y el dialecto exacto que produce `pyamf` es un contrato: los
arrays densos frente a los objetos con claves numéricas, y los marcadores de
referencia. Ruffle no implementa `AmfValue::Reference`, así que un solo objeto
serializado dos veces rompe el cliente. El cliente no tiene código fuente, así
que no se puede recompilar para tolerar otra codificación. **El códec no se
reescribe, se protege.**

La consecuencia práctica: `empires-server.py` nunca se expone a internet. Este
servicio es su única puerta, y por eso el dev server de Flask no necesita ser
production-ready.

## El juego vive en la página

`/juego` monta el player con la API imperativa de Ruffle, que es la forma ya
probada contra este SWF en `templates/ruffle.html`:

```ts
const ruffle = window.RufflePlayer.newest();
const player = ruffle.createPlayer();
await player.load({ url: SWF_PATH, allowScriptAccess: true, parameters: flashVars });
```

No se usa el custom element `<ruffle-player>`: los atributos declarativos no
pueden expresar `backgroundColor` ni `LogLevel`. Dos valores **no** son
decorativos:

- **`allowScriptAccess: true`.** El SWF llama `ExternalInterface.addCallback`
  durante la carga (MOTDManager). Sin esto lanza `Error #2067` y aborta
  `init::GameSettingsInit/onConfigXmlLoaded`, dejando el juego colgado en la
  pantalla de carga.
- **`parameters` con `app_url`.** El cliente arma su URL del gateway AMF0 desde
  ese FlashVar (`Config.SERVICES_GATEWAY_PATH`). Ver abajo.

### El juego arranca con un clic, no solo

Chrome no deja iniciar un `AudioContext` sin un gesto del usuario, y Ruffle crea
el suyo mientras el SWF arranca. Montar el player desde `onMount` producía un
juego **mudo**, con este error repetido una vez por cada sonido, cada uno con su
stack trace de Rust:

```
The AudioContext was not allowed to start. It must be resumed (or created)
after a user gesture on the page.
```

Por eso `/juego` muestra una pantalla con un botón **Jugar** y recién ahí carga
el player. Un clic le da al documento *sticky activation*, y el `AudioContext`
que Ruffle cree después sí puede arrancar: el error no ocurre en absoluto.
Reanudar el contexto después sería tapar un error ya lanzado, y dejaría el
juego mudo hasta que el jugador tocara algo.

### Ruffle va completo, no solo el loader

Ruffle **0.7.1 se sirve localmente** desde `static/ruffle/`, no desde unpkg. El
SHA-256 del loader en el repo es
`sha256-JgNqlFZwiN+z3oinWejtEKTOoHspUArzbzRe70JCAJg=`. Un proyecto de
preservación no debería depender de que un CDN siga en pie.

Ojo con esto: **`ruffle.js` no es un bundle, es un loader.** Son 455 KB que
resuelven en runtime un core WebAssembly y dos chunks de JavaScript cuyos nombres
derivan de su propia URL. Copiar solo el loader deja la página así:

```
GET /ruffle/core.ruffle.16d61072ac7fdc4d5013.js net::ERR_ABORTED 404
Serious error occurred loading SWF file: Error: Failed to load Ruffle WASM
```

El juego entero, sin ningún otro síntoma. Por eso `static/ruffle/` tiene el
**paquete completo** de `node_modules/@ruffle-rs/ruffle`: 12 archivos, 29,3 MB,
dos de ellos binarios WASM de ~14 MB.

```
ruffle.js                              455 KB   loader
core.ruffle.16d61072ac7fdc4d5013.js    106 KB   el que pedía y daba 404
core.ruffle.994eeef0a471a88cd0e3.js    112 KB
172de42e6619eac8f371.wasm            13968 KB
878d548199cddef07035.wasm            13894 KB
```

Los `.wasm` deben servirse como `application/wasm`:
`WebAssembly.instantiateStreaming` rechaza cualquier otro content type, y el
fallo se manifiesta como el mismo "Failed to load Ruffle WASM".

## Por qué `zid` se deriva de la cuenta

El gateway Python **usaba** la identidad del jugador a partir de su propia
cookie:

```python
zid = crc64_go_iso(session_id) // 2048
```

Una cookie se regenera. Cuando eso pasa, el mismo jugador recibe otro `zid` y su
partida queda partida en dos. Peor: como esa cookie no tiene nada que ver con la
cuenta de acá, **iniciar sesión noSERVía de nada dentro del juego** — la partida
era de la cookie, no del jugador.

Ahora el proxy le entrega la identidad al gateway en el header
`x-player-zid`, y `get_zid()` la prefiere:

```ts
// hooks.server.ts -> proxy.ts, solo si hay sesión verificada
headers.set(PLAYER_ZID_HEADER, event.locals.user.zid);
```

```python
# game_settings.py
supplied = request.headers.get(PLAYER_ZID_HEADER)
if supplied is not None and 0 < int(supplied) <= MAX_SAFE_ZID:
    return int(supplied)
return zid_from_sid(session.sid)   # fallback: juego anónimo intacto
```

El `zid` se deriva del **id de la cuenta**, que no cambia al cerrar sesión,
cambiar la contraseña ni rotar la cookie.

> **Este header se confía porque Flask vive en loopback.** Si expones
> `empires-server.py` en `0.0.0.0`, cualquiera puede reclamar la partida de otro
> con una cabecera escrita a mano. Mismo supuesto que el gate de admin.

El proxy **borra** cualquier `x-player-zid` que venga del cliente antes de
mandarlo: la copia automática de headers reenviaría lo que el navegador
escribiera, y eso sería autonombrarse. Fijado por `tests/proxy.test.ts`.

`src/lib/ids.ts` es el port de `crc64_go_iso.py` y `tests/ids.test.ts` fija los
mismos vectores que el test de Python, así que ambos lenguajes producen el mismo
valor. La división por 2048 no es estética: ActionScript 3 no tiene enteros,
todo `Number` es un `double`, y el checksum de 64 bits no cabría exacto.

## La base de datos

MariaDB, la misma que usa el gateway, para que el proyecto entero tenga un solo
almacén. `SAVE_STORE_PATH` / `RTE_DB_URL` deciden cuál es el servidor; todo el
SQL vive en `src/lib/server/db/` y las migraciones se aplican solas al abrir la
conexión, anotando lo aplicado en `schema_migrations`.

El paso desde `bun:sqlite` dejó tres cosas que conviene no deshacer:

- `client.ts` sigue usando placeholders `?`. MariaDB los acepta a través del
  driver; solo un motor que exija `$1` obligaría a tocarlos.
- `001_init.sql` está escrito en dialecto MariaDB, con `DATETIME` donde el
  original tenía `TEXT` (SQLite no distingue texto de fecha, así que el orden y
  las comparaciones de fechas no funcionaban).
- `activity.id` es `AUTO_INCREMENT` porque `recordActivity()` nunca da un id. Sin
  eso, cada insert falla con errno 1364.

Las migraciones se embeben en el bundle con `import.meta.glob(..., '?raw')`, no
se leen del disco: tras el build, `import.meta.dir` apunta al directorio del
chunk compilado y el filesystem no está ahí. La clave de cada migración se
normaliza a su nombre de archivo, porque el glob y el `readdir` devuelven
formatos distintos y registrarlos por separado hacía correr la misma migración
dos veces.

## Rutas

| Ruta | Quién la sirve | Qué es |
| --- | --- | --- |
| `/` · `/entrar` · `/registro` · `/cuenta` | SvelteKit | Landing y cuentas |
| `/juego` | SvelteKit | El SWF, embebido en la página |
| `/admin/editor` | SvelteKit, **solo admin** | Editor de imperio, con los iconos del juego |
| `/ruffle/*` | SvelteKit | Ruffle 0.7.1 completo (loader + chunks + WASM) |
| `/snapi.json` · `/player.json` | gateway (proxy) | Datos que el SWF y la web piden al servidor |
| `/ruffle.html` · `/assets/…` · `/flashservices/…` | gateway (proxy) | Cliente y datos del juego |
| `/save-editor` · `/gazillionaire` · `/patch/…` · `/list_session` | gateway, **solo admin** | Herramientas de edición |

El hook decide con `event.route.id`: si no hay ruta que coincida, es del gateway.

## La partida se lee del gateway, no de la cuenta

Nivel, XP, Empire Points y recursos salen de `/player.json`, que lee el save. La
tabla `progress` de Bun se conserva solo como respaldo para una cuenta que
nunca ha jugado: **nada del juego escribía ahí**, así que se quedó en nivel 1 al
lado de un imperio de nivel 85.

Esa lectura tiene que mandar **dos** cookies, y no son la misma:

- `rte_session`, la de la cuenta, que este servicio verifica. Al gateway no
  viaja: lo que importa va en `x-player-zid`.
- la `session` del gateway, que es la que **elige qué save** se lee.

Sin la segunda, el gateway responde con una partida nueva vacía y la cuenta
vuelve a mostrar nivel 1. Ojo con un detalle al depurar: la cookie lleva el
session id pelado, mientras que la columna `session_id` de la base tiene el
prefijo `session:` de flask-session encima (`_get_store_id`).

## El editor de imperio

`/admin/editor` reemplaza a la plantilla de 2013 para lo que se usa a diario:
nivel, XP, Empire Points, cada recurso y el mineral principal, con los iconos
originales del juego. Las operaciones de quests y el JSON crudo siguen solo en
`/save-editor`, enlazado desde ahí como "editor avanzado".

Los parches se aplican con **lista blanca**: el formulario manda el *nombre* de
un campo (`coins`, `level`, `ore`…) y el servidor decide a qué ruta del save
corresponde. El gateway acepta `/patch/<ruta>/int/<valor>` sobre cualquier ruta
anidada, que es justo lo que no debe quedar expuesto detrás de un campo de
texto.

## El editor de imperio es solo de admins

Esas rutas son más viejas que las cuentas: con una sesión de juego, cualquiera
podía abrir `/save-editor`, darse 10.000 Empire Points, parchear cualquier campo
de cualquier save, o listar las sesiones de todos con `/list_session`. Con
cuentas reales, el chequeo de rol va en `src/lib/access.ts`, que es la única capa
que sabe quién está conectado.

Anónimo recibe un **redirect al login** (la ruta está tras una sesión, no tras un
muro); una cuenta normal recibe un **403**; un `role = admin` pasa tal cual.

> **Esto solo funciona si Flask sigue en loopback.** El candado está en Bun, no en
> Python. Si expones `empires-server.py` en `0.0.0.0`, cualquiera alcanza el
> editor saltándoselo por completo.

## Arrancar

```powershell
cd web
bun install

# Obligatorio: la clave que firma la sesión
bun -e "console.log(crypto.randomUUID()+crypto.randomUUID())"
# -> ponerlo en web/.env (copiar de .env.example)

bun run --bun build
bun .\build              # :8080
```

En otra terminal, el gateway:

```powershell
..\.venv\Scripts\python.exe empires-server.py --port 5005 --no-popup
```

### Variables de entorno

| Variable | Para qué |
| --- | --- |
| `SESSION_SECRET` | Firma la cookie. **Obligatoria.** |
| `PORT` | Puerto público (8080). |
| `GATEWAY_ORIGIN` | Gateway AMF0 en loopback. |
| `RTE_DB_URL` | MariaDB de cuentas, amigos y progreso. Por defecto `mysql://root:2001@127.0.0.1:3306/raisetheempires`. |
| `RTE_DB_NAME` | Nombre suelto, para el `CREATE DATABASE` que corre antes de conectar. |
| `PUBLIC_ORIGIN` | Origen público, si TLS termina en otro proxy. |
| `BODY_SIZE_LIMIT` | Tope del body (6MB). El adapter-bun pone 512K por defecto y el gateway AMF0 manda binarios más grandes que eso. |

`DATABASE_FILE` ya no existe: era el nombre del archivo SQLite.

`PUBLIC_ORIGIN` también alimenta `paths.origin` en `vite.config.ts`. Sin él,
SvelteKit no sabe en qué origen vive el sitio y **rechaza todos los POST de
formulario** con *"Cross-site POST form submissions are forbidden"*, incluido el
login.

## Cuentas de administrador

```powershell
$env:ADMIN_USER="tu_usuario"
$env:ADMIN_PASS="tu_password"
bun run scripts/manage-user.ts create-admin

bun run scripts/manage-user.ts list-admins
bun run scripts/manage-user.ts promote <usuario>
bun run scripts/manage-user.ts demote  <usuario>
bun run scripts/manage-user.ts delete  <usuario>
```

La contraseña se lee del entorno, nunca de un argumento, para que no quede en el
historial de la shell ni en un log. El último admin no se puede degradar ni
borrar.

## Comandos

```powershell
bun test          # 73 tests
bun run check     # svelte-check, 0 errores
bun run --bun build
bun run dev       # desarrollo
```

## Estructura

| Archivo | Qué hace |
| --- | --- |
| `src/hooks.server.ts` | Sesión, gate admin, y todo lo que no es ruta propia va al gateway |
| `src/lib/access.ts` | Qué rutas exigen rol admin, y qué hacer según el rol |
| `src/lib/ids.ts` | CRC-64/GO-ISO y el `zid` |
| `src/lib/resources.ts` | Catálogo de recursos: etiqueta e icono del juego |
| `src/lib/snapi.ts` | El puente `ExternalInterface` que el SWF espera en la página |
| `src/lib/ruffle.ts` | Carga del player y opciones del SWF |
| `src/lib/server/` | Sesión, base de datos, modelos, proxy, estado del jugador |
| `src/routes/` | `/`, `/entrar`, `/registro`, `/cuenta`, `/juego`, `/salir`, `/admin/editor` |
| `src/routes/+layout.server.ts` | La sesión, para que el header la vea en todas las rutas |

### Los cuatro detalles que rompen el juego si se tocan

1. **`Host` hacia el gateway.** Flask lee el `Host` para construir el `app_url`
   que se mete en los FlashVars. Si el proxy no manda el host público, Flask ve
   `127.0.0.1:5005`, el `app_url` apunta al gateway directo y el juego se salta
   este servicio — en silencio, sin ningún error visible. Fijado por
   `tests/proxy.test.ts`.
2. **`Content-Encoding`.** `fetch` de Bun **decodifica el body**: infla un gzip y
   devuelve bytes planos, pero deja el header `Content-Encoding: gzip`. Si el
   proxy lo reenvía, el navegador intenta descomprimir texto plano y la página
   muere con `ERR_CONTENT_DECODING_FAILED`: pantalla negra, ningún otro síntoma.
   Por eso el filtro de headers separa petición de respuesta.
3. **`x-player-zid`.** Si el proxy deja de mandarlo (o de borrarle la versión del
   cliente), el login vuelve a no servir de nada: el juego se queda con la
   partida de su cookie y la cuenta aparece con un imperio vacío. No hay ningún
   error visible — el juego entra perfecto, solo que es el jugador equivocado.
   Fijado por `tests/proxy.test.ts` y `test/test_player_identity.py`.
4. **El puente de `ExternalInterface`.** El SWF no tiene red social propia:
   durante el setup llama a tres funciones JavaScript **por nombre global** —
   `getUserInfo()`, `getFriendData()`, `getAppFriendIds()` — y lee campos de lo
   que devuelven. Si no existen, `getUser()` deja su usuario en `null` y
   `toSocialNetworkUser` hace `new SocialNetworkUser(param1.zid)` sobre `null`
   sin comprobarlo: el juego muere en el setup con

   ```
   Error #1009: Cannot access a property or method of a null object reference.
   (accessing field: zid)
   ```

   sin llegar a ser jugable. `src/lib/snapi.ts` instala esas funciones **antes**
   de `player.load()`; si se cargara primero y se instalara después, el cliente
   ya las llamó. Datos en `/snapi.json` (gateway), y `zid` tiene que ir como
   número JSON. Fijado por `tests/snapi.test.ts`.

### Detalles de Svelte 5 que muerden

- **`/** ... */` arriba de un componente se renderiza como texto.** En el nivel
  superior de un `.svelte`, Svelte no lo interpreta como comentario: lo pinta en
  la página, arriba del player. El comentario va **dentro** del bloque `<script>`.
- **`page.data` solo trae lo que devolvió el load de esa ruta.** El header leía
  `page.data.user`, que el `+page.server.ts` raíz definía solo para `/`, así que
  en `/juego` se veía "Entrar" con la sesión viva — indistinguible de una sesión
  que se pierde sola. Va en el `+layout.server.ts` raíz, que corre en todas.