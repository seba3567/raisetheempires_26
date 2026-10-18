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
| `ruffle.html` | **Fallback de Diagnóstico** | Reproductor standalone directo en Flask (sin SvelteKit). Redirige a `/juego` por defecto; se renderiza con `?raw=1` o `?fallback=1` para tests automatizados de integración (`test/test_gateway_e2e.py`). |
| `nodebug.html` | **Eliminado** | Eliminado por obsolescencia técnica (Flash NPAPI ya no está soportado en navegadores modernos). La ruta `/nodebug.html` redirige automáticamente a `/juego`. |
| `new.html` | **Deprecado** | Antigua cuadrícula Jinja de avatares. La ruta `/new.html` redirige automáticamente a `/juego`. |
| `changelog.txt` | **Histórico** | Registro de cambios y parches históricos de la emulación de servidor. |
| `css/`, `img/`, `js/` | **Compatibilidad** | Recursos estáticos servidos por Flask (`/css`, `/img`, `/js`) para soportar la visualización del reproductor de respaldo `ruffle.html?raw=1`. |

> **Nota:** Todas las rutas web históricas en [`empires-server.py`](../empires-server.py) (`/`, `/game`, `/play`, `/home.html`, `/new.html`, `/nodebug.html`, `/ruffle.html`) redirigen limpiamente al cliente web moderno en `/juego`.
