from __future__ import annotations

import pytest
from flask import Flask, session

from service_handlers import EXTENDED_AMF_HANDLERS

app = Flask(__name__)
app.secret_key = "test-secret"


@pytest.fixture
def test_session():
    with app.test_request_context("/"):
        session["user_object"] = {
            "userInfo": {
                "player": {
                    "uid": 1,
                    "level": 10,
                    "cash": 100,
                    "energy": 25,
                    "energyMax": 25,
                    "ammo": 10,
                    "ammoMax": 50,
                    "mana": 10,
                    "manaMax": 50,
                    "seenFlags": {},
                    "inventory": {"items": {"TVK": 5, "U01": 2}},
                    "unlockedUnits": [],
                    "questTreeUnlocks": [],
                },
                "world": {
                    "objects": [],
                    "resources": {"coins": 20000, "oil": 5000, "wood": 5000, "aluminum": 1000},
                },
            },
            "pvp": {},
        }
        yield session


def test_all_extended_handlers_return_valid_amf_format(test_session):
    for endpoint, handler in EXTENDED_AMF_HANDLERS.items():
        try:
            resp = handler([{"test": True}], None, None)
        except Exception as e:
            pytest.fail(f"Handler for {endpoint} raised exception: {e}")

        assert isinstance(resp, dict), f"{endpoint} did not return a dict"
        assert resp.get("errorType") == 0, f"{endpoint} returned errorType != 0"
        assert resp.get("userId") == 1, f"{endpoint} returned userId != 1"
        assert "metadata" in resp, f"{endpoint} missing metadata"
        assert "data" in resp, f"{endpoint} missing data"


# --- 1. Combates Avanzados, DeathMatch y Dominación ---

def test_deathmatch_flow(test_session):
    # Fetch opponents
    opp_h = EXTENDED_AMF_HANDLERS["DeathMatchService.fetchOpponents"]
    res = opp_h([])
    assert isinstance(res["data"], list)
    assert len(res["data"]) > 0

    # Join room
    join_h = EXTENDED_AMF_HANDLERS["DeathMatchService.joinRoom"]
    res2 = join_h([{"roomID": 42}])
    assert res2["data"]["roomId"] == 42
    assert res2["data"]["status"] == "active"

    # Load battle
    battle_h = EXTENDED_AMF_HANDLERS["DeathMatchService.loadBattle"]
    res3 = battle_h([{"enemyID": "111"}])
    assert res3["data"]["state"] == 0
    assert "FleetName" in test_session["fleets"]
    assert len(test_session["fleets"]["FleetName"]["units"]) == 5

    # Process rewards
    proc_h = EXTENDED_AMF_HANDLERS["DeathMatchService.processRewardQueue"]
    res4 = proc_h([])
    assert len(res4["data"]) >= 3


def test_domination_flow(test_session):
    # Opponents list
    opp_h = EXTENDED_AMF_HANDLERS["DominationModeService.getDominationModeOpponentList"]
    res = opp_h([])
    assert len(res["data"]) >= 3

    # Add chat message and read back
    add_chat_h = EXTENDED_AMF_HANDLERS["DominationModeService.addDominationChat"]
    add_chat_h([{"message": "Flank them from the north!"}])
    get_chat_h = EXTENDED_AMF_HANDLERS["DominationModeService.getDominationChat"]
    chat_res = get_chat_h([])
    assert any(m["message"] == "Flank them from the north!" for m in chat_res["data"])

    # Load domination battle
    dom_battle_h = EXTENDED_AMF_HANDLERS["DominationModeService.loadDominationModeBattle"]
    b_res = dom_battle_h([{"enemyID": "zone_alpha"}])
    assert b_res["data"]["state"] == 0
    assert test_session["fleets"]["FleetName"]["uid"] == "zone_alpha"


# --- 2. Minijuegos y Tiradas de Ruleta ---

