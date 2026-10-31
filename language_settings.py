from __future__ import annotations

import xml.etree.ElementTree as ET
from pathlib import Path

from save_engine import install_path


def language_strings() -> dict[str, str | None]:
    xml_path = Path(install_path()) / "assets" / "29oct2012" / "en_US.xml"
    tree = ET.parse(xml_path)
    root = tree.getroot()
    return {text.attrib["key"]: text[0].text for pkg in root for text in pkg}
