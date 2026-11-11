# Inventario de assets - Raise the Empires

Estado final del repositorio tras aislar, ordenar y descompilar los assets.

## 1. Arbol canonico de assets

- Archivos: **506** (208.2 MB)
- SWF: **407**
- PNG: **81**
- SWF con md5 verificado contra el manifiesto: **314**

Por carpeta:
- `allies/AcidCaos-island.json`: 1
- `allies/MissTery-island.json`: 1
- `allies/Natalie-island.json`: 1
- `allies/Steele-island.json`: 1
- `allies/TheDevs-island.json`: 1
- `allies/Zuckerberg-island.json`: 1
- `allies/initial-island.json`: 1
- `assets/displays`: 227
- `assets/game`: 232
- `assets/images`: 12
- `assets/sound`: 6
- `assets/ui`: 9
- `boot/ZGame.109338.swf`: 1
- `boot/ZGame.109338_tracer.swf`: 1
- `boot/ZGame.109338_tracer2a.swf`: 1
- `boot/ZGame.109338_tracer_old.swf`: 1
- `settings/rev107829_gameSettings.xml`: 1
- `settings/rev29oct2012_en_US.xml`: 1
- `settings/rev29oct2012_gameSettings.xml`: 1
- `settings/rev29oct2012_questSettings.xml`: 1
- `settings/rev29oct2012fix_gameSettings.xml`: 1
- `settings/rev32995_en_US.xml`: 1
- `settings/rev32995_gameSettings.xml`: 1
- `settings/rev57372_gameSettings.xml`: 1
- `settings/zh_CN.xml`: 1

## 2. Descompilacion

JPEXS Flash Decompiler 26.4.0 sobre Java 21, exportando `script,image`.

- Modulos descompilados: **863**
- Clases ActionScript: **74170**
- Imagenes extraidas: **61079**
- Volumen: 1.7 GB
- SWF del arbol canonico sin fuentes: **0**

`decompiled/` replica `assets/`, asi que el SWF en
`assets/assets/game/units/Hud.swf` tiene sus clases en
`decompiled/assets/game/units/Hud/scripts/`.

## 3. Variantes

- Archivos: **272** (206.7 MB)
- Contenido duplicado descartado durante la construccion: **154**

Son los SWF que ninguna revision del juego solicita. Se conservan
completos, con su descompilacion en `decompiled/_variants/`, porque
contienen revisiones historicas del codigo (por ejemplo las
familias `OLDER_`, `OBSOLETE_` y `SAME_`).

## 4. Manifiestos

`reports/manifests/` guarda los cuatro manifests del juego, que son
la fuente de verdad de que rutas existen y con que hash:

- `rev107829_gameSettings.xml` (8.8 MB)
- `rev29oct2012_en_US.xml` (5.1 MB)
- `rev29oct2012_gameSettings.xml` (6.9 MB)
- `rev29oct2012_questSettings.xml` (2.4 MB)
- `rev29oct2012fix_gameSettings.xml` (7.0 MB)
- `rev32995_en_US.xml` (1.6 MB)
- `rev32995_gameSettings.xml` (2.1 MB)
- `rev57372_gameSettings.xml` (4.8 MB)
- `zh_CN.xml` (1.7 MB)