def test_minigame_bomber_run(test_session):
    # Load game
    load_h = EXTENDED_AMF_HANDLERS["MiniGameService.loadGame"]
    res = load_h([])
    assert res["data"]["fuel"] == 100
    assert len(res["data"]["crates"]) == 5

    # Drop bomb
    drop_h = EXTENDED_AMF_HANDLERS["MiniGameService.dropBomb"]
    drop_res = drop_h([])
    assert drop_res["data"]["hit"] is True
    assert drop_res["data"]["fuel"] == 90
    assert "reward" in drop_res["data"]

    # Buy fuel
    buy_fuel_h = EXTENDED_AMF_HANDLERS["MiniGameService.buyMiniGameFuel"]
    fuel_res = buy_fuel_h([])
    assert fuel_res["data"]["fuel"] >= 100
    # The fuel costs five empire points. The bomb picks one of five crates at
    # random and one of them pays empire points back, so the balance is the
    # cost plus whatever that crate gave -- which used to make this test fail
    # one time in twenty.
    reward = drop_res["data"]["reward"]
    given_back = reward["count"] if reward["type"] == "cash" else 0
    assert test_session["user_object"]["userInfo"]["player"]["cash"] == 95 + given_back

    # Stop game
    stop_h = EXTENDED_AMF_HANDLERS["MiniGameService.stop"]
    stop_res = stop_h([])
    assert stop_res["data"]["status"] == "stopped"


def test_spins_and_vault(test_session):
    # Treasure vault spin (uses TVK keys)
    vault_h = EXTENDED_AMF_HANDLERS["UserService.treasureVaultSpin"]
    v_res = vault_h([{"tier": 1}])
    assert "reward" in v_res["data"]
    assert test_session["user_object"]["userInfo"]["player"]["inventory"]["items"]["TVK"] == 4

    # Bookmarks daily spin
    spin_h = EXTENDED_AMF_HANDLERS["UserService.bookmarksDailySpin"]
    s_res = spin_h([])
    assert "slice" in s_res["data"]
    assert "reward" in s_res["data"]
    assert test_session["user_object"]["userInfo"]["player"].get("lastDailySpinTS") is not None

    # PvP slot machine spin
    slot_h = EXTENDED_AMF_HANDLERS["PVPService.slotMachineSpin"]
    slot_res = slot_h([])
    assert len(slot_res["data"]["roll"]) == 3
    assert "reward" in slot_res["data"]


# --- 3. Operaciones de Jugador y Economía ---

def test_player_economy_operations(test_session):
    # Buy full heal
    heal_h = EXTENDED_AMF_HANDLERS["UserService.buyFullHeal"]
    h_res = heal_h([])
    assert h_res["errorType"] == 0

    # Buy unlimited energy
    unl_h = EXTENDED_AMF_HANDLERS["UserService.buyUnlimitedEnergy"]
    unl_res = unl_h([])
    assert unl_res["data"]["success"] is True
    assert test_session["user_object"]["userInfo"]["player"]["cash"] == 90

    # Purchase ammo and mana refill
    ammo_h = EXTENDED_AMF_HANDLERS["UserService.purchaseAmmoRefill"]
    ammo_h([])
    assert test_session["user_object"]["userInfo"]["player"]["ammo"] == 50

    mana_h = EXTENDED_AMF_HANDLERS["UserService.purchaseManaRefill"]
    mana_h([])
    assert test_session["user_object"]["userInfo"]["player"]["mana"] == 50

    # Super ore order
    ore_h = EXTENDED_AMF_HANDLERS["UserService.superOreOrder"]
    ore_res = ore_h([])
    assert ore_res["data"]["success"] is True
    res_map = test_session["user_object"]["userInfo"]["world"]["resources"]
    assert res_map["coins"] == 15000
    assert res_map["aluminum"] == 2000

    # Quest tree progression
    qtree_unlock_h = EXTENDED_AMF_HANDLERS["UserService.questTreeUnlockQuest"]
    qtree_unlock_h([{"quest": "Q_TECH_ARMOR_01"}])
    assert "Q_TECH_ARMOR_01" in test_session["user_object"]["userInfo"]["player"]["questTreeUnlocks"]

    qtree_reset_h = EXTENDED_AMF_HANDLERS["UserService.questTreeReset"]
    qtree_reset_h([])
    assert test_session["user_object"]["userInfo"]["player"]["questTreeUnlocks"] == []


