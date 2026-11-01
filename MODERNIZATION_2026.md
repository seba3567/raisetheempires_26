# Propuesta de modernización 2026

## Ya hecho
- API JSON paralela al AMF0 (`/api/v1/*`).
- Caché inmutable para Ruffle (loader + WASM).
- Precompresión Brotli/Gzip en Bun.
- SWF principal cacheable (1 semana).
- Defaults de rendimiento (calidad baja, 1x DPI).
- PostgreSQL 18 + Granian + SvelteKit 3/Bun.
- FastAPI paralelo con OpenAPI (Fase A).
- Migración de rutas HTTP a FastAPI (Fase B, parcial).
- AMF0 binario migrado a FastAPI (Fase C).
- FastAPI es el servidor principal; Flask es librería/fallback (Fase D, parcial).

## Propuestas (priorizadas)

### P0 — Alto impacto, bajo riesgo
1. **OpenAPI/Swagger** para el API JSON (auto-doc de `/api/v1/*`).
2. **Más aliases REST** para herramientas externas (amigos, economía, admin).
3. **Cache de respuestas AMF** para llamadas idempotentes (loadWorld, getFriendsInfo) con ETag.
4. **HTTP/2 o HTTP/3** en Bun (ya soportado por Bun.serve).

### P1 — Medio impacto, medio riesgo
5. **Migrar el gateway a FastAPI** (async, type hints, OpenAPI nativo) manteniendo AMF0.
6. **Redis** para sesiones y caché de assets (reducir carga de PostgreSQL).
7. **Docker Compose** para despliegue reproducible (gateway + web + postgres).
8. **CI/CD** con GitHub Actions (tests + build + deploy).

### P2 — Alto riesgo, alto valor
9. **Lazy-load de assets por zona** (requiere modificar SWF o servir variantes).
10. **WebGPU por defecto** (más rápido, pero menos estable en algunos navegadores).
11. **Reescribir cliente en HTML5** (proyecto paralelo, no reemplazo; años de trabajo).

### No hacer
- Web Worker para Ruffle (no soportado por la versión vendida).
- Reemplazar el SWF original (rompe la preservación).

## Siguiente paso recomendado
Implementar P0.1 (OpenAPI) y P0.2 (más aliases) en el próximo sprint.
PY