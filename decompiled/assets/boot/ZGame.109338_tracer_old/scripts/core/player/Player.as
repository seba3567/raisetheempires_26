package core.player
{
   import Engine.Classes.SocialNetworkUser;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import ZLocalization.LocalizationName;
   import ZLocalization.LocalizationObjectToken;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.EnergyRefillItem;
   import core.gameobjects.Fleet;
   import core.gameobjects.GameItem;
   import core.gameobjects.PlayerCampaign;
   import core.gameobjects.PlayerFleets;
   import core.gameobjects.RewardHelper;
   import core.gameobjects.Unit;
   import core.gameobjects.UnitItem;
   import core.managers.AlliancesManager;
   import core.managers.BountyCenterManager;
   import core.managers.BuildManager;
   import core.managers.BuyBackManager;
   import core.managers.CrewManager;
   import core.managers.EnergiserManager;
   import core.managers.ExperimentsManager;
   import core.managers.LEUnitFactoryManager;
   import core.managers.MOTDManager.MOTDMerchManager;
   import core.managers.MatchMakingManager;
   import core.managers.MegaseriesManager;
   import core.managers.PopulationManager;
   import core.managers.PriceTestManager;
   import core.managers.UnitContractUnlockManager;
   import core.managers.WorldObjectManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.battleManager.BattleManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.mayhemManager.MayhemManager;
   import core.managers.miniGameManager.BomberGameManager;
   import core.managers.promoManager.PromoManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.viralsManager.ViralsManager;
   import core.managers.visitorManager.VisitorManager;
   import core.managers.warehouseManager.WarehouseUnitManager;
   import core.managers.worldUnitManager.WorldUnitManager;
   import core.permission.PermissionManager;
   import core.player.questTrees.PlayerQuestTrees;
   import core.resource.WorldResource;
   import core.ui.PlayerFeedbackManager;
   import core.ui.UI;
   import core.ui.UIDirector.CampaignV2DirectorScript;
   import dispatchers.ExperienceDispatcher;
   import dispatchers.MessageDispatcher;
   import dispatchers.NeighborsDispatcher;
   import dispatchers.ResourceDispatcher;
   import dispatchers.StrategicDispatcher;
   import dispatchers.UIDispatcher;
   import displays.cinema.IntroCinematics;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.RequirementsPopup;
   import displays.popups.RequirementsPopupInfoPopCap;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.popups.genericPopup.NotEnoughCashPopup;
   import displays.popups.obtainRequirement.IObtainRequirementPopupInfo;
   import displays.popups.obtainRequirement.ObtainMultiRequirementsInfoGameItem;
   import displays.popups.obtainRequirement.ObtainMultiRequirementsPopup;
   import displays.popups.obtainRequirement.ObtainRequirementPopup;
   import displays.popups.obtainRequirement.ObtainRequirementPopupInfoGameItem;
   import displays.popups.obtainRequirement.ObtainRequirementPopupInfoGameItemPurchase;
   import displays.popups.obtainRequirement.ObtainRequirementPopupInfoResourcePurchase;
   import displays.popups.obtainRequirement.OneClickBuyPopup;
   import displays.screens.UnlockMorePopup;
   import displays.screens.requests.RequestDialog;
   import events.ExperienceUpdatedEvent;
   import events.MarketEvent;
   import events.NeighborsEvent;
   import events.ResourceUpdatedEvent;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import transactions.TBuyItem;
   import transactions.TBuyItems;
   import transactions.TBuyRewardItem;
   import transactions.TSetSeenFlag;
   import transactions.TUnlockResource;
   import utils.BitArray;
   import utils.CriteriaUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.components.LocalDataComponent;
   import zlabs.components.ThinkingComponent;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.sound.SoundManager;
   import zlabs.utils.MathUtils;
   import zlabs.utils.StringUtils;
   
   public class Player extends ThinkingComponent implements IPVPPlayer
   {
      
      public static const REQUEST_FRIENDS_LOADED:String = "requestFriendsLoaded";
      
      public static const XP_MULT_CHANGED:String = "xpMultChanged";
      
      public static const FAKE_PLAYER_ID:String = "-1";
      
      public static const SURVIVAL_MODE_ALY_ID:String = "-2";
      
      public static const MW2_XPROMO_ALLY_ID:String = "-3";
      
      public static const CASTLE_XPROMO_ALLY_ID:String = "-4";
      
      public static const HC_XPROMO_ALLY_ID:String = "-5";
      
      public static const FRIENDS_ALL:String = "all";
      
      public static const FRIENDS_RECOMMENDED:String = "recommended";
      
      public static const FRIENDS_ZYNGA:String = "zynga";
      
      public static const FRIENDS_EMPIRES:String = "empires";
      
      public static const FRIENDS_7DAY:String = "7days";
      
      public static const FRIENDS_14DAY:String = "14days";
      
      public static const FRIENDS_30DAY:String = "30days";
      
      public static const FRIENDS_PAYERS:String = "payers";
      
      public static const FRIENDS_ALL_SNAPI:String = "snapi_all";
      
      public static const FRIENDS_MATCHMAKING:String = "matchmaking";
      
      public static const FRIENDS_ALL_ENGAGEMENT:String = "all_engagement";
      
      public static const FRIENDS_ZYNGA_ENGAGEMENT:String = "zynga_engagement";
      
      public static const FRIENDS_EMPIRE_ENGAGEMENT:String = "empire_engagement";
      
      public static const GATE_SUCCESS:int = 0;
      
      public static const GATE_FAILURE_LEVEL:int = 1;
      
      public static const GATE_FAILURE_NEIGHBORS:int = 2;
      
      public static const GATE_FAILURE_WORKERS:int = 3;
      
      public static const GATE_FAILURE_QUEST:int = 4;
      
      public static const GATE_FAILURE_CAMPAIGN:int = 5;
      
      public static const GATE_FAILURE_EXCEEDS_POPULATION:int = 6;
      
      public static const GATE_FAILURE_EXCEEDS_LIMIT:int = 7;
      
      public static const GATE_FAILURE_TUTORIAL_LOCKED:int = 8;
      
      public static const GATE_FAILURE_DATE:int = 9;
      
      public static const GATE_FAILURE_CONTRACT_LOCKED:int = 10;
      
      public static const GATE_FAILURE_EXCEEDS_LIMIT_IN_INVENTORY:int = 11;
      
      public static const GATE_FAILURE_EXPERIMENT:int = 12;
      
      public static const GATE_FAILURE_CONSUMABLES_USED:int = 13;
      
      public static const GATE_FAILURE_DOMINANCE:int = 14;
      
      public static const GATE_FAILURE_TITAN_LAB:int = 15;
      
      public static const MIN_LE_VISIBLE_LEVEL:int = 7;
      
      public static const RESEARCH_LE_ON:int = 3;
      
      public static const INVENTORY_UPDATED:String = "inventoryUpdated";
      
      public static const QUEST_LABELS_UPDATED:String = "questlabelsupdated";
      
      public static const LAST_SEEN_SPEECHES_CATEGORY:String = "lastSeenSpeeches";
      
      public static const LAST_SEEN_DIALOGS_CATEGORY:String = "lastSeenDialogs";
      
      public static const LAST_SEEN_CONVERSATIONS_CATEGORY:String = "lastSeenConversations";
      
      public static const CONTRACT_UNLOCKED:String = "contractUnlocked";
      
      public static const HAS_SEEN_TITAN_BATTLE:String = "playerTitanBattle";
      
      public static const HAS_SEEN_TITAN_BATTLE_QT057:String = "playerTitanBattle_QT057";
      
      public static const T8_PAYER_GROUP_ID:int = 1;
      
      private static const PREMIUM_ITEM:String = "premiumItem";
      
      private static const STATS_INFO:String = "statsInfo";
      
      private static const CALL_BACK_ON_BUY:String = "callBackOnBuy";
      
      private static const CALL_BACK_ON_CANCEL:String = "callBackOnCancel";
      
      private static const BUY_ON_PLACEMENT:String = "buyOnPlacement";
      
      private static const BUY_CALLBACK_INFO:String = "buyCallbackInfo";
      
      public const SEEN_EXTENDED_PERMISSIONS_ANY:String = "any";
      
      private const MAX_NUM_SPEECHES:Number = 10;
      
      private const MAX_NUM_CONVERSATIONS:Number = 10;
      
      public var m_name:String;
      
      public var m_worldName:String;
      
      public var m_titanName:String;
      
      public var snUser:SocialNetworkUser;
      
      protected var m_friends:Array;
      
      protected var m_recommendedFriends:Array;
      
      protected var m_zyngaFriends:Array;
      
      protected var m_empireFriends:Array;
      
      protected var m_7dayFriends:Array;
      
      protected var m_14dayFriends:Array;
      
      protected var m_30dayFriends:Array;
      
      protected var m_payerFriends:Array;
      
      protected var m_allFriends:Array;
      
      protected var m_matchmakingFriends:Array;
      
      protected var m_allFriendsByEngagement:Array;
      
      protected var m_zyngaFriendsByEngagement:Array;
      
      protected var m_empireFriendsByEngagement:Array;
      
      protected var m_asn:Number;
      
      protected var m_questInitAsn:Object;
      
      protected var m_partsGatherInitAsn:Object;
      
      protected var m_activeRequests:Dictionary;
      
      protected var m_activeGiftRequests:Array;
      
      protected var m_activeHelpRequests:Array;
      
      protected var m_pendingNeighbors:Array;
      
      protected var m_nonFriendInfo:Dictionary = new Dictionary();
      
      protected var m_appFriends:Array;
      
      protected var m_hasFriendsSNData:Boolean = false;
      
      private var m_resources:PlayerResources = null;
      
      private var m_allies:PlayerAllies = null;
      
      private var m_playerFleets:PlayerFleets = null;
      
      private var m_playerCampaign:PlayerCampaign = null;
      
      protected var m_level:Number;
      
      protected var m_xp:Number;
      
      public var m_energy:PlayerEnergy = new PlayerEnergy();
      
      public var m_ammo:PlayerAmmo = new PlayerAmmo();
      
      private var m_mana:PlayerMana = null;
      
      private var m_questTrees:PlayerQuestTrees = null;
      
      private var m_questGatesComplete:Boolean = false;
      
      protected var m_socialLevelGood:Number = 1;
      
      protected var m_socialXpGood:Number = 0;
      
      protected var m_socialLevelBad:Number = 1;
      
      protected var m_socialXpBad:Number = 0;
      
      protected var m_visitorEnergy:int;
      
      protected var m_originalVisitorEnergy:int;
      
      protected var m_cash:Number;
      
      protected var m_scrap:Number;
      
      protected var m_numCashTransactions:Number;
      
      protected var m_cashPurchasedTotal:Number;
      
      protected var m_secondsSinceLastEPPurchase:int = -1;
      
      protected var m_neighbors:Dictionary = null;
      
      private var m_neighborVisits:Dictionary = null;
      
      public var m_friendsLoaded:Boolean = false;
      
      public var topFriends:Array = [];
      
      protected var m_missionItemInventory:Array = null;
      
      protected var m_gifts:Dictionary = null;
      
      protected var m_promos:Object = null;
      
      protected var m_autopromo:Object = null;
      
      protected var m_motdMerchHistory:Object = null;
      
      protected var m_motdMerchUnlockHistory:Object = null;
      
      private var m_newInstallExperiments:Object = null;
      
      protected var m_inventory:Dictionary = null;
      
      protected var m_tempUsedItems:Dictionary = null;
      
      protected var m_options:Object = null;
      
      private var m_shownAchievementDialogs:Object = null;
      
      private var m_seenFlags:Object = null;
      
      private var m_seenSessionFlags:Object = null;
      
      private var m_gaveCoins:Boolean = false;
      
      private var m_inGaveCoins:Boolean = false;
      
      private var m_cpStatic:uint;
      
      private var m_lightningDealInfo:Object;
      
      private var m_friendFlashInfo:Object;
      
      private var m_friendFlashEPBank:int;
      
      private var m_friendFlashEPBankHold:int;
      
      private var m_meetsCriteriaLowWalletOnly:Boolean = true;
      
      protected var m_userGroups:Array = [];
      
      private var m_rareResourceType:int;
      
      private var m_loaded:Boolean = false;
      
      private var m_tutorialProgress:String = null;
      
      private var m_expansions:BitArray = null;
      
      private var m_lastSeenDialogs:Object = null;
      
      private var m_lastSeenSpeeches:Array = null;
      
      private var m_lastSeenConversations:Array = null;
      
      private var m_unlockedUnits:Array = null;
      
      private var m_unlockedItems:Array = null;
      
      private var m_unlockedContracts:Array = null;
      
      private var m_unlockedResource:Object = null;
      
      private var m_deferredLoc:Boolean = false;
      
      private var m_motdsViewed:Array = null;
      
      private var m_motdsAccepted:Array = null;
      
      private var m_completedQuestNames:Array = null;
      
      private var m_tags:Object = null;
      
      private var m_seenOreNeighborInfo:Boolean = false;
      
      private var m_timeWarpSeconds:int = 0;
      
      private var m_showWorldGamesSpeech:int = 0;
      
      private var m_lastLoginTimestamp:int = 0;
      
      private var m_isRUXActive:Boolean = false;
      
      private var m_isRUXQuestActive:Boolean = false;
      
      private var m_activeRUXDay:int = 0;
      
      private var m_showRUXInit:Boolean = false;
      
      private var m_ruxDelta:Number = 0;
      
      private var m_xpMultiplier:Number = 1;
      
      public var m_oreNonNeighbors:Dictionary = new Dictionary();
      
      public var m_oreNeighbors:Dictionary = new Dictionary();
      
      public var m_showAnnoyingInventoryDialog:Array = null;
      
      private var m_multiRequirementItemInfo:ObtainMultiRequirementsInfoGameItem = null;
      
      private var m_transactionLog:Array = null;
      
      private var m_giftRequestSent:Dictionary;
      
      private var m_helpRequestSent:Dictionary;
      
      private var m_crewRequestSent:Dictionary;
      
      private var m_neighborRequestSent:Dictionary;
      
      private var m_repelInvasionRequestSent:Dictionary;
      
      private var m_allianceInviteRequestSent:Dictionary;
      
      private var m_enableIdlePopup:Boolean = true;
      
      private var m_enableInterPage:Boolean = true;
      
      private var m_enableOnetimePopup:Boolean = true;
      
      private var m_consumableUsedByCode:Object = null;
      
      public var m_treasureVaultOpenTS:Number = 0;
      
      public var m_flashFeedTokens:int = 0;
      
      public var m_survialModeToasterTime:Number;
      
      private var m_clanStatus:String = null;
      
      private var m_starredQuests:Dictionary = new Dictionary();
      
      private var m_questsWithNotifications:Dictionary = new Dictionary();
      
      private var m_seenQuestsNotifications:Dictionary = new Dictionary();
      
      private var m_sortedStarredQuests:Array = new Array();
      
      private var m_favCount:int = 0;
      
      private var m_timedCount:int = 0;
      
      private var m_permMgr:PermissionManager = new PermissionManager();
      
      protected var m_isCIP:Boolean = false;
      
      protected var m_acceptedGDP:Boolean = false;
      
      protected var m_acceptedTOS:Boolean = false;
      
      protected var m_recheckedCIP:Boolean = false;
      
      private var m_combatSpecialBits:int = 0;
      
      public var allianceStorage:Object = new Array();
      
      public var m_acceptedAlianceQuests:Array = new Array();
      
      public var COMBAT_NO_ENERGY:String;
      
      public var COMBAT_DOUBLE_XP:String;
      
      public var COMBAT_HALF_RANSOM:String;
      
      public var m_currentQuestBattleId:String;
      
      public var MFSRewardPoints:int = 0;
      
      public var MFSRewardClaimed:Boolean = true;
      
      public var MFSRewardLap:int = 0;
      
      public var allianceQuestReq:int = 0;
      
      public function Player(param1:SocialNetworkUser)
      {
         super();
         if(param1)
         {
            this.m_name = param1.name;
            this.snUser = param1;
         }
         this.m_friends = new Array();
         this.m_recommendedFriends = new Array();
         this.m_zyngaFriends = new Array();
         this.m_empireFriends = new Array();
         this.m_7dayFriends = new Array();
         this.m_14dayFriends = new Array();
         this.m_payerFriends = new Array();
         this.m_30dayFriends = new Array();
         this.m_allFriends = new Array();
         this.m_matchmakingFriends = new Array();
         this.m_activeRequests = new Dictionary();
         this.m_activeGiftRequests = new Array();
         this.m_activeHelpRequests = new Array();
         this.m_pendingNeighbors = new Array();
         this.m_giftRequestSent = new Dictionary();
         this.m_helpRequestSent = new Dictionary();
         this.m_crewRequestSent = new Dictionary();
         this.m_neighborRequestSent = new Dictionary();
         this.m_allianceInviteRequestSent = new Dictionary();
         this.m_repelInvasionRequestSent = new Dictionary();
         this.m_showAnnoyingInventoryDialog = new Array();
         this.m_showAnnoyingInventoryDialog["army"] = true;
         this.m_showAnnoyingInventoryDialog["air"] = true;
         this.m_showAnnoyingInventoryDialog["navy"] = true;
         this.m_showAnnoyingInventoryDialog["military"] = true;
         this.m_questInitAsn = new Object();
         this.m_partsGatherInitAsn = new Object();
         this.m_asn = 1;
      }
      
      public static function GetWorldName(param1:String, param2:String) : String
      {
         return ZGameUtils.ZlocT("Main","WorldName",{"player":ZLoc.tn(param1,param2 == "F" ? ZLoc.instance.FEM : ZLoc.instance.MASC)});
      }
      
      public static function isProgressNewPlayer(param1:int = -1) : Boolean
      {
         return !TutorialManager.instance.isComplete(param1);
      }
      
      public function initLocalPlayer() : void
      {
         this.m_resources = new PlayerResources();
         this.m_neighbors = new Dictionary();
         this.m_gifts = new Dictionary();
         this.m_promos = new Object();
         this.m_motdMerchHistory = new Object();
         this.m_motdMerchUnlockHistory = new Object();
         this.m_inventory = new Dictionary();
         this.m_missionItemInventory = [];
         this.m_options = {};
         this.m_shownAchievementDialogs = {};
         this.m_seenFlags = {};
         this.m_seenSessionFlags = {};
         this.m_lastSeenDialogs = new Object();
         this.m_lastSeenSpeeches = new Array();
         MessageDispatcher.instance.addEventListener(MessageDispatcher.ITEM_GIFT,this.onItemGift);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.RESOURCE_GIFT,this.onResourceGift);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.XP_GIFT,this.onXPGift);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.NEIGHBOR,this.onNewNeighbor);
         TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,this.onTransactionComplete,false,0,true);
         var _loc1_:int = WorldResourceManager.instance.firstRareResourceIndex;
         var _loc2_:int = WorldResourceManager.instance.numRareResources;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            this.m_oreNonNeighbors[_loc3_ + _loc1_] = new Array();
            _loc3_++;
         }
      }
      
      public function getSaveObject() : Object
      {
         var _loc1_:Object = new Object();
         _loc1_.level = this.level;
         _loc1_.cash = this.cash;
         _loc1_.xp = this.xp;
         _loc1_.energy = this.m_energy.energy;
         _loc1_.energyMax = this.m_energy.energyMax;
         _loc1_.ammo = this.m_ammo.ammo;
         _loc1_.ammoMax = this.m_ammo.ammoMax;
         _loc1_.neighbors = this.neighbors;
         _loc1_.options = this.options;
         return _loc1_;
      }
      
      public function get playerName() : String
      {
         return this.m_name;
      }
      
      public function get worldName() : String
      {
         return this.m_worldName;
      }
      
      public function get titanName() : String
      {
         return this.m_titanName;
      }
      
      public function get seenOreNeighborInfo() : Boolean
      {
         return this.m_seenOreNeighborInfo;
      }
      
      public function get oreNeighbors() : Dictionary
      {
         return this.m_oreNeighbors;
      }
      
      public function get tutorialProgress() : String
      {
         return this.m_tutorialProgress;
      }
      
      public function get expansions() : BitArray
      {
         return this.m_expansions;
      }
      
      public function get isAtMaxExpansions() : Boolean
      {
         var _loc1_:int = MathUtils.EXPANSION_NUM_CELLS * MathUtils.EXPANSION_NUM_CELLS;
         var _loc2_:int = int(this.m_expansions.numBitsSet());
         return _loc1_ <= _loc2_;
      }
      
      public function get userGroups() : Array
      {
         return this.m_userGroups;
      }
      
      public function set userGroups(param1:Array) : void
      {
         this.m_userGroups = param1;
      }
      
      public function get timeWarpSeconds() : int
      {
         return this.m_timeWarpSeconds;
      }
      
      public function get showWorldGamesSpeech() : int
      {
         return this.m_showWorldGamesSpeech;
      }
      
      public function get lastLoginTimestamp() : int
      {
         return this.m_lastLoginTimestamp;
      }
      
      public function get isRUXActive() : Boolean
      {
         return this.m_isRUXActive;
      }
      
      public function set isRUXActive(param1:Boolean) : void
      {
         this.m_isRUXActive = param1;
      }
      
      public function get isRUXQuestActive() : Boolean
      {
         return this.m_isRUXQuestActive;
      }
      
      public function set isRUXQuestActive(param1:Boolean) : void
      {
         this.m_isRUXQuestActive = param1;
      }
      
      public function get activeRUXDay() : int
      {
         return this.m_activeRUXDay;
      }
      
      public function get showRUXInit() : Boolean
      {
         return this.m_showRUXInit;
      }
      
      public function get ruxDelta() : int
      {
         return this.m_ruxDelta;
      }
      
      public function get questGatesComplete() : Boolean
      {
         return Config.DEBUG_MODE && this.m_questGatesComplete;
      }
      
      public function get favCount() : int
      {
         return this.m_favCount;
      }
      
      public function set favCount(param1:int) : void
      {
         this.m_favCount = param1;
      }
      
      public function get timedCount() : int
      {
         return this.m_timedCount;
      }
      
      public function set timedCount(param1:int) : void
      {
         this.m_timedCount = param1;
      }
      
      public function storeNonFriendInfo(param1:Object) : void
      {
         var _loc2_:Object = null;
         for each(_loc2_ in param1)
         {
            this.m_nonFriendInfo[_loc2_.uid] = _loc2_;
         }
      }
      
      public function preLoadObject(param1:Object) : void
      {
         var _loc2_:* = 0;
         if(null != param1.player)
         {
            this.xpMultiplier = param1.player.xp_multiplier;
            this.m_cpStatic = param1.player.cp_static;
            this.m_lightningDealInfo = param1.player.lightningDeals;
            this.m_friendFlashInfo = param1.player.friendFlashSessionInfo;
            this.m_friendFlashEPBank = param1.player.friendFlashEPBank;
            this.m_rareResourceType = param1.player.playerResourceType;
            this.m_meetsCriteriaLowWalletOnly = param1.player.meetsCriteriaLowWalletOnly;
            this.m_newInstallExperiments = param1.player.newInstallExperiments;
            if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
            {
               PopulationManager.instance.staticWorkers = param1.player.staticWorkers;
               PopulationManager.instance.staticWorkersCap = param1.player.staticWorkersCap;
            }
            if(this.uid == FAKE_PLAYER_ID)
            {
               _loc2_ = 195;
               this.m_expansions = new BitArray([],_loc2_ + 1);
               while(_loc2_ > 0)
               {
                  this.m_expansions.setBit(_loc2_);
                  _loc2_--;
               }
            }
            else if(Boolean(param1.player.expansions) && Boolean(param1.player.expansions.data))
            {
               this.m_expansions = new BitArray(param1.player.expansions.data);
            }
            else
            {
               this.m_expansions = new BitArray([]);
            }
            this.m_questTrees = new PlayerQuestTrees(param1.player);
            if(param1.player.starredQuests)
            {
               this.setStarredQuestNames(param1.player.starredQuests);
            }
            if(param1.player.seenQuests)
            {
               this.setSeenNotificationQuestNames(param1.player.seenQuests);
            }
            MegaseriesManager.instance.setActiveMS(param1.player);
            this.m_questGatesComplete = param1.player.questGatesComplete;
            this.m_timeWarpSeconds = param1.player.warpSeconds;
            this.m_showWorldGamesSpeech = param1.player.worldGamesOver;
            this.m_lastLoginTimestamp = param1.player.lastLoginTimestamp;
            this.m_isRUXActive = param1.player.RUXStatus;
            this.m_isRUXQuestActive = param1.player.RUXQuest;
            this.m_activeRUXDay = param1.player.RUXDay;
            this.m_showRUXInit = param1.player.RUXInitShow;
            this.m_ruxDelta = param1.player.RUXDelta;
            this.MFSRewardPoints = param1.player.MFSRewardPoints;
            this.MFSRewardClaimed = Boolean(param1.player.MFSRewardClaimed) && param1.player.MFSRewardClaimed != "0";
            this.MFSRewardLap = param1.player.MFSRewardLap;
         }
         this.setFleets(param1.world);
      }
      
      public function loadObject(param1:Object) : void
      {
         var _loc7_:Array = null;
         var _loc8_:Object = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:Object = null;
         var _loc2_:Object = param1.player;
         this.m_resources.init(param1.world.resources);
         this.m_energy.init(_loc2_);
         this.m_ammo.init(_loc2_);
         this.m_mana = new PlayerMana(_loc2_);
         this.cash = _loc2_.cash;
         this.level = _loc2_.level;
         this.xp = _loc2_.xp;
         this.m_numCashTransactions = _loc2_.numCashTransactions;
         this.m_cashPurchasedTotal = _loc2_.cashPurchasedTotal;
         this.m_transactionLog = _loc2_.transactionLog;
         this.m_combatSpecialBits = _loc2_.combatSpecialBits;
         if(Boolean(_loc2_.transactionLog) && _loc2_.transactionLog.length > 0)
         {
            _loc7_ = _loc2_.transactionLog[_loc2_.transactionLog.length - 1].split("|");
            if(_loc7_.length > 0)
            {
               this.m_secondsSinceLastEPPurchase = GlobalEngine.serverTime / 1000 + this.m_timeWarpSeconds - parseInt(_loc7_[0]);
            }
         }
         this.m_promos = _loc2_.promos;
         this.m_autopromo = _loc2_.autopromo;
         this.m_motdMerchHistory = _loc2_.motdMerchHistory;
         this.m_motdMerchUnlockHistory = _loc2_.motdMerchUnlockHistory;
         LEUnitFactoryManager.instance.init(_loc2_);
         BomberGameManager.instance.init(_loc2_);
         this.m_seenFlags = _loc2_.seenFlags;
         this.m_motdsViewed = _loc2_.motdsViewed;
         this.m_motdsAccepted = _loc2_.motdsAccepted;
         MayhemManager.instance.init(_loc2_);
         BountyCenterManager.instance.init(_loc2_);
         if(_loc2_.energizerRefill >= 0)
         {
            EnergiserManager.instance.energyRefill = _loc2_.energizerRefill;
         }
         if(!_loc2_.energiserEventFinished)
         {
            EnergiserManager.instance.init(_loc2_.energiserAnimationInitTime);
         }
         if(_loc2_.energyDeduct != 0)
         {
            EnergiserManager.instance.displayEnergizerDeductToaster(null);
         }
         this.m_energy.energizerMax = _loc2_.energizerMax;
         this.m_energy.energy = _loc2_.energy;
         this.m_energy.energyMax = _loc2_.energyMax;
         this.m_energy.energy = _loc2_.energy;
         this.m_ammo.ammo = _loc2_.ammo;
         this.m_ammo.ammoMax = _loc2_.ammoMax;
         this.m_ammo.ammo = _loc2_.ammo;
         this.m_visitorEnergy = 0;
         this.m_originalVisitorEnergy = 0;
         this.options = _loc2_.options;
         this.m_worldName = param1.worldName ? param1.worldName : "NoName";
         this.m_titanName = param1.titanName ? param1.titanName : "NoName";
         this.m_socialLevelGood = _loc2_.socialLevelGood;
         this.m_socialXpGood = _loc2_.socialXpGood;
         this.m_socialLevelBad = _loc2_.socialLevelBad;
         this.m_socialXpBad = _loc2_.socialXpBad;
         this.m_scrap = _loc2_.scrap;
         this.m_enableIdlePopup = param1.player.enableIdlePopup;
         this.m_enableInterPage = param1.player.enableInterPage;
         this.m_enableOnetimePopup = param1.player.enableOnetimePopup;
         this.m_allies = new PlayerAllies(_loc2_.alliesUsed);
         this.m_inventory = new Dictionary();
         if(!this.getSeenFlag(IntroCinematics.INTRO))
         {
            LocalDataComponent.clearLocalData();
         }
         var _loc3_:Boolean = Boolean(ZGlobal.player.options["musicDisabled"]);
         LocalDataComponent.setLocalData(SoundManager.MUSIC_MIXER_CATEGORY,_loc3_);
         Zlab.soundManager.setCategoryMuted(SoundManager.MUSIC_MIXER_CATEGORY,_loc3_);
         var _loc4_:Boolean = Boolean(ZGlobal.player.options["sfxDisabled"]);
         LocalDataComponent.setLocalData(SoundManager.SFX_MIXER_CATEGORY,_loc4_);
         Zlab.soundManager.setCategoryMuted(SoundManager.SFX_MIXER_CATEGORY,_loc4_);
         this.m_lastSeenDialogs = LocalDataComponent.getLocalData(LAST_SEEN_DIALOGS_CATEGORY);
         var _loc5_:Object = LocalDataComponent.getLocalData(LAST_SEEN_SPEECHES_CATEGORY);
         this.m_lastSeenSpeeches = _loc5_ ? _loc5_.speeches : new Array();
         var _loc6_:Object = LocalDataComponent.getLocalData(LAST_SEEN_CONVERSATIONS_CATEGORY);
         this.m_lastSeenConversations = _loc6_ ? _loc6_.conversations : new Array();
         UIDispatcher.instance.dispatchEvent(new Event(UIDispatcher.OPTIONS_LOADED));
         if(Boolean(param1.world) && Boolean(param1.world.storageData))
         {
            _loc8_ = param1.world.storageData;
            for(_loc9_ in _loc8_)
            {
               if(Number(_loc9_) < 0)
               {
                  for(_loc10_ in _loc8_[_loc9_])
                  {
                     this.m_inventory[_loc10_] = Number(_loc8_[_loc9_][_loc10_]);
                  }
               }
            }
         }
         if(param1.player)
         {
            if(param1.player.inventory)
            {
               for(_loc10_ in param1.player.inventory.items)
               {
                  if(isNaN(this.m_inventory[_loc10_]))
                  {
                     this.m_inventory[_loc10_] = Number(param1.player.inventory.items[_loc10_]);
                  }
                  else
                  {
                     this.m_inventory[_loc10_] += Number(param1.player.inventory.items[_loc10_]);
                  }
               }
            }
            if(param1.player.neighborVisits)
            {
               this.m_neighborVisits = new Dictionary();
               for each(_loc11_ in param1.player.neighborVisits)
               {
                  this.m_neighborVisits[_loc11_.uid] = _loc11_.time;
               }
            }
         }
         this.m_playerCampaign = new PlayerCampaign(param1.world.campaign);
         StrategicDispatcher.instance.dispatchEvent(new Event(StrategicDispatcher.CAMPAIGN_LOADED));
         this.m_tutorialProgress = _loc2_.tutorialProgress;
         this.m_unlockedUnits = _loc2_.unlockedUnits;
         this.m_unlockedItems = _loc2_.unlockedItems;
         this.m_unlockedContracts = _loc2_.unlockedContracts;
         this.m_tags = _loc2_.tags;
         if(_loc2_.hasOwnProperty("consumableUsedByCode") && Boolean(_loc2_.consumableUsedByCode))
         {
            this.m_consumableUsedByCode = _loc2_.consumableUsedByCode;
         }
         else
         {
            this.m_consumableUsedByCode = new Object();
         }
         if(_loc2_.hasOwnProperty("treasureVaultOpenTS"))
         {
            this.m_treasureVaultOpenTS = _loc2_.treasureVaultOpenTS;
         }
         ZGlobal.watchToEarn.loadObject(_loc2_.watchToEarn);
         this.m_userGroups = _loc2_.userGroups ? _loc2_.userGroups : [];
         this.m_flashFeedTokens = _loc2_.flashFeedTokens;
         if(_loc2_.lastSurvialModeToaster)
         {
            this.m_survialModeToasterTime = Number(_loc2_.lastSurvialModeToaster);
         }
         else
         {
            this.m_survialModeToasterTime = 0;
         }
         this.m_loaded = true;
         this.m_clanStatus = _loc2_.clanStatus;
         this.allianceStorage = _loc2_.allianceStorage;
         this.m_acceptedAlianceQuests = _loc2_.acceptedAllianceQuests;
         this.setIsCIP(_loc2_.isCIP);
         this.setAcceptedGDP(_loc2_.acceptedGDP);
         this.setAcceptedTOS(_loc2_.acceptedTOS);
      }
      
      public function acceptAllianceQuest(param1:String) : void
      {
         if(!this.m_acceptedAlianceQuests)
         {
            this.m_acceptedAlianceQuests = new Array();
         }
         this.m_acceptedAlianceQuests.push(param1);
      }
      
      public function hasAcceptedAllianceQuest(param1:String) : Boolean
      {
         if(Boolean(this.m_acceptedAlianceQuests) && this.m_acceptedAlianceQuests.indexOf(param1) >= 0)
         {
            return true;
         }
         return false;
      }
      
      public function setZRTValue(param1:String, param2:Object) : void
      {
         this[param1] = param2;
      }
      
      public function get combatSpecialBits() : int
      {
         return this.m_combatSpecialBits;
      }
      
      public function setFleets(param1:Object) : void
      {
         if(this.uid == ZGlobal.player.uid)
         {
            WarehouseUnitManager.instance.clearHeldUnits();
         }
         this.m_playerFleets = new PlayerFleets(param1.fleets,param1.enemies,param1.globalFleetId,param1.battleStatus);
      }
      
      public function initNonSocial() : void
      {
         this.coins = 10000000;
         this.cash = 10000000;
         this.level = 50;
         this.xp = 50000;
      }
      
      public function getGifts() : Array
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc1_:Array = new Array();
         for(_loc2_ in this.m_gifts)
         {
            _loc3_ = this.m_gifts[_loc2_];
            _loc4_ = _loc3_.split(",");
            if(Boolean(_loc4_[0]) && int(_loc4_[0]) > 0)
            {
            }
         }
         return _loc1_;
      }
      
      public function getGiftCount() : int
      {
         var _loc1_:Array = this.getGifts();
         var _loc2_:int = int(_loc1_.length);
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_ += Number(_loc1_[_loc4_].num);
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function hasOverrideGateCheck(param1:GameItem, param2:Object) : Boolean
      {
         var _loc3_:GameItem = null;
         var _loc4_:int = 0;
         if(param1.unlockOverrideName)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByName(param1.unlockOverrideName,GameItem) as GameItem;
            if(_loc3_)
            {
               if(ZGlobal.isVisiting())
               {
                  _loc4_ = WorldObjectManager.instance.getNumberHomeBuiltObjectsWithCode(_loc3_.code);
               }
               else
               {
                  _loc4_ = WorldObjectManager.instance.getNumberBuiltObjectsWithCode(_loc3_.code);
               }
               if(_loc4_)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function getOverrideGateForcedChecks(param1:GameItem) : Array
      {
         var _loc2_:String = param1.unlockOverrideForcedChecks;
         if(_loc2_)
         {
            return _loc2_.split(",");
         }
         return [];
      }
      
      private function shouldApplyConsumableLevelGate(param1:GameItem, param2:Object) : Boolean
      {
         var _loc3_:int = 0;
         if(Boolean(param2) && Boolean(param2.forCashPurchase) && param1.xml.consumable.length() > 0)
         {
            _loc3_ = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_POWERUP_LEVEL_LOCK_IGNORE);
            if(_loc3_ == ExperimentsManager.VARIANT_POWERUPLEVELGATE_IGNORE)
            {
               return false;
            }
         }
         return true;
      }
      
      private function shouldApplyLevelGate(param1:GameItem, param2:Object) : Boolean
      {
         if(!this.shouldApplyConsumableLevelGate(param1,param2))
         {
            return false;
         }
         return true;
      }
      
      public function checkGate(param1:GameItem, param2:Object = null) : BitArray
      {
         var _loc10_:Boolean = false;
         var _loc13_:String = null;
         var _loc14_:Array = null;
         var _loc15_:String = null;
         var _loc16_:uint = 0;
         var _loc17_:Boolean = false;
         var _loc18_:int = 0;
         var _loc19_:String = null;
         var _loc20_:Array = null;
         var _loc21_:int = 0;
         var _loc22_:String = null;
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1.code,UnitItem) as UnitItem;
         var _loc4_:BitArray = new BitArray([0],30);
         if(!param1.gatepurchase && param1.cash > 0)
         {
            return _loc4_;
         }
         var _loc5_:Boolean = this.hasOverrideGateCheck(param1,param2);
         var _loc6_:Array = this.getOverrideGateForcedChecks(param1);
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         if(!_loc5_ || Boolean(_loc6_.length))
         {
            _loc10_ = !_loc5_ || _loc6_.indexOf("requiredQuest") >= 0;
            _loc13_ = param1.requiredQuests;
            if(_loc10_ && Boolean(_loc13_))
            {
               _loc14_ = _loc13_.split(",");
               for each(_loc15_ in _loc14_)
               {
                  if(!this.m_questGatesComplete && !this.didCompleteQuest(_loc15_))
                  {
                     _loc4_.setBit(GATE_FAILURE_QUEST);
                     break;
                  }
               }
            }
            else
            {
               _loc10_ = !_loc5_ || _loc6_.indexOf("requiredLevel") >= 0;
               if(_loc10_)
               {
                  _loc16_ = this.m_level;
                  if(Boolean(param2) && Boolean(param2.level))
                  {
                     _loc16_ = uint(param2.level);
                  }
                  _loc17_ = this.shouldApplyLevelGate(param1,param2);
                  if((_loc17_) && _loc16_ < param1.requiredLevel)
                  {
                     _loc9_ = this.campaign.couldUnitBeLocked(param1.code);
                     _loc8_ = (_loc9_) && this.campaign.isUnitLocked(param1.code);
                     _loc7_ = true;
                     if(Boolean(param2 && param2.ignoreCampaignLocking) || Boolean(!_loc9_) || _loc8_)
                     {
                        _loc4_.setBit(GATE_FAILURE_LEVEL);
                     }
                  }
               }
            }
         }
         if(param1.contractLocked && !ZGlobal.player.hasPurchasedContract(param1.code))
         {
            if(_loc3_.hasType(UnitItem.MEGA_UNIT) && !_loc3_.isRequriedBuildingActive)
            {
               _loc4_.setBit(GATE_FAILURE_TITAN_LAB);
            }
            else
            {
               _loc4_.setBit(GATE_FAILURE_CONTRACT_LOCKED);
            }
         }
         if(this.numNeighbors < param1.requiredNeighbors)
         {
            _loc4_.setBit(GATE_FAILURE_NEIGHBORS);
         }
         if(PopulationManager.instance.maxWorkers < param1.requiredWorkers)
         {
            _loc4_.setBit(GATE_FAILURE_WORKERS);
         }
         if(TutorialManager.instance.active && !TutorialManager.instance.isPurchaseable(param1.code))
         {
            _loc4_.setBit(GATE_FAILURE_TUTORIAL_LOCKED);
         }
         if(param1.requiredDominanceRank)
         {
            if(DominationModeManager.instance.dominanceRank < param1.requiredDominanceRank && !this.hasPurchasedContract(param1.code))
            {
               _loc4_.setBit(GATE_FAILURE_DOMINANCE);
            }
            if(Boolean(!DominationModeManager.instance.enabled) && Boolean(param2) && Boolean(param2.dominanceGatedUnitsRequireDomMode))
            {
               _loc4_.setBit(GATE_FAILURE_DOMINANCE);
            }
         }
         if(!_loc5_)
         {
            if(_loc7_ && _loc8_ || this.campaign.isUnitLocked(param1.code))
            {
               if(!param1.hasRequiredLevel || _loc16_ < param1.requiredLevel)
               {
                  _loc4_.setBit(GATE_FAILURE_CAMPAIGN);
               }
            }
         }
         if(this.wouldExceedPopulationLimit(param1))
         {
            _loc4_.setBit(GATE_FAILURE_EXCEEDS_POPULATION);
         }
         var _loc11_:int = this.wouldExceedInstanceLimit(param1);
         if(_loc11_)
         {
            _loc4_.setBit(_loc11_);
         }
         var _loc12_:int = ZGameTimeUtil.instance.getDateStatus(null,param1.xml);
         if(_loc12_ == ZGameTimeUtil.DATE_STATUS_EARLY || _loc12_ == ZGameTimeUtil.DATE_STATUS_LATE)
         {
            if(!param1.contractLocked || param1.contractLocked && !this.hasPurchasedContract(param1.code))
            {
               _loc4_.setBit(GATE_FAILURE_DATE);
            }
         }
         if(!ExperimentsManager.instance.validateItem(param1.xml))
         {
            _loc4_.setBit(GATE_FAILURE_EXPERIMENT);
         }
         if(param1.xml.requiredConsumableUsed != undefined && param1.xml.requiredConsumableUsed.length() > 0)
         {
            if(!param1.contractLocked || param1.contractLocked && !this.hasPurchasedContract(param1.code))
            {
               _loc18_ = int(param1.xml.requiredConsumableUsed[0].@count);
               _loc19_ = param1.xml.requiredConsumableUsed[0].@codes;
               _loc20_ = _loc19_.split(",");
               _loc21_ = 0;
               for(_loc22_ in _loc20_)
               {
                  _loc21_ += this.getConsumableUsedByCode(_loc20_[_loc22_]);
               }
               if(_loc21_ < _loc18_)
               {
                  _loc4_.setBit(GATE_FAILURE_CONSUMABLES_USED);
               }
            }
         }
         return _loc4_;
      }
      
      public function getNeighborVisitTime(param1:String) : Number
      {
         if(null != this.m_neighborVisits && null != this.m_neighborVisits[param1])
         {
            return this.m_neighborVisits[param1];
         }
         return -1;
      }
      
      public function setNeighborVisitTime(param1:String, param2:Number) : void
      {
         this.m_neighborVisits[param1] = param2;
      }
      
      public function set friendsLoaded(param1:Boolean) : void
      {
         this.m_friendsLoaded = param1;
      }
      
      public function get friendsLoaded() : Boolean
      {
         return this.m_friendsLoaded;
      }
      
      public function get enableIdlePopup() : Boolean
      {
         return this.m_enableIdlePopup;
      }
      
      public function get enableInterPage() : Boolean
      {
         return this.m_enableInterPage;
      }
      
      public function get enableOnetimePopup() : Boolean
      {
         return this.m_enableOnetimePopup;
      }
      
      public function get resources() : PlayerResources
      {
         return this.m_resources;
      }
      
      public function get mana() : PlayerMana
      {
         return this.m_mana;
      }
      
      public function get questTrees() : PlayerQuestTrees
      {
         return this.m_questTrees;
      }
      
      public function get loaded() : Boolean
      {
         return this.m_loaded;
      }
      
      public function get rareResourceType() : int
      {
         return this.m_rareResourceType;
      }
      
      public function get rareResourceName() : String
      {
         return WorldResourceManager.instance.resourceInfo[this.m_rareResourceType].type;
      }
      
      public function get campaign() : PlayerCampaign
      {
         return this.m_playerCampaign;
      }
      
      public function get fleets() : PlayerFleets
      {
         return this.m_playerFleets;
      }
      
      public function countUnitsInFleets(param1:String) : int
      {
         return this.m_playerFleets.countUnits(param1);
      }
      
      public function set level(param1:int) : void
      {
         var _loc2_:int = this.m_level;
         this.m_level = param1;
         ExperienceDispatcher.instance.dispatchEvent(new ExperienceUpdatedEvent(ExperienceUpdatedEvent.LEVEL,_loc2_,this.m_level));
      }
      
      public function get canSeeLEContent() : Boolean
      {
         if(this.level >= MIN_LE_VISIBLE_LEVEL)
         {
            return true;
         }
         return false;
      }
      
      public function get gaveCoins() : Boolean
      {
         return this.m_gaveCoins;
      }
      
      public function get scrap() : Number
      {
         return this.m_scrap;
      }
      
      public function set scrap(param1:Number) : void
      {
         this.m_scrap = param1;
      }
      
      public function get socialXpGood() : Number
      {
         return this.m_socialXpGood;
      }
      
      public function set socialXpGood(param1:Number) : void
      {
         var _loc3_:XML = null;
         var _loc4_:XMLList = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc9_:XML = null;
         var _loc10_:int = 0;
         if(param1 > this.m_socialXpGood)
         {
            _loc3_ = ZGlobal.gameSettings.getXML();
            _loc4_ = _loc3_.reputationGood.level;
            _loc5_ = this.socialLevelGood;
            if(param1 > 0)
            {
               _loc7_ = false;
               _loc8_ = 0;
               while(_loc8_ < _loc4_.length())
               {
                  _loc9_ = _loc4_[_loc8_];
                  if(param1 < _loc9_.@requiredXP)
                  {
                     break;
                  }
                  _loc5_ = _loc8_ + 1;
                  _loc6_ = _loc9_.@reward;
                  _loc7_ = true;
                  _loc8_++;
               }
               if(_loc7_ && this.socialLevelGood < _loc5_ && _loc5_ > 1)
               {
                  ZGlobal.player.addToInventory(_loc6_);
                  this.socialLevelGood = _loc5_;
                  _loc10_ = ZGlobal.gameSettings.getInt("newBuildingDialogDelay");
                  Zlab.processManager.schedule(_loc10_,this,this.onDisplaySocialLevelUpDialog,this.socialLevelGood,_loc6_,true);
               }
            }
         }
         var _loc2_:Number = this.m_socialXpGood;
         this.m_socialXpGood = param1;
         ExperienceDispatcher.instance.dispatchEvent(new ExperienceUpdatedEvent(ExperienceUpdatedEvent.GOOD_XP,_loc2_,param1));
      }
      
      public function get socialLevelGood() : Number
      {
         return this.m_socialLevelGood;
      }
      
      public function set socialLevelGood(param1:Number) : void
      {
         var _loc2_:int = this.m_socialLevelGood;
         this.m_socialLevelGood = param1;
         ExperienceDispatcher.instance.dispatchEvent(new ExperienceUpdatedEvent(ExperienceUpdatedEvent.GOOD_LEVEL,_loc2_,this.m_socialLevelGood));
      }
      
      public function get socialXpBad() : Number
      {
         return this.m_socialXpBad;
      }
      
      public function set socialXpBad(param1:Number) : void
      {
         var _loc3_:XML = null;
         var _loc4_:XMLList = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         var _loc9_:XML = null;
         var _loc10_:int = 0;
         if(param1 > this.m_socialXpBad)
         {
            _loc3_ = ZGlobal.gameSettings.getXML();
            _loc4_ = _loc3_.reputationBad.level;
            _loc5_ = this.socialLevelBad;
            if(param1 > 0)
            {
               _loc7_ = false;
               _loc8_ = 0;
               while(_loc8_ < _loc4_.length())
               {
                  _loc9_ = _loc4_[_loc8_];
                  if(param1 < _loc9_.@requiredXP)
                  {
                     break;
                  }
                  _loc5_ = _loc8_ + 1;
                  _loc6_ = _loc9_.@reward;
                  _loc7_ = true;
                  _loc8_++;
               }
               if(_loc7_ && this.socialLevelBad < _loc5_ && _loc5_ > 1)
               {
                  ZGlobal.player.addToInventory(_loc6_);
                  this.socialLevelBad = _loc5_;
                  _loc10_ = ZGlobal.gameSettings.getInt("newBuildingDialogDelay");
                  Zlab.processManager.schedule(_loc10_,this,this.onDisplaySocialLevelUpDialog,this.socialLevelBad,_loc6_,false);
               }
            }
         }
         var _loc2_:Number = this.m_socialXpBad;
         this.m_socialXpBad = param1;
         ExperienceDispatcher.instance.dispatchEvent(new ExperienceUpdatedEvent(ExperienceUpdatedEvent.BAD_XP,_loc2_,param1));
      }
      
      public function isZyngaFriend(param1:Object) : Boolean
      {
         var _loc2_:uint = 0;
         var _loc3_:Object = null;
         if(this.m_zyngaFriends != null)
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_zyngaFriends.length)
            {
               _loc3_ = this.m_zyngaFriends[_loc2_];
               if(param1 != null && _loc3_ != null)
               {
                  if(param1.zid == _loc3_.zid)
                  {
                     return true;
                  }
               }
               _loc2_++;
            }
         }
         return false;
      }
      
      public function get socialLevelBad() : Number
      {
         return this.m_socialLevelBad;
      }
      
      public function get recommendedFriends() : Array
      {
         return this.m_recommendedFriends;
      }
      
      public function get zyngaFriends() : Array
      {
         return this.m_zyngaFriends;
      }
      
      public function get sevenDayLapsers() : Array
      {
         return this.m_7dayFriends;
      }
      
      public function get fourteenDayLapsers() : Array
      {
         return this.m_14dayFriends;
      }
      
      public function get thirtyDayLapsers() : Array
      {
         return this.m_30dayFriends;
      }
      
      public function get payerFriends() : Array
      {
         return this.m_payerFriends;
      }
      
      public function get empireFriends() : Array
      {
         return this.m_empireFriends;
      }
      
      public function get matchmakingFriends() : Array
      {
         return this.m_matchmakingFriends;
      }
      
      public function get allFriendsSNAPI() : Array
      {
         return this.m_allFriends;
      }
      
      public function get activeRequests() : Dictionary
      {
         this.purgeActiveRequests();
         return this.m_activeRequests;
      }
      
      public function get allFriendsByEngagement() : Array
      {
         return this.m_allFriendsByEngagement;
      }
      
      public function get zyngaFriendsByEngagement() : Array
      {
         return this.m_zyngaFriendsByEngagement;
      }
      
      public function get empireFriendsByEngagement() : Array
      {
         return this.m_empireFriendsByEngagement;
      }
      
      public function get activeGiftRequests() : Array
      {
         return this.m_activeGiftRequests;
      }
      
      public function get activeHelpRequests() : Array
      {
         return this.m_activeHelpRequests;
      }
      
      public function get pendingNeighbors() : Array
      {
         return this.m_pendingNeighbors;
      }
      
      public function set pendingNeighbors(param1:Array) : void
      {
         this.m_pendingNeighbors = param1;
      }
      
      public function get flashFeedTokens() : Number
      {
         return this.m_flashFeedTokens;
      }
      
      public function initActiveRequest(param1:Object) : void
      {
         this.m_activeRequests[RequestDialog.REQUEST_SPEEDUP] = param1.request_speedup;
         this.m_activeRequests[RequestDialog.REQUEST_BUILDINGPART_SEND] = param1.request_buildingpart_send;
         this.m_activeRequests[RequestDialog.REQUEST_CREW] = param1.request_crew;
         this.m_activeRequests[RequestDialog.REQUEST_GIFT_REQUEST] = param1.request_gift_request;
         this.m_activeRequests[RequestDialog.REQUEST_GIFT_SEND] = param1.request_gift_send;
         this.m_activeRequests[RequestDialog.REQUEST_NEIGHBOR_REQUEST] = param1.request_neighbor;
         this.m_activeRequests[RequestDialog.REQUEST_REPEL_INVASION] = param1.request_repel_invasion;
         this.m_activeRequests[RequestDialog.REQUEST_SPEEDUP] = param1.request_speedup;
         this.m_activeRequests[RequestDialog.REQUEST_ALLIANCE_REQUEST] = param1.request_alliance_invite;
      }
      
      public function initRequestTracker(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         for(_loc2_ in param1.giftRequestSent)
         {
            this.m_giftRequestSent[_loc2_] = param1.giftRequestSent[_loc2_];
         }
         for(_loc3_ in param1.helpRequestSent)
         {
            this.m_helpRequestSent[_loc3_] = param1.helpRequestSent[_loc3_];
         }
         for(_loc4_ in param1.crewRequestSent)
         {
            this.m_crewRequestSent[_loc4_] = param1.crewRequestSent[_loc4_];
         }
         for(_loc5_ in param1.neighborRequestSent)
         {
            this.m_neighborRequestSent[_loc5_] = param1.neighborRequestSent[_loc5_];
         }
         for(_loc6_ in param1.repelInvasionRequestSent)
         {
            this.m_repelInvasionRequestSent[_loc6_] = param1.repelInvasionRequestSent[_loc6_];
         }
         for(_loc7_ in param1.allianceInviteRequestSent)
         {
            this.m_allianceInviteRequestSent[_loc6_] = param1.allianceInviteRequestSent[_loc6_];
         }
      }
      
      public function initActiveGiftRequest(param1:Array) : void
      {
         this.m_activeGiftRequests = param1;
      }
      
      public function initActiveHelpRequest(param1:Array) : void
      {
         this.m_activeHelpRequests = param1;
      }
      
      public function initPendingNeighbors(param1:Array) : void
      {
         this.m_pendingNeighbors = param1;
      }
      
      public function purgeActiveRequests() : void
      {
         var _loc1_:String = null;
         var _loc2_:Object = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         for(_loc1_ in this.m_activeRequests)
         {
            _loc2_ = this.m_activeRequests[_loc1_];
            if(_loc2_ != null)
            {
               _loc3_ = ZGlobal.gameSettings.getNumber(_loc1_ + "_resetTime") * 60 * 60;
               _loc4_ = Number(_loc2_.ts);
               _loc5_ = new Date().date;
               _loc6_ = _loc5_ - _loc4_;
               if(_loc6_ >= _loc3_)
               {
                  delete this.activeRequests[_loc1_];
                  this.resetViralRequestSent(_loc1_,this.uid);
               }
            }
         }
      }
      
      public function addGiftToExcludeList(param1:Boolean, param2:String) : Boolean
      {
         var _loc3_:int = this.trackGiftRequestSent(param1,param2);
         var _loc4_:Boolean = false;
         var _loc5_:Number = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MATCHMAKING_REQUESTTHROTTLE);
         if(MatchMakingManager.instance.isMatchMadeNeighbor(param2) && Boolean(_loc5_))
         {
            switch(_loc5_)
            {
               case 1:
                  if(_loc3_ >= 1)
                  {
                     _loc4_ = true;
                  }
                  break;
               case 2:
                  if(_loc3_ >= 2)
                  {
                     _loc4_ = true;
                  }
                  break;
               case 3:
                  if(_loc3_ >= 3)
                  {
                     _loc4_ = true;
                  }
                  break;
               case 4:
                  if(_loc3_ >= 4)
                  {
                     _loc4_ = true;
                  }
                  break;
               case 5:
                  if(_loc3_ >= 5)
                  {
                     _loc4_ = true;
                  }
                  break;
               case 6:
                  if(_loc3_ >= 6)
                  {
                     _loc4_ = true;
                  }
                  break;
               case 7:
                  if(_loc3_ >= 7)
                  {
                     _loc4_ = true;
                  }
            }
            return _loc4_;
         }
         switch(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_SENDCAP))
         {
            case 3:
               if(_loc3_ >= 2)
               {
                  _loc4_ = true;
               }
               break;
            case 4:
               if(_loc3_ >= 3)
               {
                  _loc4_ = true;
               }
               break;
            case 5:
               if(_loc3_ >= 4)
               {
                  _loc4_ = true;
               }
               break;
            default:
               _loc4_ = true;
         }
         return _loc4_;
      }
      
      public function addViralToExcludeList(param1:String, param2:String) : Boolean
      {
         var _loc3_:Boolean = false;
         var _loc4_:int = this.trackViralRequestSent(param1,param2);
         var _loc5_:Number = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MATCHMAKING_REQUESTTHROTTLE);
         if(MatchMakingManager.instance.isMatchMadeNeighbor(param2) && Boolean(_loc5_))
         {
            switch(_loc5_)
            {
               case 1:
                  if(_loc4_ >= 1)
                  {
                     _loc3_ = true;
                  }
                  break;
               case 2:
                  if(_loc4_ >= 2)
                  {
                     _loc3_ = true;
                  }
                  break;
               case 3:
                  if(_loc4_ >= 3)
                  {
                     _loc3_ = true;
                  }
                  break;
               case 4:
                  if(_loc4_ >= 4)
                  {
                     _loc3_ = true;
                  }
                  break;
               case 5:
                  if(_loc4_ >= 5)
                  {
                     _loc3_ = true;
                  }
                  break;
               case 6:
                  if(_loc4_ >= 6)
                  {
                     _loc3_ = true;
                  }
                  break;
               case 7:
                  if(_loc4_ >= 7)
                  {
                     _loc3_ = true;
                  }
            }
            return _loc3_;
         }
         switch(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_SENDCAP))
         {
            case 3:
               if(_loc4_ >= 2)
               {
                  _loc3_ = true;
               }
               break;
            case 4:
               if(_loc4_ >= 3)
               {
                  _loc3_ = true;
               }
               break;
            case 5:
               if(_loc4_ >= 4)
               {
                  _loc3_ = true;
               }
               break;
            default:
               _loc3_ = true;
         }
         return _loc3_;
      }
      
      private function trackGiftRequestSent(param1:Boolean, param2:String) : int
      {
         var _loc4_:Number = NaN;
         if(param1)
         {
            if(this.m_helpRequestSent[param2] == null)
            {
               this.m_helpRequestSent[param2] = 0;
            }
            _loc4_ = Number(this.m_helpRequestSent[param2]);
            _loc4_ = _loc4_ + 1;
            this.m_helpRequestSent[param2] = _loc4_;
            return this.m_helpRequestSent[param2];
         }
         if(this.m_giftRequestSent[param2] == null)
         {
            this.m_giftRequestSent[param2] = 0;
         }
         var _loc3_:Number = Number(this.m_giftRequestSent[param2]);
         _loc3_++;
         this.m_giftRequestSent[param2] = _loc3_;
         return this.m_giftRequestSent[param2];
      }
      
      private function resetViralRequestSent(param1:String, param2:String) : void
      {
         switch(param1)
         {
            case RequestDialog.REQUEST_CREW:
               delete this.m_crewRequestSent[param2];
               break;
            case RequestDialog.REQUEST_REPEL_INVASION:
               delete this.m_repelInvasionRequestSent[param2];
               break;
            case RequestDialog.REQUEST_NEIGHBOR_REQUEST:
               delete this.m_neighborRequestSent[param2];
               break;
            case RequestDialog.REQUEST_ALLIANCE_REQUEST:
               delete this.m_allianceInviteRequestSent[param2];
         }
      }
      
      private function resetGiftRequestSent(param1:Boolean, param2:String) : void
      {
         if(param1)
         {
            delete this.m_helpRequestSent[param2];
         }
         else
         {
            delete this.m_giftRequestSent[param2];
         }
      }
      
      private function trackViralRequestSent(param1:String, param2:String) : int
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         switch(param1)
         {
            case RequestDialog.REQUEST_CREW:
               if(this.m_crewRequestSent[param2] == null)
               {
                  this.m_crewRequestSent[param2] = 0;
               }
               _loc3_ = Number(this.m_crewRequestSent[param2]);
               _loc3_++;
               this.m_crewRequestSent[param2] = _loc3_;
               return this.m_crewRequestSent[param2];
            case RequestDialog.REQUEST_REPEL_INVASION:
               if(this.m_repelInvasionRequestSent[param2] == null)
               {
                  this.m_repelInvasionRequestSent[param2] = 0;
               }
               _loc4_ = Number(this.m_repelInvasionRequestSent[param2]);
               _loc4_ = _loc4_ + 1;
               this.m_repelInvasionRequestSent[param2] = _loc4_;
               return this.m_repelInvasionRequestSent[param2];
            case RequestDialog.REQUEST_NEIGHBOR_REQUEST:
               if(this.m_neighborRequestSent[param2] == null)
               {
                  this.m_neighborRequestSent[param2] = 0;
               }
               _loc5_ = Number(this.m_neighborRequestSent[param2]);
               _loc5_ = _loc5_ + 1;
               this.m_neighborRequestSent[param2] = _loc5_;
               return this.m_neighborRequestSent[param2];
            case RequestDialog.REQUEST_ALLIANCE_REQUEST:
               if(this.m_allianceInviteRequestSent[param2] == null)
               {
                  this.m_allianceInviteRequestSent[param2] = 0;
               }
               _loc6_ = Number(this.m_allianceInviteRequestSent[param2]);
               _loc6_ = _loc6_ + 1;
               this.m_allianceInviteRequestSent[param2] = _loc6_;
               return this.m_allianceInviteRequestSent[param2];
            default:
               return 1;
         }
      }
      
      public function addActiveGiftRequest(param1:Array) : void
      {
         var _loc2_:Number = ZGlobal.gameSettings.getInt("request_excludeList_size",150);
         var _loc3_:uint = 0;
         while(_loc3_ < param1.length)
         {
            if(this.m_activeGiftRequests.length >= _loc2_)
            {
               break;
            }
            if(this.addGiftToExcludeList(false,param1[_loc3_]))
            {
               if(this.m_activeGiftRequests.indexOf(param1[_loc3_]) < 0)
               {
                  this.m_activeGiftRequests.push(Number(param1[_loc3_]));
               }
            }
            _loc3_++;
         }
      }
      
      public function addActiveHelpRequest(param1:Array) : void
      {
         var _loc2_:Number = ZGlobal.gameSettings.getInt("request_excludeList_size",150);
         var _loc3_:uint = 0;
         while(_loc3_ < param1.length)
         {
            if(this.m_activeHelpRequests.length >= _loc2_)
            {
               break;
            }
            if(this.addGiftToExcludeList(true,param1[_loc3_]))
            {
               if(this.m_activeHelpRequests.indexOf(param1[_loc3_]) < 0)
               {
                  this.m_activeHelpRequests.push(Number(param1[_loc3_]));
               }
            }
            _loc3_++;
         }
      }
      
      public function pruneActiveGiftRecipients(param1:Array) : void
      {
         var _loc2_:* = 0;
         var _loc3_:Number = NaN;
         if(this.m_activeGiftRequests.length > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < param1.length)
            {
               _loc3_ = Number(param1[_loc2_].zid);
               if(this.m_activeGiftRequests.indexOf(_loc3_) >= 0)
               {
                  param1.splice(_loc2_,1);
                  _loc2_--;
               }
               _loc2_++;
            }
         }
      }
      
      public function pruneActiveHelpRecipients(param1:Array) : void
      {
         var _loc2_:* = 0;
         var _loc3_:Number = NaN;
         if(this.m_activeHelpRequests.length > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < param1.length)
            {
               _loc3_ = Number(param1[_loc2_].zid);
               if(this.m_activeHelpRequests.indexOf(_loc3_) >= 0)
               {
                  param1.splice(_loc2_,1);
                  _loc2_--;
               }
               _loc2_++;
            }
         }
      }
      
      public function pruneActiveRequestRecipient(param1:Array, param2:String) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:String = null;
         var _loc3_:* = 0;
         if(this.m_activeRequests[param2] != undefined && this.m_activeRequests[param2].zids.length > 0)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.length)
            {
               _loc4_ = Number(param1[_loc3_].zid);
               if(this.m_activeRequests[param2].zids.indexOf(_loc4_) >= 0)
               {
                  param1.splice(_loc3_,1);
                  _loc3_--;
               }
               _loc3_++;
            }
         }
         if(param2 == RequestDialog.REQUEST_NEIGHBOR_REQUEST)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.length)
            {
               _loc5_ = Number(param1[_loc3_].zid);
               if(Boolean(this.m_pendingNeighbors.indexOf(_loc5_) >= 0) || Boolean(this.m_neighbors[param1[_loc3_].zid]) || this.m_pendingNeighbors.indexOf(param1[_loc3_].zid) >= 0)
               {
                  param1.splice(_loc3_,1);
                  _loc3_--;
               }
               _loc3_++;
            }
         }
         if(param2 == RequestDialog.REQUEST_NEIGHBOR_REQUEST)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.length)
            {
               for(_loc6_ in this.neighbors)
               {
                  if(param1[_loc3_].zid == _loc6_)
                  {
                     param1.splice(_loc3_,1);
                     _loc3_--;
                  }
               }
               _loc3_++;
            }
         }
      }
      
      public function addActiveRequest(param1:String, param2:Array) : void
      {
         var _loc3_:Number = ZGlobal.gameSettings.getInt("request_excludeList_size",150);
         if(this.m_activeRequests[param1] == undefined)
         {
            this.m_activeRequests[param1] = new Object();
            this.m_activeRequests[param1].zids = new Array();
            this.m_activeRequests[param1].ts = new Date().getTime();
         }
         var _loc4_:uint = 0;
         while(_loc4_ < param2.length)
         {
            if(this.m_activeRequests[param1].zids.length >= _loc3_)
            {
               break;
            }
            if(this.addViralToExcludeList(param1,param2[_loc4_]) || param1 == RequestDialog.REQUEST_NEIGHBOR_REQUEST || param1 == RequestDialog.REQUEST_ALLIANCE_REQUEST)
            {
               if(this.m_activeRequests[param1].zids.indexOf(param2[_loc4_]) < 0)
               {
                  this.m_activeRequests[param1].zids.push(Number(param2[_loc4_]));
               }
            }
            _loc4_++;
         }
      }
      
      public function set socialLevelBad(param1:Number) : void
      {
         var _loc2_:int = this.m_socialLevelBad;
         this.m_socialLevelBad = param1;
         ExperienceDispatcher.instance.dispatchEvent(new ExperienceUpdatedEvent(ExperienceUpdatedEvent.BAD_LEVEL,_loc2_,this.m_socialLevelBad));
      }
      
      private function onDisplaySocialLevelUpDialog(param1:int, param2:String, param3:Boolean) : void
      {
         UI.displaySocialLevelUpDialog(param1,param2,param3);
      }
      
      public function set xp(param1:int) : void
      {
         var _loc3_:XML = null;
         var _loc4_:XMLList = null;
         var _loc5_:int = 0;
         var _loc6_:XML = null;
         var _loc7_:* = 0;
         var _loc8_:XML = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         if(param1 > this.m_xp && param1 > 0)
         {
            _loc3_ = ZGlobal.gameSettings.getXML();
            _loc4_ = _loc3_.levels.level;
            _loc5_ = 1;
            _loc6_ = null;
            _loc7_ = int(_loc4_.length() - 1);
            while(_loc7_ >= 0)
            {
               _loc6_ = _loc8_ = _loc4_[_loc7_];
               _loc5_ = _loc7_ + 1;
               if(param1 >= _loc8_.@requiredXP)
               {
                  break;
               }
               _loc7_--;
            }
            if(this.level < _loc5_ && _loc5_ > 1)
            {
               if(ZGlobal.cashOnLevelUpVarient != ZGlobal.EXPERIMENT_NO_CASH_ON_LEVEL_UP)
               {
                  this.executeLevelUpRewards(_loc6_);
               }
               this.level = _loc5_;
               this.m_energy.updateMaxEnergy(_loc5_);
               this.m_ammo.updateMaxAmmo(_loc5_);
               if(this.refillEnergyOnLevelUp())
               {
                  _loc9_ = Math.max(this.m_energy.energy,this.m_energy.energyMax);
                  this.m_energy.energy = _loc9_;
                  _loc10_ = Math.max(this.m_ammo.ammo,this.m_ammo.ammoMax);
                  this.m_ammo.ammo = _loc10_;
               }
               UI.displayLevelUpDialog(this.m_level);
            }
            ExternalInterface.call("SNAPI.api","points.grantXP",param1 - this.m_xp);
         }
         var _loc2_:Number = this.m_xp;
         this.m_xp = param1;
         ExperienceDispatcher.instance.dispatchEvent(new ExperienceUpdatedEvent(ExperienceUpdatedEvent.EXPERIENCE,_loc2_,param1));
      }
      
      public function set asn(param1:Number) : void
      {
         this.m_asn = param1;
      }
      
      public function get asn() : Number
      {
         return this.m_asn;
      }
      
      public function initQuestInitAsn(param1:Object) : void
      {
         if(param1)
         {
            this.m_questInitAsn = param1;
         }
      }
      
      public function get questInitAsn() : Object
      {
         return this.m_questInitAsn;
      }
      
      public function initPartsGatherInitAsn(param1:Object) : void
      {
         if(param1)
         {
            this.m_partsGatherInitAsn = param1;
         }
      }
      
      public function get partsGatherInitAsn() : Object
      {
         return this.m_partsGatherInitAsn;
      }
      
      public function get immunityClearsInvasions() : Boolean
      {
         if(Boolean(this.m_newInstallExperiments) && Boolean(this.m_newInstallExperiments[ZGlobal.EXPERIMENT_PVP_IMMUNITY_BEHAVIOR]))
         {
            return true;
         }
         return false;
      }
      
      private function refillEnergyOnLevelUp() : Boolean
      {
         var _loc1_:Boolean = true;
         if(this.level >= 7)
         {
            switch(ZGlobal.energyRewardVariant_v2)
            {
               case ZGlobal.EXPERIMENT_ENERGY_V2_VARIANT_3:
                  if(Boolean(this.m_newInstallExperiments) && Boolean(this.m_newInstallExperiments[ZGlobal.EXPERIMENT_ENERGY_REWARD_V2]))
                  {
                     _loc1_ = false;
                  }
                  else
                  {
                     _loc1_ = this.level % 2 == 0;
                  }
                  break;
               case ZGlobal.EXPERIMENT_ENERGY_V2_VARIANT_4:
                  _loc1_ = this.level % 2 == 0;
            }
         }
         return _loc1_;
      }
      
      private function executeLevelUpRewards(param1:XML) : void
      {
         var _loc2_:XML = null;
         var _loc3_:RewardHelper = null;
         for each(_loc2_ in param1.reward)
         {
            _loc3_ = new RewardHelper(_loc2_);
            _loc3_.execute();
         }
      }
      
      public function get xp() : int
      {
         return this.m_xp;
      }
      
      public function set coins(param1:int) : void
      {
         this.m_resources.setResourceAmount("coins",param1);
      }
      
      public function get coins() : int
      {
         return this.m_resources.resourceAmounts["coins"];
      }
      
      public function set cash(param1:int) : void
      {
         var _loc2_:int = this.cash;
         this.m_cash = param1;
         ResourceDispatcher.instance.dispatchEvent(new ResourceUpdatedEvent("cash",_loc2_,this.cash));
      }
      
      public function get cash() : int
      {
         return this.m_cash;
      }
      
      public function initVisitorEnergy(param1:int) : void
      {
         this.m_visitorEnergy = param1;
         this.m_originalVisitorEnergy = param1;
         this.m_energy.reservedEnergy = 0;
      }
      
      public function visitorEnergySpent() : void
      {
         --this.m_visitorEnergy;
         VisitorManager.instance.dispatchEvent(new Event(VisitorManager.VISITOR_ENERGY_SPENT));
      }
      
      public function get visitorEnergy() : int
      {
         return this.m_visitorEnergy;
      }
      
      public function get originalVisitorEnergy() : int
      {
         return this.m_originalVisitorEnergy;
      }
      
      public function get options() : Object
      {
         return this.m_options;
      }
      
      public function set options(param1:Object) : void
      {
         this.m_options = param1;
      }
      
      public function get allies() : PlayerAllies
      {
         return this.m_allies;
      }
      
      public function getSeenFlag(param1:String) : int
      {
         return this.m_seenFlags[param1];
      }
      
      public function setSeenFlag(param1:String) : void
      {
         if(!this.m_seenFlags[param1] || this.m_seenFlags[param1] <= 0)
         {
            this.m_seenFlags[param1] = 1;
         }
         else
         {
            this.m_seenFlags[param1] += 1;
         }
         TransactionManager.addTransaction(new TSetSeenFlag(param1));
      }
      
      public function get seenFlags() : Object
      {
         return this.m_seenFlags;
      }
      
      public function getSeenSessionFlag(param1:String) : Boolean
      {
         return this.m_seenSessionFlags[param1];
      }
      
      public function setSeenSessionFlag(param1:String) : void
      {
         this.m_seenSessionFlags[param1] = true;
      }
      
      public function checkSeenExtendedPermissions(param1:String, param2:Boolean = true) : Boolean
      {
         var _loc3_:Boolean = true;
         var _loc4_:String = "perm_" + param1;
         if(!this.getSeenFlag(_loc4_))
         {
            _loc3_ = false;
            if(param2)
            {
               this.setSeenFlag(_loc4_);
            }
         }
         return _loc3_;
      }
      
      public function get neighbors() : Dictionary
      {
         return this.m_neighbors;
      }
      
      public function get numNeighbors() : int
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this.m_neighbors)
         {
            _loc1_++;
         }
         return _loc1_;
      }
      
      public function getPromo(param1:String) : Object
      {
         var _loc2_:Object = null;
         if(Boolean(param1 != "") && Boolean(this.m_promos) && Boolean(this.m_promos[param1]))
         {
            _loc2_ = this.m_promos[param1];
         }
         return _loc2_;
      }
      
      public function getAllPromos() : Object
      {
         return this.m_promos;
      }
      
      public function getOngoingAutopromoName() : String
      {
         if(this.m_autopromo["current_promotion"])
         {
            return this.m_autopromo["current_promotion"];
         }
         return "";
      }
      
      public function getOnGoingAutopromoExpireTime(param1:Boolean = false) : String
      {
         var _loc2_:Number = NaN;
         var _loc3_:Date = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:String = null;
         var _loc14_:String = null;
         var _loc15_:String = null;
         if(this.m_autopromo["current_promotion_expire_time"])
         {
            if(param1 == true)
            {
               return this.m_autopromo["current_promotion_expire_time"].toString();
            }
            _loc2_ = Number(this.m_autopromo["current_promotion_expire_time"]) * 1000;
            _loc3_ = new Date(_loc2_);
            _loc4_ = _loc3_.dateUTC;
            _loc5_ = _loc3_.monthUTC + 1;
            _loc6_ = _loc3_.fullYearUTC;
            _loc7_ = _loc3_.hoursUTC;
            _loc8_ = _loc3_.minutesUTC;
            _loc9_ = _loc3_.secondsUTC;
            _loc10_ = StringUtils.stringPad(_loc4_.toString(),2,"0","PAD_LEFT");
            _loc11_ = StringUtils.stringPad(_loc5_.toString(),2,"0","PAD_LEFT");
            _loc12_ = _loc6_.toString();
            _loc13_ = StringUtils.stringPad(_loc7_.toString(),2,"0","PAD_LEFT");
            _loc14_ = StringUtils.stringPad(_loc8_.toString(),2,"0","PAD_LEFT");
            _loc15_ = StringUtils.stringPad(_loc9_.toString(),2,"0","PAD_LEFT");
            return _loc11_ + "/" + _loc10_ + "/" + _loc12_ + " " + _loc13_ + ":" + _loc14_ + ":" + _loc15_ + " UTC";
         }
         return "";
      }
      
      public function getOngoingAutopromoParams() : String
      {
         if(this.m_autopromo["current_promotion_params"])
         {
            return this.m_autopromo["current_promotion_params"];
         }
         return "";
      }
      
      public function getMotdMerchHistory(param1:String) : Object
      {
         var _loc2_:Object = null;
         if(Boolean(param1 != "") && Boolean(this.m_motdMerchHistory) && Boolean(this.m_motdMerchHistory[param1]))
         {
            _loc2_ = this.m_motdMerchHistory[param1];
         }
         return _loc2_;
      }
      
      public function setMotdMerchItemPurchased(param1:String, param2:String) : void
      {
         if(!this.m_motdMerchHistory[param1])
         {
            this.m_motdMerchHistory[param1] = new Object();
         }
         this.m_motdMerchHistory[param1][param2] = 1;
      }
      
      public function isMotdMerchItemPurchased(param1:String, param2:String) : Boolean
      {
         return this.m_motdMerchHistory[param1] != null && this.m_motdMerchHistory[param1][param2] != null;
      }
      
      public function resetMotdMerchHistory(param1:String) : void
      {
         this.m_motdMerchHistory[param1] = new Object();
      }
      
      public function setMotdMerchAwarded(param1:String, param2:int) : void
      {
         this.m_motdMerchHistory[param1]["awarded"] = param2;
      }
      
      public function set gifts(param1:Dictionary) : void
      {
         this.m_gifts = param1;
      }
      
      public function get gifts() : Dictionary
      {
         return this.m_gifts;
      }
      
      public function set inventory(param1:Dictionary) : void
      {
         this.m_inventory = param1;
      }
      
      public function get inventory() : Dictionary
      {
         return this.m_inventory;
      }
      
      public function isInventoryEmpty() : Boolean
      {
         var _loc1_:String = null;
         for(_loc1_ in this.inventory)
         {
            if(this.inventory[_loc1_] > 0)
            {
               return false;
            }
         }
         return true;
      }
      
      public function getNumberOfInventoryItems(param1:String) : int
      {
         return int(int(this.inventory[param1]) || 0);
      }
      
      public function addGift(param1:String, param2:int = 0) : void
      {
      }
      
      public function removeGift(param1:Object, param2:String = "") : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         if(param1)
         {
            _loc3_ = param1.getItem().code;
         }
         if(this.gifts[_loc3_])
         {
            _loc4_ = this.m_gifts[_loc3_];
            _loc5_ = _loc4_.split(",");
            if(Boolean(_loc5_[0]) && int(_loc5_[0]) > 0)
            {
               --_loc5_[0];
               _loc5_.splice(1,1);
               _loc4_ = _loc5_.join(",");
            }
            this.m_gifts[_loc3_] = _loc4_;
         }
      }
      
      public function hasGift(param1:String) : Boolean
      {
         return false;
      }
      
      public function removeAllGifts() : void
      {
         this.m_gifts = new Dictionary();
      }
      
      public function addToInventory(param1:String, param2:int = 1, param3:Boolean = true) : void
      {
         var _loc5_:int = 0;
         var _loc6_:XML = null;
         var _loc7_:GameItem = null;
         var _loc4_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         if((Boolean(_loc4_)) && _loc4_.isBundle)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_.bundleSize)
            {
               _loc6_ = _loc4_.bundleXML(_loc5_);
               _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc6_.@item,GameItem) as GameItem;
               if(_loc7_.type == "resource")
               {
                  this.resources.updateResourceAmount(_loc7_.resourceType,_loc7_.resourceYield * _loc6_.@quantity * param2);
               }
               else
               {
                  this.addToInventory(_loc6_.@item,_loc6_.@quantity * param2,false);
               }
               _loc5_++;
            }
         }
         if(this.inventory[param1])
         {
            this.inventory[param1] += param2;
         }
         else
         {
            this.inventory[param1] = param2;
         }
         if(param3)
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(INVENTORY_UPDATED,{
               "code":param1,
               "count":param2
            }));
         }
      }
      
      public function removeInventoryItem(param1:String, param2:int = 1) : Boolean
      {
         if(Boolean(this.inventory[param1]) && this.inventory[param1] >= param2)
         {
            this.inventory[param1] -= param2;
            UIDispatcher.instance.dispatchEvent(new WorldEvent(INVENTORY_UPDATED,{
               "code":param1,
               "count":-param2
            }));
            return true;
         }
         return false;
      }
      
      public function hasFriendsSNData() : Boolean
      {
         return this.m_hasFriendsSNData;
      }
      
      private function validUser(param1:SocialNetworkUser) : Boolean
      {
         if(!param1)
         {
            Logger.error(this,"validUser","null user");
            return false;
         }
         if(!param1.uid)
         {
            Logger.error(this,"validUser","missing uid");
            return false;
         }
         if(!param1.firstName)
         {
            Logger.error(this,"validUser","missing first name");
            return false;
         }
         return true;
      }
      
      public function requestFriendsLoaded() : void
      {
         UIDispatcher.instance.dispatchEvent(new Event(REQUEST_FRIENDS_LOADED));
      }
      
      public function setCategorizedFriends(param1:Array, param2:String) : void
      {
         if(param1 != null)
         {
            switch(param2)
            {
               case Player.FRIENDS_ALL:
                  this.m_friends = param1;
                  break;
               case Player.FRIENDS_RECOMMENDED:
                  this.m_recommendedFriends = param1;
                  break;
               case Player.FRIENDS_ZYNGA:
                  this.m_zyngaFriends = param1;
                  break;
               case Player.FRIENDS_EMPIRES:
                  this.m_empireFriends = param1;
                  break;
               case Player.FRIENDS_7DAY:
                  this.m_7dayFriends = param1;
                  break;
               case Player.FRIENDS_14DAY:
                  this.m_14dayFriends = param1;
                  break;
               case Player.FRIENDS_30DAY:
                  this.m_30dayFriends = param1;
                  break;
               case Player.FRIENDS_PAYERS:
                  this.m_payerFriends = param1;
                  break;
               case Player.FRIENDS_ALL_SNAPI:
                  this.m_allFriends = param1;
                  break;
               case Player.FRIENDS_MATCHMAKING:
                  this.m_matchmakingFriends = param1;
                  break;
               case Player.FRIENDS_ALL_ENGAGEMENT:
                  this.m_allFriendsByEngagement = param1;
                  break;
               case Player.FRIENDS_ZYNGA_ENGAGEMENT:
                  this.m_zyngaFriendsByEngagement = param1;
                  break;
               case Player.FRIENDS_EMPIRE_ENGAGEMENT:
                  this.m_empireFriendsByEngagement = param1;
            }
         }
      }
      
      public function setFriends(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:XMLList = null;
         var _loc4_:XMLList = null;
         var _loc5_:XMLList = null;
         var _loc6_:XMLList = null;
         var _loc7_:XMLList = null;
         var _loc8_:SocialNetworkUser = null;
         if(param1 != null)
         {
            this.m_friends = new Array();
            _loc2_ = 0;
            while(_loc2_ < param1.length)
            {
               _loc8_ = param1[_loc2_] as SocialNetworkUser;
               if(this.validUser(_loc8_))
               {
                  this.m_friends.push(new Player(_loc8_));
               }
               _loc2_++;
            }
            _loc3_ = ZGlobal.gameSettings.getXML().defaultAlly;
            _loc8_ = new SocialNetworkUser(parseFloat(_loc3_.uid.toString()));
            if(ZLoc.instance != null)
            {
               _loc8_.name = ZGameUtils.ZlocT("Main",_loc3_.name.toString());
               _loc8_.firstName = ZGameUtils.ZlocT("Main",_loc3_.firstName.toString());
            }
            else
            {
               this.m_deferredLoc = true;
            }
            _loc8_.gender = _loc3_.gender.toString();
            _loc8_.picture = ZGlobal.getAssetURL(_loc3_.picture.toString());
            this.m_friends.push(new Player(_loc8_));
            _loc4_ = ZGlobal.gameSettings.getXML().survivalModeAlly;
            _loc8_ = new SocialNetworkUser(parseFloat(_loc4_.uid.toString()));
            if(ZLoc.instance != null)
            {
               _loc8_.name = ZGameUtils.ZlocT("Main",_loc4_.name.toString());
               _loc8_.firstName = ZGameUtils.ZlocT("Main",_loc4_.firstName.toString());
            }
            else
            {
               this.m_deferredLoc = true;
            }
            _loc8_.gender = _loc4_.gender.toString();
            _loc8_.picture = ZGlobal.getAssetURL(_loc4_.picture.toString());
            this.m_friends.push(new Player(_loc8_));
            _loc5_ = ZGlobal.gameSettings.getXML().MW2XPromoAlly;
            _loc8_ = new SocialNetworkUser(parseFloat(_loc5_.uid.toString()));
            if(ZLoc.instance != null)
            {
               _loc8_.name = ZGameUtils.ZlocT("Main",_loc5_.name.toString());
               _loc8_.firstName = ZGameUtils.ZlocT("Main",_loc5_.firstName.toString());
            }
            else
            {
               this.m_deferredLoc = true;
            }
            _loc8_.gender = _loc5_.gender.toString();
            _loc8_.picture = ZGlobal.getAssetURL(_loc5_.picture.toString());
            this.m_friends.push(new Player(_loc8_));
            _loc6_ = ZGlobal.gameSettings.getXML().CastleXPromoAlly;
            _loc8_ = new SocialNetworkUser(parseFloat(_loc6_.uid.toString()));
            if(ZLoc.instance != null)
            {
               _loc8_.name = ZGameUtils.ZlocT("Main",_loc6_.name.toString());
               _loc8_.firstName = ZGameUtils.ZlocT("Main",_loc6_.firstName.toString());
            }
            else
            {
               this.m_deferredLoc = true;
            }
            _loc8_.gender = _loc6_.gender.toString();
            _loc8_.picture = ZGlobal.getAssetURL(_loc6_.picture.toString());
            this.m_friends.push(new Player(_loc8_));
            _loc7_ = ZGlobal.gameSettings.getXML().HCXPromoAlly;
            _loc8_ = new SocialNetworkUser(parseFloat(_loc7_.uid.toString()));
            if(ZLoc.instance != null)
            {
               _loc8_.name = ZGameUtils.ZlocT("Main",_loc7_.name.toString());
               _loc8_.firstName = ZGameUtils.ZlocT("Main",_loc7_.firstName.toString());
            }
            else
            {
               this.m_deferredLoc = true;
            }
            _loc8_.gender = _loc7_.gender.toString();
            _loc8_.picture = ZGlobal.getAssetURL(_loc7_.picture.toString());
            this.m_friends.push(new Player(_loc8_));
            PromoManager.instance.addEventListener(PromoManager.XPROMO_ADD_CARD,this.onAddXPromoFriends);
            this.m_hasFriendsSNData = true;
         }
      }
      
      private function onAddXPromoFriends(param1:WorldEvent) : void
      {
         var _loc6_:Object = null;
         var _loc7_:Object = null;
         var _loc2_:Array = param1.eventData.availableXPromos;
         var _loc3_:Array = param1.eventData.acceptedXPromos;
         var _loc4_:SocialNetworkUser = null;
         var _loc5_:uint = 0;
         _loc5_ = 0;
         while(_loc5_ < _loc2_.length)
         {
            _loc6_ = _loc2_[_loc5_];
            if(_loc6_.state == CriteriaUtil.XPROMO_STATE_NEW || _loc6_.state == CriteriaUtil.XPROMO_STATE_VIEWED || _loc6_.state == CriteriaUtil.XPROMO_STATE_ACCEPTED || _loc6_.state == CriteriaUtil.XPROMO_STATE_DECLINED || _loc6_.state == CriteriaUtil.XPROMO_STATE_REWARDED)
            {
               _loc4_ = new SocialNetworkUser(parseFloat(_loc6_.id) * -1);
               if(ZLoc.instance != null)
               {
                  _loc4_.name = ZGameUtils.ZlocT("Main",_loc6_.ui.neighbor_bar_text);
                  _loc4_.firstName = ZGameUtils.ZlocT("Main",_loc6_.ui.neighbor_bar_text);
               }
               else
               {
                  this.m_deferredLoc = true;
               }
               _loc4_.gender = "M";
               _loc4_.picture = ZGlobal.getAssetURL(_loc6_.ui.neighbor_bar_image);
               this.m_friends.push(new Player(_loc4_));
            }
            _loc5_++;
         }
         _loc5_ = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc7_ = _loc3_[_loc5_];
            if(_loc7_.state == CriteriaUtil.XPROMO_STATE_NEW || _loc7_.state == CriteriaUtil.XPROMO_STATE_VIEWED || _loc7_.state == CriteriaUtil.XPROMO_STATE_ACCEPTED || _loc7_.state == CriteriaUtil.XPROMO_STATE_DECLINED || _loc7_.state == CriteriaUtil.XPROMO_STATE_REWARDED)
            {
               _loc4_ = new SocialNetworkUser(parseFloat(_loc7_.id) * -1);
               if(ZLoc.instance != null)
               {
                  _loc4_.name = ZGameUtils.ZlocT("Main",_loc7_.ui.neighbor_bar_text);
                  _loc4_.firstName = ZGameUtils.ZlocT("Main",_loc7_.ui.neighbor_bar_text);
               }
               else
               {
                  this.m_deferredLoc = true;
               }
               _loc4_.gender = "M";
               _loc4_.picture = ZGlobal.getAssetURL(_loc7_.ui.neighbor_bar_image);
               this.m_friends.push(new Player(_loc4_));
            }
            _loc5_++;
         }
      }
      
      public function get deferredLoc() : Boolean
      {
         return this.m_deferredLoc;
      }
      
      public function localizeDeferredData() : void
      {
         var _loc1_:XMLList = null;
         var _loc2_:Player = null;
         var _loc3_:XMLList = null;
         var _loc4_:Player = null;
         var _loc5_:XMLList = null;
         var _loc6_:Player = null;
         var _loc7_:XMLList = null;
         var _loc8_:Player = null;
         var _loc9_:XMLList = null;
         var _loc10_:Player = null;
         if(this.m_deferredLoc)
         {
            _loc1_ = ZGlobal.gameSettings.getXML().defaultAlly;
            _loc2_ = this.findFriendById(_loc1_.uid);
            if(_loc2_)
            {
               _loc2_.snUser.name = ZGameUtils.ZlocT("Main",_loc1_.name.toString());
               _loc2_.snUser.firstName = ZGameUtils.ZlocT("Main",_loc1_.firstName.toString());
            }
            _loc3_ = ZGlobal.gameSettings.getXML().survivalModeAlly;
            _loc4_ = this.findFriendById(_loc3_.uid);
            if(_loc4_)
            {
               _loc4_.snUser.name = ZGameUtils.ZlocT("Main",_loc3_.name.toString());
               _loc4_.snUser.firstName = ZGameUtils.ZlocT("Main",_loc3_.firstName.toString());
            }
            _loc5_ = ZGlobal.gameSettings.getXML().MW2XPromoAlly;
            _loc6_ = this.findFriendById(_loc5_.uid);
            if(_loc6_)
            {
               _loc6_.snUser.name = ZGameUtils.ZlocT("Main",_loc5_.name.toString());
               _loc6_.snUser.firstName = ZGameUtils.ZlocT("Main",_loc5_.firstName.toString());
            }
            _loc7_ = ZGlobal.gameSettings.getXML().CastleXPromoAlly;
            _loc8_ = this.findFriendById(_loc7_.uid);
            if(_loc8_)
            {
               _loc8_.snUser.name = ZGameUtils.ZlocT("Main",_loc7_.name.toString());
               _loc8_.snUser.firstName = ZGameUtils.ZlocT("Main",_loc7_.firstName.toString());
            }
            _loc9_ = ZGlobal.gameSettings.getXML().HCXPromoAlly;
            _loc10_ = this.findFriendById(_loc9_.uid);
            if(_loc10_)
            {
               _loc10_.snUser.name = ZGameUtils.ZlocT("Main",_loc9_.name.toString());
               _loc10_.snUser.firstName = ZGameUtils.ZlocT("Main",_loc9_.firstName.toString());
            }
         }
      }
      
      public function get friends() : Array
      {
         return this.m_friends;
      }
      
      public function set appFriends(param1:Array) : void
      {
         this.m_appFriends = param1;
      }
      
      public function get appFriends() : Array
      {
         return this.m_appFriends;
      }
      
      public function get isNewPlayer() : Boolean
      {
         return isProgressNewPlayer();
      }
      
      public function findFriendById(param1:String) : Player
      {
         var _loc4_:Player = null;
         var _loc5_:Object = null;
         var _loc2_:Player = null;
         var _loc3_:int = 0;
         while(_loc3_ < this.friends.length)
         {
            _loc4_ = this.friends[_loc3_] as Player;
            if(_loc4_.uid == param1)
            {
               _loc2_ = _loc4_;
               break;
            }
            _loc3_++;
         }
         if(_loc2_ == null && param1 == this.uid)
         {
            _loc2_ = this;
         }
         else if(_loc2_ == null)
         {
            if(MatchMakingManager.instance.isMatchMadeNeighbor(param1))
            {
               _loc2_ = MatchMakingManager.instance.getPlayerObject(ZGlobal.player.neighbors[param1]);
            }
         }
         if(_loc2_ == null)
         {
            if(AlliancesManager.isExperimentEnabled() && Boolean(AlliancesManager.instance.isAllianceMember(param1)))
            {
               _loc5_ = AlliancesManager.instance.isAllianceMember(param1);
               _loc5_.uid = param1;
               _loc2_ = AlliancesManager.instance.getPlayerObject(_loc5_);
            }
         }
         return _loc2_;
      }
      
      public function findNonFriendById(param1:String) : Object
      {
         return this.m_nonFriendInfo[param1];
      }
      
      public function get uid() : String
      {
         return this.snUser.uid;
      }
      
      public function getFriendName(param1:String) : String
      {
         var _loc2_:String = null;
         var _loc3_:Player = this.findFriendById(param1);
         if(_loc3_)
         {
            _loc2_ = _loc3_.playerName;
         }
         return _loc2_;
      }
      
      public function getFriendFirstName(param1:String) : String
      {
         var _loc2_:Player = this.findFriendById(param1);
         if(_loc2_)
         {
            return _loc2_.firstName;
         }
         return null;
      }
      
      public function canBuy(param1:GameItem, param2:Boolean = true) : Boolean
      {
         var _loc7_:Dictionary = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:BitArray = null;
         var _loc3_:Array = param1.resourceCosts;
         var _loc4_:Array = new Array();
         var _loc5_:Boolean = true;
         var _loc6_:int = 0;
         while(_loc6_ < _loc3_.length)
         {
            if(this.m_resources.resourceAmounts[_loc3_[_loc6_].type] + _loc3_[_loc6_].amount < 0)
            {
               _loc5_ = false;
               _loc4_.push(_loc3_[_loc6_].type);
            }
            _loc6_++;
         }
         if(!_loc5_)
         {
            if(param2)
            {
               if(this.allowOneClickBuy() && param1.cash > 0)
               {
                  PopupManager.instance.push(new OneClickBuyPopup(new ObtainMultiRequirementsInfoGameItem(param1)));
               }
               else
               {
                  PopupManager.instance.push(new ObtainMultiRequirementsPopup(new ObtainMultiRequirementsInfoGameItem(param1)));
               }
            }
         }
         else
         {
            _loc7_ = param1.itemCosts;
            for(_loc8_ in _loc7_)
            {
               _loc9_ = _loc7_[_loc8_] - this.getNumberOfInventoryItems(_loc8_);
               if(_loc9_ > 0)
               {
                  _loc5_ = false;
                  if(param2)
                  {
                     PopupManager.instance.push(new ObtainRequirementPopup(new ObtainRequirementPopupInfoGameItem(_loc8_,_loc9_)));
                     param2 = false;
                  }
                  break;
               }
            }
         }
         if(_loc5_)
         {
            if(this.wouldExceedPopulationLimit(param1))
            {
               _loc5_ = false;
               if(param2)
               {
                  PopupManager.instance.push(new RequirementsPopup(new RequirementsPopupInfoPopCap()));
               }
            }
         }
         if(_loc5_)
         {
            _loc10_ = this.checkGate(param1);
            if(_loc10_.isBitSet(GATE_FAILURE_WORKERS))
            {
               _loc5_ = false;
               if(param2)
               {
                  PopupManager.instance.push(GenericPopup1B.NewOk(ZGameUtils.ZlocT("Dialogs","OutOfWorkersMessage"),ZGameUtils.ZlocT("Dialogs","OutOfWorkersTitle")));
               }
            }
         }
         return _loc5_;
      }
      
      public function payRansom(param1:String, param2:Number) : Boolean
      {
         var _loc3_:Array = new Array();
         var _loc4_:Boolean = true;
         if(this.m_resources.resourceAmounts[param1] - param2 < 0)
         {
            _loc4_ = false;
            _loc3_.push(param1);
         }
         if(_loc4_)
         {
            this.m_resources.updateResourceAmount(param1,-param2);
         }
         return _loc4_;
      }
      
      public function buyPremiumGameItem(param1:GameItem, param2:Boolean = true, param3:Boolean = false, param4:Object = null, param5:Function = null, param6:Function = null, param7:Object = null) : void
      {
         var _loc8_:String = null;
         var _loc9_:Object = null;
         var _loc10_:LocalizationObjectToken = null;
         var _loc11_:GenericPopup2B = null;
         var _loc12_:Object = null;
         if(this.checkPremiumGate(param1) == true)
         {
            if(param2 || ZGlobal.gameSettings.showConfirmationPopup(param1.cash) == true)
            {
               _loc9_ = ZGameUtils.CashTokenReplacements(param1.cash);
               _loc10_ = param1.getSentenceNameLocalizationObject("singular,definite");
               if(_loc10_)
               {
                  _loc9_.unit = _loc10_;
                  _loc8_ = ZGameUtils.ZlocT("Dialogs","ConfirmUnitPurchaseMessage_Object",_loc9_);
               }
               else
               {
                  _loc9_.unit = param1.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                  _loc8_ = ZGameUtils.ZlocT("Dialogs","ConfirmUnitPurchaseMessage",_loc9_);
               }
               _loc11_ = GenericPopup2B.NewYesNo(_loc8_,ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle"),this.onBuyPremiumGameItemPopupClose);
               _loc12_ = {};
               _loc12_[PREMIUM_ITEM] = param1;
               _loc12_[STATS_INFO] = param4;
               _loc12_[CALL_BACK_ON_BUY] = param5;
               _loc12_[CALL_BACK_ON_CANCEL] = param6;
               _loc12_[BUY_ON_PLACEMENT] = param3;
               _loc12_[BUY_CALLBACK_INFO] = param7;
               _loc11_.userData = _loc12_;
               PopupManager.instance.push(_loc11_);
            }
            else
            {
               this.buyPremiumGameItemConfirmed(param1,param4,param5,param3,param7);
            }
         }
      }
      
      private function checkPremiumGate(param1:GameItem) : Boolean
      {
         var _loc2_:BitArray = null;
         if(!ZGlobal.player.canBuyCash(param1.cash,true))
         {
            return false;
         }
         _loc2_ = ZGlobal.player.checkGate(param1);
         if(_loc2_.isBitSet(Player.GATE_FAILURE_LEVEL))
         {
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","ImpulseLevel",{"amount":param1.requiredLevel})));
            return false;
         }
         if(_loc2_.isBitSet(Player.GATE_FAILURE_NEIGHBORS))
         {
            PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","ImpulseNeighbors",{"amount":param1.requiredNeighbors})));
            return false;
         }
         return true;
      }
      
      private function onBuyPremiumGameItemPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.OK)
         {
            if(!(param1.userData != null && param1.userData[PREMIUM_ITEM] != null))
            {
               throw Error("Buy premium Item has no item data");
            }
            this.buyPremiumGameItemConfirmed(param1.userData[PREMIUM_ITEM],param1.userData[STATS_INFO],param1.userData[CALL_BACK_ON_BUY],param1.userData[BUY_ON_PLACEMENT],param1.userData[BUY_CALLBACK_INFO]);
         }
         else if(Boolean(param1.userData) && Boolean(param1.userData[CALL_BACK_ON_CANCEL]))
         {
            (param1.userData[CALL_BACK_ON_CANCEL] as Function).apply();
         }
      }
      
      private function buyPremiumGameItemConfirmed(param1:GameItem, param2:Object, param3:Function, param4:Boolean, param5:Object) : void
      {
         var _loc6_:Boolean = true;
         if(param4)
         {
            UI.instance.setupForItemPurchase();
            GameModeManager.instance.addGameMode(new GMObjectPlace(param1.name,MarketEvent.SOURCE_STORE,false,param2));
         }
         else
         {
            ZGlobal.player.buyItem(param1,_loc6_);
            ZGlobal.player.addToInventory(param1.code);
            TransactionManager.addTransaction(new TBuyItem(param1.code,_loc6_,1,param2));
         }
         if(param3 != null)
         {
            param3.apply(null,[param5]);
         }
      }
      
      public function buyGameItem(param1:GameItem, param2:Boolean = true, param3:int = 1, param4:Object = null) : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:XML = null;
         if(param1 != null)
         {
            _loc5_ = true;
            ZGlobal.player.buyItem(param1,_loc5_,param3);
            if(param2)
            {
               ZGlobal.player.addToInventory(param1.code,param3);
            }
            _loc6_ = null;
            if(param1.isBundle)
            {
               _loc6_ = "";
               _loc7_ = 0;
               while(_loc7_ < param1.bundleSize)
               {
                  _loc8_ = param1.bundleXML(_loc7_);
                  _loc6_ += _loc8_.@item + ":" + _loc8_.@quantity;
                  if(_loc7_ < param1.bundleSize - 1)
                  {
                     _loc6_ += ",";
                  }
                  _loc7_++;
               }
            }
            TransactionManager.addTransaction(new TBuyItem(param1.code,_loc5_,param3,param4,null,_loc6_));
         }
      }
      
      public function buyRewardItem(param1:GameItem, param2:int = 1, param3:String = "") : void
      {
         var _loc4_:Boolean = false;
         if(param1 != null)
         {
            _loc4_ = true;
            ZGlobal.player.buyItem(param1,_loc4_,param2);
            ZGlobal.player.addToInventory(param1.code,param2);
            TransactionManager.addTransaction(new TBuyRewardItem(param1.code,param3));
         }
      }
      
      public function buyResourceItem(param1:GameItem, param2:int = 1, param3:Object = null) : void
      {
         var _loc4_:Boolean = false;
         if(param1)
         {
            this.cash -= Math.ceil(param1.xmlCash * param2);
            _loc4_ = true;
            TransactionManager.addTransaction(new TBuyItem(param1.code,_loc4_,param2,param3));
         }
      }
      
      public function get multiRequirementItemInfo() : ObtainMultiRequirementsInfoGameItem
      {
         return this.m_multiRequirementItemInfo;
      }
      
      public function set multiRequirementItemInfo(param1:ObtainMultiRequirementsInfoGameItem) : void
      {
         this.m_multiRequirementItemInfo = param1;
      }
      
      public function buyMultiRequirementItem(param1:ObtainMultiRequirementsInfoGameItem, param2:Boolean = true, param3:Boolean = true, param4:Boolean = false) : void
      {
         var _loc6_:GameItem = null;
         var _loc7_:Dictionary = null;
         var _loc8_:int = 0;
         var _loc9_:IObtainRequirementPopupInfo = null;
         var _loc10_:GameItem = null;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:Object = null;
         var _loc5_:Boolean = false;
         if(param1)
         {
            _loc7_ = new Dictionary();
            _loc8_ = 0;
            while(_loc8_ < param1.numRequirements)
            {
               _loc9_ = null;
               if(param1.isResourceRequirement(_loc8_))
               {
                  _loc9_ = new ObtainRequirementPopupInfoResourcePurchase(param1.requirementType(_loc8_),param1.requirementQuantity(_loc8_));
               }
               else
               {
                  _loc9_ = new ObtainRequirementPopupInfoGameItemPurchase(param1.requirementItem(_loc8_),param1.requirementQuantity(_loc8_));
               }
               _loc10_ = GameItem(_loc9_.requirementGameItem);
               _loc11_ = _loc10_.code;
               _loc12_ = _loc9_.buyQuantity;
               if(param2)
               {
                  if(_loc10_.type == "resource")
                  {
                     this.resources.updateResourceAmount(_loc10_.xml.@resourceType,_loc9_.resourceAmount);
                  }
                  else
                  {
                     if(_loc10_.type == "consumable")
                     {
                        _loc5_ = true;
                        _loc6_ = _loc10_;
                     }
                     this.addToInventory(_loc11_,_loc12_);
                  }
               }
               _loc7_[_loc11_] = _loc12_;
               _loc8_++;
            }
            if(param2)
            {
               this.cash -= param1.cashCostTotal;
            }
            if(param3)
            {
               _loc13_ = param1.overrideCost > 0 ? param1.overrideCost : 0;
               if(_loc5_ && _loc6_.code == EnergyRefillItem.ITEM_CODE)
               {
                  _loc14_ = {};
                  _loc14_.genus = "buy_refill";
                  TransactionManager.addTransaction(EnergyRefillItem.getRefillPurchaseTransaction(_loc6_.code,true,1,_loc14_));
                  ZGlobal.player.m_energy.energy = ZGlobal.player.m_energy.energyMax;
               }
               else
               {
                  TransactionManager.addTransaction(new TBuyItems(_loc7_,true,{
                     "containingItemCode":param1.item.code,
                     "needResources":param4
                  },_loc13_));
                  if(_loc5_)
                  {
                     UI.instance.setupForItemPlacement();
                     UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_USE,MarketEvent.CONSUMABLE,_loc6_.name,MarketEvent.SOURCE_INVENTORY));
                  }
               }
            }
         }
      }
      
      public function refundMultiRequirementItem(param1:ObtainMultiRequirementsInfoGameItem) : void
      {
         var _loc2_:int = 0;
         var _loc3_:IObtainRequirementPopupInfo = null;
         var _loc4_:GameItem = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         if(param1)
         {
            _loc2_ = 0;
            while(_loc2_ < param1.numRequirements)
            {
               _loc3_ = null;
               if(param1.isResourceRequirement(_loc2_))
               {
                  _loc3_ = new ObtainRequirementPopupInfoResourcePurchase(param1.requirementType(_loc2_),param1.requirementQuantity(_loc2_));
               }
               else
               {
                  _loc3_ = new ObtainRequirementPopupInfoGameItemPurchase(param1.requirementItem(_loc2_),param1.requirementQuantity(_loc2_));
               }
               _loc4_ = GameItem(_loc3_.requirementGameItem);
               _loc5_ = _loc4_.code;
               _loc6_ = _loc3_.buyQuantity;
               if(_loc4_.type == "resource")
               {
                  this.resources.updateResourceAmount(_loc4_.xml.@resourceType,-_loc6_);
               }
               else
               {
                  this.addToInventory(_loc5_,-_loc6_);
               }
               _loc2_++;
            }
            this.cash += param1.cashCostTotal;
         }
      }
      
      private function onOutOfResourceDialogClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = "out_of_" + param1.userData.name;
            ViralsManager.instance.sendFeed(_loc2_,{"resource":ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk("Items",param1.userData.name + "_sentenceName","plural"))});
         }
      }
      
      public function canBuyCash(param1:int, param2:Boolean = true, param3:String = "", param4:Boolean = true) : Boolean
      {
         var _loc5_:Boolean = this.cash - param1 >= 0;
         if(!_loc5_ && param2)
         {
            if(Boolean(param3) && param3.length > 0)
            {
               PopupManager.instance.push(new NotEnoughCashPopup(param3),0,param4);
            }
            else
            {
               PopupManager.instance.push(new NotEnoughCashPopup(ZGameUtils.ZlocT("Dialogs","ImpulseCash")),0,param4);
            }
         }
         return _loc5_;
      }
      
      public function buyItem(param1:GameItem, param2:Boolean, param3:int = 1, param4:String = null, param5:Boolean = false, param6:Object = null) : void
      {
         var _loc7_:Number = NaN;
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         var _loc10_:Dictionary = null;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:Object = null;
         var _loc15_:uint = 0;
         if(param2 && !param5)
         {
            if(param4 != null)
            {
               this.cash -= param1.getModifiedCash(1,1,param4) * param3;
            }
            else if(Boolean(param6) && Boolean(param6.discountedCost) && param6.discountedCost >= 0)
            {
               this.cash -= param6.discountedCost * param3;
            }
            else
            {
               this.cash -= param1.cash * param3;
            }
            MOTDMerchManager.itemPurchased(param1.code);
         }
         else if(param5)
         {
            this.removeInventoryItem("VTK",param1.masteryTokenCost);
         }
         else
         {
            _loc7_ = ZGlobal.gameSettings.getBuyXp(this.m_resources.resourceAmounts["coins"]);
            this.xp += _loc7_ * param3;
            _loc8_ = param1.resourceCosts;
            _loc9_ = 0;
            while(_loc9_ < _loc8_.length)
            {
               _loc12_ = int(_loc8_[_loc9_].amount);
               if(Boolean(param6) && Boolean(param6 as Dictionary))
               {
                  _loc13_ = 0;
                  for each(_loc14_ in param6)
                  {
                     if(Boolean(_loc14_.resources) && Boolean(_loc14_.resources as Array) && _loc14_.resources.indexOf(_loc8_[_loc9_].type) >= 0)
                     {
                        _loc13_ += _loc14_.amount;
                     }
                  }
                  _loc12_ = DecorationsManager.instance.applyResourceDiscount(_loc12_,_loc13_);
               }
               this.m_resources.updateResourceAmount(_loc8_[_loc9_].type,_loc12_ * param3);
               _loc9_++;
            }
            _loc10_ = param1.itemCosts;
            for(_loc11_ in _loc10_)
            {
               this.removeInventoryItem(_loc11_,_loc10_[_loc11_] * param3);
            }
         }
         if(Boolean(param1) && this.isLightingDealItem(param1.code))
         {
            _loc15_ = this.getLightningDealInfo(PromoManager.LD_MC_KEY_CURRENT);
            if(_loc15_)
            {
               _loc15_--;
               this.updateLightningDealCount(param1.code,_loc15_);
            }
         }
      }
      
      public function buyBackItems(param1:Array, param2:Boolean) : void
      {
         var _loc5_:String = null;
         var _loc6_:GameItem = null;
         var _loc7_:int = 0;
         var _loc3_:uint = param2 ? 1 : 0;
         var _loc4_:Number = BuyBackManager.instance.costMultiplier(String(param1.length),_loc3_);
         for(_loc5_ in param1)
         {
            _loc6_ = param1[_loc5_];
            _loc7_ = _loc6_.getModifiedCash(_loc4_);
            this.cash -= _loc7_;
         }
      }
      
      public function reviveItems(param1:Array) : Boolean
      {
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         var _loc6_:GameItem = null;
         var _loc7_:int = 0;
         var _loc2_:Number = BattleManager.instance.reviveUnitMultiplier();
         var _loc3_:int = 0;
         for(_loc4_ in param1)
         {
            _loc6_ = param1[_loc4_];
            _loc7_ = _loc6_.getModifiedCash(_loc2_);
            _loc3_ += _loc7_;
         }
         _loc5_ = this.canBuyCash(_loc3_);
         if(_loc5_)
         {
            this.cash -= _loc3_;
         }
         return _loc5_;
      }
      
      public function resourceCashCost(param1:String, param2:int = 1) : int
      {
         var _loc3_:Number = 1;
         switch(param1)
         {
            case "coins":
               _loc3_ = PriceTestManager.instance.costMultiplierByType("coinspurchase");
               break;
            case "wood":
               _loc3_ = PriceTestManager.instance.costMultiplierByType("woodpurchase");
               break;
            case "oil":
               _loc3_ = PriceTestManager.instance.costMultiplierByType("oilpurchase");
         }
         var _loc4_:Number = this.resourceCostMultiplier(param1,param1 == this.rareResourceName);
         return Math.ceil(_loc3_ * param2 * _loc4_);
      }
      
      private function resourceCostMultiplier(param1:String, param2:Boolean = true) : Number
      {
         var _loc3_:XML = this.resourceItemXML(param1,param2);
         if(_loc3_)
         {
            return _loc3_.cost.@cash;
         }
         return 1;
      }
      
      public function resourceItemXML(param1:String, param2:Boolean = true) : XML
      {
         var _loc4_:XML = null;
         var _loc3_:Array = ZGlobal.gameSettings.getArrayOfItemXMLByType("resource","variable");
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_.@resourceType == param1 && param2 == (_loc4_.@nativeRare == "true"))
            {
               return _loc4_;
            }
         }
         return null;
      }
      
      private function energyBuyItemXML(param1:int) : XML
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         var _loc4_:Array = ZGlobal.gameSettings.getArrayOfItemXMLByType("consumable","energy");
         for each(_loc2_ in _loc4_)
         {
            if(_loc2_.@buyable == "true")
            {
               if(_loc2_.energyYield >= param1)
               {
                  return _loc2_;
               }
            }
         }
         return ZGlobal.gameSettings.getItemXMLByCode("ERX");
      }
      
      private function energyUseItemXML(param1:int) : XML
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         var _loc4_:Array = ZGlobal.gameSettings.getArrayOfItemXMLByType("consumable","energy");
         for each(_loc2_ in _loc4_)
         {
            if(this.getNumberOfInventoryItems(_loc2_.@code))
            {
               if(_loc2_.energyYield > param1)
               {
                  return _loc2_;
               }
               _loc3_ = _loc2_;
            }
         }
         if(this.getNumberOfInventoryItems(EnergyRefillItem.ITEM_CODE))
         {
            return ZGlobal.gameSettings.getItemXMLByCode(EnergyRefillItem.ITEM_CODE);
         }
         return _loc3_;
      }
      
      public function energyItem(param1:int, param2:Boolean = true) : GameItem
      {
         var _loc3_:XML = null;
         if(!param2)
         {
            _loc3_ = this.energyUseItemXML(param1);
         }
         if(!_loc3_)
         {
            _loc3_ = this.energyBuyItemXML(param1);
         }
         return ZGlobal.gameSettings.getItemByCode(_loc3_.@code,GameItem) as GameItem;
      }
      
      public function resourceItem(param1:String, param2:Boolean = true) : GameItem
      {
         var _loc3_:XML = this.resourceItemXML(param1,param2);
         if(_loc3_)
         {
            return ZGlobal.gameSettings.getItemByCode(_loc3_.@code,GameItem) as GameItem;
         }
         return null;
      }
      
      public function hasResource(param1:WorldResource) : Boolean
      {
         if(this.m_resources.resourceAmounts[param1.type] + param1.amount < 0)
         {
            return false;
         }
         return true;
      }
      
      public function getResourcePackageCost(param1:Boolean) : int
      {
         var _loc5_:XML = null;
         var _loc2_:int = 0;
         var _loc3_:int = ZGlobal.player.level;
         var _loc4_:XMLList = ZGlobal.gameSettings.getXML().resourceOffers.resourceOffer;
         for each(_loc5_ in _loc4_)
         {
            if(_loc3_ >= _loc5_.@minLevel && _loc3_ <= _loc5_.@maxLevel && param1 != (_loc5_.@nonNativeRare == "true"))
            {
               _loc2_ = int(_loc5_.@price);
               break;
            }
         }
         return _loc2_;
      }
      
      public function getResourcePackageQuantity(param1:GameItem, param2:int) : int
      {
         return param2 / param1.xmlCash;
      }
      
      public function get firstName() : String
      {
         return this.snUser.firstName;
      }
      
      public function get localizationName() : LocalizationName
      {
         return ZGameUtils.ZlocTn(this.firstName,this.snUser.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC);
      }
      
      public function get portraitURL() : String
      {
         return this.snUser.picture;
      }
      
      override public function get name() : String
      {
         return this.snUser.name;
      }
      
      public function get genderTag() : String
      {
         return this.snUser.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC;
      }
      
      public function get empireName() : String
      {
         var _loc1_:LocalizationName = null;
         if(!this.m_worldName || !this.m_worldName.length)
         {
            _loc1_ = ZLoc.tn(this.firstName,this.genderTag);
            return ZGameUtils.ZlocT("Main","WorldName",{"player":_loc1_});
         }
         return this.m_worldName;
      }
      
      public function get level() : int
      {
         return this.m_level;
      }
      
      public function ownsUnitAnywhere(param1:String) : Boolean
      {
         var _loc5_:Fleet = null;
         var _loc6_:Unit = null;
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         _loc2_ = this.getNumberOfInventoryItems(param1) > 0 ? true : false;
         if(Boolean(WorldUnitManager.instance.allUnits) && Boolean(WorldUnitManager.instance.allUnits[param1]))
         {
            _loc3_ = WorldUnitManager.instance.allUnits[param1].length > 0 ? true : false;
         }
         for each(_loc5_ in this.m_playerFleets.fleets)
         {
            if(_loc5_.isOwnedByPlayer(ZGlobal.player.uid))
            {
               for each(_loc6_ in _loc5_.units)
               {
                  if(_loc6_.code == param1)
                  {
                     _loc4_ = true;
                     break;
                  }
               }
            }
         }
         return _loc2_ || _loc3_ || _loc4_;
      }
      
      private function wouldExceedPopulationLimit(param1:GameItem) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(Boolean(param1) && Boolean(param1.workers) && Boolean(param1.workers.length))
         {
            _loc2_ = parseInt(param1.workers);
            if(_loc2_)
            {
               _loc3_ = _loc2_ + PopulationManager.instance.maxWorkers;
               if(_loc3_ > PopulationManager.instance.maxWorkersCap)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      private function wouldExceedInstanceLimit(param1:GameItem) : int
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:int = param1.limit;
         if(_loc2_ != GameItem.LIMIT_UNLIMITED)
         {
            _loc3_ = param1.code;
            _loc4_ = WorldObjectManager.instance.getNumberObjectsWithCode(_loc3_);
            _loc5_ = this.getNumberOfInventoryItems(_loc3_);
            if(_loc4_ + _loc5_ >= _loc2_)
            {
               return _loc5_ > 0 ? GATE_FAILURE_EXCEEDS_LIMIT_IN_INVENTORY : GATE_FAILURE_EXCEEDS_LIMIT;
            }
         }
         return GATE_SUCCESS;
      }
      
      public function setSeenConversation(param1:String) : void
      {
         if(this.m_lastSeenConversations.length >= this.MAX_NUM_CONVERSATIONS)
         {
            this.m_lastSeenConversations.shift();
         }
         this.m_lastSeenConversations.push(param1);
         LocalDataComponent.setLocalData(LAST_SEEN_CONVERSATIONS_CATEGORY,{"conversations":this.m_lastSeenConversations});
      }
      
      public function hasSeenConversation(param1:String) : Boolean
      {
         var _loc2_:String = null;
         for each(_loc2_ in this.m_lastSeenConversations)
         {
            if(_loc2_ == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function setSeenSpeech(param1:String) : void
      {
         if(this.m_lastSeenSpeeches.length >= this.MAX_NUM_SPEECHES)
         {
            this.m_lastSeenSpeeches.shift();
         }
         this.m_lastSeenSpeeches.push(param1);
         LocalDataComponent.setLocalData(LAST_SEEN_SPEECHES_CATEGORY,{"speeches":this.m_lastSeenSpeeches});
      }
      
      public function hasSeenSpeech(param1:String) : Boolean
      {
         var _loc2_:String = null;
         for each(_loc2_ in this.m_lastSeenSpeeches)
         {
            if(_loc2_ == param1)
            {
               return true;
            }
         }
         if(param1 == "Speech_Scarlett_Camp2a_01" && Boolean(ZGlobal.player.getSeenFlag(CampaignV2DirectorScript.SEEN_FLAG)))
         {
            return true;
         }
         return false;
      }
      
      public function setSeenDialog(param1:String, param2:String) : void
      {
         if(!this.m_lastSeenDialogs)
         {
            this.m_lastSeenDialogs = new Object();
         }
         this.m_lastSeenDialogs.type = param2;
         LocalDataComponent.setLocalData(LAST_SEEN_DIALOGS_CATEGORY,this.m_lastSeenDialogs);
      }
      
      public function hasSeenDialog(param1:String, param2:String) : Boolean
      {
         if(!this.m_enableOnetimePopup)
         {
            return true;
         }
         if(!this.m_lastSeenDialogs)
         {
            this.m_lastSeenDialogs = new Object();
         }
         if(this.m_lastSeenDialogs.type == param2)
         {
            return true;
         }
         return false;
      }
      
      public function getUnlockedUnits() : Array
      {
         return this.m_unlockedUnits;
      }
      
      public function unlockUnit(param1:String) : void
      {
         if(this.m_unlockedUnits.indexOf(param1) == -1)
         {
            this.m_unlockedUnits.push(param1);
         }
      }
      
      public function hasUnlockedUnit(param1:String) : Boolean
      {
         if(this.m_unlockedUnits.indexOf(param1) != -1)
         {
            return true;
         }
         return false;
      }
      
      public function unlockItem(param1:GameItem) : void
      {
         if(this.m_unlockedItems.indexOf(param1.code) == -1)
         {
            this.m_unlockedItems.push(param1.code);
         }
         this.cash -= param1.unlockCost;
      }
      
      public function isItemUnlocked(param1:String) : Boolean
      {
         return this.m_unlockedItems.indexOf(param1) != -1;
      }
      
      public function unlockContract(param1:GameItem, param2:Boolean = false, param3:Boolean = true, param4:Boolean = false) : void
      {
         if(this.m_unlockedContracts.indexOf(param1.code) == -1)
         {
            this.m_unlockedContracts.push(param1.code);
            MOTDMerchManager.itemUnlocked(param1.code);
         }
         if(!param2)
         {
            this.cash -= param1.contractCost;
         }
         if(param3)
         {
            ZGlobal.player.addToInventory(param1.code,1);
         }
         if(!param4)
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackGiftReceived",{"item":param1.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME)}));
         }
         UnitContractUnlockManager.instance.checkAndAwardSetBonuses(param1.code);
         UIDispatcher.instance.dispatchEvent(new WorldEvent(CONTRACT_UNLOCKED,param1.code));
      }
      
      public function unlockContractMotdAward(param1:String) : void
      {
         if(this.m_unlockedContracts.indexOf(param1) == -1)
         {
            this.m_unlockedContracts.push(param1);
         }
         ZGlobal.player.addToInventory(param1,1);
      }
      
      public function hasPurchasedContract(param1:String) : Boolean
      {
         return this.m_unlockedContracts.indexOf(param1) != -1;
      }
      
      public function hasMotdBeenViewed(param1:String) : Boolean
      {
         return Boolean(this.m_motdsViewed) && this.arrayContainsString(this.m_motdsViewed,param1);
      }
      
      public function hasMotdBeenAccepted(param1:String) : Boolean
      {
         return Boolean(this.m_motdsAccepted) && this.arrayContainsString(this.m_motdsAccepted,param1);
      }
      
      public function getTag(param1:String) : Object
      {
         return this.m_tags[param1];
      }
      
      public function setTag(param1:String, param2:Object) : void
      {
         this.m_tags[param1] = param2;
      }
      
      public function setCompletedQuestNames(param1:Array) : void
      {
         this.m_completedQuestNames = param1;
         UIDispatcher.instance.dispatchEvent(new Event(QUEST_LABELS_UPDATED));
      }
      
      public function setStarredQuestNames(param1:Array) : void
      {
         var _loc2_:String = null;
         this.m_sortedStarredQuests = param1;
         for each(_loc2_ in param1)
         {
            this.m_starredQuests[_loc2_.toString()] = true;
         }
      }
      
      public function setSeenNotificationQuestNames(param1:Object) : void
      {
         var _loc2_:String = null;
         for each(_loc2_ in param1)
         {
            this.m_seenQuestsNotifications[_loc2_.toString()] = true;
         }
      }
      
      public function getStarredQuestsSorted() : Array
      {
         return this.m_sortedStarredQuests;
      }
      
      public function isStarredQuest(param1:String) : Boolean
      {
         if(this.m_starredQuests[param1])
         {
            return true;
         }
         return false;
      }
      
      public function doStarQuest(param1:String) : void
      {
         this.m_starredQuests[param1.toString()] = true;
         var _loc2_:Array = this.m_sortedStarredQuests;
         var _loc3_:Number = _loc2_.length;
         this.m_sortedStarredQuests = new Array();
         this.m_sortedStarredQuests.unshift(param1);
      }
      
      public function doUnstarQuest(param1:String) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         if(this.m_starredQuests[param1.toString()])
         {
            delete this.m_starredQuests[param1.toString()];
            _loc2_ = this.m_sortedStarredQuests;
            _loc3_ = _loc2_.length;
            this.m_sortedStarredQuests = new Array();
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               if(_loc2_[_loc4_] != param1)
               {
                  this.m_sortedStarredQuests.push(_loc2_[_loc4_]);
               }
               _loc4_++;
            }
         }
      }
      
      public function notifyQuest(param1:String) : void
      {
         if(this.isStarredQuest(param1))
         {
            this.m_questsWithNotifications[param1.toString()] = "fav";
            ++this.favCount;
         }
         else
         {
            this.m_questsWithNotifications[param1.toString()] = "timed";
            ++this.timedCount;
         }
      }
      
      public function addToSeenQuestNotifications(param1:String) : void
      {
         this.m_seenQuestsNotifications[param1.toString()] = true;
      }
      
      public function isQuestNotificationSeen(param1:String) : Boolean
      {
         if(this.m_seenQuestsNotifications[param1.toString()] != undefined && this.m_seenQuestsNotifications[param1.toString()] == true)
         {
            return true;
         }
         return false;
      }
      
      public function removeQuestNotification(param1:String) : void
      {
         if(this.m_questsWithNotifications[param1.toString()] != undefined)
         {
            delete this.m_questsWithNotifications[param1.toString()];
            if(this.isStarredQuest(param1.toString()))
            {
               if(this.favCount > 0)
               {
                  --this.favCount;
               }
            }
            else if(this.timedCount > 0)
            {
               --this.timedCount;
            }
         }
      }
      
      public function removeAllStarredQuestNotifications() : void
      {
         var _loc1_:Object = null;
         for(_loc1_ in this.m_questsWithNotifications)
         {
            if(this.isStarredQuest(_loc1_.toString()))
            {
               this.removeQuestNotification(_loc1_.toString());
               this.addToSeenQuestNotifications(_loc1_.toString());
            }
         }
      }
      
      public function removeAllTimedQuestNotifications() : void
      {
         var _loc1_:Object = null;
         for(_loc1_ in this.m_questsWithNotifications)
         {
            if(!this.isStarredQuest(_loc1_.toString()))
            {
               this.removeQuestNotification(_loc1_.toString());
               this.addToSeenQuestNotifications(_loc1_.toString());
            }
         }
      }
      
      public function isNotifyQuest(param1:String) : Boolean
      {
         if(this.m_questsWithNotifications[param1.toString()] != undefined && this.m_questsWithNotifications[param1.toString()] != null)
         {
            return true;
         }
         return false;
      }
      
      public function addCompletedQuestName(param1:String) : void
      {
         this.m_completedQuestNames.push(param1);
         UIDispatcher.instance.dispatchEvent(new Event(QUEST_LABELS_UPDATED));
      }
      
      public function removeCompletedQuestName(param1:String) : void
      {
         var _loc2_:int = this.m_completedQuestNames.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.m_completedQuestNames.splice(_loc2_,1);
            UIDispatcher.instance.dispatchEvent(new Event(QUEST_LABELS_UPDATED));
         }
      }
      
      public function didCompleteQuest(param1:String) : Boolean
      {
         return this.arrayContainsString(this.m_completedQuestNames,param1);
      }
      
      private function arrayContainsString(param1:Array, param2:String) : Boolean
      {
         var _loc3_:String = null;
         if(null == param1)
         {
            return false;
         }
         for each(_loc3_ in param1)
         {
            if(_loc3_ == param2)
            {
               return true;
            }
         }
         return false;
      }
      
      public function isPayingUser() : Boolean
      {
         return this.m_numCashTransactions > 0;
      }
      
      public function get cashPurchasedTotal() : int
      {
         return this.m_cashPurchasedTotal;
      }
      
      public function get secondsSinceLastEPPurchase() : int
      {
         return this.m_secondsSinceLastEPPurchase;
      }
      
      private function onItemGift(param1:WorldEvent) : void
      {
         var _loc6_:Player = null;
         var _loc2_:String = param1.eventData.code as String;
         var _loc3_:Number = 1;
         if(param1.eventData.quantity !== undefined)
         {
            _loc3_ = parseInt(param1.eventData.quantity);
         }
         else if(param1.eventData.yield !== undefined)
         {
            _loc3_ = parseInt(param1.eventData.yield);
         }
         this.addToInventory(_loc2_,_loc3_);
         var _loc4_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc2_,GameItem) as GameItem;
         var _loc5_:String = null;
         if(Boolean(param1.eventData.sender) && _loc4_.type == GameItem.TYPE_PART)
         {
            _loc6_ = ZGlobal.player.findFriendById(param1.eventData.sender);
            if(_loc6_)
            {
               _loc5_ = ZGameUtils.ZlocT("Main","FeedbackGiftReceivedFromNeighbor",{
                  "item":_loc4_.getSentenceNameLocalizationObject("",true),
                  "user":_loc6_.localizationName
               });
            }
         }
         if(param1.eventData.id == "grant.item")
         {
            _loc5_ = ZGameUtils.ZlocT("Main","FeedbackResourcesItemReceived",{
               "item":_loc4_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME),
               "amount":_loc3_
            });
         }
         if(_loc4_.type == GameItem.TYPE_PART && _loc3_ > 1)
         {
            _loc5_ = ZGameUtils.ZlocT("Main","FeedbackResourcesGiftReceived",{
               "item":_loc4_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME),
               "amount":_loc3_
            });
         }
         if(_loc5_ == null)
         {
            _loc5_ = ZGameUtils.ZlocT("Main","FeedbackGiftReceived",{"item":_loc4_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME)});
         }
         PlayerFeedbackManager.instance.displayFeedback(_loc5_);
      }
      
      private function onResourceGift(param1:WorldEvent) : void
      {
         ZGlobal.player.resources.updateResourceAmount(param1.eventData.name,param1.eventData.yield);
         var _loc2_:String = WorldResourceManager.instance.getResourceFriendlyNameFromType(param1.eventData.name,GameItem.SENTENCE_FRIENDLYNAME,true);
         PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackResourcesGiftReceived",{
            "item":_loc2_,
            "amount":param1.eventData.yield
         }));
      }
      
      private function onXPGift(param1:WorldEvent) : void
      {
         var _loc2_:int = parseInt(param1.eventData.yield);
         ZGlobal.player.xp += _loc2_;
      }
      
      private function onNewNeighbor(param1:WorldEvent) : void
      {
         Logger.print(this,"onNewNeighbor");
         var _loc2_:String = param1.eventData.neighbor.uid;
         this.m_neighbors[_loc2_] = param1.eventData.neighbor;
         var _loc3_:Player = ZGlobal.player.findFriendById(_loc2_);
         if(_loc3_)
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackNeighborReceived",{"neighbor":_loc3_.firstName}),null,null,_loc3_.uid);
         }
         NeighborsDispatcher.instance.dispatchEvent(new WorldEvent(NeighborsEvent.NEW_NEIGHBOR_ADDED,param1.eventData.neighbor));
      }
      
      public function get effectiveCrewSlotCountVariation() : uint
      {
         if(Boolean(this.m_newInstallExperiments) && this.m_newInstallExperiments[CrewManager.EXPERIMENT_CREW_SLOTS] != null)
         {
            return this.m_newInstallExperiments[CrewManager.EXPERIMENT_CREW_SLOTS];
         }
         return 0;
      }
      
      public function getBestOreInvitee(param1:int, param2:Array) : Object
      {
         var _loc3_:String = null;
         var _loc4_:Player = null;
         var _loc5_:Object = null;
         if(this.m_oreNonNeighbors[param1] != null && Boolean(this.m_oreNonNeighbors[param1].length))
         {
            _loc3_ = this.m_oreNonNeighbors[param1].shift();
            this.m_oreNonNeighbors[param1].push(_loc3_);
            _loc4_ = ZGlobal.player.findFriendById(_loc3_);
            if(_loc4_)
            {
               return {
                  "uid":_loc4_.uid,
                  "firstName":_loc4_.firstName,
                  "portraitURL":_loc4_.portraitURL
               };
            }
         }
         if(param2.length)
         {
            _loc5_ = param2.shift();
            param2.push(_loc5_);
            return Utilities.clone(_loc5_);
         }
         if(this.m_oreNeighbors[param1] != null && Boolean(this.m_oreNeighbors[param1].length))
         {
            _loc3_ = this.m_oreNeighbors[param1].shift();
            this.m_oreNeighbors[param1].push(_loc3_);
            _loc4_ = ZGlobal.player.findFriendById(_loc3_);
            if(_loc4_)
            {
               return {
                  "uid":_loc4_.uid,
                  "firstName":_loc4_.firstName,
                  "portraitURL":_loc4_.portraitURL
               };
            }
         }
         return null;
      }
      
      private function processOreInfo(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         if(param1.results)
         {
            for(_loc2_ in param1.results)
            {
               _loc3_ = parseInt(_loc2_);
               if(this.m_oreNonNeighbors[_loc3_] != null)
               {
                  this.m_oreNonNeighbors[_loc3_] = param1.results[_loc2_].concat(this.m_oreNonNeighbors[_loc3_]);
               }
            }
         }
         this.m_seenOreNeighborInfo = true;
         MessageDispatcher.instance.dispatchEvent(new Event(MessageDispatcher.ORE_NEIGHBOR_INFO_SEEN));
      }
      
      private function processLightningDealInfo(param1:Object) : void
      {
         var _loc2_:String = param1.code;
         var _loc3_:int = int(param1.count);
         this.updateLightningDealCount(_loc2_,_loc3_);
      }
      
      public function set friendFlashEPBankHold(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(this.m_friendFlashEPBankHold != param1)
         {
            _loc2_ = this.friendFlashEPBank;
            this.m_friendFlashEPBankHold = param1;
            _loc3_ = {
               "oldAmt":_loc2_,
               "newAmt":this.friendFlashEPBank
            };
            PromoManager.instance.dispatchEvent(new WorldEvent(PromoManager.FRIENDFLASH_EP_BANK_CHANGED,_loc3_));
         }
      }
      
      public function set friendFlashEPBank(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(this.m_friendFlashEPBank != param1)
         {
            _loc2_ = this.m_friendFlashEPBank;
            this.m_friendFlashEPBank = param1;
            _loc3_ = {
               "oldAmt":_loc2_,
               "newAmt":this.friendFlashEPBank
            };
            PromoManager.instance.dispatchEvent(new WorldEvent(PromoManager.FRIENDFLASH_EP_BANK_CHANGED,_loc3_));
         }
      }
      
      private function onTransactionComplete(param1:TransactionEvent) : void
      {
         if(param1.transaction.rawResult.metadata.oreInfo)
         {
            this.processOreInfo(param1.transaction.rawResult.metadata.oreInfo);
         }
         if(param1.transaction.rawResult.metadata.lightningDealInfo != undefined)
         {
            this.processLightningDealInfo(param1.transaction.rawResult.metadata.lightningDealInfo);
         }
      }
      
      public function expansionRectCheck(param1:Point, param2:uint, param3:uint) : Boolean
      {
         var _loc4_:uint = uint(BuildManager.instance.width);
         var _loc5_:uint = MathUtils.isoToExpansionIndex(param1.x,param1.y,_loc4_);
         var _loc6_:uint = MathUtils.isoToExpansionIndex(param1.x + param2 - 1,param1.y + param3 - 1,_loc4_);
         var _loc7_:uint = MathUtils.isoToExpansionIndex(param1.x,param1.y + param3 - 1,_loc4_);
         var _loc8_:uint = MathUtils.isoToExpansionIndex(param1.x + param2 - 1,param1.y,_loc4_);
         var _loc9_:BitArray = ZGlobal.hostPlayer.expansions;
         if(_loc9_.isBitSet(_loc5_) && _loc9_.isBitSet(_loc6_) && _loc9_.isBitSet(_loc7_) && _loc9_.isBitSet(_loc8_))
         {
            return true;
         }
         return false;
      }
      
      public function allowOneClickBuy() : Boolean
      {
         return ExperimentsManager.instance.getExperimentVariant("empires_pricetest_oneclickbuy") > 2 && TutorialManager.instance.isTutorialComplete();
      }
      
      public function canAddItemToInventory(param1:GameItem) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(Boolean(param1.inventoryCap) && param1.inventoryCap > 0)
         {
            _loc2_ = param1.inventoryCap;
            _loc3_ = this.getNumberOfInventoryItems(param1.code);
            if(_loc3_ >= _loc2_)
            {
               return false;
            }
         }
         return true;
      }
      
      public function getConsumableUsedByCode(param1:String) : int
      {
         var _loc2_:int = 0;
         if(Boolean(this.m_consumableUsedByCode) && this.m_consumableUsedByCode.hasOwnProperty(param1))
         {
            _loc2_ = int(this.m_consumableUsedByCode[param1]);
         }
         return _loc2_;
      }
      
      public function onConsumableUsed(param1:String) : void
      {
         if(this.m_consumableUsedByCode.hasOwnProperty(param1))
         {
            this.m_consumableUsedByCode[param1] += 1;
         }
         else
         {
            this.m_consumableUsedByCode[param1] = 1;
         }
      }
      
      public function isLightingDealItem(param1:String) : Boolean
      {
         return this.getLightningDealInfo(PromoManager.LD_MC_KEY_ITEMCODE) == param1;
      }
      
      public function get hasLightningDeal() : Boolean
      {
         return this.getLightningDealInfo(PromoManager.LD_MC_KEY_ITEMCODE) != null;
      }
      
      private function updateLightningDealCount(param1:String, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(this.isLightingDealItem(param1))
         {
            this.m_lightningDealInfo[PromoManager.LD_MC_KEY_CURRENT] = param2;
            _loc3_ = this.lightningDealFractionClaimed;
            _loc4_ = {
               "item":param1,
               "count":param2,
               "fractionClaimed":_loc3_
            };
            PromoManager.instance.dispatchEvent(new WorldEvent(PromoManager.LIGHTNINGDEAL_ITEMCOUNT_UPDATED,_loc4_));
         }
      }
      
      public function get friendFlashEPBank() : int
      {
         return this.m_friendFlashEPBank + this.m_friendFlashEPBankHold;
      }
      
      public function get friendFlashEPBankHold() : int
      {
         return this.m_friendFlashEPBankHold;
      }
      
      public function get friendFlashValid() : Boolean
      {
         var _loc1_:int = this.friendFlashExpireTS;
         var _loc2_:int = GlobalEngine.serverTime / 1000;
         return _loc2_ < _loc1_;
      }
      
      public function get meetsCriteriaLowWalletOnly() : Boolean
      {
         return this.m_meetsCriteriaLowWalletOnly;
      }
      
      public function get friendFlashExpireTS() : int
      {
         if(Boolean(this.m_friendFlashInfo) && Boolean(this.m_friendFlashInfo["expireTS"]))
         {
            return this.m_friendFlashInfo["expireTS"];
         }
         return 0;
      }
      
      public function getLightningDealInfo(param1:String) : *
      {
         if(Boolean(this.m_lightningDealInfo) && this.m_lightningDealInfo[param1] != undefined)
         {
            return this.m_lightningDealInfo[param1];
         }
         return null;
      }
      
      public function get lightningDealFractionAvailable() : int
      {
         var _loc1_:int = this.getLightningDealInfo(PromoManager.LD_MC_KEY_AMOUNT);
         if(_loc1_ < 1)
         {
            return 0;
         }
         var _loc2_:int = this.getLightningDealInfo(PromoManager.LD_MC_KEY_CURRENT);
         if(_loc2_ < 1)
         {
            return 0;
         }
         _loc2_ = Math.min(_loc2_,_loc1_);
         var _loc3_:int = _loc2_ * 100 / _loc1_;
         return int(Math.min(100,Math.max(1,_loc3_)));
      }
      
      public function get lightningDealFractionClaimed() : int
      {
         return 100 - this.lightningDealFractionAvailable;
      }
      
      public function getFriendlyClaimProgressString(param1:int) : String
      {
         if(param1 < 100)
         {
            return ZGameUtils.ZlocT("Dialogs","LightningDeal_Progress",{"amount":param1});
         }
         return ZGameUtils.ZlocT("Dialogs","LightningDeal_SoldOut");
      }
      
      public function get lightingDealTimeRemainingString() : String
      {
         var _loc1_:int = this.getLightningDealInfo(PromoManager.LD_MC_KEY_DATEEND);
         var _loc2_:int = GlobalEngine.serverTime / 1000;
         if(_loc2_ >= _loc1_)
         {
            return "";
         }
         var _loc3_:int = _loc1_ - _loc2_;
         var _loc4_:String = ZGameTimeUtil.instance.getClockString(_loc3_,false,false,false);
         return ZGameUtils.ZlocT("Dialogs","LightningDeal_TimeRemaining",{"timeString":_loc4_});
      }
      
      public function isLightningDealSoldOutItem(param1:String) : Boolean
      {
         if(!this.isLightingDealItem(param1))
         {
            return false;
         }
         var _loc2_:uint = this.getLightningDealInfo(PromoManager.LD_MC_KEY_CURRENT);
         if(_loc2_)
         {
            return false;
         }
         return true;
      }
      
      public function hasAnyResearchableUnits() : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         var _loc4_:XML = null;
         var _loc5_:UnitItem = null;
         var _loc1_:Array = new Array("army","air","navy");
         loop0:
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = ZGlobal.gameSettings.getArrayOfItemXMLByType("Buildable",_loc1_[_loc2_]);
            var _loc6_:int = 0;
            var _loc7_:* = _loc3_;
            do
            {
               for each(_loc4_ in _loc7_)
               {
                  _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_.@code,UnitItem) as UnitItem;
               }
               _loc2_++;
               continue loop0;
            }
            while(!this.canResearchUnit(_loc5_));
            return true;
         }
         return false;
      }
      
      public function canResearchUnit(param1:UnitItem) : Boolean
      {
         if(param1.contractLocked && !ZGlobal.player.hasPurchasedContract(param1.code))
         {
            return false;
         }
         if(ZGlobal.player.checkGate(param1).isBitSet(Player.GATE_FAILURE_LEVEL))
         {
            return false;
         }
         if(ZGlobal.player.checkGate(param1).isBitSet(Player.GATE_FAILURE_QUEST))
         {
            return false;
         }
         if(ZGameTimeUtil.instance.isLimitedEdition(param1.xml) && ExperimentsManager.instance.getExperimentVariant("empire_research_le") != Player.RESEARCH_LE_ON)
         {
            return false;
         }
         var _loc2_:int = ZGameTimeUtil.instance.getDateStatus(null,GameItem(param1).xml);
         if(ZGameTimeUtil.instance.isLimitedEdition(param1.xml) && _loc2_ != ZGameTimeUtil.DATE_STATUS_ACTIVE)
         {
            return false;
         }
         if(_loc2_ == ZGameTimeUtil.DATE_STATUS_ACTIVE && !ZGlobal.player.canSeeLEContent)
         {
            return false;
         }
         if(param1.zpoints)
         {
            return false;
         }
         var _loc3_:int = WorldUpgradeManager.instance.getNumCompletedUpgrades(param1.code);
         if(_loc3_ >= WorldUpgradeManager.instance.getTotalUpgrades(param1.code))
         {
            return false;
         }
         if(param1.researchTemplate != "")
         {
            return true;
         }
         return false;
      }
      
      public function getUnlockedUnitsOfType(param1:String) : Array
      {
         var _loc3_:String = null;
         var _loc4_:UnitItem = null;
         var _loc5_:int = 0;
         var _loc2_:Array = new Array();
         for each(_loc3_ in ZGlobal.player.getUnlockedUnits())
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,UnitItem) as UnitItem;
            _loc5_ = ZGameTimeUtil.instance.getDateStatus(null,GameItem(_loc4_).xml);
            if(_loc5_ == ZGameTimeUtil.DATE_STATUS_ACTIVE && this.canSeeLEContent)
            {
               if(Boolean(_loc4_) && _loc4_.subType == param1)
               {
                  if(this.canResearchUnit(_loc4_))
                  {
                     _loc2_.push(_loc4_);
                  }
               }
            }
         }
         return _loc2_;
      }
      
      public function buildingIsReadyForResearch(param1:IEntity) : Boolean
      {
         var _loc2_:BuildingFSMComponent = param1.lookupComponentByType(BuildingFSMComponent) as BuildingFSMComponent;
         var _loc3_:BehaviorStateMachine = _loc2_.stateMachine as BehaviorStateMachine;
         if(_loc2_.isBuilt && _loc3_.researchItemName == null)
         {
            return true;
         }
         return false;
      }
      
      public function get isPayingUserFromTargeting() : Boolean
      {
         return this.userGroups.indexOf(T8_PAYER_GROUP_ID) >= 0;
      }
      
      public function mostEPPurchasedRecently(param1:int) : int
      {
         var _loc4_:String = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Number = GlobalEngine.serverTime / 1000 + this.m_timeWarpSeconds;
         for each(_loc4_ in this.m_transactionLog)
         {
            _loc5_ = _loc4_.split("|");
            if(_loc3_ - parseInt(_loc5_[0]) < param1)
            {
               _loc6_ = parseInt(_loc5_[1]);
               if(_loc6_ > _loc2_)
               {
                  _loc2_ = _loc6_;
               }
            }
         }
         return _loc2_;
      }
      
      public function getMostRecentlyPurchasedEP() : int
      {
         var _loc1_:Array = null;
         if(Boolean(this.m_transactionLog) && Boolean(this.m_transactionLog.length))
         {
            _loc1_ = this.m_transactionLog[this.m_transactionLog.length - 1].split("|");
            return parseInt(_loc1_[1]);
         }
         return 0;
      }
      
      public function get xpMultiplier() : Number
      {
         return this.m_xpMultiplier;
      }
      
      public function set xpMultiplier(param1:Number) : void
      {
         this.m_xpMultiplier = param1;
         UIDispatcher.instance.dispatchEvent(new WorldEvent(XP_MULT_CHANGED,this.xpMultiplier));
      }
      
      public function get staticCP() : uint
      {
         return this.m_cpStatic;
      }
      
      public function hasResourceUnlock(param1:String, param2:uint = 0) : Boolean
      {
         if(Boolean(this.m_unlockedResource) && Boolean(this.m_unlockedResource[param1] != undefined) && this.m_unlockedResource[param1] >= 0)
         {
            return this.m_unlockedResource[param1] >= param2;
         }
         return false;
      }
      
      public function currentResourceMultiplier(param1:String) : int
      {
         if(Boolean(this.m_unlockedResource) && Boolean(this.m_unlockedResource[param1] != undefined) && this.m_unlockedResource[param1] >= 0)
         {
            return this.m_unlockedResource[param1];
         }
         return 0;
      }
      
      public function unlockResource(param1:String, param2:uint = 0) : void
      {
         if(this.m_unlockedResource)
         {
            if(!this.m_unlockedResource[param1] || this.m_unlockedResource[param1] == 0 || this.m_unlockedResource[param1] < param2)
            {
               this.m_unlockedResource[param1] = param2;
               TransactionManager.addTransaction(new TUnlockResource(param1,param2));
            }
         }
      }
      
      public function get unlockedResource() : Object
      {
         return this.m_unlockedResource;
      }
      
      public function setUnlockedResource(param1:Object) : void
      {
         if(param1)
         {
            this.m_unlockedResource = param1;
         }
      }
      
      public function resourceMultiplier(param1:String) : uint
      {
         if(Boolean(this.m_unlockedResource) && this.m_unlockedResource[param1] >= 0)
         {
            return this.m_unlockedResource[param1];
         }
         return 0;
      }
      
      public function get clanStatus() : String
      {
         return this.m_clanStatus;
      }
      
      public function get permissionsManager() : PermissionManager
      {
         return this.m_permMgr;
      }
      
      public function setIsCIP(param1:Boolean) : void
      {
         this.m_isCIP = param1;
      }
      
      public function get isCIP() : Boolean
      {
         return this.m_isCIP;
      }
      
      public function setAcceptedGDP(param1:Boolean) : void
      {
         this.m_acceptedGDP = param1;
      }
      
      public function get acceptedGDP() : Boolean
      {
         return this.m_acceptedGDP;
      }
      
      public function setAcceptedTOS(param1:Boolean) : void
      {
         this.m_acceptedTOS = param1;
      }
      
      public function get acceptedTOS() : Boolean
      {
         return !this.m_isCIP || this.m_acceptedTOS;
      }
      
      public function isCIPExperimentOn() : Boolean
      {
         return true;
      }
      
      public function checkCIPRequirements() : Boolean
      {
         if(this.m_isCIP == true && this.isCIPExperimentOn())
         {
            if(this.acceptedTOS == false && this.acceptedGDP == false)
            {
               PopupManager.instance.push(new UnlockMorePopup(UnlockMorePopup.UPSELL));
            }
         }
         return false;
      }
      
      protected function recheckCIPRequirements() : void
      {
         this.checkCIPRequirements();
      }
      
      public function ztrackCIP() : void
      {
         if(this.m_isCIP == true && this.isCIPExperimentOn())
         {
            StatsManager.count("cip","entrance");
         }
      }
   }
}

