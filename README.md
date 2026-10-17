![Empires & Allies](templates/img/logo.png "Empires & Allies logo")

> Empires and Allies(Facebook) officially closed June 17th, 2013

The Old Empires & Allies preservation project by the Raise the Empires team.
This project is dedicated to preserving this Flash game so that it's not lost to time.

[![version](https://img.shields.io/badge/version-0.08a--preview1-blue)](#)
[![size](https://img.shields.io/badge/size-730%20MB-brightgreen)](#)
[![downloads](https://img.shields.io/github/downloads/AcidCaos/raisetheempires/total?label=downloads%40all)](../../releases/latest)

---

## Releases

| Version | Update | Release date |  Source  | Download |
| ------- | ------ | ------------ | ------ | -------- |
| **alpha 0.08a-preview1** | **Titan Update: Part I** | August 27, 2021 | :label: [tag](../../releases/tag/0.08a-preview1) | :tickets: [**Installer**](../../releases/download/0.08a-preview1/empires-setup_0.08a-preview1.exe) |
| alpha 0.07a   | Return of the Flash       | January 13, 2021   | :label: [tag](../../releases/tag/0.07a) | :tickets: [Installer](../../releases/download/0.07a/empires-setup_0.07a.exe) |
| alpha 0.06a   | Invasion Update       | July 11, 2020   | :label: [tag](../../releases/tag/0.06a) | :tickets: [Installer](../../releases/download/0.06a/empires-setup_0.06a.exe) |
| alpha 0.05a   | Multiplayer Update       | February 3, 2020   | :label: [tag](../../releases/tag/0.05a) | :tickets: [Installer](../../releases/download/0.05a/empires-setup_0.05.exe) |
| alpha 0.04a   | Combat Update            | November 14, 2019  | :label: [tag](../../releases/tag/0.04a) | :tickets: [Installer](../../releases/download/0.04a/empires-setup_0.04.exe) |
| alpha 0.03a   | Stability Update         | October 14, 2019   | :label: [tag](../../releases/tag/0.03a) | :tickets: [Installer](../../releases/download/0.03a/empires-setup_0.03.exe) |
| alpha 0.02a   | Campaign Update          | September 14, 2019 | :label: [tag](../../releases/tag/0.02a) | :ticket: [Launcher](../../releases/download/0.02a/raise_the_empires_0.02a.zip) |
| pre-alpha 0.01a   | The Empires Strikes Back | July 21, 2019      | :label: [tag](../../releases/tag/0.01a) | :ticket: [Launcher](../../releases/download/0.01a/RaiseTheEmpires-prealpa_0.01a.zip) |

| :exclamation: For *0.07a* and older versions, check the [Flash Continuation](FLASH.md) documentation |
| :---: |

## Playing in a modern browser

`/ruffle.html` loads the original client through [Ruffle](https://ruffle.rs), so you
can inspect the game UI and its assets without installing the Adobe Flash Player.

**It is not fully playable there yet.** The client talks to the server over AMF
remoting through `flash.net.NetConnection.connect()`, and Ruffle rejects the
scheme-less URL the client builds (`flashservices/gateway.php`), so every server
call fails with `Error #2126: NetConnection object must be connected`. The UI
loads and the ExternalInterface bridge works; the game cannot talk to the
backend.

For actual gameplay use `/nodebug.html` with real Flash — see
[FLASH.md](FLASH.md).

Ruffle is loaded from a **version-pinned URL with a Subresource Integrity hash**.
Please keep it that way: this game is archived, so an unpinned CDN tag could
break it with no way to roll back. To move the version, read the new integrity
from `https://unpkg.com/@ruffle-rs/ruffle@<version>/?meta`.

## Reporting Bugs and Contacting
:speech_balloon: Check our [Discord group](https://discord.gg/xrNE6Hg)  [![Discord Channel](https://img.shields.io/discord/536575691563466772?label=)](https://discord.gg/xrNE6Hg)

:paw_prints: The project [Contributors](../../contributors)

## Tools
:compass: [Empires & Allies Modding Support](mods#readme)

:iphone: [Empires & Allies Android(Termux) ~ GNU/Linux ~ macOS](https://github.com/Questandachievement7Developer/RaiseTheEmpiresPort_Native#readme)

:minidisc: [Empires & Allies Servers Support](SERVERS.md)

:classical_building: [Emipres & Allies Revision History](https://github.com/AcidCaos/empires-revision-history#readme)

:world_map: [Empires & Allies Empire Map Editor](https://github.com/AcidCaos/ea-empire-editor#readme)

## External Links
:beginner: [Empires & Allies Wiki (FANDOM)](https://empiresandallies.fandom.com/wiki/Empires_%26_Allies_Wiki/Main_2)

:clapper: [Empires & Allies Trailer](https://www.youtube.com/watch?v=pAdlyz9miqo)

:smiley_cat: [Empires & Allies subreddit](https://reddit.com/r/EmpiresAndAllies)

## On archives and accessibility to digital heritage
- [Exemption to PCCPSACT](https://www.federalregister.gov/documents/2018/10/26/2018-23241/exemption-to-prohibition-on-circumvention-of-copyright-protection-systems-for-access-control), exemptions to the provision of the Digital Millennium Copyright Act (“DMCA”). 
- [EFGAMP](https://efgamp.eu/), the European Federation of Video Game Archives, Museums and Preservation projects.
- [UNESCO PERSIST Programme](https://unescopersist.org/), helps ensure that digital information can continue to be accessed in the future.
- [The Internet Archive](https://archive.org/), a digital library of Internet sites and other cultural artifacts in digital form.
- [BlueMaxima's Flashpoint](https://bluemaxima.org/flashpoint/), the webgame preservation project.
- [Adobe Flash Player Archive](https://archive.org/download/flashplayerarchive/), the Adobe Inc. archive.org Flash Player Archive.

---

## License [![GPL v3](https://img.shields.io/badge/GPL%20v3-blue)](http://www.gnu.org/licenses/gpl-3.0)
```
Old Empires and Allies preservation project.
Copyright (C) 2019  The Raise the Empires team

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```
### Related
```
Chromium 82.0, Copyright 2020-2021 The Chromium Authors. All rights reserved.
Chromium is made possible by the Chromium open source project and other open source software.
```

```
Adobe Flash Player License Terms <http://aka.ms/adobeflash/>.
```