# --- 4. Multiplayer & Social Requests ---

def test_social_and_gift_requests(test_session):
    gift_h = EXTENDED_AMF_HANDLERS["RequestService.giftRequest"]
    resp = gift_h([[101, 102], "gift_item_code"])
    assert resp["errorType"] == 0
    tracker = test_session["user_object"]["requestTracker"]["giftRequestSent"]
    assert "101" in tracker
    assert "102" in tracker

    thank_h = EXTENDED_AMF_HANDLERS["UserService.EPGiftThankYou"]
    prev_energy = test_session["user_object"]["userInfo"]["player"]["energy"]
    resp = thank_h([])
    assert resp["errorType"] == 0
    assert test_session["user_object"]["userInfo"]["player"]["energy"] == prev_energy + 1


def test_clans_and_world_extended_operations(test_session):
    # Clan member queue & removal
    test_session["user_object"]["clansInfo"] = {
        "id": 1,
        "name": "Test Clan",
        "xp": 0,
        "members": [{"uid": 1, "role": "leader", "name": "Commander"}],
        "memberQueue": [{"uid": 202, "name": "Recruit"}],
    }
    queue_h = EXTENDED_AMF_HANDLERS["ClansService.processMemberQueue"]
    q_res = queue_h([])
    assert len(q_res["data"]) == 1
    assert any(m["uid"] == 202 for m in test_session["user_object"]["clansInfo"]["members"])

    rem_h = EXTENDED_AMF_HANDLERS["ClansService.removeMember"]
    rem_h([{"uid": 202}])
    assert not any(m["uid"] == 202 for m in test_session["user_object"]["clansInfo"]["members"])

    # Clan quest completion
    comp_q = EXTENDED_AMF_HANDLERS["ClansService.completeQuest"]
    comp_q([])
    assert test_session["user_object"]["clansInfo"]["xp"] == 50

    # BlackMarket trade for part
    bm_h = EXTENDED_AMF_HANDLERS["BlackMarketHelperService.tradeForPart"]
    bm_h([{"part": "B05"}])
    assert test_session["user_object"]["userInfo"]["player"]["inventory"]["items"].get("B05") == 1

    # World operations: Parliament repair, Research upgrade, Quest expire, Quest battle
    test_session["user_object"]["userInfo"]["world"]["objects"] = [
        {"id": 10, "itemName": "Parliament", "state": "2", "destroyed": True},
        {"id": 11, "itemName": "Research Lab", "level": 1},
    ]
    EXTENDED_AMF_HANDLERS["WorldService.resetParliamentDestroyed"]([])
    assert test_session["user_object"]["userInfo"]["world"]["objects"][0]["destroyed"] is False
    assert test_session["user_object"]["userInfo"]["world"]["objects"][0]["state"] == "8"

    EXTENDED_AMF_HANDLERS["WorldService.upgradeResearchBuilding"]([{"id": 11}])
    assert test_session["user_object"]["userInfo"]["world"]["objects"][1]["level"] == 2

    test_session["quests"] = [{"name": "Q_TEST_EXP", "complete": False, "expired": False}]
    EXTENDED_AMF_HANDLERS["WorldService.expireAQuest"]([{"name": "Q_TEST_EXP"}])
    assert test_session["quests"][0]["expired"] is True

    qb_res = EXTENDED_AMF_HANDLERS["WorldService.beginQuestBattle"]([{"questName": "Q_BOSS"}])
    assert qb_res["data"]["state"] == 0
    assert "challengerFleet" in qb_res["data"]
