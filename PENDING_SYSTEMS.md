# Sistemas y Estado de Integración Multijugador

Este documento detalla el estado de los subsistemas multijugador, la persistencia distribuida y los componentes sociales de Raise the Empires.

---

## Cómo leer este documento

Un servicio AMF registrado no significa un servicio implementado. Los handlers
de `service_handlers.py` se registran todos —para que el cliente Flash reciba
una respuesta y no un error— pero la respuesta de muchos de ellos es fija.

El reparto actual de los **128** handlers de la tabla extendida:

| | Cantidad |
| --- | --- |
| Con lógica real | 99 |
| Respuesta fija ("stub") | 29 |

Tres de ellos ya no viven en `service_handlers.py`: `UserService.checkForPromoReward`
y `DataServicesService.getPromoData` están en
`empires_gateway/amf/handlers/promo.py`, y `UserService.crewNeighborPoll` en
`empires_gateway/amf/handlers/world.py`.

Un *stub* devuelve algo fijo y no toca la base de datos. Cuando una sección de
este documento dice **COMPLETADO**, todos sus handlers tienen lógica real; cuando
dice **STUB**, todos devuelven una respuesta fija. Donde hay de las dos cosas,
se dice cuál es cuál.

El estado de cada handler se puede volver a comprobar con el análisis de
`service_handlers.py`: un handler es un stub cuando su cuerpo es un único
`return _response(...)`. Y el estado de la superficie completa —los 202 métodos
que el cliente puede llamar— lo comprueba `test/test_amf_coverage.py`, que además
deja constancia de que ninguno responde con el vacío.

---

## 1. Red Social de Alianzas y Clanes (`ClansService` & Web Hub)

* **Estado**: **COMPLETADO** ✅ — 8 de 17 handlers con lógica real; los otros 9
  son stubs (ver más abajo).
* **Implementación**:
  * **Persistencia Relacional PostgreSQL 18**: Tablas `clans`, `clan_members` y
    `clan_messages` creadas y migradas (`004_clans.sql`, `005_gifts.sql`).
  * **Modelo de Datos en SvelteKit (`clans.ts`)**: Funciones completas para crear clan, listar miembros, transferir liderazgo, cambiar blasón y nombre con control de acceso.
  * **Integración AMF Gateway (`service_handlers.py`)**: el gateway y la web
    comparten una sola base de datos, así que el juego usa las mismas tablas que
    la web en lugar de una copia propia.
    * `ClansService.getClanInfo`: Devuelve la alianza del jugador tal como está
      en las tablas, con sus miembros y su muro. Sin alliance en las tablas
      devuelve la copia de la sesión, que es lo que hay para el juego anónimo.
    * `ClansService.getNeighborClanInfo`: Busca la alianza del vecino en las
      tablas y, si no está, en su partida (`get_save_by_uid`).
    * `ClansService.postGroupFeed`: Publica en `clan_messages`, la misma tabla
      que lee el muro de `/amigos`, así que el juego y la web ven el mismo muro.
    * `ClansService.createClan`, `updateName`, `updateCrest`, `buyHealth`,
      `buySlots`: Persisten en la tabla `clans`. `createClan` crea el clan y la
      membresía del líder en una sola sentencia, de modo que un clan sin líder
      no puede existir.
  * **Stubs**: `buyCrest`, `addTaunt`, `updateTauntViewTime`, `acceptQuest`,
    `completeQuest`, `clearNotifications`, `removeMember`, `processMemberQueue`,
    `loadAllianceBattle`.

## 2. Visitas Asíncronas e Interacción de Vecinos (`VisitorService` & `RequestService`)

* **Estado**: **COMPLETADO** ✅ para el flujo de visitas y regalos.
  * `RequestService`: 1 de 5 handlers con lógica real (`giftRequest`); los
    otros 4 son stubs.
  * `VisitorService`: el servicio AMF en sí es un stub (1 de 1), pero el flujo
    de visitas que lo rodea es real y vive en el gateway base
    (`empires-server.py`), no en `service_handlers.py`.
* **Implementación**:
  * **Modificación de Partida Cruzada (Cross-Save Writeback)**:
    * `tend_ally_response` utiliza búsqueda indexada `get_save_by_uid(target_uid)` en PostgreSQL, registra el ID del visitante y el edificio en `visitorHelpRequests`, avanza el estado del edificio con `click_next_state(..., tending=True)` y persiste los cambios en la partida del vecino con `store_session(save)`.
    * `accept_tend_ally_response` y `decline_tend_ally_response` procesan las ayudas pendientes al iniciar sesión y las limpian limpiamente sin riesgo de `KeyError`.
  * **Bandeja de Entrada de Regalos Reales**:
    * `request_gift` en `service_handlers.py` deposita el paquete de regalo directamente en `activeGiftRequests` de la partida del destinatario vía `get_save_by_uid` y `store_session`.
    * La acción web `sendGift` en `/amigos` permite enviar suministros y energía directamente sin necesidad de popups de Facebook.

---

## 3. Redes de Anuncios y Telemetría de Terceros (`WatchToEarnService` & `ZlingshotService`)

* **Estado**: **STUB** ⚠️ — ninguno de sus 8 handlers tiene lógica real.
* **Lo que sí funciona**: `UserService.grantWatchToEarnReward` (y su variante
  `...New`) sí otorgan las monedas de verdad, sobre los recursos del jugador.
* **Lo que no**: los métodos del servicio de anuncios responden con valores fijos
  en lugar de seguir una campaña:
  * `WatchToEarnService`: `available` devuelve `{"available": False}`,
    `countPrompt` devuelve `0`, `loadObject` devuelve `{}`,
    `startActivity` devuelve `["success"]` y `version` devuelve `"1.0"`.
    (6 de 6 son stubs.)
  * `ZlingshotService`: `fetch` y `zoom` devuelven respuestas fijas.
    (2 de 2 son stubs.)

La diferencia con la sección 2 y la 1 es que aquí no hay ningún camino que
llegue a la base de datos: el juego recibe la respuesta fija y sigue.

---

## 4. Métricas de Anti-Cheat y Rendimiento (`sendZaspReport`)

* **Estado**: **INTEGRADO** ✅
* **Implementación**:
  * `WorldService.sendZaspReport` absorbe la telemetría del cliente (FPS, tiempos entre frames `s5s_f2f_fps`, uso de memoria AVM2) y devuelve confirmación inmediata al motor de Flash/Ruffle.

---

## 5. Servicios de terceros sin implementación (`CrossPromoService`, `DataServicesService`, `MFSService`, `BlackMarketHelperService`)

* **Estado**: **STUB** ⚠️ — un handler cada uno, todos con respuesta fija.
* Nota: `WorldService` tiene 19 métodos entre la tabla base y la extendida, y
  solo `reviveUnits` tiene lógica real en la extendida. Los que importan
  (`resolveBattle`, `loadWorld`, `spawnFleet`, `sendZaspReport`) viven en la
  tabla base de `empires-server.py` y sí funcionan.
