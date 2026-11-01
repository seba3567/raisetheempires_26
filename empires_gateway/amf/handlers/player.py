"""The player.

What the client asks for when it starts: who you are, what you own, what
you have already seen, and the small settings you change from the map. It is
the first call of every session and the largest answer the gateway gives.
"""
from __future__ import annotations

import copy
import logging
from datetime import datetime

from fastapi_session import session

from empires_gateway.amf.handlers.economy import (
    _economy_session,
)
from empires_gateway.shared import (
    MAX_ADMIN_ID,
    MIN_ADMIN_ID,
    get_allies_info,
    rand_seed_w,
    rand_seed_z,
    version,
)
from game_settings import (
    get_zid,
    initial_island,
    lookup_yield,
    replenish_energy,
    unlock_expansion,
)
from logger import (
    report_tutorial_step,
)
from quest_engine import (
    activate_unlocked_quests,
    all_lambda,
    do_rewards,
    handle_quest_progress,
    merge_quest_progress,
    new_quest_with_sequels,
    progress_action,
    progress_inventory_count,
    progress_neighbor_count,
    progress_parameter_equals,
    progress_upgrades_count,
)
from save_engine import (
    InvalidSaveException,
    ensure_fleets,
    validate_save,
)
from save_migration import (
    is_0_08a_preview,
    migrate,
)

logger = logging.getLogger(__name__)


