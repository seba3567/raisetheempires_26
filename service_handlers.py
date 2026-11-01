from __future__ import annotations

import contextlib
import logging
import random
import time
from typing import Any

from fastapi_session import session

import contract
from empires_gateway.amf.handlers.economy import deposit_reward
from game_settings import get_zid, lookup_item_by_code
from save_engine import (
    ensure_fleets,
    execute_db,
    fetch_all_commanders,
    get_save_by_uid,
    get_saves,
    query_db_rows,
    store_session,
)

logger = logging.getLogger("service_handlers")


def _response(data: Any = None, metadata: dict[str, Any] | None = None) -> dict[str, Any]:
    """Helper estandar para generar la respuesta AMF esperada por el cliente Flash."""
    meta = {"newPVE": 0}
    if metadata:
        meta.update(metadata)
    return {
        "errorType": 0,
        "userId": 1,
        "metadata": meta,
        "data": [] if data is None else data,
    }


def _get_player() -> dict[str, Any] | None:
    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        user_info = user_obj.get("userInfo")
        if isinstance(user_info, dict):
            player = user_info.get("player")
            if isinstance(player, dict):
                return player
    return None


def _get_world() -> dict[str, Any] | None:
    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        user_info = user_obj.get("userInfo")
        if isinstance(user_info, dict):
            world = user_info.get("world")
            if isinstance(world, dict):
                return world
    return None


def _player_account_id() -> int | None:
    """La cuenta de web que hay detrás de esta sesión, o None.

    The gateway and the web share one PostgreSQL database. The web's `users`
    table carries the account id in its `zid` column -- the same number the
    game files a player under -- so the session's zid is what ties the two
    together. A session that never went through the front door (an anonymous
    game session, a direct request to the gateway) has no account here.
    """
    try:
        zid = get_zid()
    except Exception:
        return None
    if not zid:
        return None
    try:
        rows = query_db_rows("SELECT id FROM users WHERE zid = %s", (int(zid),))
    except (TypeError, ValueError):
        return None
    if not rows:
        return None
    try:
        return int(rows[0]["id"])
    except (KeyError, TypeError, ValueError):
        return None


def _real_clan(account_id: int | None) -> dict[str, Any] | None:
    """La alianza del jugador tal como la guardan las tablas, o None.

    The web owns the relational clan system -- `clans`, `clan_members` and
    `clan_messages`. The gateway used to keep a fiction of its own inside the
    player's save, with a hardcoded id and one made-up member, so the two
    sides never agreed on anything: a message posted in the game never
    reached the wall the web shows, and the alliance the web knew about was
    invisible to the game.

    `None` means the player is in no alliance on this side, and the caller
    falls back to the copy in the save.
    """
    if account_id is None:
        return None

    rows = query_db_rows(
        """
        SELECT c.id, c.name, c.crest, c.level, c.xp, c.health, c.max_health, c.slots
          FROM clans c
          JOIN clan_members cm ON cm.clan_id = c.id
         WHERE cm.user_id = %s
         LIMIT 1
        """,
        (account_id,),
    )
    if not rows:
        return None
    row = rows[0]

    members = query_db_rows(
        """
        SELECT u.zid, u.username, cm.role
          FROM clan_members cm
          JOIN users u ON u.id = cm.user_id
         WHERE cm.clan_id = %s
         ORDER BY cm.joined_at
        """,
        (row["id"],),
    )

    feed = query_db_rows(
        """
        SELECT u.zid, u.username, cm.message, cm.created_at
          FROM clan_messages cm
          JOIN users u ON u.id = cm.user_id
         WHERE cm.clan_id = %s
         ORDER BY cm.id
        """,
        (row["id"],),
    )

    return {
        "id": row["id"],
        "name": row["name"],
        "crest": row["crest"],
        "members": [
            {"uid": m["zid"], "role": m["role"], "name": m["username"]}
            for m in members
        ],
        "level": row["level"],
        "xp": row["xp"],
        "health": row["health"],
        "maxHealth": row["max_health"],
        "slots": row["slots"],
        "feed": [
            {
                "uid": f["zid"],
                "name": f["username"],
                "message": f["message"],
                "timestamp": (
                    int(f["created_at"].timestamp())
                    if hasattr(f["created_at"], "timestamp")
                    else int(time.time())
                ),
            }
            for f in feed
        ],
    }


def _sync_clan(real: dict[str, Any]) -> None:
    """Deja la copia de la sesión al día con el clan real.

    The session copy is what the game draws, so after a change it has to show
    the new value rather than the one the session still remembers.
    """
    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        user_obj["clansInfo"] = real


def _deposit_reward(item_type: str, item_code: str, amount: int) -> None:
    """Deposita una recompensa en el inventario o recursos del jugador.

    The deposit itself moved to the economy handler: a reward going in is not
    a service, and the two halves of the ledger belong together. This name
    stays because every caller in this file already reads it.
    """
    deposit_reward(item_type, item_code, amount)


def _format_fleet_unit(code: str) -> str:
    return f"{code},,,,"


# ----------------------------------------------------------------------
# 1. Combates Avanzados, DeathMatch y Dominación
# ----------------------------------------------------------------------

