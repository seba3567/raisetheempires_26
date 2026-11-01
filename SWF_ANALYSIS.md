# Análisis de los archivos SWF del proyecto

## Herramientas disponibles

No hay decompiladores SWF externos instalados (ffdec, swftools, etc.).
Se usó un **parser Python propio** (`scratch_analyze_swf.py`) que lee la cabecera
SWF (firma, versión, dimensiones, frame rate, frame count) y clasifica por
directorio. Para el SWF principal se extrajeron cadenas imprimibles
(`scratch_swf_strings.py`) para identificar componentes de UI.

## Resumen global

- **Total de SWF:** 875 archivos
- **Tamaño total:** ~460 MB
- **Formatos:** FWS (sin comprimir), CWS (zlib), ZWS (LZMA). La mayoría son CWS.

## Clasificación por categoría semántica

| Categoría | Archivos | Tamaño |
|---|---|---|
| `sol_assets` (raíz) | 406 | 278.4 MB |
| `sol_assets/displays` | 246 | 16.0 MB |
| `sol_assets/game` | 191 | 139.1 MB |
| `sol_assets/ui` | 9 | 0.3 MB |
| `sol_assets/sound` | 5 | 2.1 MB |
| `sol_assets/images` | 1 | 0.1 MB |
| `hashed` (sin clasificar) | 6 | 1.4 MB |
| `ZGame.109338_tracer2.swf` | 3 | 6.7 MB |
| `ZGame.109338.swf` | 2 | 4.3 MB |
| `ZGame.109338_tracer.swf` | 1 | 2.4 MB |
| `ZGame.109338_tracer2a.swf` | 1 | 2.4 MB |
| `ZGame.109338_tracer_old.swf` | 1 | 2.4 MB |
| `cooking/*` | 3 | 0.3 MB |

## Tipos de asset más frecuentes (normalizados)

Los nombres se normalizaron quitando prefijos `OLDER_`/`NEWER_`/`MAYBE_` y
hashes. Los más comunes:

- `GeneralAssetGroup_UI.swf` (25)
- `Quests_Icons_0.swf` (24)
- `Units_Sea_Icons.swf` (19)
- `Buildings_Buildables_01.swf` (18)
- `Units_Land_Icons.swf` (16)
- `Buildables_Icons_0.swf` (16)
- `Units_Air_Icons.swf` (14)
- `Buildings_MS_Entry_Point.swf` (13)
- `Decorations_Icons.swf` (13)
- `Quests_MS_0.swf` (11)
- `Quests_Icons_1.swf` (10)
- `Quests_TimedQuest_0.swf` (10)
- `Hud.swf` (9)
- `Buildings_Icons.swf` (7)
- `Leaderboard2.swf` (7)
- `Pvp_PicksAndMisc.swf` (7)
- `BattleSetupHudOverlay.swf` (6)
- `Units_Land_Mega.swf` (6)
- `BattleSounds.swf` (5)
- `Consumables.swf` / `ConsumablesUI.swf` (5)
- `Decorations_03.swf`, `Decorations_Bonus.swf` (5)
- `Seasons_April.swf` (5)
- `Weapon_FX.swf` (5)

## SWF principal del juego

- **`ZGame.109338.swf` / `ZGame.109338_tracer2.swf`** — el cliente Flash completo.
  - Versión SWF 10, comprimido (CWS).
  - Dimensiones: 1000×750 (coincide con `PLAYER_WIDTH`/`PLAYER_HEIGHT`).
  - Frame rate: 30 FPS.
  - Contiene cientos de componentes de UI (`icon_mc`, `hit_mc`, `title_tf`,
    `label_tf`, `description_tf`, `panel_mc`, `mask_mc`, `alert_mc`, etc.)
    y etiquetas HTML (`<p align="center">`).

## Clasificación funcional (por nombre/directorio)

| Grupo | Ejemplos | Función |
|---|---|---|
| **Game core** | `ZGame.109338*.swf` | Cliente completo: lógica, red, UI. |
| **Buildings** | `Buildings_*.swf`, `Buildables_*.swf` | Arte y animaciones de edificios. |
| **Units** | `Units_Land_*.swf`, `Units_Sea_*.swf`, `Units_Air_*.swf` | Unidades militares (iconos, animaciones). |
| **Decorations** | `Decorations_*.swf` | Decoraciones del mapa. |
| **UI / HUD** | `Hud.swf`, `GeneralAssetGroup_UI.swf`, `Pvp_PicksAndMisc.swf` | Interfaz de usuario, paneles. |
| **Quests** | `Quests_Icons_*.swf`, `Quests_MS_*.swf`, `Quests_TimedQuest_*.swf` | Iconos y assets de misiones. |
| **Consumables** | `Consumables.swf`, `ConsumablesUI.swf` | Items consumibles. |
| **Dialogs** | `PU_*.swf` (varios) | Pop-ups y diálogos. |
| **Sound** | `BattleSounds.swf`, `Sounds_UI.swf` | Efectos de sonido. |
| **Villains** | `Villains01.swf` | Arte de villanos/enemigos. |
| **Seasons** | `Seasons_April.swf` | Assets estacionales. |
| **Cooking** | `cw2_*`, `SharedFonts_en_US__*.swf` | Cooking Dash (mini-juego integrado). |

## Notas

- Los archivos en `sol_assets_octdict/assets` (406 archivos, 278 MB) son los
  assets servidos por `/nullassets/` y `/assets/`. Están organizados por
  directorio (`game/`, `displays/`, `ui/`, `sound/`, `images/`).
- Los 6 archivos en `hashed/` son copias con nombre hash (posiblemente
  duplicados o versiones alternativas).
- No hay herramientas de decompilación instaladas; el análisis se basó en
  cabeceras y cadenas imprimibles. Para análisis profundo (bytecode, clases)
  se necesitaría FFDec o RABCDAsm.
PY