def init_user():
    # global game_objects
    unit = "U01,,,,"

    # resources = {"energy": 100, "coins": 100000, "oil": 7000, "wood": 5000, "aluminum": 9000,
    #                                 "copper": 4000, "gold": 3000, "iron": 2000, "uranium": 1000}

    resources = {"energy": 25, "coins": 5000, "oil": 25, "wood": 150, "aluminum": 1000,
                 "copper": 0, "gold": 0, "iron": 0, "uranium": 0}

    # xp = 20000
    # level =100
    # zcash = 1000
    # energy = 200
    # energy_max = 400
    xp = 0
    level = 1
    zcash = 15
    energy = 25
    energy_max = 25

    # user_fleet = {
    #     "type": "army",
    #     "uid": "0",
    #     "name": "FleetName",
    #     "status": 0,
    #     "target": "",
    #     "consumables": [],
    #     "inventory": [],
    #     "playerLevel": 1,
    #     "specialBits": None,
    #     "lost": None,
    #     "lastUnitLost": None,
    #     "lastIndexLost": None,
    #     "allies": None,
    #     "battleTarget": None,
    #     "battleTimestamp": None,
    #     "ransomRandom": None,
    #     "ransomResource": None,
    #     "ransomAmount": None,
    #     "units": [unit],  # only one unit for tutorial [unit, unit, unit],
    #     "store": [0],  # [0, 0, 0],
    #     "fleets": None,
    #     "upgrades": None,
    #     "hp": None
    # }

    user = {
        "userInfo": {
            "player": {
                "uid": get_zid(),
                "lastTrackingTimestamp": 0,
                "viralSurfacing": {"seen": [], "counts": {}},
                "crewNeighbors": [],
                "dm_band": None,
                "dm_endTS": None,
                "tutorialProgress": "",
                "xp_multiplier": 1,
                "cp_static": 1,
                "lightningDeals": {},
                "friendFlashSessionInfo": {},
                "m_friendFlashEPBank": 1000,
                "playerResourceType": 3,  # 0:coins 1:oil 2: wood 3:alum,
                "meetsCriteriaLowWalletOnly": False,
                "newInstallExperiments": None,
                "staticWorkers": 20,
                "staticWorkersCap": 100,
                # "expansions": {
                #     "data": [4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295,
                #              4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295,
                #              4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295, 4294967295,
                #              4294967295, 4294967295]},
                "expansions": {"data": [0,0,0,0,805306368,6291456,49152,0,0,0,0]},
                "questTrees": {},
                "questTreeUnlocks": {},
                "questTreeData": {},
                "starredQuests": [],
                "seenQuests": [],
                "megaseriesList": {},
                "questGatesComplete": False,
                "warpSeconds": 0,
                "worldGamesOver": 0,
                "lastLoginTimestamp": 0,
                "RUXStatus": False,
                "RUXQuest": False,
                "RUXDay": 0,
                "RUXInitShow": False,
                "RUXDelta": 0,
                "MFSRewardPoints": 0,
                "MFSRewardClaimed": False,
                "MFSRewardLap": 0,
                "mana": {"value": 100},
                "cash": zcash,
                "level": level,
                "xp": xp,
                "numCashTransactions": 100,
                "cashPurchasedTotal": 1000,
                "transactionLog": [],
                "combatSpecialBits": None,
                "promos": None,
                "autopromo": None,
                "motdMerchHistory": None,
                "motdMerchUnlockHistory": None,
                "lufCodes": None,
                "lufEndDate": 0,
                "lufZRTData": None,
                "lufCodesLevelUnlocked": None,
                "miniGamePlayedTS": 0,
                "bomberFuel": 1000,
                "bombTierReached": 0,
                "miniGameRewardTier": 0,
                "miniGameRewards": [],
                "miniGameTotalFuel": 1500,
                "mgrsData": "",
                "seenFlags": {},
                # seen "introCine":True otherwise blackscreen but no startepisode then ->  either false (ZGlobal.noIntroCineVariant != ZGlobal.EXPERIMENT_NO_INTRO_CINE && Zlab.getFlashVar("mute") == null)
                "motdsViewed": [],
                "motdsAccepted": [],
                "m_mayhemEvents": None,
                "bountyCenter": {"lastActivated": 0, "bountyBonds": 0},
                "energizerRefill": 1000,
                "energiserEventFinished": False,
                "energiserAnimationInitTime": 0,
                "energyDeduct": 0,
                "energizerMax": 1000,
                "energy": energy,
                "energyMax": energy_max,
                "unlimitedEnergyTS": 0,
                "unlimitedEnergyIndex": 0,
                "lastEnergyCheck": datetime.now().timestamp(),
                "ammo": 1234,
                "ammoMax": 2000,
                "options": {"musicDisabled": False, "sfxDisabled": False},
                "socialLevelGood": 100,
                "socialXpGood": 10000,
                "socialLevelBad": 0,
                "socialXpBad": 0,
                "scrap": None,
                "enableIdlePopup": False,
                "enableInterPage": False,
                "enableOnetimePopup": False,
                "alliesUsed": None,
                "storageData": {},
                "inventory": {"items": {"B01": 20}},
                "neighborVisits": {},
                "unlockedUnits": [],
                "unlockedItems": [],
                "unlockedContracts": [],
                "tags": {},
                "consumableUsedByCode": None,
                "treasureVaultOpenTS": 0,
                "watchToEarn": {"dailyWatchCount": 0, "dailyWatchStartTime": 0},
                "userGroups": None,
                "flashFeedTokens": None,
                "lastSurvialModeToaster": 0,
                "clanStatus": None,
                "allianceStorage": None,
                "acceptedAllianceQuests": None,
                "isCIP": False,
                "acceptedGDP": True,
                "acceptedTOS": True,
                "fightMeter": {"lastActivated": 0, "lastInitWeek": 0, "weekInitTarget": 0},
                "fightsPerDay": 1,
                # "fleets": None,
                "activeVirals": {},
                "sequentialLogins": 1,
                "mechDailyRewardOffset": 0,

                "world": {
                    "deathMatch": None
                }
            },
            "worldName": "Rising Empire",
            "titanName": "Titan",
            "isCIP": False,
            "dominanceDefaultFleets": [],
            "bookmarkReward": 0,
            "iconCodes": None,

            "world": {"fleets": [], "enemies": [], "globalFleetId": 0, "battleStatus": {},  # user_fleet
                      "research": {}, "research2": {"buildingTypesUpgraded": None, "treesUnlocked": None},
                      "resourceOrder": ["aluminum", "copper", "gold", "iron", "uranium"],
                      "globalObjectId": 10000,  # initial id high enough not to overlap with preloaded objects
                      "sizeX": 200,
                      "sizeY": 200,
                      "ownerId": 0,
                      "randSeedW": rand_seed_w,
                      "randSeedZ": rand_seed_z,
                      "unitDropData": {"unclaimedUnits": []},
                      "islands": 1,
                      "roadData": initial_island["roads"],
                      "objects": initial_island["objects"],
                      "rewardRandSeedW": 484584,
                      "rewardRandSeedZ": 7549,
                      "ransomRandSeedW": 456647,
                      "ransomRandSeedZ": 4546,
                      "scrapRandSeedW": 5646,
                      "scrapRandSeedZ": 3567,
                      "resources": resources,
                      "campaign": {"current": "camp001", "active": {}, "mastery": {}}
                      }

        },
        "neighbors": get_allies_info(),
        "unlockedResource": {"aluminum": 3, "copper": 4, "gold": 5, "iron": 6},
        "showBookmark": True,
        "firstDay": True,
        "survivalMode": None,
        "prisonerInfo": [],
        "pvp": {"invaders": {"pve": {"quest": True}}, "gpInv": None, "nAssists": None, "immunity": [],
                "notifications": None, "pcCapturedNotify": None, "pcEscapedNotify": None},
        "autoFilledCrewBuildings": None,
        "numCrewNeighborsDirty": 0,
        "ineligibleGiftRecipients": [],
        "priceTestSettings": {},
        "buyBackSettings": {},
        "DEATHMATCH_FRAG_LIMITS": None,
        "DEATHMATCH_CACHE_TTL": None,
        "DEATHMATCH_OPP_COOLDOWN": None,
        "DEATHMATCH_STANDARD_REWARDS": None,
        "DEATHMATCH_GRAND_REWARDS": None,
        "DEATHMATCH_START_TIME": None,
        "DEATHMATCH_DURATION": None,
        "clansInfo": None,
        "immunityTimeVariant": 0,
        "experiments": {"empire_combataicancritical": 2, "empire_decorations_master": 2, "empire_doober_pickup": 3,
                        "empires_consumable_2": 3, "empire_research_shield_upgrade": 2, "empires_support_units": 5,
                        "empire_buildable_zrig_master": 3, "empire_request2_master": 2, "empire_mfs_uili": 4,
                        "empire_survivalmode3_master": 3, "empire_survivalMode_master": 2,
                        "empire_survivalmode_enhancements": 2, "empire_mech_fight_master": 3, "empire_mech_fight_gate_flat": 5,
                        "empire_mech_lab_master": 3, "empire_titanresearch_master": 2, "empire_tier_8": 4,
                        "empire_campv2_enabled": 2, "empire_campaign_mastery": 2,
                        "empire_domination_master": 4, "empire_domination_warchest": 2,
                        "empire_globalpvp_master": 2, "empire_globalpvp_strangerbar_enable": 2,
                        "empire_alliances_master": 3, "empire_alliances_phase_4": 3,
                        "empire_alliances_quest_connections": 3, "empire_alliances_quest_power": 3,
                        "empire_leaderboard_summary": 1, "empire_blackmarket_master": 2},
        "completedQuests": [],
        "decorationsInfo": None,
        "treasureVaultHighlights": None,
        "crewSlotCostExperiment": 0,
        "combatAllyGatingVarient": 0,
        "cashOnLevelUpVarient": 0,
        "immunityViralVarient": 0,
        "autopublishFeedVarient": 0,
        "autopublishFeedMessageVarient": 0,
        "publishFeedPermissionVarient": 0,
        "autopublishAllFeedVarient": 0,
        "researchPartsVariantArmy": 0,
        "researchPartsVariantNavy": 0,
        "researchPartsVariantAir": 0,
        "noIntroCineVariant": 2,  # disable intro cinematics (we don't have yet)
        "energyRewardVariant_v2": 0,
        "energyRewardVariant_v3": 0,
        "allyTimeoutVariant": 0,
        "speedUpViralVarient": 0,
        "pricetestEarlyUnitUnlockVariant": 0,
        "starterBundleVariant": 0,
        "meetsCriteriaStarterPack": False,
        "energyRewardModVariant": 0,
        "enhancedProgressBarVariant": 0,
        "epSpendConfirmation": 0,
        "leaderboardsVariant": 3,
        "survivalModeMaster": 1,
        "survivalModeContinueCost": 1,
        "survivalModeCardAccess": 1,
        "INTERSTITIAL_GIFTING_REWARDS": "",
        "FREE_GIFT_PARTS_BUILDING_DATA": "",
        "snid": 0,
        "snuid": 0,
        "visitorHelpRequests": {},
        "LE_DISCOUNT_SALE": 0,
        "LOW_EP_POPUP": None,
        "COMBAT_NO_ENERGY": 0,
        "COMBAT_DOUBLE_XP": 2,
        "COMBAT_HALF_RANSOM": 1,
        "overlaySurveyURL": None,
        "friendBarVarient": 0,
        "requestTracker": {"giftRequestSent": {}, "helpRequestSent": {}, "crewRequestSent": {},
                           "neighborRequestSent": {}, "repelInvasionRequestSent": {}, "allianceInviteRequestSent": {}},
        "activeRequests": {"request_speedup": None, "request_buildingpart_send": None, "request_crew": None,
                           "request_gift_request": None, "request_gift_send": None, "request_neighbor": None,
                           "request_repel_invasion": None, "request_alliance_invite": None},
        "activeGiftRequests": [],
        "activeHelpRequests": [],
        "allPendingNeighbors": [],
        "playerAsn": 1,
        "questInitAsn": 1,
        "partsGatherInitAsn": 1,
        "blackmarketItems": None,
        "worldEvents": None,
        "FLASHFEED_EXPIRE_TIME": 0,
        "FB_REQ_PERMS": "gdpr",
    }
    return user


