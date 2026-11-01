# web/ — la puerta pública

Servicio **SvelteKit 3 + Svelte 5** sobre **Bun**, con el adaptador oficial
`@sveltejs/adapter-bun`. Es lo que el jugador ve: la landing, las cuentas, los
amigos, el progreso y **el juego, con el SWF embebido en la página**. Todo lo
demás lo sirve el servidor Python, al que este proceso hace de proxy.

```
navegador ──► web/ (SvelteKit, :8080)  ──► empires-server.py (Flask, 127.0.0.1:5005)
                landing, cuentas,            /assets/… , /js, /flashservices/gateway.php  (AMF0)
                amigos, progreso,           /ruffle.html  ->  /juego (redirect)
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

Ruffle **0.8.0-nightly.2026.10.18 se sirve localmente** desde `static/ruffle/`,
no desde unpkg. El SHA-256 del loader en el repo es
`C142B01123D1FAF2E8F20687409BD2080A9FD00CD56361F6DBD2BD805E3AB8A0`. Un proyecto
de preservación no debería depender de que un CDN siga en pie.

Ojo con esto: **`ruffle.js` no es un bundle, es un loader.** Son 666 KB que
resuelven en runtime un core WebAssembly cuyo nombre de archivo lleva un hash y
se deriva de la URL del propio loader. Copiar solo el loader deja la página así:

```
GET /ruffle/ruffle_web_bg.FX3UZSBY.wasm net::ERR_ABORTED 404
Serious error occurred loading SWF file: Error: Failed to load Ruffle WASM
```

El juego entero, sin ningún otro síntoma. Por eso `static/ruffle/` tiene el
**paquete completo** de `node_modules/@ruffle-rs/ruffle`: 8 archivos, 29,2 MB,
dos de ellos binarios WASM de ~13,5 MB.

```
ruffle.js                                  666 KB   loader
ruffle.js.map                             1524 KB   source map
ruffle_web_bg.FX3UZSBY.wasm              13831 KB   core WebAssembly
ruffle_web-wasm_mvp_bg.CVX62F7H.wasm    13876 KB   core WebAssembly, build MVP
```

Sobre la versión anterior (0.7.1) el layout era otro: el loader pedía además
`core.ruffle.<hash>.js`. Si al hacer `bun add @ruffle-rs/ruffle@<version>` el
nombre de esos chunks cambia, eso no es una regresión, es el layout nuevo.

Los `.wasm` deben servirse como `application/wasm`:
`WebAssembly.instantiateStreaming` rechaza cualquier otro content type, y el
fallo se manifiesta como el mismo "Failed to load Ruffle WASM".

### El `INFO web/src/log_adapter.rs:18` de la consola no es un fallo

Al cargar el juego aparece en la consola del navegador una línea parecida a
esta:

```
INFO web/src/log_adapter.rs:18 17:17:22 null: StatsManager.count errors zcache ZCacheResourceProvider resourceLoaded   1
```

No viene de este proyecto. Las tres piezas:

- **`web/src/log_adapter.rs` es de Ruffle**, no nuestro. Es el crate `ruffle_web`,
  que en el repo de Ruffle vive en `web/src/`. La línea 18 es `avm_trace`, que
  hace `tracing::info!(target: "avm_trace", ...)`: eso es, cada `trace()` que el
  ActionScript del SWF emite. La línea 26 sería `avm_warning`.
- **El texto es del juego, no de Ruffle.** `StatsManager`, `ZCacheResourceProvider`,
  `resourceLoaded` y `zcache` dan cero coincidencias en los dos `.wasm`; están en
  el pool de constantes del ABC de `ZGame.109338.swf`. Junto a ellos aparecen
  `ZLA ZCache hit: <uri>, type=<type>`, `ZLA ZCache put: <...>.png`,
  `zlabs.resource:ImageResource` con su `bitmapData`, `PBEFallbackProvider.getPixels`
  y la interfaz `IZCache` (`flush`, `put`, `containsKey`, `stats`). **ZCache es
  la caché de imágenes y textures del juego servida por el CDN de Zynga**, no
  telemetría: el `StatsManager` (`COUNTER_ZCACHE.zcache`) intentó hablar con ella,
  no la encontró, y contó un error.
- **Ese "error" es el diseño, no una falla.** El juego construye las URLs de
  assets como `<zcache_url>/game/...`, y `zcache_url` es un FlashVar. Como no se
  lo mandamos, la concatenación da la cadena literal `null` y el cliente pide
  `/nullassets/game/...` a este origen. `empires-server.py` mapea ese prefijo al
  archivo local en `assets/sol_assets_octdict/assets` (527 archivos, 174,7 MB:
  437 SWF, 88 PNG, 2 MP3).

  O sea que el trace es la huella de que los assets locales están sirviéndose.
  **195 peticiones a `/nullassets/`, 195 respondidas 200/304, cero 404** en
  `log.txt`. Apuntar `zcache_url` a un CDN "para arreglarlo" sería justo lo
  contrario de arreglarlo: dejarían de servirse los assets locales y el juego
  caería a `EmbeddedResourceProvider` sin arte. Cubierto por
  `test_gateway_e2e.py::TestNullAssetsRoute`.

**Por qué `logLevel: 'error'` no lo calla**, que es lo que más confunde: en
`web/src/lib.rs`, `global_init()` instala un suscriptor global con
`set_max_level(tracing::Level::INFO)` fijo. `logLevel` solo construye el
suscriptor *por instancia*, y ese solo está activo dentro de `with_core()` /
`with_instance()`. La carga asíncrona de recursos corre fuera de esos ámbitos y
cae al global de `INFO`. No hay forma de bajarlo desde `RufflePlayer.config`, y
`set_trace_observer` no sirve: añade un segundo camino de salida, no quita el
`WASMLayer`.

Se deja pasar. Silenciarlo exigiría parchear `console`, y un parche así
escondería también el próximo `trace()` de verdad. Si molesta en una sesión
concreta, se filtra desde las DevTools.

### El arte del juego se cachea una semana; el resto no

`/nullassets/**`, `/assets/**` e `/img/**` se sirven con
`Cache-Control: public, max-age=604800`. Antes no había ninguna cabecera de
caché en el proyecto, así que Werkzeug aplicaba su `no-cache` por defecto: el
navegador guardaba el archivo pero tenía que **revalidarlo en cada uso**. El
juego pide los mismos assets en cada visita, y eso convirtió 1133 de sus 1328
peticiones de assets en 304 vacíos — un viaje entero por el proxy y de vuelta al
disco para recibir tres cabeceras y ningún contenido.

Lo que **no** se cachea, a propósito:

- **`/nullassets/**` y `/img/**` no son `immutable`.** Sus nombres son descriptivos
  (`Island3_Tileset_ENV.swf`), no hashes del contenido, así que un cache
  inmutable sobreviviría a una edición del archivo y los jugadores seguirían
  viendo el arte viejo. Una semana es el punto medio: elimina la revalidación en
  cualquier sesión normal, y si el archivo cambia, el cambio tarda como mucho
  una semana en llegar a quien ya lo cargó. El `ETag` sigue presente, que es lo
  que avisa cuando la semana vence.
- **`/css/` y `/js/` siguen en `no-cache`.** Son los recursos de las páginas
  Jinja de 2013, se editan a mano y son 301 peticiones frente a las 2132 del
  arte. Cachearlos convierte cada retoque en una adivina durante el desarrollo.
- **Un 404 tampoco se cachea**, para que un asset que se archive después llegue a
  quien ya lo pidió sin éxito.

Cubierto por `test_gateway_e2e.py::TestAssetCacheHeaders`.

Lo que **no** se puede cachear desde aquí: `/ruffle/*` (loader y WASM de Ruffle)
lo sirve SvelteKit desde `static/`, y el adaptador solo fija cabeceras para
`_app/immutable/*`, la salida de Vite. `static/` va sin `Cache-Control` y no hay
gancho para cambiarlo. Son 3 peticiones por sesión, contra 2132 del arte, así que
se deja. Si algún día llegaran a importar, habría que sacarlos de `static/` y
servirlos desde una ruta propia.

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

PostgreSQL 18, la misma que usa el gateway, para que el proyecto entero tenga un
solo almacén. `RTE_DB_URL` decide cuál es el servidor, y lo leen **las dos
mitades** con ese nombre; todo el SQL vive en `src/lib/server/db/` y las
migraciones se aplican solas al abrir la conexión, anotando lo aplicado en
`schema_migrations`.

`SAVE_STORE_PATH` era el nombre que usaba el gateway y sigue funcionando como
alias, pero no se escribe más: un despliegue que pusiera uno de cada par dejaba
las dos mitades apuntando a bases distintas.

Cada migración es un archivo `.sql` en `src/lib/server/db/migrations/`, y **su SQL se
ejecuta**. El runner las recorre en orden de nombre, corre cada una dentro de su
propia transacción junto con la fila que la registra, y se salta las que ya
figuraron en `schema_migrations`. El DDL de PostgreSQL es transaccional, así que una
migración que falla no deja nada a medias y se reintenta entera en el siguiente
arranque, en vez de quedar a medias y marcada como aplicada.

> Antes el runner solo *anotaba* los nombres y el esquema vivía en una copia inline
> del mismo DDL dentro de `client.ts`. Los archivos nunca se ejecutaban, de modo que
> una migración agregada al directorio no hacía nada y aun así quedaba registrada
> como aplicada. La copia inline ya no está: los archivos **son** el esquema.

Lo que conviene no deshacer del paso desde `bun:sqlite`:

- `client.ts` sigue usando placeholders `?`. PostgreSQL los acepta a través del
  driver; solo un motor que exija `$1` obligaría a tocarlos.
- `001_init.sql` usa los tipos de PostgreSQL, con `TIMESTAMP` donde el original
  tenía `TEXT` (SQLite no distingue texto de fecha, así que el orden y las
  comparaciones de fechas no funcionaban).
- `activity.id` es `SERIAL` porque `recordActivity()` nunca da un id. Sin eso, cada
  insert falla con errno 1364.

Las tablas del gateway (`saves`, `save_backups`) **no** están aquí: las tiene el save
store, que las crea con su propio `schema.sql` cuando se construye. Nada de este
lado las lee ni las escribe.

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
| `/ruffle/*` | SvelteKit | Ruffle 0.8.0-nightly completo (loader + WASM), desde `static/ruffle/` |
| `/snapi.json` · `/player.json` | gateway (proxy) | Datos que el SWF y la web piden al servidor |
| `/ruffle.html` | gateway | Redirige a `/juego`. Ya no renderiza nada. |
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
| `PORT` | Puerto público (8080). Tiene que ser el puerto de `PUBLIC_ORIGIN`. |
| `HOST` | Interfaz donde se binds (0.0.0.0). |
| `GATEWAY_ORIGIN` | Gateway AMF0 en loopback. |
| `RTE_DB_URL` | PostgreSQL 18 de cuentas, amigos y progreso. Por defecto `postgres://postgres:42kSM0ud2nRLlTZv6YVsXgPcbxwAx9Qe!7a@127.0.0.1:5432/raisetheempires`. |
| `RTE_DB_NAME` | Nombre suelto, para el `CREATE DATABASE` que corre antes de conectar. |
| `RTE_TEST_DB_URL` | Solo para los tests: la base que `bun test` crea y usa. Por defecto `postgres://postgres:42kSM0ud2nRLlTZv6YVsXgPcbxwAx9Qe!7a@127.0.0.1:5432/rte_web_test`. |
| `PUBLIC_ORIGIN` | Origen público, si TLS termina en otro proxy. Por defecto `http://localhost:<PORT>`. |
| `PUBLIC_TRUSTED_ORIGINS` | Orígenes extra que pueden mandar formularios, separados por comas. |
| `RTE_CONTRACT_FILE` | Ruta alternativa a `contract/runtime.json`. |
| `BODY_SIZE_LIMIT` | Tope del body (6MB). El adapter-bun pone 512K por defecto y el gateway AMF0 manda binarios más grandes que eso. |

`DATABASE_FILE` ya no existe: era el nombre del archivo SQLite.

### El contrato entre los dos runtimes

Este proyecto son dos programas en dos lenguajes: el gateway AMF0 en Python (en
la raíz) y esta puerta web. Se encuentran por HTTP, por una base de datos
PostgreSQL y por la identidad del jugador. **Cada valor que cruza una de esas
costuras está escrito una sola vez**, en `contract/runtime.json`, en la raíz
del repositorio:

| Sección | Qué es |
| --- | --- |
| `database` | Host, puerto, usuario, clave y nombre de la base. |
| `gateway` | Dónde escucha el gateway AMF0. |
| `public` | Dónde escucha esta puerta. |
| `headers` | Cómo viaja la identidad del jugador al gateway. |
| `adminPaths` | Qué rutas del gateway son herramienta de admin. |
| `env` | El nombre canónico de cada variable, y los alias viejos que aún funcionan. |
| `snapi` | Las claves del objeto de usuario y del payload que el SWF pide. |
| `playerState` | Las claves de `/player.json`. |
| `resources` | Los recursos del mundo, en orden. |
| `zid` | El divisor del checksum y el máximo exacto para el cliente Flash. |

Python lo lee con `contract.py`; TypeScript con `#lib/server/contract`. Los dos
suites de tests lo leen y comprueban que lo que resolvió cada runtime es lo que
está escrito ahí, así que un valor que se desvía rompe el build y no el juego.

Las variables de entorno siguen mandando sobre el archivo: ahí viven los
**defaults**, no la configuración de un despliegue.

Esto no es purismo. El bug que arregló el turno pasado --el servidor atado al
puerto 3000 con el origen compilado diciendo 8080, y el login respondiendo 403
mientras todas las páginas cargaban-- era exactamente un contrato con dos
dueños.

### La puerta de admin, por los dos lados

Las rutas del gateway que cambian el estado del juego o exponen los datos de
otro jugador (`/gazillionaire`, `/patch/...`, `/list_session`, `DELETE /save`,
`/editor/save`...) están en `adminPaths`. Las dos mitades las respetan:

- **Esta puerta** las filtra antes de proxear, en `access.ts`.
- **El gateway** las filtra en sí mismo, en `admin_gate.py`.

El filtro de esta puerta decodifica el path antes de compararlo, porque
`event.url.pathname` llega con los `%61` intactos y Werkzeug, que enruta al
otro lado, decodifica: `/gazillionaire` se rechazaba y `/%67azillionaire` no,
y ese segundo pedía diez mil monedas de regalo.

El gateway no puede preguntar quién está conectado --no sabe de cuentas--, así
que quien lo afirma es esta puerta, que es la única que conoce la sesión: en
la cabecera de rol, que la puerta pone y nunca reenvía desde el navegador. El
gateway escucha en loopback y esta puerta es su única puerta; por eso confía
en ella, igual que en la cabecera con el id del jugador.

### El puerto y el origen tienen que ser el mismo servidor

`PUBLIC_ORIGIN` alimenta `paths.origin` en `vite.config.ts`, y el adapter-bun
**reescribe cada petición** sobre ese origen antes de que SvelteKit la vea.
SvelteKit compara el header `Origin` de la petición con el origen de la URL
reescrita, y si no son el mismo rechaza el POST con *"Cross-site POST form
submissions are forbidden"*.

Así que el síntoma de un desajuste no es un error de puerto: es el login y el
registro devolviendo 403 mientras todas las páginas cargan bien.

Las tres cosas que tienen que coincidir salen hoy de un solo sitio,
`src/lib/server/config.ts`, que es lo que lee `vite.config.ts`:

- el puerto que se binds (`PORT`),
- el origen que se compila dentro del build (`PUBLIC_ORIGIN`),
- el puerto que el adapter usa cuando el entorno no dice nada (su defecto es
  3000, y por eso se le pasa en `serverOptions`).

Si el sitio se alcanza por más de un nombre —un dominio y una IP, o
`localhost` y `127.0.0.1`— el origen que llega en el header no es el que está
compilado, y el formulario vuelve a ser rechazado. Las alias de loopback de
un origen de loopback se confían solas; cualquier otro nombre hay que
declararlo en `PUBLIC_TRUSTED_ORIGINS`.

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
bun test          # 165 tests
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

### Los cinco detalles que rompen el juego si se tocan

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
5. **El puerto que se binds contra el origen que se compila.** El adapter
   reescribe cada petición sobre `paths.origin` y SvelteKit valida el header
   `Origin` contra ese origen reescrito. Si el servidor escucha en un puerto y
   el origen compilado dice otro, **todas las páginas cargan y todos los
   formularios se rechazan con 403** — login y registro incluidos. El adapter
   solo lee `PORT` y `HOST` del entorno, y su defecto es el 3000, así que
   `vite.config.ts` le pasa los dos en `serverOptions` y usa el mismo valor
   para `paths.origin`. Arriba está el detalle completo. Fijado por
   `tests/config-env.test.ts`.
6. **El filtro de admin sobre el path decodificado.** `event.url.pathname`
   llega con los `%61` intactos y Werkzeug decodifica antes de enrutar, así que
   un path codificado pasaba el filtro y `/%67azillionaire` repartía diez mil
   monedas. `access.ts` decodifica antes de comparar. Fijado por
   `tests/access.test.ts`.
7. **El contrato de los dos runtimes.** Base de datos, dirección del gateway,
   puerto público, cabeceras y rutas de admin están escritos una sola vez, en
   `contract/runtime.json`, y los dos runtimes los leen. Un valor con dos
   dueños es un valor que algún día discrepa. Fijado por
   `tests/config-env.test.ts` y `test/test_contract.py`.

### Detalles de Svelte 5 que muerden

- **`/** ... */` arriba de un componente se renderiza como texto.** En el nivel
  superior de un `.svelte`, Svelte no lo interpreta como comentario: lo pinta en
  la página, arriba del player. El comentario va **dentro** del bloque `<script>`.
- **`page.data` solo trae lo que devolvió el load de esa ruta.** El header leía
  `page.data.user`, que el `+page.server.ts` raíz definía solo para `/`, así que
  en `/juego` se veía "Entrar" con la sesión viva — indistinguible de una sesión
  que se pierde sola. Va en el `+layout.server.ts` raíz, que corre en todas.