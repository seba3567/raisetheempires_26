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
| `ruffle.html` | **Fallback Activo** | Reproductor standalone directo en Flask (sin SvelteKit). Se mantiene para pruebas de integración automatizadas de bajo nivel (`test/test_gateway_e2e.py`). |
| `nodebug.html` | **Legacy / Referencia** | Contenedor original ActiveX / NPAPI de Flash Player 11. Se conserva como referencia histórica de incrustación de plugins. |
| `new.html` | **Deprecado** | Antigua cuadrícula Jinja de avatares. Reemplazada por la cuadrícula reactiva de Svelte en `/juego` y el endpoint JSON `/avatar.json`. |
| `changelog.txt` | **Histórico** | Registro de cambios y parches históricos de la emulación de servidor. |
| `css/`, `img/`, `js/` | **Compatibilidad** | Recursos estáticos servidos por Flask (`/css`, `/img`, `/js`) para soportar la visualización del reproductor de respaldo `ruffle.html`. |

> **Nota:** Las rutas web en [`empires-server.py`](../empires-server.py) (`/`, `/game`, `/play`, `/home.html`, `/new.html`) redirigen automáticamente al cliente web moderno en `/juego`.