def user_response():
    new_quests = []
    if 'user_object' in session:
        print("Loading user from save, modified=", session.modified)
        _p = session.get("user_object", {}).get("userInfo", {}).get("player", {})
        print("level=", _p.get("level"), "uid=", _p.get("uid"), "worldName=", session.get("user_object", {}).get("userInfo", {}).get("worldName"), "xp=", _p.get("xp"), "prt=", _p.get("playerResourceType"), "coins=", session.get("user_object", {}).get("userInfo", {}).get("world", {}).get("resources", {}).get("coins"), "socialXpGood=", _p.get("socialXpGood"), "socialLevelGood=", _p.get("socialLevelGood"), "socialXpBad=", _p.get("socialXpBad"), "socialLevelBad=", _p.get("socialLevelBad"))
        if not validate_save(session):
            print("invalid save file")
            raise InvalidSaveException
        user = session['user_object']
        user["userInfo"]["player"]["uid"] = get_zid()
        if session.get('save_version') != version:
            print("WARNING: Save game was saved with version", session.get('save_version'), "while game is version",
                  version)

        qc = session['quests']

        user["neighbors"] = get_allies_info()

        meta = {"newPVE": 0, "QuestComponent": [e for e in session['quests'] if not e["complete"]]}

    else:
        user = copy.deepcopy(init_user())
        print("initialized new")
        session['user_object'] = user
        # qc = [{"name": "Q0516", "complete":False, "expired":False,"progress":[0],"completedTasks":0}]
        session['quests'] = []

        session['save_version'] = version
        session['original_save_version'] = version
        session['saved_on'] = datetime.now().timestamp()
        meta = {"newPVE": 0, "QuestComponent": [e for e in session['quests'] if not e["complete"]]}
        new_quest_with_sequels("Q0516", new_quests, meta)

    # session['user_object']["userInfo"]["player"]["tutorialProgress"] = "tut_step_krunsch1Battle2Speeech" #'tut_step_inviteFriendsViral'
    # session['user_object']["userInfo"]["player"]["tutorialProgress"] = 'tut_step_remindCombatUIWaitForPreBattleUI'
    # session['user_object']["userInfo"]["player"]["tutorialProgress"] = 'tut_step_remindCombatUIClearCircles'
    # session['user_object']["userInfo"]["player"]["lastEnergyCheck"] = datetime.now().timestamp()
    # save migration only
    # if "lastEnergyCheck" not in session['user_object']["userInfo"]["player"]:
    #     session['user_object']["userInfo"]["player"]["lastEnergyCheck"] = datetime.now().timestamp()

    replenish_energy()

    session["battle"] = None
    # The fleet registry survives a re-login.
    #
    # It used to be reset here, and that was the quiet half of a battle bug:
    # the client's troops only ever reach the server through `addFleet`, so
    # wiping the registry left it simulating units it did not have. When the
    # next fight started, `init_battle` found nothing and fell back to the
    # quest's troops -- which the client, already drawing its own, refused to
    # accept ("TResolveBattle: unit strength out of sync"). A login in the
    # middle of a session is normal; losing the troops because of it was not.
    ensure_fleets()
    session['population'] = lookup_yield()

    if "market" not in session:
        session["market"] = {}
    # #temp migration
    # session['user_object']["experiments"]["empire_store_sorting_rev_enhanced"] = 0
    # session['user_object']["experiments"]["empires_shop_improvements"] = 0
    session['user_object']["experiments"]["empire_combataicancritical"] = 2
    # Ensure leaderboards and competition modes are fully unlocked for existing sessions
    session['user_object']["leaderboardsVariant"] = 3
    session['user_object']["survivalModeMaster"] = 1
    session['user_object']["survivalModeContinueCost"] = 1
    session['user_object']["survivalModeCardAccess"] = 1
    exp = session['user_object'].setdefault("experiments", {})
    exp["empire_domination_master"] = 4
    exp["empire_domination_warchest"] = 2
    exp["empire_globalpvp_master"] = 2
    exp["empire_globalpvp_strangerbar_enable"] = 2
    exp["empire_alliances_master"] = 3
    exp["empire_alliances_phase_4"] = 3
    exp["empire_alliances_quest_connections"] = 3
    exp["empire_alliances_quest_power"] = 3
    exp["empire_survivalmode3_master"] = 3
    exp["empire_survivalMode_master"] = 2
    exp["empire_survivalmode_enhancements"] = 2
    exp["empire_leaderboard_summary"] = 1
    exp["empire_blackmarket_master"] = 2
    unlock_expansion(156)
    unlock_expansion(157)
    unlock_expansion(181)
    unlock_expansion(182)
    unlock_expansion(206)
    unlock_expansion(207)

    # Ensure quest gates and resource counters (wood, oil, rare ores) are unlocked and visible
    player_data = session['user_object']["userInfo"]["player"]
    player_data["questGatesComplete"] = True
    default_unlocked_res = {"wood": 1, "oil": 1, "aluminum": 3, "copper": 4, "gold": 5, "iron": 6, "uranium": 7}
    if not player_data.get("unlockedResource"):
        player_data["unlockedResource"] = default_unlocked_res.copy()
    if not session['user_object'].get("unlockedResource"):
        session['user_object']["unlockedResource"] = default_unlocked_res.copy()

    # Ensure player has starting oil if depleted
    world_res = session['user_object']["userInfo"]["world"].setdefault("resources", {})
    if world_res.get("oil", 0) <= 0:
        world_res["oil"] = 50
    if world_res.get("copper", 0) <= 0:
        world_res["copper"] = 250
    if world_res.get("gold", 0) <= 0:
        world_res["gold"] = 250
    if world_res.get("iron", 0) <= 0:
        world_res["iron"] = 250
    if world_res.get("uranium", 0) <= 0:
        world_res["uranium"] = 100
    # battle_status = 0
    # island = 2
    # replay_island = 0
    #
    # status_campaign = battle_status | replay_island << 8 | island << 20
    # status_campaign_2 = battle_status | replay_island << 8 | 5 << 20
    # # #
    # user['userInfo']['world']['campaign'] = {"current": "camp001", "active":{'C000': {"status": status_campaign, "fleets":[]},
    #                                                                        'C003': {"status": status_campaign_2, "fleets":[]}}, "mastery": {}}

    camp = user['userInfo']['world'].setdefault('campaign', {"current": "camp001", "active": {}, "mastery": {}})
    if not camp.get('current'):
        camp['current'] = 'camp001'
    if 'C000' not in camp.setdefault('active', {}):
        camp['active']['C000'] = {"status": 0, "fleets": []}
    completed_quests = user.setdefault('completedQuests', [])
    if 'Q1061' not in completed_quests:
        completed_quests.append('Q1061')

    # session['campaign'] = {}
    # session['campaign']['C003'] = {'island':4} #will receive a next "island": 1

    # if ""B01": 20"


    item_inventory = session['user_object']["userInfo"]["player"]["inventory"]["items"]
    if item_inventory.get("B01", 0) < 20:
        item_inventory["B01"] = 20
        print("Refilling upgrade blueprints to 20")  # until friend gift mechanisms are working
    if item_inventory.get("B05", 0) < 25:
        item_inventory["B05"] = 25
        print("Refilling advanced hull plating to 25")  # until friend gift mechanisms are working
    if item_inventory.get("B18", 0) < 25:
        item_inventory["B18"] = 25
        print("Refilling propeller to 25")  # until friend gift mechanisms are working
    if item_inventory.get("B04", 0) < 25:
        item_inventory["B04"] = 25
        print("Refilling mission map to 25")  # until friend gift mechanisms are working
    if item_inventory.get("B23", 0) < 25:
        item_inventory["B23"] = 25
        print("Refilling blast shield to 25")  # until friend gift mechanisms are working
    if item_inventory.get("B17", 0) < 25:
        item_inventory["B17"] = 25
        print("Refilling deck turret to 25")  # until friend gift mechanisms are working

    mechLab_inventory_req = session['user_object']["userInfo"]["player"]["xp"]
    # Set level 21 (1881 xp) for all players to get Titan Lab in inventory
    # Every session should only get it once.
    if (
        mechLab_inventory_req > 1880
        and not any(i["itemName"] == "MechLab" for i in session['user_object']["userInfo"]["world"]["objects"])
        and item_inventory.get("TL01", 0) < 1
    ):
        item_inventory["TL01"] = 1
        print("Level 21 has been reached, Titan Lab unlocked at inventory")

    handle_quest_progress(meta, progress_inventory_count())
    handle_quest_progress(meta, progress_neighbor_count())
    handle_quest_progress(meta, progress_upgrades_count())

    activate_unlocked_quests(new_quests, meta)

    for neighbor in user["neighbors"]:
        if neighbor["uid"] in [MIN_ADMIN_ID, MAX_ADMIN_ID]:
            neighbor["level"] =  user["userInfo"]["player"]["level"] + 5

    if session.get('save_version') != version or is_0_08a_preview(version):
        print("Trying migration")
        migrate(meta, session.get('save_version'), version)

    # sleep(0.05)  # Legacy delay no longer needed with PostgreSQL & Granian

    # for e in session['user_object']["userInfo"]["world"]["objects"]:
    #     e['lastUpdated'] = 1308211628  #1 minute earlier to test
    user["completedQuests"] = [e["name"] for e in session['quests'] if e["complete"]]

    merge_quest_progress(new_quests, meta['QuestComponent'], "output quest")
    merge_quest_progress(new_quests, session['quests'], "session quest")
    user_response = {"errorType": 0, "userId": get_zid(), "metadata": meta,
                     # {"name": "Q0531", "complete":False, "expired":False,"progress":[0],"completedTasks":0},{"name": "QW120", "complete":False, "expired":False,"progress":[0],"completedTasks":0}
                     "data": user}
    return user_response


