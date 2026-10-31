from __future__ import annotations

import json
from pathlib import Path
from typing import Any

import mod_engine
from language_settings import language_strings
from save_engine import my_games_path


def read_quest_settings() -> dict[str, Any]:
    return json.loads(Path(quest_settings_path).read_text(encoding="utf-8"))


def simple_list(raw_list: Any) -> list[Any]:
    return (raw_list if isinstance(raw_list, list) else [raw_list]) if raw_list != '' else []

print("Loading Quest settings")
quest_settings_path = str(Path(my_games_path()) / "questsettings-converted.json")
quest_settings = json.loads(mod_engine.mod.get(quest_settings_path)()) if quest_settings_path in mod_engine.mod else read_quest_settings()
print("Loading sequels")
sequels: dict[str, list[str]] = { q["_name"]:[t["_name"] for s in simple_list(q["sequels"]) for t in simple_list(s["sequel"])] for q in quest_settings['quests']['quest']}
print("Loading prequels")

prequels: dict[str, list[str]] = {}
for k , seq in sequels.items():
    for v in seq:
        prequels[v] = prequels.get(v, []) + [k]


print("Loading debut quests")
debut_quests: dict[str, list[str]] = {g: [] for g in sequels if g not in prequels}

prequels.update(debut_quests)
print("Loading translations")

lang_strings = language_strings()
quest_titles: dict[str, str] = {q["_name"]: lang_strings.get(q["_title"].split(":")[-1], "No title") for q in quest_settings['quests']['quest']}

print("Questsettings loaded: ",  len(quest_settings['quests']['quest']), " quests loaded")
