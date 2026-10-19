# Plantillas Legacy y Fallback (Templates)

Este directorio contiene los archivos HTML, CSS y JavaScript del launcher original y plantillas Jinja heredadas del servidor Flask (período 2012–2020).

## Estado de Arquitectura

El frontend principal y moderno del proyecto está completamente migrado y desacoplado en el directorio [`web/`](../web/README.md), implementado con:
- **SvelteKit 5 + TypeScript + Tailwind CSS**
- Ejecución optimizada en **Bun** (puerto `8080`)
- Integración nativa de emulación con **Ruffle WASM** (WebGPU / WebGL)
- Gestión de cuentas de usuario, sesiones, selección de avatares y panel administrativo `/admin/editor`

## Rol de los Archivos en este Directorio

| Archivo / Carpeta | Estado | Propósito |
|-------------------|--------|-----------|
| `ruffle.html` | **Eliminado** | Reproductor standalone en Jinja. Se fue cuando `/juego` (SvelteKit) pasó a ser el único player: era una segunda copia de los FlashVars y pineaba Ruffle en unpkg. La ruta `/ruffle.html` redirige a `/juego`. |
| `nodebug.html` | **Eliminado** | Eliminado por obsolescencia técnica (Flash NPAPI ya no está soportado en navegadores modernos). La ruta `/nodebug.html` redirige automáticamente a `/juego`. |
| `new.html` | **Deprecado** | Antigua cuadrícula Jinja de avatares. La ruta `/new.html` redirige automáticamente a `/juego`. |
| `changelog.txt` | **Histórico** | Registro de cambios y parches históricos de la emulación de servidor. |
| `css/facebook.css`, `js/session.js` | **Compatibilidad** | Lo único que queda de la maquetación 2013: los necesita `new.html`. Servidos por Flask en `/css` y `/js`. |
| `img/` | **Mixto** | `motds/` y `avatars/` los leen `/motd.json` y `/avatar.json`; el resto son sprites y fondos que `facebook.css` referencia. La web moderna sirve los suyos desde `web/static/`. |

> **Nota:** Todas las rutas web históricas en [`empires-server.py`](../empires-server.py) (`/`, `/game`, `/play`, `/home.html`, `/new.html`, `/nodebug.html`, `/ruffle.html`) redirigen limpiamente al cliente web moderno en `/juego`.