def tutorial_response(step, sequence, endpoint):
    meta = {"newPVE": 0}
    qz = {"name": "Q0516", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}
    qz_cadets_start = {"name": "Q0531", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    # complete cadets?
    qz_cadets_start = {"name": "Q0531", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    qz_cadets_done = {"name": "Q0531", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}
    qz_invasion_start = {"name": "Q6016", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    qz_invasion_done = {"name": "Q6016", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}
    flag_Q1098_start = {"name": "Q1098", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    flag_Q1098_done = {"name": "Q1098", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}
    cadets_Q0611_start = {"name": "Q0611", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    cadets_Q0611_done = {"name": "Q0611", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}
    flag_Q6011_start = {"name": "Q6011", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    flag_Q6011_done = {"name": "Q6011", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}

    sergeant_Q0671_start = {"name": "Q0671", "complete": False, "expired": False, "progress": [0, 0],
                            "completedTasks": 0}  # after 6011
    sergeant_Q0671_done = {"name": "Q0671", "complete": True, "expired": False, "progress": [1, 1], "completedTasks": 2}
    flag_Q0591_start = {"name": "Q0591", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    flag_Q0591_done = {"name": "Q0591", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}
    farm_Q0571_start = {"name": "Q0571", "complete": False, "expired": False, "progress": [0, 0], "completedTasks": 0}
    farm_Q0571_done = {"name": "Q0571", "complete": True, "expired": False, "progress": [1, 1], "completedTasks": 2}
    corn_Q0521_start = {"name": "Q0521", "complete": False, "expired": False, "progress": [0], "completedTasks": 0}
    corn_Q0521_done = {"name": "Q0521", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}
    parliament_Q0691_start = {"name": "Q0691", "complete": False, "expired": False, "progress": [0],
                              "completedTasks": 0}
    parliament_Q0691_done = {"name": "Q0691", "complete": True, "expired": False, "progress": [1], "completedTasks": 1}

    # if step == 'tut_step_placeBarracksServer':
    #     meta['QuestComponent'] = [qz, qz_cadets_start]
    # if step == 'tut_step_cadetsComplete':
    #     pass
    # handle_quest_progress(meta, progress_action("build")) build is covered
    # meta['QuestComponent'] = [qz_cadets_done, qz_invasion_start]  #what starts invasion?
    ## meta["newPVE"] = {"status": 2, "pos": "60,63,0", "villain":"v18", "quest":"Q6016"}
    # if step == 'tut_step_firstInvasionEnd':
    # if step == 'tut_step_postFirstInvasionResumeQuests':
    #     handle_quest_progress(meta, progress_action(
    #         "fight"))
    # meta['QuestComponent'] = [qz_invasion_done,flag_Q1098_start,cadets_Q0611_start]
    #  meta["newPVE"] = {"status": 2, "pos": "60,66,0", "villain":"v18", "quest":"Q6016"}  #contineous battle mode experience QT01_05b_2
    # if step == 'tut_step_placeFlagQuestDialog':
    #     meta['QuestComponent'] = [flag_Q1098_done, flag_Q6011_start]

    # if step == 'tut_step_placeFlagWaitForInventoryOpen':   # sometimes one of them is skipped?
    #     meta['QuestComponent'] = [flag_Q1098_done, flag_Q6011_start]
    # if step == 'tut_step_placeFlagEnd':
    #     meta['QuestComponent'] = [flag_Q6011_done, sergeant_Q0671_start, flag_Q0591_start]
    # if step == 'tut_step_buildFarm':  #after cadets placed?
    #     meta['QuestComponent'] = [cadets_Q0611_done, sergeant_Q0671_start] #possibly already done by this point see if it doesn't redo quests already done
    # if step == 'tut_step_placeHouseEnd':  #after cadets placed?
    #     meta['QuestComponent'] = [flag_Q0591_done, farm_Q0571_start]
    # if step == 'tut_step_placeFarmEnd':  #after cadets placed?
    #     meta['QuestComponent'] = [farm_Q0571_done, corn_Q0521_start, parliament_Q0691_start, sergeant_Q0671_start]
    #
    if step == 'tut_step_inviteFriendsEndPauseTutorial':
        handle_quest_progress(meta, progress_neighbor_count())

    merge_quest_progress(meta.get('QuestComponent', []), session['quests'], "session quest")
    session['user_object']["userInfo"]["player"]["tutorialProgress"] = step  # TODO: revert step when loading if needed

    report_tutorial_step(step, meta.get('QuestComponent'), meta['newPVE'], sequence,
                         endpoint)
    tutorial_response = {"errorType": 0, "userId": 1, "metadata": meta,
                         "data": []}
    return tutorial_response


def seen_flag_response(flag):
    seen_flags = session['user_object']["userInfo"]["player"]["seenFlags"]

    seen_flags[flag] = seen_flags.get(flag, 0) + 1

    seen_flag_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                          "data": []}
    return seen_flag_response


def generic_string_response(param):
    meta = {"newPVE": 0}
    handle_quest_progress(meta, all_lambda(progress_action("genericString"),
                                           progress_parameter_equals("_string", str(param))))

    generic_string_response = {"errorType": 0, "userId": 1, "metadata": meta,
                               "data": []}
    return generic_string_response


def streak_bonus_response(param):
    meta = {"newPVE": 0}

    do_rewards("Streak", {"_type": "coins", "_count": param["amount"]}, meta)

    streak_bonus_response = {"errorType": 0, "userId": 1, "metadata": meta,
                             "data": []}
    return streak_bonus_response


def save_options_response(options):
    save_options_response = {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0},
                             "data": []}
    session['user_object']["userInfo"]["player"]["options"] = options
    return save_options_response


def full_screen_response():
    meta = {"newPVE": 0}
    handle_quest_progress(meta, progress_action("fullscreen"))
    full_screen_response = {"errorType": 0, "userId": 1, "metadata": meta,
                            "data": []}
    return full_screen_response


def view_zoom_response(zoom):
    meta = {"newPVE": 0}
    handle_quest_progress(meta, all_lambda(progress_action("zoom"), progress_parameter_equals("_zoom", str(zoom))))
    view_zoom_response = {"errorType": 0, "userId": 1, "metadata": meta,
                          "data": []}
    return view_zoom_response


def motd_action_response(param):
    """`UserService.motdAction` -- registrar acciones del MOTD."""
    meta = {"newPVE": 0}
    if isinstance(param, dict) and _economy_session():
        player = session['user_object']["userInfo"]["player"]
        motd_id = param.get("motdId") or param.get("id") or param.get("name")
        action = param.get("action", "viewed")
        if motd_id:
            if action == "accepted":
                accepted = player.setdefault("motdsAccepted", [])
                if motd_id not in accepted:
                    accepted.append(motd_id)
            else:
                viewed = player.setdefault("motdsViewed", [])
                if motd_id not in viewed:
                    viewed.append(motd_id)
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def open_dialog_response(param=None):
    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": []}


def calculate_ransom_response(param=None):
    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": {"ransom": 100, "resource": "coins"}}


def feed_response(param=None):
    return {"errorType": 0, "userId": 1, "metadata": {"newPVE": 0}, "data": []}


def clear_incentive_response(param):
    """`UserService.clearIncentive` -- marcar un incentivo/promo como limpio."""
    meta = {"newPVE": 0}
    if isinstance(param, dict) and _economy_session():
        player = session['user_object']["userInfo"]["player"]
        inc_id = param.get("incentiveId") or param.get("id") or param.get("name")
        if inc_id:
            cleared = player.setdefault("clearedIncentives", [])
            if inc_id not in cleared:
                cleared.append(inc_id)
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def do_seen_quest_notification_response(param):
    """`UserService.doSeenQuestNotification` -- marcar notificacion de quest como vista."""
    meta = {"newPVE": 0}
    if isinstance(param, dict) and _economy_session():
        player = session['user_object']["userInfo"]["player"]
        quest_name = param.get("quest") or param.get("name")
        task_id = param.get("task", 0)
        if quest_name:
            seen_flags = player.setdefault("seenFlags", {})
            seen_flags[f"quest_seen_{quest_name}_{task_id}"] = 1
    return {"errorType": 0, "userId": 1, "metadata": meta, "data": []}


def select_response(param):
    meta = {"newPVE": 0}
    handle_quest_progress(meta, all_lambda(progress_action("select"),
                                           progress_parameter_equals("_item", param['itemCode'])))
    select_response = {"errorType": 0, "userId": 1, "metadata": meta,
                          "data": []}
    return select_response