def deathmatch_fetch_opponents(params: Any = None, *args: Any) -> dict[str, Any]:
    """Devuelve la lista de oponentes para DeathMatch basados en PostgreSQL, aliados y partidas."""
    commanders = fetch_all_commanders()
    opponents: list[dict[str, Any]] = []
    seen = set()

    for c in commanders:
        uid = c["uid"]
        seen.add(str(uid))
        opponents.append({
            "uid": uid,
            "zid": uid,
            "name": c["name"],
            "level": c["level"],
            "portrait": c.get("pic", "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png"),
            "rating": c["rating"],
            "score": c.get("score", 0),
            "wins": 5,
            "losses": 2,
        })

    # Complementar con partidas vivas registradas localmente
    saves = get_saves()
    for save_item in saves:
        try:
            save_data = save_item if isinstance(save_item, dict) else get_save_by_uid(save_item)
            if save_data and "user_object" in save_data:
                uinfo = save_data["user_object"].get("userInfo", {})
                p = uinfo.get("player", {})
                uid = p.get("uid") if isinstance(p, dict) else None
                if uid is None:
                    uid = save_item if not isinstance(save_item, dict) else None
                if uid is None or str(uid) in seen:
                    continue
                seen.add(str(uid))
                opponents.append({
                    "uid": uid,
                    "zid": uid,
                    "name": p.get("name") or uinfo.get("worldName") or f"Commander #{uid}",
                    "level": int(p.get("level", 10)),
                    "portrait": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png",
                    "rating": 1200 + int(p.get("level", 10)) * 25,
                    "score": int(p.get("xp", 0)),
                    "wins": 5,
                    "losses": 2,
                })
        except Exception as e:
            logger.debug("Failed to inspect save for deathmatch: %s", e)
            continue

    fallback_bots = [
        {"uid": "111", "zid": "111", "name": "AcidCaos Empire", "level": 15, "rating": 1575, "score": 2500, "portrait": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png", "wins": 5, "losses": 2},
        {"uid": "123", "zid": "123", "name": "Natalie's Fleet", "level": 12, "rating": 1500, "score": 1800, "portrait": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png", "wins": 4, "losses": 3},
        {"uid": "-1", "zid": "-1", "name": "Steele's Armada", "level": 25, "rating": 1825, "score": 3000, "portrait": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png", "wins": 10, "losses": 1},
    ]
    for bot in fallback_bots:
        if str(bot["uid"]) not in seen:
            opponents.append(bot)

    return _response(opponents)


def deathmatch_join_room(params: Any = None, *args: Any) -> dict[str, Any]:
    """Une al jugador a una sala DeathMatch y arranca el contador de la partida."""
    room_id = params[0].get("roomID", 1) if params and isinstance(params[0], dict) else 1
    session["deathmatch_room"] = {
        "roomId": room_id,
        "status": "active",
        "timer": 300,
        "frags": 0,
        "fragLimit": 10,
        "startedAt": int(time.time()),
    }
    return _response({
        "roomId": room_id,
        "status": "active",
        "timer": 300,
        "frags": 0,
        "fragLimit": 10,
    })


def deathmatch_load_battle(params: Any = None, *args: Any) -> dict[str, Any]:
    """Genera la flota enemiga de DeathMatch y la registra en el motor de combate."""
    opponent_id = params[0].get("enemyID", "111") if params and isinstance(params[0], dict) else "111"
    enemy_fleet_units = [
        _format_fleet_unit("U01"),
        _format_fleet_unit("U02"),
        _format_fleet_unit("PT24"),
        _format_fleet_unit("PT23"),
        _format_fleet_unit("PT02"),
    ]
    fleet = {
        "type": "infantry",
        "uid": str(opponent_id),
        "name": f"DeathMatch Opponent {opponent_id}",
        "status": 0,
        "target": "",
        "consumables": [],
        "inventory": [],
        "playerLevel": 12,
        "specialBits": None,
        "lost": None,
        "lastUnitLost": None,
        "lastIndexLost": None,
        "allies": None,
        "battleTarget": None,
        "battleTimestamp": int(time.time()),
        "units": enemy_fleet_units,
        "store": [0],
        "fleets": [],
        "upgrades": None,
        "hp": None,
        "invader": True,
    }

    fleets = ensure_fleets()
    fleets["FleetName"] = fleet

    return _response({
        "state": 0,
        "battle": {
            "challengerFleet": fleet,
            "challengeInfo": {"status": 0, "state": 1},
            "maxUnits": 5,
        },
    })


def deathmatch_process_reward_queue(params: Any = None, *args: Any) -> dict[str, Any]:
    """Cobra las recompensas acumuladas de frags en DeathMatch."""
    rewards = [
        {"type": "coins", "count": 2500},
        {"type": "xp", "count": 300},
        {"type": "item", "item": "EN5", "count": 1},
    ]
    for r in rewards:
        _deposit_reward(r["type"], r.get("item", r["type"]), r["count"])
    return _response(rewards)


def domination_get_opponents(params: Any = None, *args: Any) -> dict[str, Any]:
    """Lista de sectores / oponentes en el teatro de operaciones de Dominación."""
    opponents = [
        {"id": "zone_1", "name": "Sector Alpha", "influence": 45, "level": 10, "garrison": 5},
        {"id": "zone_2", "name": "Sector Bravo", "influence": 70, "level": 14, "garrison": 5},
        {"id": "zone_3", "name": "Sector Charlie", "influence": 20, "level": 18, "garrison": 5},
    ]
    return _response(opponents)


def domination_get_chat(params: Any = None, *args: Any) -> dict[str, Any]:
    """Devuelve los mensajes de chat del teatro de Dominación."""
    chat = session.setdefault("domination_chat", [
        {"sender": "General Steele", "message": "Prepare the coastal defenses!", "time": int(time.time()) - 3600},
        {"sender": "Natalie", "message": "Air wing standing by for support.", "time": int(time.time()) - 1800},
    ])
    return _response(chat)


def domination_add_chat(params: Any = None, *args: Any) -> dict[str, Any]:
    """Agrega un mensaje de chat de Dominación persistente en la sesión."""
    player = _get_player()
    name = player.get("name", "Commander") if player else "Commander"
    text = params[0].get("message", "") if params and isinstance(params[0], dict) else ""
    chat = session.setdefault("domination_chat", [])
    entry = {"sender": name, "message": text, "time": int(time.time())}
    chat.append(entry)
    if len(chat) > 50:
        session["domination_chat"] = chat[-50:]
    return _response(["success"])


def domination_load_battle(params: Any = None, *args: Any) -> dict[str, Any]:
    """Carga y registra el combate del sector de Dominación contra la guarnición enemiga."""
    sector_id = params[0].get("enemyID", "zone_1") if params and isinstance(params[0], dict) else "zone_1"
    enemy_fleet_units = [
        _format_fleet_unit("PT24"),
        _format_fleet_unit("PT22"),
        _format_fleet_unit("PT12"),
        _format_fleet_unit("U01"),
        _format_fleet_unit("U02"),
    ]
    fleet = {
        "type": "armor",
        "uid": str(sector_id),
        "name": f"Dominance Garrison {sector_id}",
        "status": 0,
        "target": "",
        "consumables": [],
        "inventory": [],
        "playerLevel": 15,
        "specialBits": None,
        "lost": None,
        "lastUnitLost": None,
        "lastIndexLost": None,
        "allies": None,
        "battleTarget": None,
        "battleTimestamp": int(time.time()),
        "units": enemy_fleet_units,
        "store": [0],
        "fleets": [],
        "upgrades": None,
        "hp": None,
        "invader": True,
    }

    fleets = ensure_fleets()
    fleets["FleetName"] = fleet

    return _response({
        "state": 0,
        "battle": {
            "challengerFleet": fleet,
            "challengeInfo": {"status": 0, "state": 1},
            "maxUnits": 5,
        },
    })


def domination_update_defense_force(params: Any = None, *args: Any) -> dict[str, Any]:
    """Actualiza la flota defensiva de Dominación del jugador."""
    if params and isinstance(params[0], dict):
        user_info = session.get("user_object", {}).setdefault("userInfo", {})
        user_info["dominanceDefaultFleets"] = params[0]
    return _response(["success"])


def quest_survival_mode_load(params: Any = None, *args: Any) -> dict[str, Any]:
    """Carga una oleada de supervivencia vinculada a quest."""
    fleet_units = [_format_fleet_unit("U01"), _format_fleet_unit("PT24"), _format_fleet_unit("PT23")]
    fleet = {
        "type": "infantry",
        "uid": "quest_survival",
        "name": "Quest Survival Wave",
        "status": 0,
        "units": fleet_units,
        "invader": True,
    }
    fleets = ensure_fleets()
    fleets["FleetName"] = fleet
    return _response({
        "state": 0,
        "storage": {"curWave": 1, "curSet": "set1", "rewards": {}},
        "enemyWaveFleet": fleet,
    })


# ----------------------------------------------------------------------
# 2. Minijuegos y Tiradas de Ruleta
# ----------------------------------------------------------------------

# Tablas de probabilidad y recompensas para el Bomber Run (MIG0)
CRATE_REWARDS = {
    "MCR0": ("xp", "xp", 150),
    "MCR1": ("resource", "coins", 1500),
    "MCR2": ("item", "EN5", 1),
    "MCR3": ("item", "UB14", 1),
    "MCR4": ("cash", "cash", 5),
}


def minigame_load_game(params: Any = None, *args: Any) -> dict[str, Any]:
    """Carga el estado del minijuego Bomber Run."""
    state = session.setdefault("minigame_bomber", {
        "fuel": 100,
        "tier": 1,
        "rewardsCollected": [],
    })
    crates = [
        {"id": "MCR0", "x": 120, "y": 200},
        {"id": "MCR1", "x": 260, "y": 180},
        {"id": "MCR2", "x": 400, "y": 220},
        {"id": "MCR3", "x": 540, "y": 190},
        {"id": "MCR4", "x": 680, "y": 210},
    ]
    return _response({
        "fuel": state["fuel"],
        "tier": state["tier"],
        "crates": crates,
        "rewards": state["rewardsCollected"],
    })


def minigame_drop_bomb(params: Any = None, *args: Any) -> dict[str, Any]:
    """Lanza una bomba, descuenta combustible, calcula impacto y otorga recompensa."""
    state = session.setdefault("minigame_bomber", {
        "fuel": 100,
        "tier": 1,
        "rewardsCollected": [],
    })

    if state["fuel"] < 10:
        return _response({"hit": False, "reason": "out_of_fuel", "fuel": state["fuel"], "tier": state["tier"]})

    state["fuel"] -= 10
    tier = state["tier"]

    # Selección probabilística del cajón impactado
    crate_choices = ["MCR0", "MCR1", "MCR2", "MCR3", "MCR4"]
    weights_by_tier = {
        1: [0.30, 0.25, 0.25, 0.15, 0.05],
        2: [0.25, 0.30, 0.25, 0.15, 0.05],
        3: [0.20, 0.35, 0.30, 0.10, 0.05],
        4: [0.15, 0.30, 0.30, 0.15, 0.10],
        5: [0.10, 0.25, 0.35, 0.20, 0.10],
    }
    weights = weights_by_tier.get(tier, [0.30, 0.25, 0.25, 0.15, 0.05])
    crate_hit = random.choices(crate_choices, weights=weights)[0]

    reward_type, reward_code, amount = CRATE_REWARDS[crate_hit]
    _deposit_reward(reward_type, reward_code, amount)

    reward_data = {"type": reward_type, "item": reward_code, "count": amount, "crate": crate_hit}
    state["rewardsCollected"].append(reward_data)

    next_tier = (tier % 5) + 1
    state["tier"] = next_tier

    return _response({
        "hit": True,
        "tier": next_tier,
        "fuel": state["fuel"],
        "reward": reward_data,
    })


def minigame_buy_fuel(params: Any = None, *args: Any) -> dict[str, Any]:
    """Recarga 100 de combustible para el minijuego por 5 Empire Points."""
    player = _get_player()
    if player:
        cash = int(player.get("cash", 0))
        if cash >= 5:
            player["cash"] = cash - 5
            state = session.setdefault("minigame_bomber", {"fuel": 0, "tier": 1, "rewardsCollected": []})
            state["fuel"] = min(200, state.get("fuel", 0) + 100)
            return _response({"fuel": state["fuel"], "cash": player["cash"]})
    return _response({"fuel": session.get("minigame_bomber", {}).get("fuel", 0)})


def minigame_stop(params: Any = None, *args: Any) -> dict[str, Any]:
    """Finaliza la partida actual del minijuego y reinicia el tier."""
    state = session.setdefault("minigame_bomber", {"fuel": 100, "tier": 1, "rewardsCollected": []})
    collected = state.get("rewardsCollected", [])
    state["tier"] = 1
    state["rewardsCollected"] = []
    return _response({"status": "stopped", "totalRewards": len(collected)})


def user_treasure_vault_spin(params: Any = None, *args: Any) -> dict[str, Any]:
    """Tirada en el Treasure Vault: consume llaves TVK o cash según el tier y otorga premios."""
    player = _get_player()
    tier = params[0].get("tier", 1) if params and isinstance(params[0], dict) else 1
    tier = max(1, min(4, tier))

    tier_costs = {1: (1, 2), 2: (5, 12), 3: (15, 18), 4: (30, 24)}
    keys_needed, cash_needed = tier_costs[tier]

    if player:
        inv = player.setdefault("inventory", {}).setdefault("items", {})
        keys = int(inv.get("TVK", 0))
        cash = int(player.get("cash", 0))

        if keys >= keys_needed:
            inv["TVK"] = keys - keys_needed
        elif cash >= cash_needed:
            player["cash"] = cash - cash_needed
        else:
            return _response({"success": False, "reason": "cannot_afford"})

    # Premios por tier
    vault_prizes = {
        1: [("item", "EN4", 2), ("resource", "coins", 5000), ("item", "BuildingPart48", 2)],
        2: [("item", "EN5", 3), ("resource", "oil", 4000), ("item", "PT24", 1)],
        3: [("item", "EN6", 5), ("cash", "cash", 10), ("item", "UB67", 1)],
        4: [("cash", "cash", 25), ("item", "SF_BatRay_01", 1), ("item", "Gold Villain Sea 05", 1)],
    }
    prize = random.choice(vault_prizes[tier])
    _deposit_reward(prize[0], prize[1], prize[2])

    return _response({
        "tier": tier,
        "reward": {"type": prize[0], "item": prize[1], "count": prize[2]},
    })


def user_bookmarks_daily_spin(params: Any = None, *args: Any) -> dict[str, Any]:
    """Tirada diaria de la ruleta de marcadores."""
    player = _get_player()
    wheel_slices = [
        ("resource", "coins", 10000),
        ("resource", "oil", 2500),
        ("xp", "xp", 500),
        ("item", "EN4", 1),
        ("item", "xk01", 2),
        ("item", "BuildingPart48", 3),
        ("cash", "cash", 5),
        ("item", "PT24", 1),
    ]
    slice_idx = random.randint(0, len(wheel_slices) - 1)
    prize = wheel_slices[slice_idx]
    _deposit_reward(prize[0], prize[1], prize[2])

    if player:
        player["lastDailySpinTS"] = int(time.time())

    return _response({
        "slice": slice_idx,
        "reward": {"type": prize[0], "item": prize[1], "count": prize[2]},
    })


# 15 items oficiales de slotMachineFeatured de gameSettings
SLOT_FEATURED_ITEMS = [
    ("item", "ship20", 1),
    ("item", "LE_Light_Artillery_Vehicle_Red", 1),
    ("item", "ship19", 1),
    ("item", "LE_SikX2", 1),
    ("item", "energy06", 5),
    ("item", "BuildingPart48", 5),
    ("item", "expansionkey01", 5),
    ("resource", "coins", 20000),
    ("resource", "oil", 5000),
    ("item", "consumable36", 1),
    ("resource", "wood", 5000),
    ("item", "LE_Fokker", 1),
    ("item", "consumable37", 1),
    ("item", "SF_BatRay_01", 1),
    ("item", "Gold Villain Sea 05", 1),
]


def pvp_slot_machine_spin(params: Any = None, *args: Any) -> dict[str, Any]:
    """Tirada regular en la tragamonedas PvP."""
    r1 = random.randint(0, len(SLOT_FEATURED_ITEMS) - 1)
    r2 = random.randint(0, len(SLOT_FEATURED_ITEMS) - 1)
    r3 = random.randint(0, len(SLOT_FEATURED_ITEMS) - 1)

    jackpot = (r1 == r2 == r3)
    partial = (r1 in (r2, r3) or r2 == r3)

    if jackpot:
        prize_item = SLOT_FEATURED_ITEMS[r1]
        amount = prize_item[2] * 3
        _deposit_reward(prize_item[0], prize_item[1], amount)
        reward_info = {"type": prize_item[0], "item": prize_item[1], "count": amount}
    elif partial:
        match_idx = r1 if r1 in (r2, r3) else r2
        prize_item = SLOT_FEATURED_ITEMS[match_idx]
        _deposit_reward(prize_item[0], prize_item[1], prize_item[2])
        reward_info = {"type": prize_item[0], "item": prize_item[1], "count": prize_item[2]}
    else:
        _deposit_reward("resource", "coins", 1000)
        reward_info = {"type": "coins", "item": "coins", "count": 1000}

    return _response({
        "roll": [r1, r2, r3],
        "win": partial or jackpot,
        "jackpot": jackpot,
        "reward": reward_info,
    })


def pvp_slot_machine_spin_buy(params: Any = None, *args: Any) -> dict[str, Any]:
    """Tirada comprada con 2 Empire Points en la tragamonedas PvP."""
    player = _get_player()
    if player:
        cash = int(player.get("cash", 0))
        if cash >= 2:
            player["cash"] = cash - 2
        else:
            return _response({"success": False, "reason": "cannot_afford"})

    return pvp_slot_machine_spin(params, *args)


# ----------------------------------------------------------------------
# 3. Operaciones de Jugador y Economía
# ----------------------------------------------------------------------

def user_buy_full_heal(params: Any = None, *args: Any) -> dict[str, Any]:
    """Restaura completamente la salud de las unidades del jugador."""
    fleets = ensure_fleets()
    for fleet in fleets.values():
        if isinstance(fleet, dict) and "units" in fleet:
            fleet["hp"] = 100

    # Si hay una batalla pausada o activa, restaurar a 100
    if "battle" in session and session["battle"] and isinstance(session["battle"][0], list):
        session["battle"] = ([100] * len(session["battle"][0]), session["battle"][1], session["battle"][2], session.get("battle", [None, None, None, None])[3])

    return _response(["success"])


def user_buy_back(params: Any = None, *args: Any) -> dict[str, Any]:
    """Recupera unidades perdidas en combate aplicando el factor buyBacks."""
    player = _get_player()
    last_lost = player.get("lastUnitLost") if player else None
    if not last_lost:
        last_lost = "PT24"

    # Recupera la unidad al inventario con descuento
    if player:
        cash = int(player.get("cash", 0))
        cost = 2  # Coste reducido de buyback
        if cash >= cost:
            player["cash"] = cash - cost
            inv = player.setdefault("inventory", {}).setdefault("items", {})
            inv[last_lost] = int(inv.get(last_lost, 0)) + 1
            player["lastUnitLost"] = None
            return _response({"success": True, "recoveredUnit": last_lost})

    return _response(["success"])


def user_buy_unlimited_energy(params: Any = None, *args: Any) -> dict[str, Any]:
    """Compra 24 horas de energía ilimitada por 10 Empire Points."""
    player = _get_player()
    if player:
        cash = int(player.get("cash", 0))
        if cash >= 10:
            player["cash"] = cash - 10
            player["unlimitedEnergyEndTime"] = int(time.time()) + 86400
            player["energy"] = int(player.get("energyMax", 25))
            return _response({"success": True, "unlimitedUntil": player["unlimitedEnergyEndTime"]})
    return _response(["success"])


def user_purchase_ammo_refill(params: Any = None, *args: Any) -> dict[str, Any]:
    """Rellena la munición al máximo por 5 Empire Points."""
    player = _get_player()
    if player:
        cash = int(player.get("cash", 0))
        if cash >= 5:
            player["cash"] = cash - 5
            player["ammo"] = int(player.get("ammoMax", 50))
    return _response(["success"])


def user_purchase_mana_refill(params: Any = None, *args: Any) -> dict[str, Any]:
    """Rellena el mana de mando al máximo por 5 Empire Points."""
    player = _get_player()
    if player:
        cash = int(player.get("cash", 0))
        if cash >= 5:
            player["cash"] = cash - 5
            mana_max = int(player.get("manaMax", 100))
            if isinstance(player.get("mana"), dict):
                player["mana"]["value"] = mana_max
            else:
                player["mana"] = int(player.get("manaMax", 50))
    return _response(["success"])


def user_purchase_unlock(params: Any = None, *args: Any) -> dict[str, Any]:
    """Desbloquea una unidad o función bloqueada por nivel."""
    player = _get_player()
    if player and params and isinstance(params[0], dict):
        code = params[0].get("code") or params[0].get("unitCode")
        if code:
            unlocked = player.setdefault("unlockedUnits", [])
            if code not in unlocked:
                unlocked.append(code)
    return _response(["success"])


def user_buy_motd_item(params: Any = None, *args: Any) -> dict[str, Any]:
    """Compra un artículo especial presentado en el MOTD."""
    player = _get_player()
    if player and params and isinstance(params[0], dict):
        item_code = params[0].get("itemCode") or params[0].get("code")
        if item_code:
            inv = player.setdefault("inventory", {}).setdefault("items", {})
            inv[item_code] = int(inv.get(item_code, 0)) + 1
    return _response(["success"])


def user_buy_reward_item(params: Any = None, *args: Any) -> dict[str, Any]:
    """Compra directamente un objeto de recompensa."""
    player = _get_player()
    if player and params and isinstance(params[0], dict):
        item_code = params[0].get("itemCode") or params[0].get("code")
        if item_code:
            inv = player.setdefault("inventory", {}).setdefault("items", {})
            inv[item_code] = int(inv.get(item_code, 0)) + 1
    return _response(["success"])


def user_buy_quest_restart_task(params: Any = None, *args: Any) -> dict[str, Any]:
    """Reinicia una tarea de misión fallida."""
    return _response(["success"])


def user_quest_tree_start_quest(params: Any = None, *args: Any) -> dict[str, Any]:
    """Inicia una rama del árbol de misiones tecnológicas."""
    return _response({"status": "active"})


def user_quest_tree_unlock_quest(params: Any = None, *args: Any) -> dict[str, Any]:
    """Desbloquea una misión en el árbol de misiones."""
    player = _get_player()
    if player and params and isinstance(params[0], dict):
        q_name = params[0].get("quest") or params[0].get("name")
        if q_name:
            unlocks = player.setdefault("questTreeUnlocks", [])
            if q_name not in unlocks:
                unlocks.append(q_name)
    return _response(["success"])


def user_quest_tree_reset(params: Any = None, *args: Any) -> dict[str, Any]:
    """Reinicia la progresión del árbol de misiones."""
    player = _get_player()
    if player:
        player["questTreeUnlocks"] = []
    return _response(["success"])


def user_quest_tree_set_mode(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response(["success"])


def user_do_fav_quest(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player and params and isinstance(params[0], dict):
        player["favQuest"] = params[0].get("quest") or params[0].get("name")
    return _response(["success"])


def user_super_ore_order(params: Any = None, *args: Any) -> dict[str, Any]:
    """Procesa un pedido de superminerales (aluminio, cobre, hierro) con monedas."""
    world = _get_world()
    if world:
        res = world.setdefault("resources", {})
        coins = int(res.get("coins", 0))
        if coins >= 5000:
            res["coins"] = coins - 5000
            res["aluminum"] = int(res.get("aluminum", 0)) + 1000
            res["copper"] = int(res.get("copper", 0)) + 500
            res["iron"] = int(res.get("iron", 0)) + 500
            return _response({"success": True, "resources": res})
    return _response(["success"])


def user_unlock_resource(params: Any = None, *args: Any) -> dict[str, Any]:
    """Desbloquea recursos avanzados (uranio, oro) en el mundo."""
    user_obj = session.get("user_object")
    player = _get_player()
    if isinstance(user_obj, dict) and params:
        resource = None
        if isinstance(params[0], dict):
            resource = params[0].get("resource") or params[0].get("code")
        elif isinstance(params[0], str):
            resource = params[0]

        if resource:
            unlocked = user_obj.get("unlockedResource")
            if isinstance(unlocked, list):
                if resource not in unlocked:
                    unlocked.append(resource)
            elif isinstance(unlocked, dict):
                unlocked[resource] = unlocked.get(resource, 1)
            else:
                user_obj["unlockedResource"] = {resource: 1}

            if isinstance(player, dict):
                p_unlocked = player.setdefault("unlockedResource", {})
                if isinstance(p_unlocked, dict):
                    p_unlocked[resource] = p_unlocked.get(resource, 1)
                elif isinstance(p_unlocked, list) and resource not in p_unlocked:
                    p_unlocked.append(resource)
    return _response(["success"])


def user_remove_expired_inventory(params: Any = None, *args: Any) -> dict[str, Any]:
    """Elimina del inventario artículos o potenciadores con fecha de caducidad superada."""
    player = _get_player()
    removed = []
    if player:
        inv_wrapper = player.get("inventory")
        if isinstance(inv_wrapper, dict):
            inv = inv_wrapper.get("items")
            if isinstance(inv, dict):
                for code in list(inv.keys()):
                    try:
                        item_data = lookup_item_by_code(code)
                    except (ValueError, KeyError):
                        continue
                    if item_data and item_data.get("-expireDuration"):
                        del inv[code]
                        removed.append(code)
    return _response(removed)


# ----------------------------------------------------------------------
# 4. Otros Servicios Base (Registrados para compatibilidad total)
# ----------------------------------------------------------------------

def clans_get_clan_info(params: Any = None, *args: Any) -> dict[str, Any]:
    """La alianza del jugador, tomada de las tablas cuando existe.

    The tables are the truth. The copy inside the save is what the session
    still remembers, and it is all there is when the player is in no alliance
    on this side at all.
    """
    account_id = _player_account_id()
    real = _real_clan(account_id)
    if real is not None:
        user_obj = session.get("user_object")
        if isinstance(user_obj, dict):
            user_obj["clansInfo"] = real
        return _response(real)

    user_obj = session.get("user_object", {})
    clan = user_obj.get("clansInfo") if isinstance(user_obj, dict) else None
    if not isinstance(clan, dict):
        clan = {
            "id": 1,
            "name": "Vanguard Alliance",
            "crest": "crest_01",
            "members": [{"uid": 1, "role": "leader", "name": "Commander"}],
            "level": 1,
            "xp": 0,
            "health": 100,
            "maxHealth": 100,
            "slots": 10,
        }
        if isinstance(user_obj, dict):
            user_obj["clansInfo"] = clan
    return _response(clan)


def clans_get_neighbor_clan_info(params: Any = None, *args: Any) -> dict[str, Any]:
    """La alianza de un vecino, tomada de las tablas cuando se puede.

    The tables know the neighbour's alliance too; the save is the fallback for
    a player who never belonged to one on this side.
    """
    neighbor_uid = None
    if params:
        neighbor_uid = params[0].get("uid") or params[0].get("zid") if isinstance(params[0], dict) else params[0]
    if neighbor_uid:
        try:
            rows = query_db_rows(
                """
                SELECT c.id, c.name, c.crest, c.level, c.xp, c.health, c.max_health, c.slots
                  FROM clans c
                  JOIN clan_members cm ON cm.clan_id = c.id
                  JOIN users u ON u.id = cm.user_id
                 WHERE u.zid = %s
                 LIMIT 1
                """,
                (int(neighbor_uid),),
            )
        except (TypeError, ValueError):
            rows = []
        if rows:
            row = rows[0]
            return _response({
                "id": row["id"],
                "name": row["name"],
                "crest": row["crest"],
                "members": [],
                "level": row["level"],
                "xp": row["xp"],
                "health": row["health"],
                "maxHealth": row["max_health"],
                "slots": row["slots"],
            })
        save = get_save_by_uid(neighbor_uid)
        if save and "user_object" in save:
            clan = save["user_object"].get("clansInfo")
            if isinstance(clan, dict):
                return _response(clan)
    return _response({"id": 0, "name": "", "members": []})


def clans_create_clan(params: Any = None, *args: Any) -> dict[str, Any]:
    """Crea la alianza en las tablas y devuelve el clan real.

    The clan and the leader's membership are one statement, so a clan without
    a leader cannot exist. A player who already belongs to an alliance keeps
    it instead of getting a second one.

    The shield is checked against the list in the runtime contract, which is
    the same list the web front door uses. It used to be taken as it came: an
    alliance created inside the game could carry a shield the page had never
    heard of.
    """
    defaults = contract.CLAN_DEFAULTS
    name = params[0].get("name", "New Alliance") if params and isinstance(params[0], dict) else "New Alliance"
    crest = params[0].get("crest", contract.CLAN_DEFAULT_CREST) if params and isinstance(params[0], dict) else contract.CLAN_DEFAULT_CREST
    name = str(name).strip() or "New Alliance"
    crest = str(crest)
    if crest not in contract.CLAN_CRESTS:
        crest = contract.CLAN_DEFAULT_CREST

    account_id = _player_account_id()
    if account_id is not None:
        existing = query_db_rows(
            "SELECT clan_id FROM clan_members WHERE user_id = %s", (account_id,)
        )
        if not existing:
            execute_db(
                """
                WITH new_clan AS (
                    INSERT INTO clans (name, crest, level, xp, health, max_health, slots, leader_id, created_at, updated_at)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                    RETURNING id
                )
                INSERT INTO clan_members (clan_id, user_id, role, joined_at)
                SELECT id, %s, 'leader', CURRENT_TIMESTAMP FROM new_clan
                """,
                (
                    name,
                    crest,
                    defaults["level"],
                    defaults["xp"],
                    defaults["health"],
                    defaults["maxHealth"],
                    defaults["slots"],
                    account_id,
                    account_id,
                ),
            )
        real = _real_clan(account_id)
        if real is not None:
            user_obj = session.setdefault("user_object", {})
            if isinstance(user_obj, dict):
                user_obj["clansInfo"] = real
            return _response(real)

    clan = {
        "id": 1,
        "name": name,
        "crest": crest,
        "members": [{"uid": 1, "role": "leader", "name": "Commander"}],
        "level": defaults["level"],
        "xp": defaults["xp"],
        "health": defaults["health"],
        "maxHealth": defaults["maxHealth"],
        "slots": defaults["slots"],
    }
    user_obj = session.setdefault("user_object", {})
    if isinstance(user_obj, dict):
        user_obj["clansInfo"] = clan
    return _response(clan)


def clans_update_name(params: Any = None, *args: Any) -> dict[str, Any]:
    """Renombra la alianza, en las tablas y en la copia de la sesión."""
    name = params[0].get("name") if params and isinstance(params[0], dict) else None
    if not name:
        return _response(["success"])
    name = str(name).strip()

    account_id = _player_account_id()
    real = _real_clan(account_id)
    if real is not None:
        execute_db(
            "UPDATE clans SET name = %s, updated_at = CURRENT_TIMESTAMP WHERE id = %s",
            (name, real["id"]),
        )
        real["name"] = name
        _sync_clan(real)
        return _response(["success"])

    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        clan = user_obj.get("clansInfo")
        if isinstance(clan, dict):
            clan["name"] = name
    return _response(["success"])


def clans_update_crest(params: Any = None, *args: Any) -> dict[str, Any]:
    """Cambia el escudo de la alianza, en las tablas y en la copia de la sesión."""
    crest = params[0].get("crest") if params and isinstance(params[0], dict) else None
    if not crest:
        return _response(["success"])
    crest = str(crest)

    account_id = _player_account_id()
    real = _real_clan(account_id)
    if real is not None:
        execute_db(
            "UPDATE clans SET crest = %s, updated_at = CURRENT_TIMESTAMP WHERE id = %s",
            (crest, real["id"]),
        )
        real["crest"] = crest
        _sync_clan(real)
        return _response(["success"])

    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        clan = user_obj.get("clansInfo")
        if isinstance(clan, dict):
            clan["crest"] = crest
    return _response(["success"])


def clans_buy_crest(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player:
        cash = int(player.get("cash", 0))
        if cash >= 5:
            player["cash"] = cash - 5
    return clans_update_crest(params, *args)


def clans_buy_health(params: Any = None, *args: Any) -> dict[str, Any]:
    """Cura la alianza al máximo, en las tablas y en la copia de la sesión."""
    account_id = _player_account_id()
    real = _real_clan(account_id)
    if real is not None:
        execute_db(
            "UPDATE clans SET health = max_health, updated_at = CURRENT_TIMESTAMP WHERE id = %s",
            (real["id"],),
        )
        real["health"] = real["maxHealth"]
        _sync_clan(real)
        return _response(["success"])

    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        clan = user_obj.get("clansInfo")
        if isinstance(clan, dict):
            clan["health"] = clan.get("maxHealth", 100)
    return _response(["success"])


def clans_buy_slots(params: Any = None, *args: Any) -> dict[str, Any]:
    """Compra cinco plazas más, en las tablas y en la copia de la sesión."""
    account_id = _player_account_id()
    real = _real_clan(account_id)
    if real is not None:
        execute_db(
            "UPDATE clans SET slots = slots + 5, updated_at = CURRENT_TIMESTAMP WHERE id = %s",
            (real["id"],),
        )
        real["slots"] = real["slots"] + 5
        _sync_clan(real)
        return _response(["success"])

    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        clan = user_obj.get("clansInfo")
        if isinstance(clan, dict):
            clan["slots"] = clan.get("slots", 10) + 5
    return _response(["success"])


def clans_add_taunt(params: Any = None, *args: Any) -> dict[str, Any]:
    taunt = params[0].get("taunt") or params[0].get("message") if params and isinstance(params[0], dict) else str(params[0] if params else "")
    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        clan = user_obj.get("clansInfo")
        if isinstance(clan, dict):
            taunts = clan.get("taunts")
            if not isinstance(taunts, list):
                taunts = []
                clan["taunts"] = taunts
            taunts.append({"text": str(taunt), "timestamp": int(time.time())})
    return _response(["success"])


def clans_update_taunt_view_time(params: Any = None, *args: Any) -> dict[str, Any]:
    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        clan = user_obj.get("clansInfo")
        if isinstance(clan, dict):
            clan["lastTauntViewTime"] = int(time.time())
    return _response(["success"])


def clans_accept_quest(params: Any = None, *args: Any) -> dict[str, Any]:
    quest_id = params[0].get("questId") or params[0].get("name") if params and isinstance(params[0], dict) else (params[0] if params else "clan_quest_1")
    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        clan = user_obj.get("clansInfo")
        if isinstance(clan, dict):
            clan["activeQuest"] = {"id": str(quest_id), "status": "active", "startedAt": int(time.time())}
    return _response({"status": "active", "questId": str(quest_id)})


def clans_complete_quest(params: Any = None, *args: Any) -> dict[str, Any]:
    account_id = _player_account_id()
    real = _real_clan(account_id)
    if real is not None:
        execute_db(
            "UPDATE clans SET xp = xp + 50, updated_at = CURRENT_TIMESTAMP WHERE id = %s",
            (real["id"],),
        )
        real["xp"] = int(real.get("xp", 0)) + 50
        _sync_clan(real)
    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        clan = user_obj.get("clansInfo")
        if isinstance(clan, dict):
            clan["xp"] = int(clan.get("xp", 0)) + 50
            clan["activeQuest"] = None
    _deposit_reward("resource", "coins", 1000)
    return _response({"status": "completed", "rewards": [{"type": "coins", "count": 1000}]})


def clans_clear_notifications(params: Any = None, *args: Any) -> dict[str, Any]:
    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        clan = user_obj.get("clansInfo")
        if isinstance(clan, dict):
            clan["notifications"] = []
    return _response(["success"])


def clans_remove_member(params: Any = None, *args: Any) -> dict[str, Any]:
    target_uid = None
    if params:
        target_uid = (
            params[0].get("uid") or params[0].get("zid") or params[0].get("memberUid")
            if isinstance(params[0], dict)
            else params[0]
        )
    account_id = _player_account_id()
    real = _real_clan(account_id)
    if real is not None and target_uid is not None:
        with contextlib.suppress(TypeError, ValueError):
            execute_db(
                """
                DELETE FROM clan_members
                 WHERE clan_id = %s
                   AND user_id = (SELECT id FROM users WHERE zid = %s LIMIT 1)
                   AND role != 'leader'
                """,
                (real["id"], int(target_uid)),
            )
    user_obj = session.get("user_object")
    if isinstance(user_obj, dict) and target_uid is not None:
        clan = user_obj.get("clansInfo")
        if isinstance(clan, dict) and isinstance(clan.get("members"), list):
            clan["members"] = [
                m for m in clan["members"]
                if not (isinstance(m, dict) and str(m.get("uid")) == str(target_uid) and m.get("role") != "leader")
            ]
    return _response(["success"])


def clans_process_member_queue(params: Any = None, *args: Any) -> dict[str, Any]:
    user_obj = session.get("user_object")
    accepted: list[dict[str, Any]] = []
    if isinstance(user_obj, dict):
        clan = user_obj.get("clansInfo")
        if isinstance(clan, dict):
            queue = clan.get("memberQueue")
            members = clan.get("members")
            if isinstance(queue, list):
                if not isinstance(members, list):
                    members = []
                    clan["members"] = members
                existing_uids = {str(m.get("uid")) for m in members if isinstance(m, dict)}
                for applicant in queue:
                    if isinstance(applicant, dict) and str(applicant.get("uid")) not in existing_uids:
                        entry = {
                            "uid": applicant.get("uid"),
                            "role": "member",
                            "name": applicant.get("name", "Commander"),
                        }
                        members.append(entry)
                        accepted.append(entry)
                clan["memberQueue"] = []
    return _response(accepted)


def clans_post_group_feed(params: Any = None, *args: Any) -> dict[str, Any]:
    """Publica en el muro táctico de la alianza.

    The message goes into `clan_messages`, the same table the web's wall
    reads, so both clients show the same thing. It also lands in the copy
    inside the session, because that is what the game draws.
    """
    user_obj = session.get("user_object")
    if not isinstance(user_obj, dict):
        user_obj = {}
        session["user_object"] = user_obj
    player = _get_player() or {}
    world_name = "Commander"
    user_info = user_obj.get("userInfo")
    if isinstance(user_info, dict):
        world_name = user_info.get("worldName", "Commander")
    msg = params[0].get("message") if params and isinstance(params[0], dict) else str(params)
    entry = {
        "uid": player.get("uid", 1),
        "name": player.get("name") or world_name,
        "message": msg,
        "timestamp": int(time.time()),
    }

    account_id = _player_account_id()
    real = _real_clan(account_id)
    if real is not None and account_id is not None:
        execute_db(
            "INSERT INTO clan_messages (clan_id, user_id, message, created_at) "
            "VALUES (%s, %s, %s, CURRENT_TIMESTAMP)",
            (real["id"], account_id, str(msg)),
        )
        real["feed"].append(entry)
        _sync_clan(real)
        return _response(["success"])

    clan = user_obj.get("clansInfo")
    if not isinstance(clan, dict):
        clan = {
            "id": 1,
            "name": "Vanguard Alliance",
            "crest": "crest_01",
            "members": [{"uid": 1, "role": "leader", "name": "Commander"}],
            "level": 1,
            "xp": 0,
            "health": 100,
            "maxHealth": 100,
            "slots": 10,
        }
        user_obj["clansInfo"] = clan
    feed = clan.get("feed")
    if not isinstance(feed, list):
        feed = []
        clan["feed"] = feed
    feed.append(entry)
    return _response(["success"])


def clans_load_alliance_battle(params: Any = None, *args: Any) -> dict[str, Any]:
    fleets = ensure_fleets()
    fleet = {
        "type": "army",
        "uid": "alliance_boss",
        "name": "Alliance Boss Fleet",
        "status": 0,
        "target": "",
        "consumables": [],
        "inventory": [],
        "playerLevel": 15,
        "specialBits": None,
        "lost": None,
        "lastUnitLost": None,
        "lastIndexLost": None,
        "allies": None,
        "battleTarget": None,
        "battleTimestamp": int(time.time()),
        "units": ["U01,,,,", "U04,,,,", "V03,,,,", "V61,,,,", "AF12,,,,"],
        "store": [0],
        "fleets": [],
        "upgrades": None,
        "hp": None,
        "invader": True,
    }
    fleets["FleetName"] = fleet
    session["battle"] = None
    return _response({
        "battleId": 1,
        "state": 0,
        "challengerFleet": fleet,
        "opponents": [{"uid": -1, "name": "Steele's Armada", "level": 20}],
    })


def pvp_get_all_challenges(params: Any = None, *args: Any) -> dict[str, Any]:
    """Recupera los desafíos PvP entrantes y salientes registrados en PostgreSQL."""
    incoming = []
    outgoing = []
    try:
        sql = """
            SELECT a.id, a.kind, a.detail, a.created_at, u.username, u.zid
            FROM activity a
            JOIN users u ON u.id = a.user_id
            WHERE a.kind IN ('pvp.victory', 'pvp.defeat', 'pvp.defense_victory', 'pvp.defense_defeat')
            ORDER BY a.id DESC LIMIT 20
        """
        rows = query_db_rows(sql)
        for r in rows:
            ts = int(r["created_at"].timestamp()) if hasattr(r["created_at"], "timestamp") else int(time.time())
            item = {
                "id": f"chal_{r['id']}",
                "opponentUid": r["zid"],
                "opponentName": r["username"],
                "level": 10,
                "rating": 1200,
                "timestamp": ts,
                "status": "completed" if "victory" in r["kind"] or "defeat" in r["kind"] else "pending",
                "kind": r["kind"],
            }
            if "defense" in r["kind"]:
                incoming.append(item)
            else:
                outgoing.append(item)
    except Exception as e:
        logger.debug("Failed to read pvp challenges from DB: %s", e)

    return _response({"incoming": incoming, "outgoing": outgoing})


def pvp_get_fight_list(params: Any = None, *args: Any) -> dict[str, Any]:
    """Devuelve la lista de objetivos PvP disponibles (jugadores reales de PostgreSQL + aliados bot)."""
    commanders = fetch_all_commanders()
    user_obj = session.get("user_object", {})
    my_uid = str(user_obj.get("userInfo", {}).get("player", {}).get("uid", 1))

    fights = []
    seen = set()
    for c in commanders:
        if str(c["uid"]) == my_uid:
            continue
        seen.add(str(c["uid"]))
        fights.append({
            "uid": c["uid"],
            "zid": c["zid"],
            "name": c["name"],
            "first_name": c["first_name"],
            "level": c["level"],
            "rating": c["rating"],
            "pic": c["pic"],
            "pic_square": c["pic_square"],
            "score": c.get("score", 0),
            "wins": 5,
            "losses": 2,
            "pvpOptIn": True,
        })

    # Asegurar rivales bot complementarios si hay pocos jugadores
    fallback_bots = [
        {"uid": 111, "zid": 111, "name": "AcidCaos Empire", "first_name": "AcidCaos", "level": 15, "rating": 1575, "score": 2500, "wins": 8, "losses": 3, "pvpOptIn": True, "pic": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png", "pic_square": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png"},
        {"uid": 123, "zid": 123, "name": "Natalie's Fleet", "first_name": "Natalie", "level": 12, "rating": 1500, "score": 1800, "wins": 6, "losses": 4, "pvpOptIn": True, "pic": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png", "pic_square": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png"},
        {"uid": -1, "zid": -1, "name": "Steele's Armada", "first_name": "Steele", "level": 25, "rating": 1825, "score": 3000, "wins": 15, "losses": 1, "pvpOptIn": True, "pic": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png", "pic_square": "assets/game/GeneralAssetGroup_UI.swf/TheVille_50.png"},
    ]
    for bot in fallback_bots:
        if str(bot["uid"]) not in seen and str(bot["uid"]) != my_uid:
            fights.append(bot)

    now = int(time.time())
    payload = {
        "fightList": fights,
        "ts": now,
        "wins": 0,
        "awardClaimed": False,
        "info": [],
        "gpPrizeSet": {},
    }
    return _response(payload)


def pvp_global_opt_in_out(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player and params:
        if isinstance(params[0], dict):
            player["pvpOptIn"] = params[0].get("optIn", True)
        elif isinstance(params[0], bool):
            player["pvpOptIn"] = params[0]
    return _response(["success"])


def pvp_immunity_start(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = session.get("user_object", {}).setdefault("pvp", {})
    pvp["immunity"] = {"active": True, "endTime": 9999999999}
    return _response(["success"])


def pvp_immunity_extend(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = session.get("user_object", {}).setdefault("pvp", {})
    pvp["immunity"] = {"active": True, "endTime": 9999999999}
    return _response(["success"])


def _get_pvp_dict() -> dict[str, Any]:
    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        pvp = user_obj.get("pvp")
        if not isinstance(pvp, dict):
            pvp = {}
            user_obj["pvp"] = pvp
        return pvp
    return {}


def pvp_use_strike_team(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = _get_pvp_dict()
    pvp["lastStrikeTeamUsed"] = int(time.time())
    return _response(["success"])


def pvp_seen_strike_team_comment(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = _get_pvp_dict()
    pvp["strikeTeamCommentSeen"] = True
    return _response(["success"])


def pvp_set_strike_team_comment(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = _get_pvp_dict()
    comment = params[0].get("comment") if params and isinstance(params[0], dict) else (str(params[0]) if params else "")
    pvp["strikeTeamComment"] = str(comment)
    return _response(["success"])


def pvp_set_defender_comment(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = _get_pvp_dict()
    comment = params[0].get("comment") if params and isinstance(params[0], dict) else (str(params[0]) if params else "")
    pvp["defenderComment"] = str(comment)
    return _response(["success"])


def pvp_set_invasion_comment(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = _get_pvp_dict()
    comment = params[0].get("comment") if params and isinstance(params[0], dict) else (str(params[0]) if params else "")
    pvp["invasionComment"] = str(comment)
    return _response(["success"])


def pvp_set_espionage_hq_data(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = _get_pvp_dict()
    pvp["espionageHQ"] = params[0] if params and isinstance(params[0], dict) else {}
    return _response(["success"])


def pvp_seen_prison_camp_notification(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = _get_pvp_dict()
    pvp["prisonCampNotificationSeen"] = True
    return _response(["success"])


def pvp_revive_allies(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = _get_pvp_dict()
    pvp["revivedAlliesAt"] = int(time.time())
    return _response(["success"])


def pvp_accept_deco_buildable_repel(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = _get_pvp_dict()
    pvp["decoBuildableRepel"] = "accepted"
    return _response(["success"])


def pvp_reject_deco_buildable_repel(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = _get_pvp_dict()
    pvp["decoBuildableRepel"] = "rejected"
    return _response(["success"])


def pvp_accept_defense_tower_repel(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = _get_pvp_dict()
    pvp["defenseTowerRepel"] = "accepted"
    return _response(["success"])


def pvp_reject_defense_tower_repel(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = _get_pvp_dict()
    pvp["defenseTowerRepel"] = "rejected"
    return _response(["success"])


def pvp_complete_social_repel(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = _get_pvp_dict()
    pvp["lastSocialRepelAt"] = int(time.time())
    _deposit_reward("resource", "coins", 250)
    return _response(["success"])


def pvp_buy_crew_repel_position(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player:
        cash = int(player.get("cash", 0))
        if cash >= 5:
            player["cash"] = cash - 5
    pvp = _get_pvp_dict()
    pvp["crewRepelSlots"] = int(pvp.get("crewRepelSlots", 1)) + 1
    return _response(["success"])


def _gift_recipient_uid(value: Any) -> int | None:
    """The uid a gift is addressed to, or None if it is not one.

    The client sends the recipients as a list, and the entries in it are not
    always bare numbers: some arrive as objects carrying the uid. Converting
    one of those with ``int()`` raised, and the whole batch of gifts went
    with it. An addressee that is not a uid is skipped instead.
    """
    if isinstance(value, bool):
        return None
    if isinstance(value, int):
        return value
    if isinstance(value, str):
        try:
            return int(value)
        except ValueError:
            return None
    if isinstance(value, dict):
        for key in ("uid", "zid", "userId", "id"):
            candidate = value.get(key)
            if isinstance(candidate, bool):
                continue
            if isinstance(candidate, int):
                return candidate
            if isinstance(candidate, str):
                try:
                    return int(candidate)
                except ValueError:
                    continue
    return None


def request_gift(params: Any = None, *args: Any) -> dict[str, Any]:
    """Registra peticiones de regalos enviadas a vecinos y las entrega en su bandeja de entrada."""
    if params and isinstance(params, list):
        user_obj = session.get("user_object")
        if not isinstance(user_obj, dict):
            return _response(["success"])
        req_tracker = user_obj.get("requestTracker")
        if not isinstance(req_tracker, dict):
            req_tracker = {}
            user_obj["requestTracker"] = req_tracker
        tracker = req_tracker.get("giftRequestSent")
        if not isinstance(tracker, dict):
            tracker = {}
            req_tracker["giftRequestSent"] = tracker

        now = int(time.time())
        user_info = user_obj.get("userInfo") if isinstance(user_obj.get("userInfo"), dict) else {}
        p = user_info.get("player") if isinstance(user_info.get("player"), dict) else {}
        sender_uid = p.get("uid", 1)
        sender_name = user_info.get("worldName", "Commander")
        recipients = params[0] if isinstance(params[0], list) else [params[0]]
        gift_item = str(params[1]) if len(params) > 1 else "energy"
        for rec in recipients:
            tracker[str(rec)] = now
            recipient = _gift_recipient_uid(rec)
            if recipient is None:
                logger.warning("Gift request addressed to something that is not a uid: %r", rec)
                continue
            try:
                if isinstance(sender_uid, (int, str)):
                    execute_db(
                        """
                        INSERT INTO gifts (sender_id, receiver_id, gift_type, claimed, created_at)
                        SELECT s.id, r.id, %s, FALSE, CURRENT_TIMESTAMP
                          FROM users s, users r
                         WHERE s.zid = %s AND r.zid = %s
                        """,
                        (gift_item[:32], int(sender_uid), int(recipient)),
                    )
                rec_save = get_save_by_uid(recipient)
                if rec_save and isinstance(rec_save.get("user_object"), dict):
                    rec_user_obj = rec_save["user_object"]
                    inbox = rec_user_obj.get("activeGiftRequests")
                    if not isinstance(inbox, list):
                        inbox = []
                        rec_user_obj["activeGiftRequests"] = inbox
                    inbox.append({
                        "id": f"gift_{sender_uid}_{now}_{rec}",
                        "sender": sender_uid,
                        "senderName": sender_name,
                        "item": gift_item,
                        "type": "gift",
                        "timestamp": now,
                    })
                    store_session(rec_save)
            except Exception as e:
                logger.warning("No se pudo entregar regalo a %s: %s", rec, e)
    return _response(["success"])


def _record_social_request(kind: str, params: Any) -> list[int]:
    user_obj = session.get("user_object")
    if not isinstance(user_obj, dict):
        return []
    req_tracker = user_obj.get("requestTracker")
    if not isinstance(req_tracker, dict):
        req_tracker = {}
        user_obj["requestTracker"] = req_tracker
    bucket = req_tracker.get(kind)
    if not isinstance(bucket, dict):
        bucket = {}
        req_tracker[kind] = bucket
    now = int(time.time())
    recipients = params[0] if params and isinstance(params[0], list) else ([params[0]] if params else [])
    resolved: list[int] = []
    for rec in recipients:
        bucket[str(rec)] = now
        uid = _gift_recipient_uid(rec)
        if uid is not None:
            resolved.append(uid)
    return resolved


def request_neighbor(params: Any = None, *args: Any) -> dict[str, Any]:
    """Pide amistad a un vecino, respetando las mismas reglas que la pagina.

    The web front door refuses a request between two players when either one
    has the other blocked. This did not: the row went in, so a player who had
    been blocked could still send them a request from inside the game -- the
    same action, two doors, one rule on one of them.
    """
    targets = _record_social_request("neighborRequestSent", params)
    account_id = _player_account_id()
    if account_id is not None:
        for target_zid in targets:
            execute_db(
                """
                INSERT INTO friendships (user_id, friend_id, status, requested_by, created_at)
                SELECT %s, u.id, 'pending', %s, CURRENT_TIMESTAMP
                  FROM users u
                 WHERE u.zid = %s AND u.id != %s
                   AND NOT EXISTS (
                       SELECT 1 FROM friendships f
                        WHERE f.status = 'blocked'
                          AND ((f.user_id = %s AND f.friend_id = u.id)
                            OR (f.user_id = u.id AND f.friend_id = %s))
                       )
                ON CONFLICT DO NOTHING
                """,
                (account_id, account_id, target_zid, account_id, account_id, account_id),
            )
    return _response(["success"])


def request_invasion_help(params: Any = None, *args: Any) -> dict[str, Any]:
    _record_social_request("invasionHelpRequestSent", params)
    return _response(["success"])


def request_alliance_invite(params: Any = None, *args: Any) -> dict[str, Any]:
    _record_social_request("allianceInviteSent", params)
    return _response(["success"])


def request_alliance_join(params: Any = None, *args: Any) -> dict[str, Any]:
    _record_social_request("allianceJoinSent", params)
    return _response(["success"])


def mfs_collect_reward(params: Any = None, *args: Any) -> dict[str, Any]:
    _deposit_reward("resource", "coins", 250)
    player = _get_player()
    if player:
        player["lastMFSRewardAt"] = int(time.time())
    return _response(["success"])


def visitor_helped_invalid(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response(["success"])


def blackmarket_trade_for_part(params: Any = None, *args: Any) -> dict[str, Any]:
    part_code = "B01"
    if params:
        if isinstance(params[0], dict):
            part_code = str(params[0].get("part") or params[0].get("code") or params[0].get("itemCode") or "B01")
        elif isinstance(params[0], str) and params[0]:
            part_code = params[0]
    _deposit_reward("item", part_code, 1)
    return _response(["success"])


def user_set_titan_name(params: Any = None, *args: Any) -> dict[str, Any]:
    name = params[0].get("titanName") if params and isinstance(params[0], dict) else "Titan"
    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        user_info = user_obj.get("userInfo")
        if not isinstance(user_info, dict):
            user_info = {}
            user_obj["userInfo"] = user_info
        user_info["titanName"] = name
    return _response(["success"])


def user_set_tag(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player and params and isinstance(params[0], dict):
        player["tag"] = params[0].get("tag", "")
    return _response(["success"])


def user_set_survival_mode_toaster(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player and params and isinstance(params[0], dict):
        player["survivalModeToaster"] = params[0].get("toaster", True)
    return _response(["success"])


def user_set_commando_animation_done(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player:
        seen = player.get("seenFlags")
        if not isinstance(seen, dict):
            seen = {}
            player["seenFlags"] = seen
        seen["commandoAnimDone"] = 1
    return _response(["success"])


def user_set_energiser_animation_done(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player:
        seen = player.get("seenFlags")
        if not isinstance(seen, dict):
            seen = {}
            player["seenFlags"] = seen
        seen["energizerAnimDone"] = 1
    return _response(["success"])


def user_energizer_setup(params: Any = None, *args: Any) -> dict[str, Any]:
    """``UserService.energizerSetup`` -- the other half of the energizer.

    The client has four energizer calls: this one, ``buyUnlimitedEnergy``,
    ``purchaseEnergyRefill`` and ``setEnergiserAnimationDone``. The gateway
    answered three of them and this one came back as the empty answer it
    gives to a method it does not know -- which the client cannot tell apart
    from a failure.

    It marks the energizer as seen, which is what the animation call does, so
    it does the same thing.
    """
    return user_set_energiser_animation_done(params, *args)


def user_spend(params: Any = None, *args: Any) -> dict[str, Any]:
    """``UserService.spend`` -- the client's "spend" call.

    The gateway answered it with the empty answer it gives to a method it does
    not know. Nothing was spent then and nothing is spent now: what the client
    sends with it was not disassembled, and guessing at what to spend would
    be worse than not spending.

    What it does get is the answer the rest of the family gets. Every other
    purchase in the client answers ``["success"]``, and this one answered an
    empty array, which the client reads as a call that did not happen.
    """
    return _response(["success"])


def user_promo_action(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player and params:
        seen = player.get("seenFlags")
        if not isinstance(seen, dict):
            seen = {}
            player["seenFlags"] = seen
        seen["lastPromoAction"] = int(time.time())
    return _response(["success"])


def cross_promo_accepted(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player:
        seen = player.get("seenFlags")
        if not isinstance(seen, dict):
            seen = {}
            player["seenFlags"] = seen
        seen["crossPromoAccepted"] = 1
    return _response(["success"])


def user_ep_gift_send(params: Any = None, *args: Any) -> dict[str, Any]:
    _record_social_request("epGiftSent", params)
    return _response(["success"])


def user_ep_gift_thank_you(params: Any = None, *args: Any) -> dict[str, Any]:
    _deposit_reward("resource", "energy", 1)
    return _response(["success"])


def user_accepted_gdp(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player:
        seen = player.get("seenFlags")
        if not isinstance(seen, dict):
            seen = {}
            player["seenFlags"] = seen
        seen["acceptedGDP"] = 1
    return _response(["success"])


def user_accepted_tos(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player:
        seen = player.get("seenFlags")
        if not isinstance(seen, dict):
            seen = {}
            player["seenFlags"] = seen
        seen["acceptedTOS"] = 1
    return _response(["success"])


def user_acknowledge_tos_status(params: Any = None, *args: Any) -> dict[str, Any]:
    return user_accepted_tos(params, *args)


def user_clear_old_flash_tokens(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response(["success"])


def user_reactivate_fight_meter(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player:
        player["fightMeterActive"] = True
    return _response(["success"])


def user_finish_spy(params: Any = None, *args: Any) -> dict[str, Any]:
    pvp = _get_pvp_dict()
    pvp["lastSpyFinishedAt"] = int(time.time())
    return _response(["success"])


def user_get_prisoner_info(params: Any = None, *args: Any) -> dict[str, Any]:
    user_obj = session.get("user_object")
    if isinstance(user_obj, dict):
        return _response(user_obj.get("prisonerInfo", []))
    return _response([])


def user_viral_surfacing_seen(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player:
        seen = player.get("seenFlags")
        if not isinstance(seen, dict):
            seen = {}
            player["seenFlags"] = seen
        seen["viralSurfacingSeen"] = 1
    return _response(["success"])


def user_stream_publish_with_comment(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response(["success"])


def user_publish_action(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response(["success"])


def user_add_friend_publish(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response(["success"])


def user_send_notification(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response(["success"])


def user_flash_feed_redeem_item(params: Any = None, *args: Any) -> dict[str, Any]:
    code = "B01"
    if params and isinstance(params[0], dict):
        code = str(params[0].get("item") or params[0].get("code") or "B01")
    _deposit_reward("item", code, 1)
    return _response(["success"])


def user_get_fb_credit_promo_status(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response({"active": False})


def user_set_fb_credit_participation(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player:
        player["fbCreditParticipation"] = True
    return _response(["success"])


def user_grant_watch_to_earn_reward(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    world = _get_world()
    if player and world:
        res = world.get("resources")
        if not isinstance(res, dict):
            res = {}
            world["resources"] = res
        res["coins"] = int(res.get("coins", 0)) + 100
    return _response({"type": "coins", "count": 100})


def user_lcs(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response({})


def user_mega_series_reset(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player:
        player["megaSeriesProgress"] = 0
    return _response(["success"])


def user_crew_zmc_event(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response(["success"])


def world_multi_harvest(params: Any = None, *args: Any) -> dict[str, Any]:
    """Cosecha múltiples edificios en lote avanzando su máquina de estados."""
    from state_machine import click_next_state

    meta: dict[str, Any] = {}
    targets: list[Any] = []
    if params:
        if isinstance(params[0], list):
            targets = params[0]
        elif isinstance(params[0], dict) and isinstance(params[0].get("ids") or params[0].get("objects"), list):
            targets = params[0].get("ids") or params[0].get("objects") or []
        else:
            targets = list(params)

    harvested = 0
    for item in targets:
        obj_id = item.get("id") if isinstance(item, dict) else item
        if obj_id is None or isinstance(obj_id, bool):
            continue
        try:
            click_next_state(False, obj_id, meta, "harvest", None)
            harvested += 1
        except Exception as e:
            logger.debug("world_multi_harvest skipped object %r: %s", obj_id, e)
    if harvested == 0 and _get_world() is not None:
        _deposit_reward("resource", "coins", 100)
    return _response(["success"], metadata=meta)


def world_start_mayhem_event(params: Any = None, *args: Any) -> dict[str, Any]:
    world = _get_world()
    if world is not None:
        world["mayhemEvent"] = {"active": True, "startedAt": int(time.time())}
    return _response(["success"])


def world_upgrade_research_building(params: Any = None, *args: Any) -> dict[str, Any]:
    world = _get_world()
    if world is not None:
        objs = world.get("objects")
        target_id = params[0].get("id") if params and isinstance(params[0], dict) else (params[0] if params else None)
        if isinstance(objs, list):
            for obj in objs:
                if isinstance(obj, dict) and (
                    (target_id is not None and str(obj.get("id")) == str(target_id))
                    or "Research" in str(obj.get("itemName", ""))
                    or "Lab" in str(obj.get("itemName", ""))
                ):
                    obj["level"] = int(obj.get("level", 1)) + 1
                    break
    return _response(["success"])


def world_reset_parliament_destroyed(params: Any = None, *args: Any) -> dict[str, Any]:
    world = _get_world()
    if world is not None:
        objs = world.get("objects")
        if isinstance(objs, list):
            for obj in objs:
                if isinstance(obj, dict) and obj.get("itemName") == "Parliament":
                    obj["destroyed"] = False
                    if int(obj.get("state", 8)) < 8:
                        obj["state"] = "8"
    return _response(["success"])


def world_mechlab_status(params: Any = None, *args: Any) -> dict[str, Any]:
    world = _get_world()
    has_mechlab = False
    if world is not None and isinstance(world.get("objects"), list):
        has_mechlab = any(isinstance(o, dict) and o.get("itemName") == "MechLab" for o in world["objects"])
    return _response({"status": "ready", "built": has_mechlab})


def world_remove_extra_inventory_buildings(params: Any = None, *args: Any) -> dict[str, Any]:
    player = _get_player()
    if player and params and isinstance(params[0], dict):
        inv = player.get("inventory")
        items = inv.get("items") if isinstance(inv, dict) else None
        code = params[0].get("code") or params[0].get("itemName")
        if isinstance(items, dict) and code in items and int(items[code]) > 1:
            items[code] = 1
    return _response(["success"])


def world_remove_extra_world_buildings(params: Any = None, *args: Any) -> dict[str, Any]:
    world = _get_world()
    if world is not None and params and isinstance(params[0], dict):
        target_id = params[0].get("id")
        objs = world.get("objects")
        if target_id is not None and isinstance(objs, list):
            world["objects"] = [o for o in objs if not (isinstance(o, dict) and str(o.get("id")) == str(target_id))]
    return _response(["success"])


def world_revive_units(params: Any = None, *args: Any) -> dict[str, Any]:
    return user_buy_full_heal(params, *args)


def world_begin_quest_battle(params: Any = None, *args: Any) -> dict[str, Any]:
    quest_name = (
        params[0].get("questName") or params[0].get("name") or "quest_battle"
        if params and isinstance(params[0], dict)
        else (str(params[0]) if params else "quest_battle")
    )
    fleets = ensure_fleets()
    fleet = {
        "type": "army",
        "uid": str(quest_name),
        "name": f"Quest Fleet {quest_name}",
        "status": 0,
        "target": "",
        "consumables": [],
        "inventory": [],
        "playerLevel": 10,
        "specialBits": None,
        "lost": None,
        "lastUnitLost": None,
        "lastIndexLost": None,
        "allies": None,
        "battleTarget": None,
        "battleTimestamp": int(time.time()),
        "units": ["U01,,,,", "U04,,,,", "V03,,,,"],
        "store": [0],
        "fleets": [],
        "upgrades": None,
        "hp": None,
        "invader": True,
    }
    fleets["FleetName"] = fleet
    session["battle"] = None
    return _response({
        "state": 0,
        "battle": None,
        "challengerFleet": fleet,
    })


def world_expire_a_quest(params: Any = None, *args: Any) -> dict[str, Any]:
    quest_name = (
        params[0].get("questName") or params[0].get("name")
        if params and isinstance(params[0], dict)
        else (str(params[0]) if params else None)
    )
    quests = session.get("quests")
    if quest_name and isinstance(quests, list):
        for q in quests:
            if isinstance(q, dict) and q.get("name") == quest_name:
                q["expired"] = True
    return _response(["success"])


def zlingshot_fetch(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response({"presence": 1})


def zlingshot_zoom(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response(["success"])


def watch_to_earn_available(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response({"available": False})


def watch_to_earn_count_prompt(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response(0)


def watch_to_earn_load_object(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response({})


def watch_to_earn_start_activity(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response(["success"])


def watch_to_earn_version(params: Any = None, *args: Any) -> dict[str, Any]:
    return _response("1.0")


# ----------------------------------------------------------------------
# Full Map of All Extended Services
# ----------------------------------------------------------------------

EXTENDED_AMF_HANDLERS: dict[str, Any] = {
    # 1. Combates Avanzados, DeathMatch y Dominación
    "DeathMatchService.fetchOpponents": deathmatch_fetch_opponents,
    "DeathMatchService.joinRoom": deathmatch_join_room,
    "DeathMatchService.loadBattle": deathmatch_load_battle,
    "DeathMatchService.processRewardQueue": deathmatch_process_reward_queue,
    "DominationModeService.getDominationModeOpponentList": domination_get_opponents,
    "DominationModeService.getDominationChat": domination_get_chat,
    "DominationModeService.addDominationChat": domination_add_chat,
    "DominationModeService.loadDominationModeBattle": domination_load_battle,
    "DominationModeService.updateDefenseForce": domination_update_defense_force,
    "QuestSurvivalModeService.loadQuestSurvivalMode": quest_survival_mode_load,

    # 2. Minijuegos y Tiradas de Ruleta
    "MiniGameService.loadGame": minigame_load_game,
    "MiniGameService.dropBomb": minigame_drop_bomb,
    "MiniGameService.buyMiniGameFuel": minigame_buy_fuel,
    "MiniGameService.stop": minigame_stop,
    "UserService.treasureVaultSpin": user_treasure_vault_spin,
    "UserService.bookmarksDailySpin": user_bookmarks_daily_spin,
    "PVPService.slotMachineSpin": pvp_slot_machine_spin,
    "PVPService.slotMachineSpinBuy": pvp_slot_machine_spin_buy,

    # 3. Operaciones de Jugador y Economía
    "UserService.buyFullHeal": user_buy_full_heal,
    "UserService.buyBack": user_buy_back,
    "UserService.buyUnlimitedEnergy": user_buy_unlimited_energy,
    "UserService.purchaseAmmoRefill": user_purchase_ammo_refill,
    "UserService.purchaseManaRefill": user_purchase_mana_refill,
    "UserService.purchaseUnlock": user_purchase_unlock,
    "UserService.buyMOTDItem": user_buy_motd_item,
    "UserService.buyRewardItem": user_buy_reward_item,
    "UserService.buyQuestRestartTask": user_buy_quest_restart_task,
    "UserService.questTreeStartQuest": user_quest_tree_start_quest,
    "UserService.questTreeUnlockQuest": user_quest_tree_unlock_quest,
    "UserService.questTreeReset": user_quest_tree_reset,
    "UserService.questTreeSetMode": user_quest_tree_set_mode,
    "UserService.doFavQuest": user_do_fav_quest,
    "UserService.superOreOrder": user_super_ore_order,
    "UserService.unlockResource": user_unlock_resource,
    "UserService.removeExpiredInventory": user_remove_expired_inventory,

    # Clans
    "ClansService.getClanInfo": clans_get_clan_info,
    "ClansService.getNeighborClanInfo": clans_get_neighbor_clan_info,
    "ClansService.createClan": clans_create_clan,
    "ClansService.updateName": clans_update_name,
    "ClansService.updateCrest": clans_update_crest,
    "ClansService.buyCrest": clans_buy_crest,
    "ClansService.buyHealth": clans_buy_health,
    "ClansService.buySlots": clans_buy_slots,
    "ClansService.addTaunt": clans_add_taunt,
    "ClansService.updateTauntViewTime": clans_update_taunt_view_time,
    "ClansService.acceptQuest": clans_accept_quest,
    "ClansService.completeQuest": clans_complete_quest,
    "ClansService.clearNotifications": clans_clear_notifications,
    "ClansService.removeMember": clans_remove_member,
    "ClansService.processMemberQueue": clans_process_member_queue,
    "ClansService.postGroupFeed": clans_post_group_feed,
    "ClansService.loadAllianceBattle": clans_load_alliance_battle,

    # PVP Extra
    "PVPService.getAllChallenges": pvp_get_all_challenges,
    "PVPService.getFightList": pvp_get_fight_list,
    "PVPService.globalPVPOptInOut": pvp_global_opt_in_out,
    "PVPService.immunityStart": pvp_immunity_start,
    "PVPService.immunityExtend": pvp_immunity_extend,
    "PVPService.useStrikeTeam": pvp_use_strike_team,
    "PVPService.seenStrikeTeamComment": pvp_seen_strike_team_comment,
    "PVPService.setStrikeTeamComment": pvp_set_strike_team_comment,
    "PVPService.setDefenderComment": pvp_set_defender_comment,
    "PVPService.setInvasionComment": pvp_set_invasion_comment,
    "PVPService.setEspionageHQData": pvp_set_espionage_hq_data,
    "PVPService.seenPrisonCampNotification": pvp_seen_prison_camp_notification,
    "PVPService.reviveAllies": pvp_revive_allies,
    "PVPService.acceptDecoBuildableRepel": pvp_accept_deco_buildable_repel,
    "PVPService.rejectDecoBuildableRepel": pvp_reject_deco_buildable_repel,
    "PVPService.acceptDefenseTowerRepel": pvp_accept_defense_tower_repel,
    "PVPService.rejectDefenseTowerRepel": pvp_reject_defense_tower_repel,
    "PVPService.completeSocialRepel": pvp_complete_social_repel,
    "PVPService.buyCrewRepelPosition": pvp_buy_crew_repel_position,

    # Requests & Social
    "RequestService.giftRequest": request_gift,
    "RequestService.neighborRequest": request_neighbor,
    "RequestService.invasionHelpRequest": request_invasion_help,
    "RequestService.allianceInviteRequest": request_alliance_invite,
    "RequestService.allianceJoinRequest": request_alliance_join,
    "MFSService.collectReward": mfs_collect_reward,
    "VisitorService.helpedInvalid": visitor_helped_invalid,
    "BlackMarketHelperService.tradeForPart": blackmarket_trade_for_part,

    # UserService Extra Flags & Social
    "UserService.setTitanName": user_set_titan_name,
    "UserService.setTag": user_set_tag,
    "UserService.setSurvivalModeToaster": user_set_survival_mode_toaster,
    "UserService.setCommandoAnimationDone": user_set_commando_animation_done,
    "UserService.setEnergiserAnimationDone": user_set_energiser_animation_done,
    "UserService.energizerSetup": user_energizer_setup,
    "UserService.spend": user_spend,
    "UserService.promoAction": user_promo_action,
    "CrossPromoService.accepted": cross_promo_accepted,
    "UserService.EPGiftSend": user_ep_gift_send,
    "UserService.EPGiftThankYou": user_ep_gift_thank_you,
    "UserService.acceptedGDP": user_accepted_gdp,
    "UserService.acceptedTOS": user_accepted_tos,
    "UserService.acknowledgeTOSStatus": user_acknowledge_tos_status,
    "UserService.clearOldFlashTokens": user_clear_old_flash_tokens,
    "UserService.reactivateFightMeter": user_reactivate_fight_meter,
    "UserService.finishSpy": user_finish_spy,
    "UserService.getPrisonerInfo": user_get_prisoner_info,
    "UserService.viralSurfacingSeen": user_viral_surfacing_seen,
    "UserService.streamPublishWithComment": user_stream_publish_with_comment,
    "UserService.publishUserAction": user_publish_action,
    "UserService.addFriendPublish": user_add_friend_publish,
    "UserService.sendUserNotification": user_send_notification,
    "UserService.flashFeedRedeemItem": user_flash_feed_redeem_item,
    "UserService.getFBCreditPromoStatus": user_get_fb_credit_promo_status,
    "UserService.setFBCreditParticipation": user_set_fb_credit_participation,
    "UserService.grantWatchToEarnReward": user_grant_watch_to_earn_reward,
    "UserService.grantWatchToEarnRewardNew": user_grant_watch_to_earn_reward,
    "UserService.lcs": user_lcs,
    "UserService.megaSeriesReset": user_mega_series_reset,
    "UserService.crewZMCEvent": user_crew_zmc_event,

    # WorldService Extra
    "WorldService.multiHarvest": world_multi_harvest,
    "WorldService.startMayhemEvent": world_start_mayhem_event,
    "WorldService.upgradeResearchBuilding": world_upgrade_research_building,
    "WorldService.resetParliamentDestroyed": world_reset_parliament_destroyed,
    "WorldService.mechlabStatus": world_mechlab_status,
    "WorldService.removeExtraInventoryBuildings": world_remove_extra_inventory_buildings,
    "WorldService.removeExtraWorldBuildings": world_remove_extra_world_buildings,
    "WorldService.reviveUnits": world_revive_units,
    "WorldService.beginQuestBattle": world_begin_quest_battle,
    "WorldService.expireAQuest": world_expire_a_quest,

    # Zlingshot & WatchToEarn
    "ZlingshotService.fetch": zlingshot_fetch,
    "ZlingshotService.zoom": zlingshot_zoom,
    "WatchToEarnService.available": watch_to_earn_available,
    "WatchToEarnService.countPrompt": watch_to_earn_count_prompt,
    "WatchToEarnService.loadObject": watch_to_earn_load_object,
    "WatchToEarnService.startActivity": watch_to_earn_start_activity,
    "WatchToEarnService.VERSION": watch_to_earn_version,
    "WatchToEarnService.as": watch_to_earn_version,
}
