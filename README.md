# Raise the Empires - Assets del juego

Arbol de recursos del juego, aislado del backend y descompilado a codigo fuente.

Este repositorio contiene **solo los assets del juego**. El backend (FastAPI,
gateway AMF, persistencia), el cliente web, los tests y las herramientas de
build se eliminaron; el codigo del backend sigue disponible en la rama `main`
de este mismo repositorio.

## Estructura

```
assets/                    arbol canonico: las rutas que el cliente pide
  assets/game/...          edificios, unidades, decoraciones, consumos, misiones
  assets/displays/...      dialogos, pantallas, miniseries, megaseries
  assets/ui/...            HUD y avisos
  assets/images/...        imagenes de interfaz (episodios)
  assets/sound/...         musica
  assets/boot/             SWF de arranque ZGame*.swf
  assets/settings/         gameSettings / questSettings / idiomas por revision
  assets/allies/           disposicion de islas (JSON)

decompiled/                fuentes ActionScript + imagenes embebidas
  assets/game/.../         espejo del arbol canonico, un modulo por SWF
    scripts/               clases .as descompiladas
    images/                imagenes extraidas del SWF
  _variants/               modulos de variantes que el juego ya no solicita

_variants/                 SWF obsoletos o no referenciados por el manifiesto
reports/                   informes de inventario, manifiesto y verificacion
```

## Como se determino el arbol canonico

El manifiesto del juego (`gameSettings.xml`) lista una linea por recurso:

```
<md5>:<ruta del recurso>
```

Por ejemplo `2fda94716385231417dcb9956e876fb8:assets/game/gifts/Aluminum_96.png`.
Ese manifiesto es la lista de lo que el cliente pide y con que hash debe
servirse, asi que unirlo contra los archivos en disco resuelve la ruta real de
cada recurso sin adivinar.

El proyecto tenia cuatro revisiones del juego, cada una con su manifiesto:

| Revision | Entradas | SWF |
|---|---|---|
| `rev32995` | 1883 | 283 |
| `rev29oct2012` | 6151 | 876 |
| `rev107829` | 7689 | 1169 |
| `rev57372` | 4254 | 561 |

El join se hizo por ruta primero y, para los archivos con nombre CDN
(`<Nombre>_<md5>.swf`), por el md5 embebido en el nombre. Los archivos con
contenido identico se deduplicaron por hash.

## Descompilacion

JPEXS Flash Decompiler 26.4.0 (Java 21), exportando `script` e `image`:

```
ffdec.bat -export script,image <destino> <archivo.swf>
```

Cobertura: los 866 SWF, sin fallos. De ellos, 853 tienen ActionScript
(63.011 clases) y los 13 restantes son vectores puros sin codigo.

El codigo conserva los paquetes e imports originales, por ejemplo:

```actionscript
package displays.screens.questTreeScreen
{
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   ...
}
```

## Estado de los archivos

Sobre 981 archivos locales:

- **490 verificados**: el md5 coincide con lo que pide el manifiesto.
- **63 modificados**: el contenido difiere del upstream (parches locales, o
  recompresion de PNG/MP3).
- **428 no referenciados**: ninguna revision los pide.

Los no referenciados se conservan en `_variants/` con su descompilacion
correspondiente, para no perder nada.

## Nota sobre los hashes

El manifiesto guarda el md5 del archivo publicado originalmente por el CDN.
Para los PNG y MP3 las copias locales fueron recomprimidas, asi que su md5 no
coincide aunque el recurso sea el correcto. En los SWF la coincidencia es
exacta, y sirve como verificacion de integridad.

## Herramientas usadas

- `ffdec` (JPEXS) 26.4.0 para descompilar
- scripts propios de inventario, resolucion contra el manifiesto y verificacion
