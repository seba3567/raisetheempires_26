"""El fichero de traduccion tiene que ser un XML que se pueda parsear.

Por que este test existe
-------------------------
``assets/zh_CN.xml`` tiene 77 ampersands sin escapar. Un ``&`` suelto es un
error de sintaxis de XML, no un caracter raro: el fichero entero era
ilegible, asi que el cliente que lo pidiera se comia un error de parseo en
lugar de una traduccion.

El fichero lleva mucho tiempo en el repositorio sin que nadie lo abriera, y
eso es justo lo que hacia que pasara: un fichero de 1,7 MB que solo falla
si alguien lo parsea. Este test lo parsea.

Que se comprueba
----------------
* que el fichero se puede parsear;
* que el atributo ``locale`` sigue siendo ``zh_CN``;
* que las cadenas estan donde el cliente las busca: ``<string key=...>`` con
  el texto en ``<original>``;
* que las claves coinciden con las del ingles, para que una clave que se
  cambio en un idioma no se quede colgando en el otro.
"""

from __future__ import annotations

import xml.etree.ElementTree as ET
from pathlib import Path

import pytest

from conftest import asset_status

ASSETS = Path(__file__).resolve().parent.parent / "assets"
ZH_CN = ASSETS / "zh_CN.xml"
EN_US = ASSETS / "29oct2012" / "en_US.xml"


def _strings_of(root) -> dict[str, str]:
    """Las cadenas del fichero, por clave.

    La forma es ``<pkg><string key=...><original>texto</original></string>``
    y el texto puede estar tambien en ``<variation>`` (las variantes de
    plural).
    """
    strings = {}
    for package in root:
        for entry in package:
            if entry.tag != "string":
                continue
            parts = [node.text or "" for node in entry
                     if node.tag == "original" and node.text]
            if not parts:
                parts = [node.text or "" for node in entry
                         if node.tag == "variation" and node.text]
            strings[entry.get("key")] = " ".join(parts).strip()
    return strings


@pytest.fixture(scope="module")
def zh_root():
    return ET.fromstring(ZH_CN.read_text(encoding="utf-8"))


@pytest.fixture(scope="module")
def en_root():
    return ET.fromstring(EN_US.read_text(encoding="utf-8"))


class TestTheChineseTranslationIsWellFormed:
    def test_it_parses(self, zh_root):
        assert zh_root.tag == "strings"

    def test_it_declares_its_own_locale(self, zh_root):
        assert zh_root.attrib.get("locale") == "zh_CN"

    def test_it_has_strings(self, zh_root):
        assert len(_strings_of(zh_root)) > 1000

    def test_no_ampersand_is_left_unescaped(self):
        """The exact defect that was there: a bare `&` in the text.

        ``&amp;`` is the escaped form and is fine. A bare one is not.
        """
        import re

        text = ZH_CN.read_text(encoding="utf-8")
        bare = re.findall(r"&(?!#?\w+;)", text)

        assert bare == [], f"ampersands sin escapar: {len(bare)}"


class TestTheKeysLineUpWithEnglish:
    def test_every_chinese_key_exists_in_english(self, zh_root, en_root):
        """A key that exists in one language and not the other is a string the
        client will ask for and not find."""
        zh_keys = set(_strings_of(zh_root))
        en_keys = set(_strings_of(en_root))

        orphans = zh_keys - en_keys

        assert not orphans, f"claves que el ingles no tiene: {sorted(orphans)[:10]}"

    def test_the_translation_covers_a_useful_part_of_the_game(self, zh_root, en_root):
        """A translation that is nearly empty is not a translation.

        The Chinese file has 39% of the English strings -- the game's own
        translation was never finished -- but of the ones it does have, the
        great majority are actually translated rather than left as English.
        """
        zh = _strings_of(zh_root)
        en = _strings_of(en_root)
        shared = set(zh) & set(en)

        translated = [key for key in shared
                      if zh[key] and zh[key] != en[key]]

        assert len(shared) > 5000, f"solo {len(shared)} claves compartidas"
        assert len(translated) > 0.8 * len(shared), (
            f"solo {len(translated)} de {len(shared)} cadenas compartidas estan traducidas"
        )


@pytest.fixture(scope="module")
def client(gateway_app):
    """The gateway app, for the asset routes. See test/conftest.py."""
    return gateway_app.test_client()


class TestTheGatewayServesIt:
    """El fichero no era solo ilegible: tampoco se servia.

    El cliente pide el idioma como ``<host><locale>.xml`` -- de ahi las rutas
    ``/en_US.xml`` y ``/127.0.0.1en_US.xml``. Sin una ruta para el chino, el
    fichero era un fichero: 1,7 MB de traduccion que nadie podia leer.
    """

    @pytest.mark.parametrize("path", ["/zh_CN.xml", "/127.0.0.1zh_CN.xml"])
    def test_the_file_is_served(self, client, path):
        assert asset_status(client, path) == 200

    def test_what_is_served_parses(self, client):
        """Un 200 con XML roto no sirve de nada: el cliente lo parsea entero."""
        response = client.get("/zh_CN.xml")
        try:
            root = ET.fromstring(response.get_data())
        finally:
            response.close()

        assert root.tag == "strings"
        assert root.attrib.get("locale") == "zh_CN"
        assert len(list(root.iter("string"))) > 1000
