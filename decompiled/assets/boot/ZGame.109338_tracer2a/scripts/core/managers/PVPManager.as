package core.managers
{
   import Engine.Classes.SocialNetworkUser;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import ZLocalization.LocalizationName;
   import ZQuest.Managers.QuestManager;
   import as3isolib.core.IIsoDisplayObject;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import com.adobe.crypto.MD5;
   import com.adobe.serialization.json.JSON;
   import core.ZGameManager;
   import core.ZGlobal;
   import core.entities.components.AreaImmuneComponent;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.PVPAreaImmuneMarkerComponent;
   import core.entities.components.PVPOccupationMarkerComponent;
   import core.entities.components.PVPOccupationMarkerHomeComponent;
   import core.entities.components.PVPOccupationMarkerPickOnlyComponent;
   import core.entities.components.PVPOccupationMarkerPillageComponent;
   import core.entities.components.PillageableComponent;
   import core.entities.components.ProtectorComponent;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.AutoDialogState;
   import core.entities.components.behaviors.states.DecoBuildableDefenseState;
   import core.entities.components.behaviors.states.DefenseTowerDialogState;
   import core.entities.components.utils.YieldHelper;
   import core.gamemode.GMDefault;
   import core.gamemode.GMVisit;
   import core.gamemode.GameMode;
   import core.gamemode.GameModeManager;
   import core.gamemode.UnitDefenseRangeRect;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.GMBattle;
   import core.gamemode.island.GMIsland;
   import core.gamemode.island.GMPVPOccupationPlace;
   import core.gameobjects.CrewTemplateWrapper;
   import core.gameobjects.GameItem;
   import core.gameobjects.IslandGroupItem;
   import core.gameobjects.VillainItem;
   import core.managers.leaderboardManager.LeaderboardManager;
   import core.managers.prisoncamp.PrisonCampManager;
   import core.managers.promoManager.PromoManager;
   import core.managers.questManager.FightItemTask;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.visitorManager.VisitorManager;
   import core.player.Friend;
   import core.player.IPVPPlayer;
   import core.player.Player;
   import core.player.PlayerDummy;
   import core.player.PlayerNonFriend;
   import core.player.PlayerVillain;
   import core.ui.PlayerFeedbackManager;
   import core.ui.UIManager;
   import core.ui.menuitem.ContextualBarUIItem;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.CineCameraComponent;
   import core.worlds.islandworld.factory.IslandViewFactory;
   import dispatchers.MessageDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.PVPCombatStartPopup;
   import displays.popups.PrisonCampNotification;
   import displays.popups.SpecialForcesMissionNoticePopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.screens.globalpvp.GlobalPVPLegalPopup;
   import entity.BuildingEntity;
   import entity.EntityInit;
   import entity.GameDataComponent;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.FullScreenEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import rendering.renderingIso.QuadSpatialComponent;
   import rendering.renderingIso.QuadSpatialManager;
   import transactions.TBuyCrewRepelPosition;
   import transactions.TFightList;
   import transactions.TGetNeighborVisitChallenges;
   import transactions.TGetUsersInvaderChallenges;
   import transactions.TLoadChallenge;
   import transactions.TPVPGlobalOptInOut;
   import transactions.TPVPGlobalSlotMachineSpin;
   import transactions.TPVPGlobalSlotMachineSpinBuy;
   import transactions.TPVPImmunityExtend;
   import transactions.TPVPImmunityStart;
   import transactions.TPVPOccupationPlace;
   import transactions.TPVPPillage;
   import transactions.TRejectDecoBuildableDefenseRepel;
   import transactions.TRejectDefenseTowerRepel;
   import transactions.TRejectFriendRepel;
   import transactions.TSeenPrisonCampNotification;
   import transactions.TWorldLoad;
   import utils.TileUtil;
   import utils.TimerHandler;
   import utils.ZGameRandom;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.core.InputManager;
   import zlabs.core.PBGroup;
   import zlabs.debug.Logger;
   import zlabs.displays.popups.IWindow;
   import zlabs.displays.zflex.ZCanvas;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.rendering.renderingISO.ISpatialObjectISO;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.utils.MathUtils;
   import zlabs.utils.StringUtils;
   
   public class PVPManager extends EventDispatcher
   {
      
      public static var instance:PVPManager = new PVPManager();
      
      public static const NUM_IMMUNITY_CONTRIBUTORS:int = 7;
      
      public static const DEFAULT_ENTITY_CODE:String = "PVP";
      
      public static const MARKER_FADE_ALPHA:int = 1;
      
      public static const MARKER_FADE_EMBERS:int = 2;
      
      public static const STATUS_AVAILABLE:int = 0;
      
      public static const STATUS_INCOMBAT:int = 1;
      
      public static const STATUS_OCCUPIED:int = 2;
      
      public static const STATUS_RETAL_COOLDOWN:int = 3;
      
      public static const VISIT_MODE_NONE:int = 0;
      
      public static const VISIT_MODE_PILLAGE:int = 1;
      
      public static const VISIT_MODE_ATTACK:int = 2;
      
      public static const STRANGERBAR_NORMAL:int = 0;
      
      public static const STRANGERBAR_COMPACT:int = 1;
      
      public static const IMMUNITY_STARTED:String = "immunityStarted";
      
      public static const IMMUNITY_EXPIRED:String = "immunityExpired";
      
      public static const IMMUNITY_UPDATED:String = "immunityUpdated";
      
      public static const IMMUNITY_TIMER_UPDATED:String = "immunityTimerUpdated";
      
      public static const IMMUNITY_CONTRIBUTORS_CHANGED:String = "immunityContributorsChanged";
      
      public static const PILLAGE_ENABLED:String = "pillageStart";
      
      public static const PILLAGE_PERFORMED:String = "pillagePerformed";
      
      public static const PILLAGE_PLACED:String = "pillagePlaced";
      
      public static const BUILD_FINISHED:String = "pillageBuildFinished";
      
      public static const MARKER_ACTIVATED:String = "pvpMarkerActivated";
      
      public static const MARKER_DEACTIVATED:String = "pvpMarkerDeactivated";
      
      public static const INVADER_UPDATED:String = "invaderUpdated";
      
      public static const DEFENDER_UPDATED:String = "defenderUpdated";
      
      public static const LAST_MINUTE_IMMUNITY:String = "lastMinuteImmunity";
      
      public static const WHITE_KNIGHT_REPEL:String = "whiteKnightRepel";
      
      public static const FRIEND_REPEL_PICK_REMOVED:String = "friendRepelPickRemoved";
      
      public static const FRIEND_REPEL_PICK_ADD:String = "friendRepelPickAdd";
      
      public static const REPEL_CREW_UPDATED:String = "repelCrewUpdated";
      
      public static const REMOVE_MARKER:String = "removeMarker";
      
      public static const FADEOUT_MARKER:String = "fadeoutMarker";
      
      public static const DISABLE_MARKER:String = "disableMarker";
      
      public static const UPDATE_MARKER:String = "updateMarker";
      
      public static const INVASION_REPEL_HANDLED:String = "invasionRepelHandled";
      
      public static const UPDATE_COMMENT:String = "updateComment";
      
      public static const UPDATE_TAUNT:String = "updateTaunt";
      
      public static const SPIN_START:String = "spinStart";
      
      public static const SPIN_RESULTS:String = "spinResults";
      
      public static const GLOBALPVP_UI_STATECHANGE:String = "gpUIChange";
      
      public static const GLOBALPVP_UI_STATECHANGEDONE:String = "gpUIDone";
      
      public static const FIGHT_LIST_RECEIVED:String = "fightListReceived";
      
      public static const FIGHT_LIST_CHANGED:String = "fightListChanged";
      
      public static const GPVP_OPT_INOUT_CHANGED:String = "optInChanged";
      
      public static const GPVP_WINS_CHANGED:String = "winsChanged";
      
      public static const GPVP_AWARD_CLAIMED:String = "awardChanged";
      
      public static const GLOBALPVP_MOTD_DONE:String = "globalPVPMOTDDone";
      
      public static const PVE_MARKER_KEY:String = "pve";
      
      public static const UPDATE_NEIGHBOR_PVP_ICON:String = "updateNeighborPvpIcon";
      
      public static const REPEL_CREW_FULL:String = "full";
      
      public static const REPEL_CREW_NOBUY:String = "nobuy";
      
      public static const REPEL_CREW_SUCCESS:String = "success";
      
      public static const GLOBALPVP_UI_NONE:uint = 0;
      
      public static const GLOBALPVP_UI_FADEIN:uint = 1;
      
      public static const GLOBALPVP_UI_ACTIVE:uint = 2;
      
      public static const GLOBALPVP_UI_FADEOUT:uint = 3;
      
      public static const INVASION_COMPLETE_OK:int = 0;
      
      public static const INVASION_COMPLETE_IMMUNE:int = 1;
      
      public static const INVASION_COMPLETE_MAXOCCUPATIONS:int = 2;
      
      public static const INVASION_COMPLETE_OVERLAP:int = 3;
      
      public static const INVASION_COMPLETE_DEFENSETOWER:int = 4;
      
      public static const INVASION_COMPLETE_DECOBUILDABLE:int = 6;
      
      public static const OCCUPATION_INVALID:int = 0;
      
      public static const OCCUPATION_VALID:int = 1;
      
      public static const OCCUPATION_VALID_PROTECTED_BUILDING:int = 2;
      
      public static const OCCUPATION_VALID_PROTECTED_AREA:int = 3;
      
      public static const DEFENSE_TOWER_FAKE_USER_ID:int = -1;
      
      public static const DECO_BUILDABLE_FAKE_USER_ID:int = -2;
      
      public static const REWARD_SPIN_MODE_BUY:uint = 1;
      
      public static const REWARD_SPIN_MODE_KEYS:uint = 2;
      
      public static const MISSION_DEPLOY_MODE:String = "missionDeployModeActive";
      
      public static const MISSION_DEPLOY_MODE_CLICK:String = "missionDeployModeClick";
      
      public static const STRIKE_TEAM_DEPLOYED:String = "strikeTeamDeployed";
      
      public static const MISSION_AMBUSH:String = "N43";
      
      public static const MISSION_MIND_CONTROL:String = "N44";
      
      public static const MISSION_AMBUSH2:String = "N45";
      
      public static const STRIKE_TEAM_BUILDING:String = "HQ01";
      
      private static const m_globalPVPFightListBucketNames:Array = ["Lowest","Lower","Equal","Higher","Highest"];
      
      private static const m_invasionUpdateLabels:Array = new Array("","PVPLastMinuteImmunity","PVPLastMinuteMaxOccupations","PVPLastMinuteOverlap","PVPLastMinuteDefenseTower");
      
      private var m_immunity:Object = new Object();
      
      private var m_hostImmunity:Object = new Object();
      
      private var m_visitMode:int = 0;
      
      private var m_combatModalPopup:PVPCombatStartPopup;
      
      private var m_quadComponent:QuadSpatialManager = null;
      
      private var m_isoScene:IsoScene = null;
      
      private var m_invaders:Dictionary = new Dictionary();
      
      private var m_neighborAssists:Dictionary = new Dictionary();
      
      private var m_activeAreaImmunity:Dictionary = new Dictionary();
      
      private var m_globalPVPInfos:Dictionary = new Dictionary();
      
      private var m_globalPVPWinChangeEvents:Array = new Array();
      
      private var m_winChangePollTimer:Timer;
      
      private var m_globalPVPInvasions:Dictionary = new Dictionary();
      
      private var m_globalPVPState:Object;
      
      private var m_globalPVPOptIn:Boolean;
      
      private var m_globalPVPMOTDActive:Boolean;
      
      private var m_globalPVPPrizeSet:uint = 0;
      
      private var m_entityOverlaps:Boolean;
      
      private var m_invasionUpdateQueue:Array = new Array();
      
      private var m_defenderUpdateQueue:Array = new Array();
      
      private var m_lastMinuteImmunities:Dictionary = new Dictionary();
      
      private var m_maxDefenseRange:int = -1;
      
      private var m_maxDefenseOverlap:int = -1;
      
      private var m_immunityTimer:TimerHandler;
      
      private var m_globalPVPInactionTimer:TimerHandler;
      
      private var m_lastMinuteImmunityDialogTimer:TimerHandler;
      
      private var m_isVisitGlobalPVP:Boolean = false;
      
      private var m_globalPVPUIState:uint = 0;
      
      private var m_windowParent:DisplayObjectContainer;
      
      private var m_container:ZCanvas = new ZCanvas();
      
      private var m_pcEscapedNotify:Array = new Array();
      
      private var m_pcCapturedNotify:Object = new Object();
      
      public function PVPManager()
      {
         super();
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onBattleComplete,false,0,true);
         TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
         TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,this.onTransactionComplete);
         addEventListener(INVADER_UPDATED,this.onInvaderUpdated,false,0,true);
         addEventListener(DEFENDER_UPDATED,this.onDefenderUpdated,false,0,true);
         addEventListener(LAST_MINUTE_IMMUNITY,this.onLastMinuteImmunity,false,0,true);
         addEventListener(GLOBALPVP_UI_STATECHANGEDONE,this.onGlobalPVPUIStateChangeDone,false,0,true);
         addEventListener(FIGHT_LIST_RECEIVED,this.onFightListReceived,false,0,true);
         GameModeManager.instance.addEventListener(GMIsland.ISLAND_MODE_ENTERED,this.onIslandEntered,false,0,true);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.PVP_INVADED,this.onInvaded);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.PVP_REPELLED,this.onRepelled);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.PVP_ASSIST_REPELLED,this.onAssistRepelled);
      }
      
      public static function get strangerBarType() : int
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant("empire_globalpvp_strangerbar_type");
         if(_loc1_ == 2)
         {
            return STRANGERBAR_COMPACT;
         }
         return STRANGERBAR_NORMAL;
      }
      
      public static function get globalPVPMaxProgress() : int
      {
         return ZGlobal.gameSettings.getInt("GlobalPVPMaxInvasionSlots",15);
      }
      
      public static function get neighborImmunityDuration() : int
      {
         return ZGlobal.gameSettings.getInt("PVPImmunityNeighborDurationBonus",86400);
      }
      
      public static function get pvpMinLevel() : int
      {
         return ZGlobal.gameSettings.getInt("PVPMinLevel");
      }
      
      public static function canLevelParticipate(param1:int) : Boolean
      {
         return param1 >= pvpMinLevel;
      }
      
      public static function activityAreaRootToCenter(param1:Point, param2:int, param3:Point = null) : Point
      {
         if(!param3)
         {
            param3 = new Point();
         }
         param3.x = param1.x + Math.floor(param2 * 0.5);
         param3.y = param1.y + Math.floor(param2 * 0.5);
         return param3;
      }
      
      public static function get pvpInvasionAreaSize() : int
      {
         return ZGlobal.gameSettings.getInt("PVPInvasionAreaSize",8);
      }
      
      public static function get pvpLiveInvasionAreaSize() : int
      {
         if(DroneCommandManager.instance.isActive())
         {
            return ZGlobal.gameSettings.getInt("PVPDroneInvasionAreaSize",8);
         }
         return ZGlobal.gameSettings.getInt("PVPInvasionAreaSize",8);
      }
      
      public static function get pvpInvasionAreaOverlapSize() : int
      {
         return ZGlobal.gameSettings.getInt("PVPInvasionAreaOverlapSize",1);
      }
      
      public static function get pillageCooldownTime() : int
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_PILLAGE_TIME_EXTEND) == ExperimentsManager.VARIANT_PILLAGE_TIME_EXTEND_ENABLED)
         {
            return ZGlobal.gameSettings.getInt("PVPPillageCooldown") * ZGlobal.gameSettings.getInt("PVPPillageScalar");
         }
         return ZGlobal.gameSettings.getInt("PVPPillageCooldown");
      }
      
      public static function getNextCampaignVillain() : String
      {
         var _loc1_:IslandGroupItem = ZGlobal.gameSettings.getItemByCode(ZGlobal.player.campaign.activeMap,IslandGroupItem) as IslandGroupItem;
         return _loc1_.villain;
      }
      
      public static function getImmunityDuration(param1:Boolean) : int
      {
         var _loc6_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:int = ZGlobal.immunityTimeVariant;
         var _loc4_:String = param1 ? "PVPImmunityBaseDurations" : "PVPImmunityNeighborDurationBonuses";
         var _loc5_:String = ZGlobal.gameSettings.getString(_loc4_,"18h,18h,12h,8h,4h");
         if((Boolean(_loc5_)) && Boolean(_loc5_.length))
         {
            _loc6_ = _loc5_.split(",");
            if((Boolean(_loc6_)) && _loc3_ < _loc6_.length)
            {
               _loc2_ = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc6_[_loc3_],0);
            }
         }
         return _loc2_;
      }
      
      public static function get spinPurchaseCost() : uint
      {
         var _loc1_:uint = uint(ExperimentsManager.instance.getExperimentVariant("empire_globalpvp_slotpull_epcost"));
         var _loc2_:String = ZGlobal.gameSettings.getString("GlobalPVPSlotPullEPCost","");
         var _loc3_:Array = _loc2_.split(",");
         if(_loc1_ < _loc3_.length)
         {
            return _loc3_[_loc1_];
         }
         return 1;
      }
      
      public static function get spinPurchaseKeyCost() : uint
      {
         var _loc1_:uint = uint(ExperimentsManager.instance.getExperimentVariant("empire_globalpvp_slotpull_epcost"));
         var _loc2_:String = ZGlobal.gameSettings.getString("GlobalPVPSlotPullKeyCost","");
         var _loc3_:Array = _loc2_.split(",");
         if(_loc1_ < _loc3_.length)
         {
            return _loc3_[_loc1_];
         }
         return 1;
      }
      
      public static function isGlobalPVPFadeState(param1:uint) : Boolean
      {
         return param1 == GLOBALPVP_UI_FADEIN || param1 == GLOBALPVP_UI_FADEOUT;
      }
      
      public static function get globalPVPDurationHours() : Number
      {
         var _loc1_:String = ZGlobal.gameSettings.getString("GlobalPVPFightListDuration","1d");
         var _loc2_:Number = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc1_,0);
         var _loc3_:Object = ZGameTimeUtil.instance.getTimeObject(_loc2_,true);
         return _loc3_["hours"];
      }
      
      public static function getInvasionAreaFromInvader(param1:Object) : int
      {
         if(param1.size)
         {
            return param1.size;
         }
         return pvpInvasionAreaSize;
      }
      
      public function get globalPVPUIState() : uint
      {
         return this.m_globalPVPUIState;
      }
      
      public function get isStrangerBarStable() : Boolean
      {
         return this.m_globalPVPUIState == GLOBALPVP_UI_NONE || this.m_globalPVPUIState == GLOBALPVP_UI_ACTIVE;
      }
      
      public function getStrangerSlotIndex(param1:String) : int
      {
         var _loc2_:int = 0;
         if(this.hasGlobalPVPFightBatch)
         {
            if(this.m_globalPVPState.cfb.fightList as Array)
            {
               _loc2_ = int(this.m_globalPVPState.cfb.fightList.indexOf(param1));
               if(_loc2_ >= 0)
               {
                  return _loc2_;
               }
            }
         }
         return -1;
      }
      
      public function get canToggleGlobalPVPBar() : Boolean
      {
         return this.canShowGlobalPVPBar() || this.canHideGlobalPVPBar();
      }
      
      public function toggleGlobalPVPBar() : void
      {
         if(this.canShowGlobalPVPBar())
         {
            this.showGlobalPVPBar();
         }
         else if(this.canHideGlobalPVPBar())
         {
            this.hideGlobalPVPBar();
         }
      }
      
      public function canShowGlobalPVPBar(param1:Boolean = false) : Boolean
      {
         if(this.globalPVPUIState != GLOBALPVP_UI_NONE)
         {
            return false;
         }
         var _loc2_:int = ZGlobal.gameSettings.getInt("GlobalPVPMinLevel",8);
         if(ZGlobal.player.level < _loc2_)
         {
            return false;
         }
         if(!param1 && !this.globalPVPOptedIn)
         {
            return false;
         }
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant("empire_globalpvp_strangerbar_enable");
         if(_loc3_ != 2)
         {
            return false;
         }
         return true;
      }
      
      public function canHideGlobalPVPBar() : Boolean
      {
         return this.globalPVPUIState == GLOBALPVP_UI_ACTIVE;
      }
      
      public function showGlobalPVPBar() : void
      {
         if(this.canShowGlobalPVPBar())
         {
            if(this.needsFightList)
            {
               TransactionManager.addTransaction(new TFightList(false),true);
            }
            else
            {
               StatsManager.count("stranger_pvp","g_flip","clicked");
            }
            this.globalPVPUIState = GLOBALPVP_UI_FADEIN;
         }
      }
      
      public function refreshingTruncatedFightList(param1:int) : Boolean
      {
         var _loc2_:Array = this.globalPVPFightList;
         if(_loc2_.length != globalPVPMaxProgress && param1 + 1 >= _loc2_.length)
         {
            TransactionManager.addTransaction(new TFightList(true),true);
            return true;
         }
         return false;
      }
      
      private function get needsFightList() : Boolean
      {
         if(!this.hasGlobalPVPFightBatch)
         {
            return true;
         }
         if(!this.m_globalPVPState.cfb.ts)
         {
            return true;
         }
         var _loc1_:int = GlobalEngine.serverTime;
         var _loc2_:String = ZGlobal.gameSettings.getString("GlobalPVPFightListDuration","1d");
         var _loc3_:int = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc2_,0);
         var _loc4_:int = this.m_globalPVPState.cfb.ts + _loc3_;
         if(_loc1_ >= _loc4_)
         {
            return true;
         }
         if(!this.m_globalPVPState.cfb.fightList || !(this.m_globalPVPState.cfb.fightList as Array) || this.m_globalPVPState.cfb.fightList.length < globalPVPMaxProgress)
         {
            return true;
         }
         return false;
      }
      
      public function hideGlobalPVPBar() : void
      {
         if(this.canHideGlobalPVPBar())
         {
            this.globalPVPUIState = GLOBALPVP_UI_FADEOUT;
         }
      }
      
      public function init(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:Number = NaN;
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         if(param1.pvp)
         {
            _loc2_ = param1.pvp;
            if(!(_loc2_.immunity as Array))
            {
               this.m_immunity = _loc2_.immunity;
               this.m_hostImmunity = _loc2_.immunity;
               this.startImmunityTimer();
               dispatchEvent(new Event(IMMUNITY_UPDATED));
            }
            if(_loc2_.invaders)
            {
               this.parseInvaders(_loc2_.invaders);
            }
            if(_loc2_.nAssists)
            {
               this.storeNeighborAssists(_loc2_.nAssists);
            }
            if(!(_loc2_.gpInv as Array))
            {
               for(_loc3_ in _loc2_.gpInv)
               {
                  this.m_globalPVPInvasions[_loc3_] = _loc2_.gpInv[_loc3_];
               }
            }
            if(_loc2_.notifications)
            {
               this.parseNotifications(_loc2_.notifications);
            }
            if(_loc2_.pcCapturedNotify)
            {
               for(_loc4_ in _loc2_.pcCapturedNotify)
               {
                  this.m_pcCapturedNotify[_loc4_.substr(1)] = _loc2_.pcCapturedNotify[_loc4_];
               }
            }
            if(_loc2_.pcEscapedNotify)
            {
               for each(_loc5_ in _loc2_.pcEscapedNotify)
               {
                  this.m_pcEscapedNotify.push(_loc5_.substr(1));
               }
            }
         }
         if(param1.globalPVPOptIn)
         {
            this.m_globalPVPOptIn = param1.globalPVPOptIn;
         }
         if(param1.globalPVPInactive)
         {
            _loc6_ = ZGlobal.gameSettings.getString("GlobalPVPInactionSessionTimer","5m");
            _loc7_ = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc6_,0);
            this.m_globalPVPInactionTimer = new TimerHandler(_loc7_ * 1000,this,this.onGlobalPVPInaction);
            this.m_globalPVPInactionTimer.start();
         }
         if(param1.globalPVPInfos)
         {
            this.m_globalPVPInfos = new Dictionary();
            _loc8_ = param1.globalPVPInfos;
            _loc9_ = 0;
            while(_loc9_ < _loc8_.length)
            {
               this.updateGlobalPVPInfo(_loc8_[_loc9_]);
               _loc9_++;
            }
         }
      }
      
      public function get globalPVPCurrentAwardClaimed() : Boolean
      {
         if(this.hasGlobalPVPFightBatch)
         {
            return this.m_globalPVPState.cfb.awardClaimed;
         }
         return false;
      }
      
      public function get globalPVPWinProgress() : int
      {
         if(this.hasGlobalPVPFightBatch)
         {
            return this.m_globalPVPState.cfb.wins;
         }
         return -1;
      }
      
      public function getGlobalPVPStrangerInfo(param1:String) : Object
      {
         if(this.m_globalPVPInfos[param1])
         {
            return this.m_globalPVPInfos[param1];
         }
         return null;
      }
      
      public function updateGlobalPVPInfo(param1:Object) : void
      {
         var _loc2_:Friend = new Friend(param1.uid,param1.coins,param1.xp,param1.level,param1.socialXpGood,param1.socialLevelGood,param1.socialXpBad,param1.socialLevelBad,param1.resource,param1.snUser.image,param1.snUser.name,param1.dominanceRank);
         _loc2_.tendInfo = param1.tending;
         var _loc3_:SocialNetworkUser = new SocialNetworkUser(parseInt(param1.uid));
         _loc3_.firstName = _loc3_.name = param1.snUser.name;
         _loc3_.picture = _loc3_.picture = param1.snUser.image;
         _loc3_.gender = param1.snUser.gender;
         var _loc4_:Player = new Player(_loc3_);
         var _loc5_:Object = new Object();
         _loc5_.friendInfo = _loc2_;
         _loc5_.playerInfo = _loc4_;
         _loc5_.gpInfo = param1.gpInfo;
         this.m_globalPVPInfos[param1.uid] = _loc5_;
      }
      
      public function getGlobalPVPInvasionStatus(param1:String) : int
      {
         if(this.m_globalPVPInvasions[param1] == undefined)
         {
            return STATUS_AVAILABLE;
         }
         return this.m_globalPVPInvasions[param1];
      }
      
      public function getStrangerWins(param1:String) : int
      {
         if(Boolean(this.m_globalPVPInfos[param1]) && Boolean(this.m_globalPVPInfos[param1].gpInfo))
         {
            return this.m_globalPVPInfos[param1].gpInfo.tWins;
         }
         return 0;
      }
      
      public function getImmunityStartReinvadeCooldownInfo() : Object
      {
         var _loc1_:int = 0;
         var _loc2_:Boolean = false;
         if(this.m_immunity.invExpTs > 0)
         {
            _loc1_ = GlobalEngine.serverTime / 1000;
            _loc2_ = _loc1_ > this.m_immunity.invExpTs;
            if(!_loc2_)
            {
               return {
                  "active":true,
                  "remaining":this.m_immunity.invExpTs - _loc1_
               };
            }
         }
         return {"active":false};
      }
      
      public function getMaxDefenseRange() : Number
      {
         if(this.m_maxDefenseRange == -1)
         {
            this.m_maxDefenseRange = ZGlobal.gameSettings.getInt("PVPMaxDefenseRange");
         }
         return this.m_maxDefenseRange;
      }
      
      public function getMaxDefenseOverlap() : Number
      {
         if(this.m_maxDefenseOverlap == -1)
         {
            this.m_maxDefenseOverlap = Math.floor(this.getMaxDefenseRange() / 2);
         }
         return this.m_maxDefenseOverlap;
      }
      
      public function neighborOccupiersExceeded(param1:String) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Object = ZGlobal.player.neighbors[param1];
         if(_loc2_)
         {
            _loc3_ = ZGlobal.gameSettings.getPVPMaxOccupations(_loc2_.level);
            return _loc2_.pvpNumOccupiers >= _loc3_;
         }
         return false;
      }
      
      public function neighborHasOccupiers(param1:String) : Boolean
      {
         var _loc2_:Object = ZGlobal.player.neighbors[param1];
         if(_loc2_)
         {
            return _loc2_.pvpNumOccupiers > 0;
         }
         return false;
      }
      
      public function neighborHasUnDefendedOccupiers(param1:String) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Object = ZGlobal.player.neighbors[param1];
         if(_loc2_)
         {
            _loc3_ = ExperimentsManager.instance.getExperimentVariant("empires_invasion_marker");
            if(_loc3_ == ZGlobal.EXPERIMENT_INVASION_MARKER_EXCLUDE_DEFENDED)
            {
               return _loc2_.pvpNumOccupiersNotDefended > 0;
            }
            return _loc2_.pvpNumOccupiers > 0;
         }
         return false;
      }
      
      private function updateNeighborHasOccupiers(param1:String) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(param1 != ZGlobal.player.uid)
         {
            _loc2_ = ZGlobal.player.neighbors[param1];
            if(_loc2_)
            {
               if(this.m_invaders)
               {
                  _loc5_ = 0;
                  _loc6_ = 0;
                  for(_loc3_ in this.m_invaders)
                  {
                     _loc4_ = this.m_invaders[_loc3_];
                     if((Boolean(_loc4_)) && _loc4_.status == STATUS_OCCUPIED)
                     {
                        if(_loc3_ != PVE_MARKER_KEY)
                        {
                           _loc5_++;
                        }
                        if(_loc4_.dID == null)
                        {
                           _loc6_++;
                        }
                     }
                  }
                  _loc2_.pvpNumOccupiers = _loc5_;
                  _loc2_.pvpNumOccupiersNotDefended = _loc6_;
               }
               else
               {
                  _loc2_.pvpNumOccupiers = 0;
                  _loc2_.pvpNumOccupiersNotDefended = 0;
               }
               dispatchEvent(new WorldEvent(UPDATE_NEIGHBOR_PVP_ICON,param1));
            }
         }
      }
      
      public function postInit() : void
      {
         var _loc1_:Player = null;
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:Point = null;
         if(this.m_invaders)
         {
            _loc1_ = null;
            if(ZGlobal.isHome())
            {
               for(_loc2_ in this.m_invaders)
               {
                  _loc3_ = this.m_invaders[_loc2_];
                  if(_loc3_.status == STATUS_OCCUPIED)
                  {
                     this.createOccupationMarker(_loc2_,_loc3_);
                     this.pillageMarkerActive(_loc2_,this.parsePosition(_loc3_.pos),getInvasionAreaFromInvader(_loc3_));
                     if(ZGlobal.PVPdefendOnStart == MD5.hash(_loc2_.toString() + ZGlobal.player.uid))
                     {
                        _loc1_ = ZGlobal.player.findFriendById(_loc2_);
                     }
                  }
               }
            }
            else if(ZGlobal.isVisiting())
            {
               for(_loc2_ in this.m_invaders)
               {
                  if(_loc2_ == ZGlobal.player.uid)
                  {
                     _loc4_ = this.getLocalPlayerInvasion();
                     if(_loc4_.status == STATUS_OCCUPIED)
                     {
                        _loc5_ = this.parsePosition(_loc4_.pos);
                        this.createPillageEntity(_loc5_,getInvasionAreaFromInvader(_loc4_));
                        dispatchEvent(new WorldEvent(PILLAGE_ENABLED,ZGlobal.player.uid));
                        this.pillageMarkerActive(ZGlobal.player.uid,this.parsePosition(_loc4_.pos),getInvasionAreaFromInvader(_loc4_));
                     }
                  }
                  else
                  {
                     _loc3_ = this.m_invaders[_loc2_];
                     if(_loc3_.status == STATUS_OCCUPIED)
                     {
                        if(this.isAttackVisit() || this.isPillageVisit())
                        {
                           this.createInertInvasionEntity(this.getPVPPlayer(_loc2_),this.parsePosition(_loc3_.pos),getInvasionAreaFromInvader(_loc3_));
                        }
                        else
                        {
                           this.createOccupationMarker(_loc2_,_loc3_);
                        }
                     }
                  }
               }
            }
            if(_loc1_)
            {
               if(ChallengeModeManager.instance.onSelectChallengerPlayer(_loc1_.uid))
               {
                  PVPManager.instance.setAndShowCombatPopup(new PVPCombatStartPopup(ZGlobal.player,_loc1_));
                  ZGlobal.PVPdefendOnStart = null;
               }
            }
         }
      }
      
      private function getEntityCode(param1:Object) : String
      {
         var _loc2_:VillainItem = null;
         var _loc3_:String = null;
         if(param1.villain)
         {
            _loc2_ = ZGlobal.gameSettings.getItemByCode(param1.villain,VillainItem) as VillainItem;
            _loc3_ = _loc2_.megaUnit();
            if(_loc3_)
            {
               return _loc3_;
            }
         }
         return DEFAULT_ENTITY_CODE;
      }
      
      private function createOccupationMarker(param1:String, param2:Object) : void
      {
         var _loc4_:String = null;
         var _loc5_:Point = null;
         var _loc6_:int = 0;
         var _loc7_:IEntity = null;
         var _loc8_:Player = null;
         var _loc9_:PVPOccupationMarkerComponent = null;
         var _loc3_:IPVPPlayer = this.getPVPPlayer(param1);
         if(_loc3_)
         {
            _loc4_ = this.getEntityCode(param2);
            _loc5_ = this.parsePosition(param2.pos);
            _loc6_ = getInvasionAreaFromInvader(param2);
            _loc7_ = this.createActivityEntity(_loc5_,_loc4_,_loc6_);
            if(_loc7_)
            {
               _loc8_ = null;
               if(Boolean(param2.dID) && ZGlobal.isHome())
               {
                  _loc8_ = ZGlobal.player.findFriendById(param2.dID);
               }
               if(Boolean(param2.quest) && ZGlobal.isVisiting())
               {
                  _loc9_ = new PVPOccupationMarkerPickOnlyComponent(_loc3_);
               }
               else
               {
                  _loc9_ = new PVPOccupationMarkerHomeComponent(param2,_loc3_,_loc8_);
               }
               _loc9_.activityMarkerRoot = _loc5_;
               _loc9_.isoOutlineRectSize = getInvasionAreaFromInvader(param2);
               _loc7_.addComponent(_loc9_,"pvpmarkerhome");
            }
         }
      }
      
      public function isInvaderQuestPVE(param1:String) : Boolean
      {
         if(param1 != PVE_MARKER_KEY)
         {
            return false;
         }
         var _loc2_:Object = this.m_invaders[param1];
         if(!_loc2_)
         {
            return false;
         }
         if(!_loc2_.quest)
         {
            return false;
         }
         return true;
      }
      
      public function isInvaderManualRepelOnly(param1:String) : Boolean
      {
         var _loc2_:Object = this.m_invaders[param1];
         if(!_loc2_)
         {
            return false;
         }
         if(!_loc2_.manualRepelOnly)
         {
            return false;
         }
         return true;
      }
      
      public function getCooldownInfo() : Object
      {
         var _loc1_:int = 0;
         if(Boolean(this.m_immunity) && Boolean(this.m_immunity.cdExp))
         {
            _loc1_ = GlobalEngine.serverTime / 1000;
            if(_loc1_ < this.m_immunity.cdExp)
            {
               return {
                  "active":true,
                  "timeLeft":this.m_immunity.cdExp - _loc1_
               };
            }
            this.m_immunity = {};
         }
         return {"active":false};
      }
      
      public function get numOccupiedInvaders() : Number
      {
         var _loc2_:Object = null;
         var _loc1_:Number = 0;
         for each(_loc2_ in this.m_invaders)
         {
            if(_loc2_.status == STATUS_OCCUPIED)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public function startImmunity() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Object = null;
         if(this.isImmune)
         {
            Logger.print(this,"error, can\'t start immunity if we\'re already immune");
            return;
         }
         for each(_loc1_ in ZGlobal.player.neighbors)
         {
            _loc2_ = _loc1_.pvpInfo;
            if(Boolean(_loc2_) && _loc2_.status == STATUS_OCCUPIED)
            {
               _loc1_.pvpInfo = {"status":STATUS_AVAILABLE};
            }
         }
         TransactionManager.addTransaction(new TPVPImmunityStart(),true);
         this.m_immunity.expTS = GlobalEngine.serverTime / 1000 + getImmunityDuration(true);
         if(!this.m_immunity.hIDs)
         {
            this.m_immunity.hIDs = new Array();
         }
         this.m_immunity.hIDs.push(ZGlobal.player.uid);
         dispatchEvent(new Event(IMMUNITY_STARTED));
         this.startImmunityTimer();
         if(ZGlobal.player.immunityClearsInvasions)
         {
            this.immunityClearInvasions();
         }
      }
      
      public function get immunityEndTime() : int
      {
         return this.immunityEndTimeHelper();
      }
      
      private function immunityEndTimeHelper() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this.isImmuneHelper(this.m_immunity))
         {
            _loc1_ = int(this.m_immunity.expTS);
            if(Boolean(this.m_immunity.hIDs) && Boolean(this.m_immunity.hIDs.length))
            {
               _loc2_ = (this.m_immunity.hIDs.length - 1) * getImmunityDuration(false);
            }
            else
            {
               Logger.print(this,"Error, we\'re immune but we don\'t have contributors. Strange");
            }
            return _loc1_ + _loc2_;
         }
         return 0;
      }
      
      public function get numImmunityContributors() : int
      {
         if(this.isImmune)
         {
            return this.m_immunity.hIDs.length;
         }
         return 0;
      }
      
      public function get immunityContributors() : Array
      {
         if(this.m_immunity.hIDs)
         {
            return this.m_immunity.hIDs;
         }
         return new Array();
      }
      
      public function get immunityPurchaseCost() : int
      {
         return ZGlobal.gameSettings.getInt("PVPImmunityNeighborSlotPurchaseCost",3);
      }
      
      public function canBuyImmunity() : Boolean
      {
         if(!this.isImmune)
         {
            Logger.print(this,"can only buy immunity if you\'re already active");
            return false;
         }
         if(this.m_immunity.hIDs.length >= NUM_IMMUNITY_CONTRIBUTORS)
         {
            return false;
         }
         if(!ZGlobal.player.canBuyCash(this.immunityPurchaseCost,true))
         {
            return false;
         }
         return true;
      }
      
      public function extendImmunity() : void
      {
         var _loc1_:int = 0;
         var _loc2_:TPVPImmunityExtend = null;
         if(this.canBuyImmunity())
         {
            _loc1_ = this.immunityPurchaseCost;
            ZGlobal.player.cash -= _loc1_;
            _loc2_ = new TPVPImmunityExtend();
            TransactionManager.addTransaction(_loc2_);
            this.m_immunity.hIDs.push(Player.FAKE_PLAYER_ID);
            this.startImmunityTimer();
            dispatchEvent(new WorldEvent(IMMUNITY_CONTRIBUTORS_CHANGED,this.m_immunity.hIDs));
         }
      }
      
      public function addImmunityCrew(param1:Object) : void
      {
         this.m_immunity.hIDs.push(param1.staffer);
         this.startImmunityTimer();
         dispatchEvent(new WorldEvent(IMMUNITY_CONTRIBUTORS_CHANGED,this.m_immunity.hIDs));
         var _loc2_:Player = ZGlobal.player.findFriendById(param1.staffer);
         if(_loc2_)
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackImmunityCrewReceived",{"crew":_loc2_.firstName}),null,null,_loc2_.uid);
         }
      }
      
      public function get isImmuneHost() : Boolean
      {
         return ZGlobal.isVisiting() ? this.isImmuneHelper(this.m_hostImmunity,false) : this.isImmuneHelper(this.m_immunity);
      }
      
      public function get isImmune() : Boolean
      {
         return this.isImmuneHelper(this.m_immunity);
      }
      
      public function isImmuneHelper(param1:Object, param2:Boolean = true) : Boolean
      {
         if(param2)
         {
            this.updateImmunity(param1);
         }
         if(!param1.expTS)
         {
            return false;
         }
         return param1.expTS > GlobalEngine.serverTime / 1000;
      }
      
      public function canVisitNeighbor(param1:String) : Boolean
      {
         var _loc2_:Object = null;
         if(Boolean(ZGlobal.player.neighbors[param1]) && Boolean(ZGlobal.player.neighbors[param1].pvpInfo))
         {
            _loc2_ = ZGlobal.player.neighbors[param1].pvpInfo;
            if(_loc2_.status == STATUS_INCOMBAT || _loc2_.status == STATUS_OCCUPIED)
            {
               return false;
            }
         }
         return true;
      }
      
      public function getPlayerInvasionInfoForNeighbor(param1:String) : Object
      {
         var _loc2_:int = 0;
         if(Boolean(ZGlobal.player.neighbors[param1]) && Boolean(ZGlobal.player.neighbors[param1].pvpInfo))
         {
            if(ZGlobal.player.neighbors[param1].pvpInfo.status == STATUS_RETAL_COOLDOWN)
            {
               _loc2_ = ZGlobal.gameSettings.getInt("PVPRetaliationCooldown",600);
               if(ZGlobal.player.neighbors[param1].pvpInfo.ts + _loc2_ < GlobalEngine.serverTime / 1000)
               {
                  ZGlobal.player.neighbors[param1].pvpInfo.status = STATUS_AVAILABLE;
                  delete ZGlobal.player.neighbors[param1].pvpInfo.ts;
               }
            }
            return ZGlobal.player.neighbors[param1].pvpInfo;
         }
         return null;
      }
      
      public function isNeighborImmune(param1:String) : Boolean
      {
         var _loc2_:Object = ZGlobal.player.neighbors[param1];
         return Boolean(_loc2_) && Boolean(_loc2_.pvpImmunityTimestamp);
      }
      
      public function canBeAttacked(param1:String) : Boolean
      {
         var _loc2_:Object = ZGlobal.player.neighbors[param1];
         if(_loc2_)
         {
            if(_loc2_.level >= pvpMinLevel)
            {
               if(!_loc2_.PVPIsImmune)
               {
                  return true;
               }
            }
         }
         _loc2_ = this.m_globalPVPInfos[param1];
         if(_loc2_)
         {
            return true;
         }
         return false;
      }
      
      public function neighborRepelled(param1:String, param2:Object) : void
      {
         if(ZGlobal.player.neighbors[param1])
         {
            ZGlobal.player.neighbors[param1].pvpInfo = param2;
            dispatchEvent(new WorldEvent(UPDATE_NEIGHBOR_PVP_ICON,param1));
         }
      }
      
      public function updateInvasion(param1:String, param2:Object) : void
      {
         var _loc3_:WorldEvent = new WorldEvent(INVADER_UPDATED,{
            "id":param1,
            "invasion":param2
         });
         dispatchEvent(_loc3_);
      }
      
      public function performInvasion(param1:String, param2:Object) : void
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:Point = null;
         if(this.m_invaders != null)
         {
            _loc4_ = this.m_invaders[param1] != null ? int(this.m_invaders[param1].status) : STATUS_AVAILABLE;
            _loc5_ = this.m_invaders[param1] != null ? this.m_invaders[param1].chID : null;
            _loc6_ = this.m_invaders[param1] != null ? this.m_invaders[param1].pos : null;
            this.m_invaders[param1] = param2;
            if(_loc4_ == STATUS_OCCUPIED && param2.status != STATUS_OCCUPIED)
            {
               _loc7_ = MARKER_FADE_ALPHA;
               if(ZGlobal.isHome())
               {
                  ChallengeModeManager.instance.cleanupChallengeBattle(_loc5_);
                  _loc7_ = MARKER_FADE_EMBERS;
                  if(param2.giveRepelReward)
                  {
                     dispatchEvent(new WorldEvent(INVASION_REPEL_HANDLED,{"invaderID":param1}));
                  }
               }
               dispatchEvent(new WorldEvent(REMOVE_MARKER,{
                  "invaderID":param1,
                  "fadeType":_loc7_
               }));
               this.pillageMarkerInactive(param1,this.parsePosition(_loc6_));
            }
            else if(_loc4_ == STATUS_INCOMBAT && param2.status == STATUS_AVAILABLE)
            {
               if(ZGlobal.isVisiting())
               {
                  if(param1 == ZGlobal.player.uid)
                  {
                     _loc3_ = ZGlobal.player.neighbors[ZGlobal.hostPlayer.uid];
                     if(_loc3_)
                     {
                        _loc3_.pvpInfo = param2;
                        dispatchEvent(new WorldEvent(UPDATE_NEIGHBOR_PVP_ICON,ZGlobal.hostPlayer.uid));
                     }
                  }
                  this.pillageMarkerInactive(param1,this.parsePosition(param2.pos));
                  dispatchEvent(new WorldEvent(FADEOUT_MARKER,param1));
               }
            }
            else if(_loc4_ != STATUS_OCCUPIED && param2.status == STATUS_OCCUPIED)
            {
               if(param1 == ZGlobal.player.uid)
               {
                  param2.size = pvpLiveInvasionAreaSize;
                  this.m_invaders[param1].size = pvpLiveInvasionAreaSize;
                  _loc3_ = ZGlobal.player.neighbors[ZGlobal.hostPlayer.uid];
                  if(_loc3_)
                  {
                     _loc3_.pvpInfo = param2;
                     dispatchEvent(new WorldEvent(UPDATE_NEIGHBOR_PVP_ICON,ZGlobal.hostPlayer.uid));
                  }
                  this.pillageMarkerInactive(param1,this.parsePosition(param2.pos));
                  this.m_visitMode = VISIT_MODE_PILLAGE;
                  if(!PVPOccupationMarkerPillageComponent.hasInstance)
                  {
                     _loc8_ = this.parsePosition(param2.pos);
                     this.createPillageEntity(_loc8_,getInvasionAreaFromInvader(param2));
                  }
                  this.doPillage(true);
                  LeaderboardManager.instance.dispatchEvent(new WorldEvent(LeaderboardManager.LEADERBOARD_PVP_BATTLE_COMPLETE,LeaderboardManager.PVP_INVASION));
                  dispatchEvent(new WorldEvent(PILLAGE_ENABLED,ZGlobal.player.uid));
                  this.pillageMarkerActive(param1,this.parsePosition(param2.pos),getInvasionAreaFromInvader(param2));
                  PrisonCampManager.instance.clearInfo();
               }
               else if(param2.istatus != null && param2.istatus != INVASION_COMPLETE_OK)
               {
                  delete this.m_invaders[param1];
               }
               else
               {
                  if(this.isAttackVisit() || this.isPillageVisit())
                  {
                     this.createInertInvasionEntity(this.getPVPPlayer(param1),this.parsePosition(param2.pos),getInvasionAreaFromInvader(param2));
                  }
                  else
                  {
                     this.createOccupationMarker(param1,param2);
                  }
                  if(ZGlobal.isHome())
                  {
                     this.pillageMarkerActive(param1,this.parsePosition(param2.pos),getInvasionAreaFromInvader(param2));
                  }
               }
            }
            this.updateNeighborHasOccupiers(ZGlobal.hostPlayer.uid);
            if(param2.iTxt)
            {
               dispatchEvent(new WorldEvent(UPDATE_TAUNT,param2));
            }
         }
      }
      
      public function setDefended(param1:String, param2:Object, param3:Boolean = false) : void
      {
         var _loc4_:WorldEvent = new WorldEvent(DEFENDER_UPDATED,{
            "id":param1,
            "invasion":param2,
            "local":param3
         });
         dispatchEvent(_loc4_);
      }
      
      public function lastMinuteImmunity(param1:Object) : void
      {
         var _loc2_:WorldEvent = new WorldEvent(LAST_MINUTE_IMMUNITY,param1);
         dispatchEvent(_loc2_);
      }
      
      public function performDefended(param1:String, param2:Object, param3:Boolean) : void
      {
         var _loc4_:Point = null;
         var _loc5_:int = 0;
         var _loc6_:CineCameraComponent = null;
         var _loc7_:XML = null;
         var _loc8_:String = null;
         var _loc9_:IEntity = null;
         var _loc10_:PropertyReference = null;
         var _loc11_:BehaviorStateMachine = null;
         var _loc12_:YieldHelper = null;
         var _loc13_:Number = NaN;
         if(this.m_invaders != null && param2 != null)
         {
            if(ZGlobal.isHome() && this.m_invaders[param1].status != STATUS_OCCUPIED)
            {
               return;
            }
            this.m_invaders[param1] = param2;
         }
         if(ZGlobal.isHome())
         {
            dispatchEvent(new WorldEvent(REMOVE_MARKER,{"invaderID":param1}));
            this.createOccupationMarker(param1,param2);
         }
         else if(this.isNormalVisit())
         {
            dispatchEvent(new WorldEvent(REMOVE_MARKER,{
               "invaderID":param1,
               "fadeType":MARKER_FADE_ALPHA
            }));
            if(param3)
            {
               if(param2)
               {
                  _loc4_ = this.parsePosition(param2.pos);
               }
               else
               {
                  _loc8_ = ZGlobal.gameSettings.getString("cameraStartingPosition");
                  _loc4_ = StringUtils.parsePoint(_loc8_);
               }
               _loc6_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,CineCameraComponent) as CineCameraComponent;
               _loc6_.moveTo(new Pt(_loc4_.x,_loc4_.y));
               _loc7_ = VisitorManager.getRewardXML("defend");
               if(_loc7_)
               {
                  _loc9_ = this.createActivityEntity(_loc4_,DEFAULT_ENTITY_CODE,pvpLiveInvasionAreaSize);
                  if(_loc9_)
                  {
                     LeaderboardManager.instance.dispatchEvent(new WorldEvent(LeaderboardManager.LEADERBOARD_PVP_BATTLE_COMPLETE,LeaderboardManager.PVP_ASSIST));
                     _loc10_ = new PropertyReference("@StateMachine.stateMachine");
                     _loc11_ = _loc9_.getProperty(_loc10_) as BehaviorStateMachine;
                     _loc12_ = new YieldHelper();
                     _loc12_.initFromData(_loc7_);
                     _loc13_ = ZGameRandom.rewardInstance.float();
                     _loc12_.saveRandomFloat(_loc13_);
                     _loc12_.execute(_loc11_,_loc7_);
                     _loc9_.destroy();
                  }
               }
               this.clearNeighborAssist(ZGlobal.hostPlayer.uid);
            }
            else if(Boolean(param2) && Boolean(param2.dID) && param2.dID != ZGlobal.player.uid)
            {
               this.createOccupationMarker(param1,param2);
            }
         }
         this.updateNeighborHasOccupiers(ZGlobal.hostPlayer.uid);
         if(Boolean(param2) && Boolean(param2.dTxt))
         {
            dispatchEvent(new WorldEvent(UPDATE_COMMENT,param2));
         }
      }
      
      public function performLastMinuteImmunity(param1:Object) : void
      {
         var _loc2_:String = param1.victim;
         if(ZGlobal.hostPlayer.uid == _loc2_)
         {
            if(!param1.dontShowError)
            {
               this.startLastMinuteImmunityFeedback(param1);
            }
         }
         this.updateImmunityInfoForNeighbor(param1);
         delete this.m_lastMinuteImmunities[_loc2_];
      }
      
      public function performLastMinuteAreaImmune() : void
      {
      }
      
      private function rejectDefendedLocal(param1:String, param2:Class) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         if(this.m_invaders)
         {
            _loc3_ = this.m_invaders[param1];
            if(_loc3_)
            {
               TransactionManager.addTransaction(new param2(param1),true);
               _loc4_ = Utilities.clone(_loc3_);
               delete _loc4_.dID;
               delete _loc4_.dTxt;
               this.rejectDefended(param1,_loc4_);
            }
         }
      }
      
      public function rejectFriendDefendedLocal(param1:String) : void
      {
         this.rejectDefendedLocal(param1,TRejectFriendRepel);
      }
      
      public function rejectDefenseTowerDefendedLocal(param1:String) : void
      {
         this.rejectDefendedLocal(param1,TRejectDefenseTowerRepel);
      }
      
      public function rejectDecoBuildableDefendedLocal(param1:String) : void
      {
         this.rejectDefendedLocal(param1,TRejectDecoBuildableDefenseRepel);
      }
      
      public function rejectDefended(param1:String, param2:Object) : void
      {
         var _loc3_:Boolean = false;
         if(this.m_invaders != null)
         {
            _loc3_ = Boolean(this.m_invaders[param1]) && Boolean(this.m_invaders[param1].dID);
            this.m_invaders[param1] = param2;
         }
         if(_loc3_)
         {
            if(ZGlobal.isHome() || this.isNormalVisit())
            {
               dispatchEvent(new WorldEvent(REMOVE_MARKER,{
                  "invaderID":param1,
                  "fadeType":MARKER_FADE_ALPHA
               }));
               this.createOccupationMarker(param1,param2);
            }
         }
      }
      
      public function startPillage(param1:Point) : void
      {
         var _loc2_:Object = new Object();
         _loc2_.ts = GlobalEngine.serverTime / 1000;
         _loc2_.status = STATUS_AVAILABLE;
         _loc2_.pos = this.pointToPosString(param1);
         _loc2_.size = pvpLiveInvasionAreaSize;
         this.m_invaders[ZGlobal.player.uid] = _loc2_;
      }
      
      public function finalizePillage(param1:Point) : void
      {
         var _loc4_:PVPCombatStartPopup = null;
         var _loc2_:TPVPOccupationPlace = new TPVPOccupationPlace(param1);
         TransactionManager.addTransaction(_loc2_);
         if(ChallengeModeManager.instance.onSelectNewChallengePlayer(ZGlobal.hostPlayer.uid))
         {
            _loc4_ = new PVPCombatStartPopup(ZGlobal.player,ZGlobal.hostPlayer);
            this.setAndShowCombatPopup(_loc4_);
         }
         var _loc3_:Object = this.getLocalPlayerInvasion();
         if(!_loc3_)
         {
            _loc3_ = new Object();
         }
         _loc3_.ts = GlobalEngine.serverTime / 1000;
         _loc3_.status = STATUS_AVAILABLE;
         _loc3_.pos = this.pointToPosString(param1);
         _loc3_.size = pvpLiveInvasionAreaSize;
         this.m_invaders[ZGlobal.player.uid] = _loc3_;
         dispatchEvent(new Event(PILLAGE_PLACED));
      }
      
      public function isNormalVisit() : Boolean
      {
         return this.m_visitMode == VISIT_MODE_NONE;
      }
      
      public function isPillageVisit() : Boolean
      {
         return this.m_visitMode == VISIT_MODE_PILLAGE;
      }
      
      public function isAttackVisit() : Boolean
      {
         return this.m_visitMode == VISIT_MODE_ATTACK;
      }
      
      public function canPlace() : Boolean
      {
         var _loc1_:Object = this.getLocalPlayerInvasion();
         return !_loc1_ || _loc1_.status == STATUS_AVAILABLE;
      }
      
      public function canPillage() : Object
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(!this.isPillageVisit())
         {
            return {"canPillage":false};
         }
         var _loc1_:Object = ZGlobal.player.neighbors[ZGlobal.hostPlayer.uid];
         if(!_loc1_)
         {
            return {"canPillage":false};
         }
         var _loc2_:Object = _loc1_.pvpInfo;
         if(!_loc2_)
         {
            return {"canPillage":false};
         }
         if(_loc2_.status != STATUS_OCCUPIED)
         {
            return {"canPillage":false};
         }
         if(_loc2_.pillTS)
         {
            _loc3_ = _loc2_.pillTS + pillageCooldownTime;
            _loc4_ = GlobalEngine.serverTime / 1000;
            if(_loc3_ > _loc4_)
            {
               return {
                  "canPillage":false,
                  "remainingTime":_loc3_ - _loc4_
               };
            }
         }
         return {"canPillage":true};
      }
      
      public function getNewGameMode() : GMDefault
      {
         var _loc1_:Object = null;
         if(!this.isNormalVisit() && this.canBeAttacked(ZGlobal.hostPlayer.uid))
         {
            _loc1_ = this.getLocalPlayerInvasion();
            if(!_loc1_)
            {
               return new GMPVPOccupationPlace();
            }
            switch(_loc1_.status)
            {
               case STATUS_AVAILABLE:
               case STATUS_INCOMBAT:
               case STATUS_OCCUPIED:
                  return new GMPVPOccupationPlace();
            }
         }
         return new GMVisit();
      }
      
      public function isVisitGlobalPVP() : Boolean
      {
         return this.m_isVisitGlobalPVP;
      }
      
      public function isVisitBattleContinue() : Boolean
      {
         var _loc2_:Object = null;
         var _loc1_:Object = this.getLocalPlayerInvasion();
         if(!this.isNormalVisit() && Boolean(_loc1_))
         {
            switch(_loc1_.status)
            {
               case STATUS_INCOMBAT:
                  return true;
            }
         }
         else if(this.isNormalVisit())
         {
            _loc2_ = this.getNeighborAssist(ZGlobal.hostPlayer.uid);
            if(_loc2_)
            {
               return true;
            }
         }
         return false;
      }
      
      public function onVisit() : void
      {
         var _loc2_:Object = null;
         var _loc1_:Object = this.getLocalPlayerInvasion();
         if(!this.isNormalVisit() && Boolean(_loc1_))
         {
            switch(_loc1_.status)
            {
               case STATUS_INCOMBAT:
                  ChallengeModeManager.instance.onSelectNewChallengePlayer(ZGlobal.hostPlayer.uid);
                  return;
            }
         }
         else if(this.isNormalVisit())
         {
            _loc2_ = ChallengeModeManager.instance.getNeighborRepelChallengeInfo(ZGlobal.hostPlayer.uid);
            if(Boolean(_loc2_) && Boolean(_loc2_.challenge) && Boolean(_loc2_.assist) && _loc2_.challenge.state == ChallengeModeManager.CHALLENGE_STATE_IN_PROGRESS)
            {
               ChallengeModeManager.instance.startNeighborRepel(ZGlobal.hostPlayer.uid,_loc2_.assist.invID);
               return;
            }
         }
      }
      
      public function isValidOccupationLocation(param1:String, param2:Point) : int
      {
         var _loc10_:Object = null;
         var _loc11_:Boolean = false;
         var _loc12_:Rectangle = null;
         var _loc13_:Point = null;
         var _loc14_:Array = null;
         var _loc15_:Boolean = false;
         var _loc16_:String = null;
         var _loc17_:Point = null;
         var _loc18_:Object = null;
         var _loc19_:int = 0;
         var _loc20_:Object = null;
         var _loc21_:Object = null;
         var _loc22_:IEntity = null;
         var _loc23_:AreaImmuneComponent = null;
         var _loc3_:int = pvpLiveInvasionAreaSize;
         var _loc4_:Object = {
            "x":param2.x,
            "y":param2.y,
            "xLength":_loc3_,
            "yLength":_loc3_
         };
         var _loc5_:int = pvpInvasionAreaOverlapSize;
         var _loc6_:Object = {
            "x":param2.x,
            "y":param2.y,
            "xLength":_loc5_,
            "yLength":_loc5_
         };
         var _loc7_:Object = {
            "x":param2.x + _loc3_ / 2,
            "y":param2.y + _loc3_ / 2,
            "xLength":_loc5_,
            "yLength":_loc5_
         };
         var _loc8_:Boolean = false;
         if(!this.expansionUnlockCheck(param2))
         {
            _loc8_ = true;
         }
         var _loc9_:Boolean = false;
         for each(_loc10_ in this.m_invaders)
         {
            if(_loc10_.status == STATUS_OCCUPIED)
            {
               _loc17_ = this.parsePosition(_loc10_.pos);
               _loc18_ = {
                  "x":_loc17_.x,
                  "y":_loc17_.y,
                  "xLength":_loc5_,
                  "yLength":_loc5_
               };
               _loc19_ = PVPManager.getInvasionAreaFromInvader(_loc10_);
               _loc20_ = {
                  "x":_loc17_.x + _loc19_ / 2,
                  "y":_loc17_.y + _loc19_ / 2,
                  "xLength":_loc5_,
                  "yLength":_loc5_
               };
               if(TileUtil.tileOverlapCheck(_loc6_,_loc18_) || TileUtil.tileOverlapCheck(_loc7_,_loc20_))
               {
                  _loc9_ = true;
               }
            }
         }
         _loc11_ = false;
         for each(_loc12_ in this.m_activeAreaImmunity)
         {
            _loc21_ = {
               "x":_loc12_.x,
               "y":_loc12_.y,
               "xLength":_loc12_.width,
               "yLength":_loc12_.height
            };
            if(TileUtil.tileOverlapCheck(_loc4_,_loc21_))
            {
               _loc11_ = true;
            }
         }
         param2 = new Point(param2.x,param2.y);
         _loc13_ = new Point(_loc3_,_loc3_);
         _loc14_ = BuildManager.instance.getObjectsOverlappingVolume(param2,_loc13_);
         _loc15_ = false;
         for each(_loc16_ in _loc14_)
         {
            _loc22_ = Zlab.nameManager.lookup(_loc16_);
            if(_loc22_)
            {
               _loc23_ = _loc22_.lookupComponentByType(AreaImmuneComponent) as AreaImmuneComponent;
               if(_loc23_)
               {
                  if(_loc23_.isAreaImmune())
                  {
                     _loc15_ = true;
                  }
               }
            }
         }
         if(_loc9_ || _loc8_)
         {
            return OCCUPATION_INVALID;
         }
         if(_loc15_)
         {
            return OCCUPATION_VALID_PROTECTED_BUILDING;
         }
         if(_loc11_)
         {
            return OCCUPATION_VALID_PROTECTED_AREA;
         }
         return OCCUPATION_VALID;
      }
      
      public function getAreaImmunityRectangle(param1:IEntity) : Rectangle
      {
         var _loc3_:ISpatialObjectISO = null;
         var _loc4_:Vector3D = null;
         var _loc5_:IIsoDisplayObject = null;
         var _loc6_:Pt = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Pt = null;
         var _loc14_:Pt = null;
         var _loc2_:GameDataComponent = GameDataComponent(param1.lookupComponentByType(GameDataComponent));
         if(_loc2_.gameData.isAreaImmunityBuilding())
         {
            _loc3_ = param1.lookupComponentByType(QuadSpatialComponent) as ISpatialObjectISO;
            _loc4_ = _loc3_.position;
            _loc5_ = (param1.lookupComponentByType(IsoSpriteComponent) as IsoSpriteComponent).isoSprite;
            _loc6_ = new Pt(_loc5_.width,_loc5_.length);
            _loc7_ = _loc2_.gameData.defenseRangeX;
            _loc8_ = _loc2_.gameData.defenseRangeY;
            _loc9_ = ZGlobal.cellSize * _loc7_;
            _loc10_ = ZGlobal.cellSize * _loc8_;
            _loc11_ = Math.floor(_loc6_.x * 0.5) - Math.floor(_loc9_ * 0.5);
            _loc12_ = Math.floor(_loc6_.y * 0.5) - Math.floor(_loc10_ * 0.5);
            _loc13_ = new Pt(_loc4_.x + _loc11_,_loc4_.y + _loc12_);
            _loc14_ = MathUtils.worldToTile(_loc13_,ZGlobal.cellSize);
            return new Rectangle(_loc14_.x,_loc14_.y,_loc7_,_loc8_);
         }
         return new Rectangle();
      }
      
      public function updateAreaImmunitySingle(param1:IEntity) : void
      {
         var _loc3_:String = null;
         var _loc4_:Rectangle = null;
         var _loc5_:BuildingFSMComponent = null;
         var _loc6_:DefenseTowerDialogState = null;
         var _loc7_:DecoBuildableDefenseState = null;
         var _loc2_:GameDataComponent = GameDataComponent(param1.lookupComponentByType(GameDataComponent));
         if(_loc2_.gameData.isAreaImmunityBuilding())
         {
            _loc3_ = param1.name;
            _loc4_ = this.getAreaImmunityRectangle(param1);
            _loc5_ = BuildingFSMComponent(param1.lookupComponentByType(BuildingFSMComponent));
            _loc6_ = _loc5_.stateMachine.getCurrentState() as DefenseTowerDialogState;
            if((Boolean(_loc6_)) && _loc6_.isActive())
            {
               this.m_activeAreaImmunity[_loc3_] = _loc4_;
            }
            else
            {
               _loc7_ = _loc5_.stateMachine.getCurrentState() as DecoBuildableDefenseState;
               if((Boolean(_loc7_)) && _loc7_.canProtectAlways())
               {
                  this.m_activeAreaImmunity[_loc3_] = _loc4_;
               }
            }
         }
      }
      
      public function updateAreaImmunity() : void
      {
         var _loc2_:IEntity = null;
         var _loc3_:Dictionary = null;
         var _loc4_:IEntity = null;
         var _loc5_:GameDataComponent = null;
         var _loc1_:Dictionary = WorldObjectManager.instance.getObjectsBySubType("building","military");
         for each(_loc2_ in _loc1_)
         {
            this.updateAreaImmunitySingle(_loc2_);
         }
         _loc3_ = WorldObjectManager.instance.getObjectsBySubType("Buildable","decoration");
         for each(_loc4_ in _loc3_)
         {
            _loc5_ = GameDataComponent(_loc4_.lookupComponentByType(GameDataComponent));
            if(_loc5_.gameData.isAreaImmunityBuilding())
            {
               this.updateAreaImmunitySingle(_loc4_);
            }
         }
      }
      
      public function clearAreaImmunity() : void
      {
         var _loc1_:String = null;
         var _loc2_:IEntity = null;
         var _loc3_:PVPAreaImmuneMarkerComponent = null;
         dispatchEvent(new WorldEvent(AreaImmuneComponent.AREA_IMMUNITY_DEACTIVATED,null));
         for(_loc1_ in this.m_activeAreaImmunity)
         {
            _loc2_ = Zlab.nameManager.lookup(_loc1_);
            if(_loc2_)
            {
               _loc3_ = _loc2_.lookupComponentByType(PVPAreaImmuneMarkerComponent) as PVPAreaImmuneMarkerComponent;
               if(_loc3_)
               {
                  _loc2_.removeComponent(_loc3_);
               }
            }
         }
         this.m_activeAreaImmunity = new Dictionary();
      }
      
      public function updateAreaImmunityBuildings() : void
      {
         var _loc1_:Rectangle = null;
         var _loc2_:Pt = null;
         var _loc3_:Pt = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc6_:IEntity = null;
         for each(_loc1_ in this.m_activeAreaImmunity)
         {
            _loc2_ = new Pt(_loc1_.x,_loc1_.y);
            _loc3_ = new Pt(_loc1_.width,_loc1_.height);
            _loc4_ = BuildManager.instance.getObjectsOverlappingVolume(_loc2_,_loc3_);
            for each(_loc5_ in _loc4_)
            {
               _loc6_ = Zlab.nameManager.lookup(_loc5_);
               if(_loc6_)
               {
                  _loc6_.eventDispatcher.dispatchEvent(new WorldEvent(AreaImmuneComponent.AREA_IMMUNITY_ACTIVATED,null));
               }
            }
         }
      }
      
      public function updateAreaImmunityMarkers() : void
      {
         var _loc1_:String = null;
         var _loc2_:IEntity = null;
         var _loc3_:PVPAreaImmuneMarkerComponent = null;
         var _loc4_:Rectangle = null;
         for(_loc1_ in this.m_activeAreaImmunity)
         {
            _loc2_ = Zlab.nameManager.lookup(_loc1_);
            if(_loc2_)
            {
               _loc3_ = _loc2_.lookupComponentByType(PVPAreaImmuneMarkerComponent) as PVPAreaImmuneMarkerComponent;
               if(!_loc3_)
               {
                  _loc4_ = this.m_activeAreaImmunity[_loc1_];
                  _loc3_ = new PVPAreaImmuneMarkerComponent(_loc4_.width);
                  _loc3_.activityMarkerRoot = new Pt(_loc4_.x,_loc4_.y);
                  _loc2_.addComponent(_loc3_,"pvpmarkerareaimmunity");
               }
            }
         }
      }
      
      public function canActivateAreaImmunity(param1:IEntity) : Boolean
      {
         var _loc4_:Object = null;
         var _loc5_:Point = null;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         var _loc2_:Rectangle = this.getAreaImmunityRectangle(param1);
         var _loc3_:Object = {
            "x":_loc2_.x,
            "y":_loc2_.y,
            "xLength":_loc2_.width,
            "yLength":_loc2_.height
         };
         if(this.m_invaders)
         {
            for each(_loc4_ in this.m_invaders)
            {
               if(_loc4_.status == STATUS_OCCUPIED)
               {
                  _loc5_ = this.parsePosition(_loc4_.pos);
                  _loc6_ = getInvasionAreaFromInvader(_loc4_);
                  _loc7_ = {
                     "x":_loc5_.x,
                     "y":_loc5_.y,
                     "xLength":_loc6_,
                     "yLength":_loc6_
                  };
                  if(TileUtil.tileOverlapCheck(_loc3_,_loc7_))
                  {
                     return false;
                  }
               }
            }
         }
         return true;
      }
      
      public function activityAreaCenterToRoot(param1:Point, param2:int, param3:Point = null) : Point
      {
         if(!param3)
         {
            param3 = new Point();
         }
         param3.x = param1.x - Math.floor(param2 * 0.5);
         param3.y = param1.y - Math.floor(param2 * 0.5);
         return param3;
      }
      
      public function setCurrentVisitInfo(param1:Object, param2:String, param3:Boolean) : void
      {
         var _loc4_:Object = null;
         this.parseInvaders(param1.pvpInvaders);
         this.m_visitMode = param1.pvpMode;
         this.m_hostImmunity = param1.pvpImmunity;
         if(param1.pvpImmunityCooldown)
         {
            this.m_immunity = {"cdExp":param1.pvpImmunityCooldown};
         }
         if(param2 == ZGlobal.player.uid)
         {
            this.m_isVisitGlobalPVP = false;
            TransactionManager.addTransaction(new TGetUsersInvaderChallenges(),true);
         }
         else
         {
            this.m_isVisitGlobalPVP = param3;
            TransactionManager.addTransaction(new TGetNeighborVisitChallenges(param2),true);
            this.updateNeighborHasOccupiers(param2);
            _loc4_ = this.getLocalPlayerInvasion();
            if(_loc4_)
            {
               ZGlobal.setStartVisitingCameraPos(_loc4_.pos);
            }
            if(this.m_isVisitGlobalPVP)
            {
               if(this.m_globalPVPInactionTimer)
               {
                  this.m_globalPVPInactionTimer.dispose();
                  this.m_globalPVPInactionTimer = null;
               }
            }
         }
      }
      
      public function doPillage(param1:Boolean = false) : void
      {
         var _loc2_:Object = null;
         var _loc3_:TPVPPillage = null;
         if(ZGlobal.isVisiting() && this.isPillageVisit())
         {
            this.doPillageReward();
            if(!param1)
            {
               _loc3_ = new TPVPPillage(ZGlobal.hostPlayer.uid);
               TransactionManager.addTransaction(_loc3_,true);
            }
            _loc2_ = ZGlobal.player.neighbors[ZGlobal.hostPlayer.uid];
            if(Boolean(_loc2_) && Boolean(_loc2_.pvpInfo))
            {
               _loc2_.pvpInfo.pillTS = GlobalEngine.serverTime / 1000;
            }
            dispatchEvent(new WorldEvent(PILLAGE_PERFORMED,ZGlobal.player.uid));
         }
      }
      
      public function doStrikeTeamPillage(param1:String, param2:String) : void
      {
         var _loc3_:Number = 1;
         var _loc4_:GameItem = ZGlobal.gameSettings.getItemByCode(param2,GameItem) as GameItem;
         if((Boolean(_loc4_)) && Boolean(_loc4_.xml.mission) && _loc4_.xml.mission.@rewardMultiplier != undefined)
         {
            _loc3_ = Number(_loc4_.xml.mission.@rewardMultiplier);
         }
         this.doPillageReward(param1,_loc3_);
         dispatchEvent(new WorldEvent(PILLAGE_PERFORMED,ZGlobal.player.uid));
      }
      
      public function strikeTeamNotification(param1:String, param2:Object) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(param2.mCode == MISSION_AMBUSH || param2.mCode == PVPManager.MISSION_AMBUSH2)
         {
            _loc3_ = "StrikeTeamInvaderRepelTitle";
            _loc4_ = "StrikeTeamInvaderRepelMessage";
         }
         else
         {
            _loc3_ = "StrikeTeamInvaderReflectTitle";
            _loc4_ = "StrikeTeamInvaderReflectMessage";
         }
         _loc3_ = ZGameUtils.ZlocT("Dialogs",_loc3_);
         var _loc5_:IPVPPlayer = this.getPVPPlayer(param1);
         _loc4_ = ZGameUtils.ZlocT("Dialogs",_loc4_,{"victimName":_loc5_.firstName});
         var _loc6_:SpecialForcesMissionNoticePopup = new SpecialForcesMissionNoticePopup(_loc4_,_loc3_,_loc5_,param2.mCode,param2.mTxt);
         PopupManager.instance.push(_loc6_,0,false);
      }
      
      public function isStrikeTeamInvasion(param1:String) : Boolean
      {
         return Boolean(this.m_invaders[param1]) && Boolean(this.m_invaders[param1].mCode);
      }
      
      public function strikeTeamDeployModeClick(param1:Point) : Boolean
      {
         return true;
      }
      
      public function underInvasionMarkerInfluence(param1:IEntity) : Boolean
      {
         var _loc2_:Object = null;
         var _loc3_:Point = null;
         var _loc4_:int = 0;
         var _loc5_:Point = null;
         if(ZGlobal.isHome())
         {
            if(this.m_invaders)
            {
               for each(_loc2_ in this.m_invaders)
               {
                  if(_loc2_.status == STATUS_OCCUPIED)
                  {
                     _loc3_ = this.parsePosition(_loc2_.pos);
                     _loc4_ = getInvasionAreaFromInvader(_loc2_);
                     _loc5_ = new Point(_loc4_,_loc4_);
                     if(BuildManager.instance.doesObjectOverlap(_loc3_,_loc5_,param1))
                     {
                        return true;
                     }
                  }
               }
            }
         }
         return false;
      }
      
      public function positionUnderInvasionMarkerInfluence(param1:int, param2:int) : Boolean
      {
         return this.areaUnderInvasionMarkerInfluence(param1,param2,1,1);
      }
      
      public function areaUnderInvasionMarkerInfluence(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc6_:Object = null;
         var _loc7_:Point = null;
         var _loc8_:int = 0;
         var _loc9_:Object = null;
         var _loc5_:Object = {
            "x":param1,
            "y":param2,
            "xLength":param3,
            "yLength":param4
         };
         if(ZGlobal.isHome())
         {
            if(this.m_invaders)
            {
               for each(_loc6_ in this.m_invaders)
               {
                  if(_loc6_.status == STATUS_OCCUPIED)
                  {
                     _loc7_ = this.parsePosition(_loc6_.pos);
                     _loc8_ = getInvasionAreaFromInvader(_loc6_);
                     _loc9_ = {
                        "x":_loc7_.x,
                        "y":_loc7_.y,
                        "xLength":_loc8_,
                        "yLength":_loc8_
                     };
                     if(TileUtil.tileOverlapCheck(_loc9_,_loc5_))
                     {
                        return true;
                     }
                  }
               }
            }
         }
         return false;
      }
      
      public function buildingUnderInvasionMarkerInfluence(param1:IEntity, param2:Pt) : Boolean
      {
         var _loc3_:GameDataComponent = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param1)
         {
            _loc3_ = GameDataComponent(param1.lookupComponentByType(GameDataComponent));
            if(_loc3_)
            {
               _loc4_ = _loc3_.gameData.sizeX;
               _loc5_ = _loc3_.gameData.sizeY;
               return this.areaUnderInvasionMarkerInfluence(param2.x,param2.y,_loc4_,_loc5_);
            }
         }
         return false;
      }
      
      public function createPillageEntity(param1:Point, param2:int) : IEntity
      {
         var _loc4_:PVPOccupationMarkerPillageComponent = null;
         var _loc3_:IEntity = this.createActivityEntity(param1,DEFAULT_ENTITY_CODE,param2);
         if(_loc3_)
         {
            _loc4_ = new PVPOccupationMarkerPillageComponent(ZGlobal.player);
            _loc4_.activityMarkerRoot = param1;
            _loc4_.isoOutlineRectSize = param2;
            _loc3_.addComponent(_loc4_,"pvpmarkerpillage");
            return _loc3_;
         }
         return null;
      }
      
      private function createInertInvasionEntity(param1:IPVPPlayer, param2:Point, param3:int) : IEntity
      {
         var _loc5_:PVPOccupationMarkerPickOnlyComponent = null;
         var _loc4_:IEntity = this.createActivityEntity(param2,DEFAULT_ENTITY_CODE,param3);
         if(_loc4_)
         {
            _loc5_ = new PVPOccupationMarkerPickOnlyComponent(param1);
            _loc5_.activityMarkerRoot = param2;
            _loc5_.isoOutlineRectSize = param3;
            _loc4_.addComponent(_loc5_,"pvpmarkerpillageinert");
            return _loc4_;
         }
         return null;
      }
      
      public function pointToPosString(param1:Point) : String
      {
         if(param1)
         {
            return String(param1.x + "," + param1.y);
         }
         return "0,0";
      }
      
      public function setAndShowCombatPopup(param1:PVPCombatStartPopup) : void
      {
         this.m_combatModalPopup = param1;
         PopupManager.instance.push(param1,0,false);
      }
      
      public function clearCombatPopup() : void
      {
         if(this.m_combatModalPopup)
         {
            this.m_combatModalPopup.pop();
            this.m_combatModalPopup = null;
         }
      }
      
      public function pillageMarkerActive(param1:String, param2:Point, param3:int, param4:Boolean = false, param5:int = 1) : void
      {
         var _loc6_:Object = {
            "uid":param1,
            "forPlacement":param4,
            "validity":param5
         };
         this.dispatchObjectEvent(param2,param3,MARKER_ACTIVATED,_loc6_);
         this.dispatchObjectEvent(param2,param3,PillageableComponent.ADJUST_FEEDBACK_TEXT,_loc6_);
         if(this.isAttackVisit())
         {
            this.dispatchUnitEvent(param2,param3,param3,ProtectorComponent.PROTECTOR_ACTIVATED,_loc6_);
         }
      }
      
      public function pillageMarkerInactive(param1:String, param2:Point) : void
      {
         dispatchEvent(new WorldEvent(MARKER_DEACTIVATED,{"uid":param1}));
         if(this.isAttackVisit())
         {
            dispatchEvent(new WorldEvent(ProtectorComponent.PROTECTOR_DEACTIVATED));
         }
      }
      
      public function pillageMarkerDeactivateAll(param1:String) : void
      {
         dispatchEvent(new WorldEvent(MARKER_DEACTIVATED,{"uid":param1}));
         dispatchEvent(new WorldEvent(ProtectorComponent.PROTECTOR_DEACTIVATED));
      }
      
      public function getAffectingMarkers(param1:IEntity) : Array
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:Point = null;
         var _loc6_:int = 0;
         var _loc7_:Point = null;
         var _loc2_:Array = new Array();
         for(_loc3_ in this.m_invaders)
         {
            _loc4_ = this.m_invaders[_loc3_];
            if(_loc4_.status == STATUS_OCCUPIED)
            {
               _loc5_ = this.parsePosition(_loc4_.pos);
               _loc6_ = getInvasionAreaFromInvader(_loc4_);
               _loc7_ = new Point(_loc6_,_loc6_);
               if(BuildManager.instance.doesObjectOverlap(_loc5_,_loc7_,param1))
               {
                  _loc2_.push(_loc3_);
               }
            }
         }
         return _loc2_;
      }
      
      public function addRepelCrew(param1:Object) : void
      {
         this.addSocialHelpersForInvasion(param1.attacker,param1.staffer);
         var _loc2_:Player = ZGlobal.player.findFriendById(param1.staffer);
         if(_loc2_)
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackRepelCrewReceived",{"crew":_loc2_.firstName}),null,null,_loc2_.uid);
         }
      }
      
      public function completeSocialRepel(param1:String) : void
      {
         var _loc3_:CrewTemplateWrapper = null;
         var _loc4_:Object = null;
         var _loc2_:Object = this.m_invaders[param1];
         if(Boolean(_loc2_) && Boolean(_loc2_.hIDs as Array))
         {
            _loc3_ = ZGlobal.gameSettings.getCrewTemplateWrapper("PVPFriendAssist");
            if(_loc2_.hIDs.length >= _loc3_.numPositions)
            {
               if(param1 == PVE_MARKER_KEY)
               {
                  dispatchEvent(new WorldEvent(REMOVE_MARKER,{
                     "invaderID":param1,
                     "fadeType":MARKER_FADE_EMBERS
                  }));
                  this.pillageMarkerInactive(param1,this.parsePosition(_loc2_.pos));
                  delete this.m_invaders[param1];
               }
               else
               {
                  _loc4_ = Utilities.clone(_loc2_);
                  _loc4_.status = STATUS_RETAL_COOLDOWN;
                  this.performInvasion(param1,_loc4_);
               }
            }
         }
      }
      
      public function initialInvasionRetreated() : void
      {
         var _loc2_:Object = null;
         var _loc1_:Object = this.m_invaders[ZGlobal.player.uid];
         if(_loc1_)
         {
            _loc1_.status = STATUS_AVAILABLE;
         }
         if(ZGlobal.player.neighbors[ZGlobal.hostPlayer.uid])
         {
            _loc2_ = ZGlobal.player.neighbors[ZGlobal.hostPlayer.uid].pvpInfo;
            if(_loc2_)
            {
               _loc2_.status = STATUS_AVAILABLE;
            }
         }
         dispatchEvent(new WorldEvent(UPDATE_NEIGHBOR_PVP_ICON,ZGlobal.hostPlayer.uid));
      }
      
      private function invasionFailedLocal() : void
      {
         var _loc2_:Object = null;
         var _loc1_:Object = this.m_invaders[ZGlobal.player.uid];
         if(_loc1_)
         {
            _loc2_ = Utilities.clone(_loc1_);
            _loc2_.status = STATUS_AVAILABLE;
            this.updateInvasion(ZGlobal.player.uid,_loc2_);
         }
      }
      
      private function invasionSucceededLocal(param1:String) : void
      {
         var _loc3_:Object = null;
         var _loc2_:Object = this.m_invaders[ZGlobal.player.uid];
         if(_loc2_)
         {
            _loc3_ = Utilities.clone(_loc2_);
            _loc3_.status = STATUS_OCCUPIED;
            this.updateInvasion(ZGlobal.player.uid,_loc3_);
         }
         this.handleGlobalPVPWin(param1);
      }
      
      private function handleGlobalPVPWin(param1:String = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:int = this.globalPVPWinProgress;
         if(param1)
         {
            _loc2_ = this.getStrangerSlotIndex(param1);
         }
         if(_loc2_ >= 0)
         {
            _loc3_ = this.m_globalPVPState.cfb.wins == undefined ? 0 : int(this.m_globalPVPState.cfb.wins);
            _loc4_ = _loc3_;
            if(_loc2_ == _loc3_)
            {
               _loc3_++;
               this.m_globalPVPState.cfb.wins = _loc3_;
               this.m_globalPVPState.cfb.awardClaimed = false;
               this.notifyWinsChanged(_loc4_,_loc3_);
            }
         }
      }
      
      private function get canDispatchWinChangeEvent() : Boolean
      {
         var _loc1_:GameMode = GameModeManager.instance.getTopGameMode();
         if(!(_loc1_ is GMIsland))
         {
            return false;
         }
         var _loc2_:ContextualBarUIItem = UIManager.instance.getMenuItemByName(ContextualBarUIItem.ITEM_ID) as ContextualBarUIItem;
         if(!_loc2_ || _loc2_.isTweening())
         {
            return false;
         }
         if(WindowManager.instance.displayedWindow)
         {
            return false;
         }
         if(PopupManager.instance.displayedWindow)
         {
            return false;
         }
         return true;
      }
      
      private function notifyWinsChanged(param1:int, param2:int) : void
      {
         var _loc3_:WorldEvent = new WorldEvent(GPVP_WINS_CHANGED,{
            "oldValue":param1,
            "newValue":param2
         });
         this.m_globalPVPWinChangeEvents.push(_loc3_);
         if(this.canDispatchWinChangeEvent)
         {
            this.dispatchWinChangeEvents();
         }
         else if(!this.m_winChangePollTimer)
         {
            this.m_winChangePollTimer = new Timer(2000);
            this.m_winChangePollTimer.addEventListener(TimerEvent.TIMER,this.onWinChangePoll,false,0,true);
            this.m_winChangePollTimer.start();
         }
      }
      
      private function dispatchWinChangeEvents() : void
      {
         var _loc1_:WorldEvent = null;
         this.disposeWinChangeTimer();
         for each(_loc1_ in this.m_globalPVPWinChangeEvents)
         {
            dispatchEvent(_loc1_);
         }
         this.m_globalPVPWinChangeEvents = [];
      }
      
      private function onWinChangePoll(param1:TimerEvent) : void
      {
         if(this.canDispatchWinChangeEvent)
         {
            this.dispatchWinChangeEvents();
         }
      }
      
      private function disposeWinChangeTimer() : void
      {
         if(this.m_winChangePollTimer)
         {
            this.m_winChangePollTimer.stop();
            this.m_winChangePollTimer.removeEventListener(TimerEvent.TIMER,this.onWinChangePoll);
            this.m_winChangePollTimer = null;
         }
      }
      
      private function pvpDefendSucceededLocal(param1:String) : void
      {
         var _loc3_:Object = null;
         var _loc2_:Object = this.m_invaders[param1];
         if(_loc2_)
         {
            _loc3_ = Utilities.clone(_loc2_);
            _loc3_.dID = ZGlobal.player.uid;
            this.setDefended(param1,_loc3_,true);
            this.disableMarker(param1);
         }
         else
         {
            this.setDefended(param1,null,true);
         }
         dispatchEvent(new WorldEvent(WHITE_KNIGHT_REPEL,param1));
      }
      
      public function acceptRepelLocal(param1:String) : void
      {
         var _loc3_:Object = null;
         var _loc2_:Object = this.m_invaders[param1];
         if(_loc2_)
         {
            _loc3_ = Utilities.clone(_loc2_);
            _loc3_.status = STATUS_AVAILABLE;
            this.performInvasion(param1,_loc3_);
         }
      }
      
      public function pveRepelled() : void
      {
         var _loc2_:Object = null;
         var _loc1_:Object = this.m_invaders[PVE_MARKER_KEY];
         if(_loc1_)
         {
            _loc2_ = Utilities.clone(_loc1_);
            _loc2_.status = STATUS_AVAILABLE;
            this.updateInvasion(PVE_MARKER_KEY,_loc2_);
            this.disableMarker(PVE_MARKER_KEY);
         }
      }
      
      public function parsePosition(param1:String) : Point
      {
         var _loc2_:Array = null;
         var _loc3_:Point = null;
         if(param1)
         {
            _loc2_ = param1.split(",");
            if(_loc2_.length == 2 || _loc2_.length == 3)
            {
               return new Point(_loc2_[0],_loc2_[1]);
            }
         }
         return new Point(0,0);
      }
      
      private function createActivityEntity(param1:Point, param2:String, param3:int) : IEntity
      {
         var _loc4_:Point = activityAreaRootToCenter(param1,param3);
         var _loc5_:EntityInit = new EntityInit();
         _loc5_.m_isoScene = this.getIsoScene();
         _loc5_.m_spatialComponent = this.getQuadComponent();
         _loc5_.m_item = this.getPVPGameItem(param2);
         _loc5_.m_position = new Pt(_loc4_.x,_loc4_.y,0);
         _loc5_.m_group = this.getWorldObjectGroup();
         return BuildingEntity.createEntity(_loc5_);
      }
      
      private function doPillageReward(param1:String = null, param2:Number = 1) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Point = null;
         var _loc5_:int = 0;
         if(param1)
         {
            _loc3_ = this.m_invaders[param1];
         }
         else
         {
            _loc3_ = this.getLocalPlayerInvasion();
         }
         if(_loc3_)
         {
            _loc4_ = this.parsePosition(_loc3_.pos);
            _loc5_ = getInvasionAreaFromInvader(_loc3_);
            this.dispatchObjectEvent(_loc4_,_loc5_,PILLAGE_PERFORMED,{"rewardMultiplier":param2});
         }
      }
      
      private function parseInvaders(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         this.m_invaders = new Dictionary();
         if(param1)
         {
            for(_loc2_ in param1)
            {
               _loc3_ = _loc2_;
               if(_loc2_ != PVE_MARKER_KEY)
               {
                  _loc3_ = _loc2_.slice(1);
               }
               this.m_invaders[_loc3_] = param1[_loc2_];
               Logger.info(this,"parseInvaders","_loc2_: " + _loc2_ + " _loc3_: " + _loc3_);
            }
         }
      }
      
      private function parseNotifications(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(param1)
         {
            for(_loc2_ in param1)
            {
               _loc3_ = _loc2_;
               if(_loc2_ != PVE_MARKER_KEY)
               {
                  _loc3_ = _loc2_.slice(1);
               }
               this.strikeTeamNotification(_loc3_,param1[_loc2_]);
            }
         }
      }
      
      private function storeNeighborAssists(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         this.m_neighborAssists = new Dictionary();
         if(param1)
         {
            for(_loc2_ in param1)
            {
               _loc3_ = _loc2_.slice(1);
               this.m_neighborAssists[_loc3_] = param1[_loc2_];
            }
         }
      }
      
      public function addNeighborAssist(param1:String, param2:String, param3:String) : void
      {
         var _loc4_:Object = new Object();
         _loc4_.chID = param2;
         _loc4_.invID = param3;
         this.m_neighborAssists[param1] = _loc4_;
      }
      
      public function clearNeighborAssist(param1:String) : void
      {
         delete this.m_neighborAssists[param1];
      }
      
      public function getNeighborAssist(param1:String) : Object
      {
         return this.m_neighborAssists[param1];
      }
      
      public function getInvadedNeighborId(param1:String) : String
      {
         var _loc2_:String = null;
         for(_loc2_ in this.m_neighborAssists)
         {
            if(this.m_neighborAssists[_loc2_].invID == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getSocialHelpersForInvasion(param1:String) : Array
      {
         var _loc2_:CrewTemplateWrapper = null;
         if(this.m_invaders[param1])
         {
            if(!this.m_invaders[param1].hIDs)
            {
               this.m_invaders[param1].hIDs = new Array();
            }
            _loc2_ = ZGlobal.gameSettings.getCrewTemplateWrapper("PVPFriendAssist");
            while(this.m_invaders[param1].hIDs.length < _loc2_.numPositions)
            {
               this.m_invaders[param1].hIDs.push(null);
            }
            return this.m_invaders[param1].hIDs;
         }
         return null;
      }
      
      public function addSocialHelpersForInvasion(param1:String, param2:String) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         var _loc3_:Object = this.m_invaders[param1];
         if(_loc3_)
         {
            if(!_loc3_.hIDs)
            {
               _loc3_.hIDs = new Array();
            }
            _loc4_ = false;
            _loc5_ = 0;
            while(_loc5_ < _loc3_.hIDs.length)
            {
               if(_loc3_.hIDs[_loc5_] == null)
               {
                  _loc3_.hIDs[_loc5_] = param2;
                  _loc4_ = true;
                  break;
               }
               _loc5_++;
            }
            if(!_loc4_)
            {
               _loc3_.hIDs.push(param2);
            }
         }
      }
      
      public function getInvadersChallenge(param1:String) : Object
      {
         var _loc3_:String = null;
         var _loc2_:Object = this.m_invaders[param1];
         if(Boolean(_loc2_) && Boolean(_loc2_.chID))
         {
            _loc3_ = _loc2_.chID;
         }
         else if(param1 == PVE_MARKER_KEY)
         {
            _loc3_ = "fleet_" + PVE_MARKER_KEY + "_ai";
         }
         return ChallengeModeManager.instance.getChallenge(_loc3_);
      }
      
      public function getQuestFightTaskEpisodeDialog(param1:String) : String
      {
         return (QuestManager.getInstance() as ZGameQuestManager).getEpisodeDialog(param1);
      }
      
      public function doPveRepel(param1:Boolean) : void
      {
         var _loc3_:Object = null;
         var _loc4_:PVPCombatStartPopup = null;
         var _loc2_:Object = this.m_invaders[PVE_MARKER_KEY];
         if(Boolean(_loc2_) && Boolean(_loc2_.quest))
         {
            _loc3_ = this.getQuestData(_loc2_);
            GMBattle.createStaticBattleFromQuest(_loc3_.enemyFleetName == _loc2_.quest ? null : _loc3_,_loc3_.enemyFleetName,this.getQuestFightTaskEpisodeDialog(_loc2_.quest));
         }
         else if(ChallengeModeManager.instance.onSelectNewChallengePlayer(PVE_MARKER_KEY,param1))
         {
            _loc4_ = new PVPCombatStartPopup(ZGlobal.player,this.getPVPPlayer(PVE_MARKER_KEY));
            PVPManager.instance.setAndShowCombatPopup(_loc4_);
         }
      }
      
      private function getQuestData(param1:Object) : Object
      {
         var _loc4_:ZGameTask = null;
         var _loc5_:FightItemTask = null;
         var _loc6_:Boolean = false;
         var _loc2_:Array = (QuestManager.getInstance() as ZGameQuestManager).getQuestTasks(param1.quest);
         var _loc3_:int = 0;
         for each(_loc4_ in _loc2_)
         {
            if(_loc4_.pveVillain)
            {
               _loc5_ = _loc4_ as FightItemTask;
               _loc6_ = (Boolean(_loc5_)) && _loc5_.isPVE;
               return {
                  "id":param1.quest,
                  "quest":param1.quest,
                  "enemyFleetName":_loc4_.fleetName,
                  "villain":_loc4_.pveVillain,
                  "index":_loc3_,
                  "pve":_loc6_
               };
            }
            _loc3_++;
         }
         return null;
      }
      
      public function getPVPPlayer(param1:String) : IPVPPlayer
      {
         var _loc2_:Object = null;
         var _loc3_:IslandGroupItem = null;
         var _loc4_:Player = null;
         var _loc5_:Object = null;
         var _loc6_:Object = null;
         if(param1 == PVE_MARKER_KEY)
         {
            _loc2_ = this.m_invaders[param1];
            if(Boolean(_loc2_) && Boolean(_loc2_.villain))
            {
               return new PlayerVillain(_loc2_.villain);
            }
            _loc3_ = ZGlobal.gameSettings.getItemByCode(ZGlobal.player.campaign.activeMap,IslandGroupItem) as IslandGroupItem;
            return new PlayerVillain(_loc3_.villain);
         }
         _loc4_ = ZGlobal.player.findFriendById(param1);
         if(_loc4_)
         {
            return _loc4_;
         }
         _loc5_ = this.m_globalPVPInfos[param1];
         if((Boolean(_loc5_)) && Boolean(_loc5_.playerInfo))
         {
            return _loc5_.playerInfo;
         }
         _loc6_ = ZGlobal.player.findNonFriendById(param1);
         if(_loc6_)
         {
            return new PlayerNonFriend(_loc6_);
         }
         return new PlayerDummy(param1);
      }
      
      public function positionHasPVPInfluence(param1:Pt, param2:IEntity) : Boolean
      {
         this.m_entityOverlaps = false;
         var _loc3_:Point = new Point(param1.x / ZGlobal.cellSize,param1.y / ZGlobal.cellSize);
         BuildManager.instance.iterateEntityBounds(_loc3_,param2,this.pvpInfluence);
         return this.m_entityOverlaps;
      }
      
      public function isInInitialCombat(param1:String) : Boolean
      {
         var _loc2_:Object = this.getPlayerInvasionInfoForNeighbor(param1);
         if(Boolean(_loc2_) && _loc2_.status == PVPManager.STATUS_INCOMBAT)
         {
            return true;
         }
         return false;
      }
      
      public function getLocalPlayerInvasion() : Object
      {
         Logger.info(this,"getLocalPlayerInvasion","this.m_invaders: " + com.adobe.serialization.json.JSON.encode(this.m_invaders));
         return this.m_invaders[ZGlobal.player.uid];
      }
      
      private function pvpInfluence(param1:int, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc6_:Object = null;
         var _loc7_:Point = null;
         var _loc8_:int = 0;
         var _loc9_:Object = null;
         var _loc5_:Object = {
            "x":param1,
            "y":param2,
            "xLength":1,
            "yLength":1
         };
         for each(_loc6_ in this.m_invaders)
         {
            if(_loc6_.status == STATUS_OCCUPIED)
            {
               _loc7_ = this.parsePosition(_loc6_.pos);
               _loc8_ = getInvasionAreaFromInvader(_loc6_);
               if(_loc7_)
               {
                  _loc9_ = {
                     "x":_loc7_.x,
                     "y":_loc7_.y,
                     "xLength":_loc8_,
                     "yLength":_loc8_
                  };
                  if(TileUtil.tileOverlapCheck(_loc9_,_loc5_))
                  {
                     this.m_entityOverlaps = true;
                  }
               }
            }
         }
         return true;
      }
      
      private function getPVPGameItem(param1:String) : GameItem
      {
         return ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
      }
      
      private function getQuadComponent() : QuadSpatialManager
      {
         if(!this.m_quadComponent)
         {
            this.m_quadComponent = ViewManager.instance.getComponentFromName(IslandWorld.ID,IslandViewFactory.AREA_OBJECTS) as QuadSpatialManager;
         }
         return this.m_quadComponent;
      }
      
      private function getIsoScene() : IsoScene
      {
         var _loc1_:IsoViewComponent = null;
         if(!this.m_isoScene)
         {
            _loc1_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
            this.m_isoScene = IsoScene(_loc1_.getSceneByID("gameScene"));
         }
         return this.m_isoScene;
      }
      
      private function getWorldObjectGroup() : PBGroup
      {
         var _loc1_:PBGroup = Zlab.nameManager.lookup(ZGameManager.WORLD_OBJECT_GROUP_NAME);
         if(!_loc1_)
         {
            _loc1_ = new PBGroup();
            _loc1_.initialize(ZGameManager.WORLD_OBJECT_GROUP_NAME);
         }
         return _loc1_;
      }
      
      private function dispatchObjectEvent(param1:Point, param2:int, param3:String, param4:Object = null) : void
      {
         var _loc7_:String = null;
         var _loc8_:IEntity = null;
         var _loc9_:WorldEvent = null;
         var _loc5_:Point = new Point(param2,param2);
         var _loc6_:Array = BuildManager.instance.getObjectsOverlappingVolume(param1,_loc5_);
         for each(_loc7_ in _loc6_)
         {
            _loc8_ = Zlab.nameManager.lookup(_loc7_);
            if(_loc8_)
            {
               _loc9_ = new WorldEvent(param3,param4);
               _loc8_.eventDispatcher.dispatchEvent(_loc9_);
            }
         }
      }
      
      public function clearQueuedInvasions(param1:String) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_invasionUpdateQueue.length)
         {
            if(this.m_invasionUpdateQueue[_loc2_].id == param1)
            {
               this.m_invasionUpdateQueue.splice(_loc2_,1);
               return;
            }
            _loc2_++;
         }
      }
      
      public function clearQueuedDefends(param1:String) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_defenderUpdateQueue.length)
         {
            if(this.m_defenderUpdateQueue[_loc2_].id == param1 && !this.m_defenderUpdateQueue[_loc2_].local)
            {
               this.m_defenderUpdateQueue.splice(_loc2_,1);
               return;
            }
            _loc2_++;
         }
      }
      
      public function dispatchUnitEvent(param1:Point, param2:int, param3:int, param4:String, param5:Object = null) : void
      {
         var _loc9_:String = null;
         var _loc10_:IEntity = null;
         var _loc11_:GameDataComponent = null;
         var _loc12_:IsoSpriteComponent = null;
         var _loc13_:Pt = null;
         var _loc14_:ISpatialObjectISO = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:Point = null;
         var _loc18_:Object = null;
         var _loc19_:Object = null;
         var _loc20_:WorldEvent = null;
         var _loc6_:Point = param1.clone();
         var _loc7_:Point = new Point(param2 + this.getMaxDefenseOverlap() + this.getMaxDefenseOverlap(),param3 + this.getMaxDefenseOverlap() + this.getMaxDefenseOverlap());
         param1.x -= this.getMaxDefenseOverlap();
         param1.y -= this.getMaxDefenseOverlap();
         var _loc8_:Array = BuildManager.instance.getObjectsOverlappingVolume(param1,_loc7_);
         for each(_loc9_ in _loc8_)
         {
            _loc10_ = Zlab.nameManager.lookup(_loc9_);
            if((Boolean(_loc10_)) && (UnitDefenseRangeRect.isUnit(_loc10_) || UnitDefenseRangeRect.isImmunityBuilding(_loc10_)))
            {
               _loc11_ = GameDataComponent.getGameDataComponent(_loc10_);
               _loc12_ = _loc10_.lookupComponentByType(IsoSpriteComponent) as IsoSpriteComponent;
               _loc13_ = new Pt(_loc12_.isoSprite.isoBounds.width,_loc12_.isoSprite.isoBounds.length);
               _loc14_ = _loc10_.lookupComponentByType(QuadSpatialComponent) as ISpatialObjectISO;
               _loc15_ = _loc11_.gameData.defenseRangeX;
               _loc16_ = _loc11_.gameData.defenseRangeY;
               _loc17_ = this.parsePosition(_loc11_.userData.position);
               _loc17_.x -= Math.floor((_loc11_.gameData.defenseRangeX - _loc11_.gameData.sizeX) * 0.5);
               _loc17_.y -= Math.floor((_loc11_.gameData.defenseRangeY - _loc11_.gameData.sizeY) * 0.5);
               _loc18_ = {
                  "x":_loc6_.x,
                  "y":_loc6_.y,
                  "xLength":param2,
                  "yLength":param3
               };
               _loc19_ = {
                  "x":_loc17_.x,
                  "y":_loc17_.y,
                  "xLength":_loc15_,
                  "yLength":_loc16_
               };
               if(TileUtil.tileOverlapCheck(_loc18_,_loc19_))
               {
                  _loc20_ = new WorldEvent(param4,param5);
                  _loc10_.eventDispatcher.dispatchEvent(_loc20_);
               }
            }
         }
      }
      
      public function doBuySlotMachineSpin() : void
      {
         var _loc1_:uint = spinPurchaseCost;
         if(!ZGlobal.player.canBuyCash(_loc1_))
         {
            return;
         }
         if(ZGlobal.gameSettings.showConfirmationPopup(_loc1_))
         {
            return;
         }
         this.doBuySpin(_loc1_);
      }
      
      private function doBuySpin(param1:uint = 0) : void
      {
         if(!param1)
         {
            param1 = spinPurchaseCost;
         }
         ZGlobal.player.cash -= param1;
         var _loc2_:TPVPGlobalSlotMachineSpinBuy = new TPVPGlobalSlotMachineSpinBuy();
         TransactionManager.addTransaction(_loc2_);
         if(!this.m_globalPVPState.cfb.spinsBought)
         {
            this.m_globalPVPState.cfb.spinsBought = 0;
         }
         ++this.m_globalPVPState.cfb.spinsBought;
      }
      
      public function slotMachineSpin(param1:uint) : Boolean
      {
         var _loc2_:int = 0;
         switch(param1)
         {
            case REWARD_SPIN_MODE_BUY:
               _loc2_ = int(spinPurchaseCost);
               if(ZGlobal.player.canBuyCash(_loc2_,true))
               {
                  ZGlobal.player.cash -= _loc2_;
                  break;
               }
               return false;
               break;
            case REWARD_SPIN_MODE_KEYS:
               _loc2_ = int(spinPurchaseKeyCost);
               if(_loc2_ <= ZGlobal.player.inventory["GPTK"])
               {
                  ZGlobal.player.removeInventoryItem("GPTK",_loc2_);
                  break;
               }
               return false;
               break;
            default:
               return false;
         }
         var _loc3_:TPVPGlobalSlotMachineSpin = new TPVPGlobalSlotMachineSpin(param1);
         TransactionManager.addTransaction(_loc3_);
         return true;
      }
      
      public function getFightBatchRemainingTime() : Object
      {
         if(!this.hasGlobalPVPFightBatch)
         {
            return {
               "success":false,
               "remaining":0
            };
         }
         if(!this.m_globalPVPState.cfb.ts)
         {
            return {
               "success":false,
               "remaining":0
            };
         }
         var _loc1_:String = ZGlobal.gameSettings.getString("GlobalPVPFightListDuration","1d");
         var _loc2_:int = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc1_,0);
         var _loc3_:int = int(this.m_globalPVPState.cfb.ts);
         _loc3_ += _loc2_;
         var _loc4_:int = GlobalEngine.serverTime / 1000;
         return {
            "success":true,
            "remaining":Math.max(0,_loc3_ - _loc4_)
         };
      }
      
      public function optInOut(param1:Boolean) : void
      {
         var _loc2_:TPVPGlobalOptInOut = new TPVPGlobalOptInOut(param1);
         TransactionManager.addTransaction(_loc2_);
         this.m_globalPVPOptIn = param1;
         if(!param1)
         {
            ChallengeModeManager.instance.globalPVPOptedOut();
            if(ZGlobal.isVisiting())
            {
               ZGame.instance.visitNeighbor(ZGlobal.player.uid,TWorldLoad.DBG_RETURN);
            }
         }
         dispatchEvent(new Event(GPVP_OPT_INOUT_CHANGED));
      }
      
      public function get globalPVPOptedIn() : Boolean
      {
         return this.m_globalPVPOptIn;
      }
      
      public function get hasGlobalPVPFightBatch() : Boolean
      {
         return Boolean(this.m_globalPVPState) && Boolean(this.m_globalPVPState.cfb);
      }
      
      public function get globalPVPFightList() : Array
      {
         if(this.hasGlobalPVPFightBatch && Boolean(this.m_globalPVPState.cfb.fightList as Array))
         {
            return this.m_globalPVPState.cfb.fightList;
         }
         return null;
      }
      
      private function updateImmunity(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(param1.expTS)
         {
            _loc2_ = GlobalEngine.serverTime / 1000;
            if(_loc2_ >= param1.expTS)
            {
               if(param1.hIDs.length)
               {
                  param1.hIDs.splice(0,1);
                  if(param1.hIDs.length)
                  {
                     param1.expTS = _loc2_ + neighborImmunityDuration;
                     dispatchEvent(new WorldEvent(IMMUNITY_CONTRIBUTORS_CHANGED,param1.hIDs));
                  }
                  else
                  {
                     delete param1.expTS;
                  }
               }
               else
               {
                  delete param1.expTS;
               }
            }
         }
      }
      
      private function startImmunityTimer() : void
      {
         if(this.isImmuneHelper(this.m_immunity))
         {
            if(!this.m_immunityTimer)
            {
               this.m_immunityTimer = new TimerHandler(1000,this,this.onImmunityTimer);
               this.m_immunityTimer.start();
            }
         }
         else if(this.m_immunityTimer)
         {
            this.m_immunityTimer.dispose();
            this.m_immunityTimer = null;
         }
      }
      
      private function onImmunityTimer(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:WorldEvent = null;
         if(this.isImmuneHelper(this.m_immunity))
         {
            _loc2_ = this.immunityEndTimeHelper();
            _loc3_ = _loc2_ - GlobalEngine.getTimer() / 1000;
            _loc3_ = Math.max(0,_loc3_);
            _loc4_ = new WorldEvent(IMMUNITY_TIMER_UPDATED,{"remaining":_loc3_});
            dispatchEvent(_loc4_);
            this.m_immunityTimer.start();
         }
         else
         {
            dispatchEvent(new Event(IMMUNITY_EXPIRED));
            this.m_immunityTimer.dispose();
            this.m_immunityTimer = null;
         }
      }
      
      private function onBattleComplete(param1:WorldEvent) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc2_:String = param1.eventData.playerUID;
         var _loc3_:String = param1.eventData.enemyUID;
         if(Boolean(param1.eventData.pveRepel) && !param1.eventData.neighborAssist)
         {
            if(param1.eventData.result == Battle.BATTLE_RESULT_WON)
            {
               this.pveRepelled();
            }
         }
         else if(param1.eventData.battle.isChallenge)
         {
            if(_loc3_ == ZGlobal.hostPlayer.uid)
            {
               if(param1.eventData.result == Battle.BATTLE_RESULT_LOST || param1.eventData.result == Battle.BATTLE_RESULT_RETREAT)
               {
                  PVPManager.instance.invasionFailedLocal();
               }
               else if(param1.eventData.result == Battle.BATTLE_RESULT_WON)
               {
                  PVPManager.instance.invasionFailedLocal();
                  PVPManager.instance.invasionSucceededLocal(_loc3_);
               }
            }
            else if(param1.eventData.neighborAssist)
            {
               if(param1.eventData.result == Battle.BATTLE_RESULT_WON)
               {
                  this.pvpDefendSucceededLocal(_loc3_);
               }
            }
            else if(ZGlobal.isHome())
            {
               _loc4_ = this.m_invaders[_loc3_];
               if((Boolean(_loc4_)) && param1.eventData.result == Battle.BATTLE_RESULT_WON)
               {
                  _loc5_ = Utilities.clone(_loc4_);
                  _loc5_.status = STATUS_RETAL_COOLDOWN;
                  _loc5_.giveRepelReward = true;
                  this.updateInvasion(_loc3_,_loc5_);
                  this.disableMarker(_loc3_);
               }
            }
         }
      }
      
      private function expansionUnlockCheck(param1:Point) : Boolean
      {
         var _loc2_:uint = uint(pvpLiveInvasionAreaSize);
         return ZGlobal.hostPlayer.expansionRectCheck(param1,_loc2_,_loc2_);
      }
      
      private function onTransactionComplete(param1:TransactionEvent) : void
      {
         var _loc4_:String = null;
         var _loc5_:TBuyCrewRepelPosition = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:GenericPopup1B = null;
         var _loc2_:Object = param1.transaction.rawResult.metadata.newPVE;
         if(_loc2_)
         {
            this.updateInvasion(PVE_MARKER_KEY,_loc2_);
         }
         var _loc3_:Object = param1.transaction.rawResult.data;
         if(Boolean(_loc3_) && param1.transaction is TBuyCrewRepelPosition)
         {
            switch(_loc3_.result)
            {
               case REPEL_CREW_FULL:
               case REPEL_CREW_NOBUY:
                  _loc5_ = param1.transaction as TBuyCrewRepelPosition;
                  _loc6_ = _loc5_.invader;
                  if(this.m_invaders[_loc6_])
                  {
                     this.m_invaders[_loc6_].hIDs = _loc3_.crew;
                  }
                  dispatchEvent(new WorldEvent(REPEL_CREW_UPDATED,{
                     "result":_loc3_.result,
                     "invader":_loc6_,
                     "crew":_loc3_.crew
                  }));
                  _loc7_ = _loc3_.result == REPEL_CREW_FULL ? "PVPRepelCrewErrorFull" : "PVPRepelCrewErrorNoBuy";
                  _loc8_ = ZGameUtils.ZlocT("Dialogs",_loc7_);
                  _loc9_ = GenericPopup1B.NewOk(_loc8_,null);
                  PopupManager.instance.push(_loc9_);
                  ZGlobal.player.cash += _loc5_.cost;
                  break;
               case REPEL_CREW_SUCCESS:
            }
         }
      }
      
      private function onTransactionAdded(param1:TransactionEvent) : void
      {
         var _loc2_:TLoadChallenge = null;
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:Object = null;
         if(param1.transaction as TLoadChallenge)
         {
            _loc2_ = param1.transaction as TLoadChallenge;
            if(ZGlobal.isVisiting())
            {
               _loc3_ = ChallengeModeManager.instance.currentChallengerID();
               if(_loc3_ == ZGlobal.hostPlayer.uid)
               {
                  _loc4_ = ChallengeModeManager.instance.isRandomFleetChallenge();
                  _loc5_ = ChallengeModeManager.instance.isPVEChallenge();
                  if(_loc4_ && !_loc5_)
                  {
                     _loc6_ = this.m_invaders[ZGlobal.player.uid];
                     if(_loc6_)
                     {
                        _loc6_.status = STATUS_INCOMBAT;
                     }
                     if(ChallengeModeManager.instance.currentChallengeHasStatus(ChallengeModeManager.CHALLENGE_FLAG_GLOBAL_PVP))
                     {
                        this.m_globalPVPInvasions[ZGlobal.hostPlayer.uid] = STATUS_INCOMBAT;
                     }
                     if(ZGlobal.player.neighbors[_loc3_])
                     {
                        ZGlobal.player.neighbors[_loc3_].pvpInfo = _loc6_;
                     }
                     dispatchEvent(new WorldEvent(UPDATE_NEIGHBOR_PVP_ICON,_loc3_));
                  }
               }
            }
         }
      }
      
      private function onInvaderUpdated(param1:WorldEvent) : void
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this.m_invasionUpdateQueue)
         {
            if(_loc2_.id == param1.eventData.id)
            {
               _loc2_.invasion = Utilities.clone(param1.eventData.invasion);
               return;
            }
         }
         this.m_invasionUpdateQueue.push(Utilities.clone(param1.eventData));
      }
      
      private function onDefenderUpdated(param1:WorldEvent) : void
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this.m_defenderUpdateQueue)
         {
            if(_loc2_.id == param1.eventData.id)
            {
               _loc2_.invasion = Utilities.clone(param1.eventData.invasion);
               return;
            }
         }
         this.m_defenderUpdateQueue.push(Utilities.clone(param1.eventData));
      }
      
      private function onLastMinuteImmunity(param1:WorldEvent) : void
      {
         if(ZGlobal.isVisiting())
         {
            this.m_lastMinuteImmunities[param1.eventData.victim] = param1.eventData;
         }
         else
         {
            this.updateImmunityInfoForNeighbor(param1.eventData);
         }
      }
      
      private function onGlobalPVPUIStateChangeDone(param1:WorldEvent) : void
      {
         var _loc2_:Object = null;
         if(this.globalPVPUIState == GLOBALPVP_UI_FADEIN)
         {
            this.globalPVPUIState = GLOBALPVP_UI_ACTIVE;
         }
         else if(this.globalPVPUIState == GLOBALPVP_UI_FADEOUT)
         {
            this.globalPVPUIState = GLOBALPVP_UI_NONE;
            _loc2_ = ZGlobal.player.neighbors[ZGlobal.hostPlayer.uid];
            if(!_loc2_ && ZGlobal.hostPlayer.uid != ZGlobal.player.uid)
            {
               ZGame.instance.visitNeighbor(ZGlobal.player.uid,TWorldLoad.DBG_RETURN);
            }
         }
      }
      
      private function onFightListReceived(param1:WorldEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         if(!this.m_globalPVPState)
         {
            this.m_globalPVPState = new Object();
         }
         if(!this.m_globalPVPState.cfb)
         {
            this.m_globalPVPState.cfb = new Object();
         }
         if(param1.eventData.ts)
         {
            this.m_globalPVPState.cfb.ts = param1.eventData.ts;
         }
         if(param1.eventData.wins)
         {
            this.m_globalPVPState.cfb.wins = param1.eventData.wins;
         }
         if(param1.eventData.fightList as Array)
         {
            this.m_globalPVPState.cfb.fightList = new Array();
            for each(_loc2_ in param1.eventData.fightList)
            {
               this.m_globalPVPState.cfb.fightList.push(_loc2_);
            }
         }
         if(param1.eventData.awardClaimed)
         {
            this.m_globalPVPState.cfb.awardClaimed = param1.eventData.awardClaimed;
         }
         if(param1.eventData.info as Array)
         {
            for each(_loc3_ in param1.eventData.info)
            {
               this.updateGlobalPVPInfo(_loc3_);
            }
         }
         if(param1.eventData.rf)
         {
            _loc4_ = int(ZGlobal.player.inventory["GPTK"]);
            ZGlobal.player.removeInventoryItem("GPTK",_loc4_);
         }
         if(param1.eventData.gpPrizeSet)
         {
            this.m_globalPVPPrizeSet = param1.eventData.gpPrizeSet;
         }
         dispatchEvent(new WorldEvent(FIGHT_LIST_CHANGED));
      }
      
      private function onIslandEntered(param1:Event) : void
      {
         this.doIslandLoadedActions();
      }
      
      private function onInvaded(param1:WorldEvent) : void
      {
         if(param1.eventData.world == ZGlobal.player.uid)
         {
            this.showFeedback(param1.eventData.invasionID,null,"FeedbackInvasion");
         }
      }
      
      private function onRepelled(param1:WorldEvent) : void
      {
         this.showFeedback(param1.eventData.victim,null,"FeedbackInvasionRepelled");
      }
      
      private function onAssistRepelled(param1:WorldEvent) : void
      {
         if(param1.eventData.invasionID == ZGlobal.player.uid)
         {
            if(param1.eventData.invader.dID == DEFENSE_TOWER_FAKE_USER_ID.toString())
            {
               this.showFeedback(null,param1.eventData.world,"FeedbackInvasionDefenseTowerRepelledEmpire");
            }
            else if(param1.eventData.invader.dID == DECO_BUILDABLE_FAKE_USER_ID.toString())
            {
               this.showFeedback(null,param1.eventData.world,"FeedbackInvasionAmityNavalStationProtected",false);
            }
            else
            {
               this.showFeedback(param1.eventData.invader.dID,param1.eventData.world,"FeedbackInvasionAssistRepelledEmpire");
            }
         }
      }
      
      private function showFeedback(param1:String, param2:String, param3:String, param4:Boolean = true) : void
      {
         var _loc5_:Object = new Object();
         var _loc6_:Player = ZGlobal.player.findFriendById(param1);
         var _loc7_:Player = null;
         if(_loc6_)
         {
            _loc5_.user = _loc6_.localizationName;
         }
         if(param2)
         {
            _loc7_ = ZGlobal.player.findFriendById(param2);
            if(_loc7_)
            {
               _loc5_.empire = _loc7_.localizationName;
            }
         }
         if(Boolean(_loc6_) || Boolean(_loc7_))
         {
            if(!param4)
            {
               _loc5_ = null;
            }
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main",param3,_loc5_),null,null,_loc6_ ? _loc6_.uid : null);
         }
      }
      
      private function doIslandLoadedActions() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Object = null;
         var _loc3_:Dictionary = null;
         var _loc4_:Object = null;
         this.removeLastMinuteImmunityDialogTimer();
         for each(_loc1_ in this.m_invasionUpdateQueue)
         {
            this.performInvasion(_loc1_.id,_loc1_.invasion);
         }
         for each(_loc2_ in this.m_defenderUpdateQueue)
         {
            this.performDefended(_loc2_.id,_loc2_.invasion,_loc2_.local);
         }
         _loc3_ = this.m_lastMinuteImmunities;
         this.m_lastMinuteImmunities = new Dictionary();
         for each(_loc4_ in _loc3_)
         {
            this.performLastMinuteImmunity(_loc4_);
         }
         this.m_invasionUpdateQueue = [];
         this.m_defenderUpdateQueue = [];
      }
      
      private function removeLastMinuteImmunityDialogTimer() : void
      {
         if(this.m_lastMinuteImmunityDialogTimer)
         {
            this.m_lastMinuteImmunityDialogTimer.dispose();
            this.m_lastMinuteImmunityDialogTimer = null;
         }
      }
      
      private function disableMarker(param1:String) : void
      {
         dispatchEvent(new WorldEvent(DISABLE_MARKER,{"invaderID":param1}));
      }
      
      private function startLastMinuteImmunityFeedback(param1:Object) : void
      {
         if(RewardPickupManager.instance.anyActivePickups)
         {
            this.removeLastMinuteImmunityDialogTimer();
            this.m_lastMinuteImmunityDialogTimer = new TimerHandler(1000,this,this.onStatusUpdateDooberTimeout,param1);
            this.m_lastMinuteImmunityDialogTimer.start();
         }
         else
         {
            this.showLastMinuteImmunityDialog(param1);
         }
      }
      
      private function onStatusUpdateDooberTimeout(param1:Object) : void
      {
         if(!RewardPickupManager.instance.anyActivePickups)
         {
            this.removeLastMinuteImmunityDialogTimer();
            this.showLastMinuteImmunityDialog(param1);
         }
         else
         {
            this.m_lastMinuteImmunityDialogTimer.start();
         }
      }
      
      private function showLastMinuteImmunityDialog(param1:Object) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:Player = null;
         var _loc4_:LocalizationName = null;
         var _loc5_:String = null;
         var _loc6_:GenericPopup = null;
         if(ZGlobal.isVisiting())
         {
            _loc2_ = uint(param1.status);
            if(_loc2_ < m_invasionUpdateLabels.length)
            {
               _loc3_ = ZGlobal.hostPlayer;
               _loc4_ = ZGameUtils.ZlocTn(_loc3_.firstName,_loc3_.snUser.gender == "F" ? ZGlobal.localizer.FEM : ZGlobal.localizer.MASC);
               _loc5_ = ZGameUtils.ZlocT("Dialogs",m_invasionUpdateLabels[_loc2_],{"user":_loc4_});
               _loc6_ = GenericPopup1B.NewOk(_loc5_,null,this.onLastMinuteImmunityClosed);
               PopupManager.instance.push(_loc6_);
            }
         }
      }
      
      private function onLastMinuteImmunityClosed(param1:GenericPopupEvent) : void
      {
         if(ZGlobal.isVisiting())
         {
            ZGame.instance.visitNeighbor(ZGlobal.player.uid,TWorldLoad.DBG_RETURN);
         }
      }
      
      private function updateImmunityInfoForNeighbor(param1:Object) : void
      {
         var _loc2_:String = param1.victim;
         var _loc3_:Object = param1.immunity;
         if(ZGlobal.player.neighbors[_loc2_])
         {
            if(param1.status == INVASION_COMPLETE_IMMUNE)
            {
               ZGlobal.player.neighbors[_loc2_].pvpImmunityTimestamp = _loc3_.expTS;
            }
            else if(param1.status == INVASION_COMPLETE_DEFENSETOWER)
            {
            }
            ZGlobal.player.neighbors[_loc2_].pvpInfo = null;
            if(ZGlobal.hostPlayer.uid == _loc2_)
            {
               if(this.m_invaders[ZGlobal.player.uid])
               {
                  delete this.m_invaders[ZGlobal.player.uid];
               }
            }
            this.updateNeighborHasOccupiers(_loc2_);
         }
      }
      
      private function immunityClearInvasions() : void
      {
         var _loc1_:int = ZGlobal.gameSettings.getSeconds("PVPImmunityStartReinvadeCooldown",60 * 60 * 12);
         this.m_immunity.invExpTs = int(GlobalEngine.serverTime / 1000 + _loc1_);
      }
      
      public function getSortedStrangerList() : Array
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc1_:Array = new Array();
         if(Boolean(this.m_globalPVPState) && Boolean(this.m_globalPVPState.cfb) && Boolean(this.m_globalPVPState.cfb.fightList) && Boolean(this.m_globalPVPState.cfb.fightList as Array))
         {
            for each(_loc2_ in this.m_globalPVPState.cfb.fightList)
            {
               _loc3_ = this.m_globalPVPInfos[_loc2_];
               if(Boolean(_loc3_) && Boolean(_loc3_.friendInfo))
               {
                  _loc1_.push(_loc3_.friendInfo);
               }
            }
            _loc1_ = _loc1_.reverse();
         }
         return _loc1_;
      }
      
      public function set globalPVPUIState(param1:uint) : void
      {
         var _loc2_:uint = this.globalPVPUIState;
         this.m_globalPVPUIState = param1;
         dispatchEvent(new WorldEvent(GLOBALPVP_UI_STATECHANGE,{
            "oldState":_loc2_,
            "newState":this.globalPVPUIState
         }));
         var _loc3_:Boolean = isGlobalPVPFadeState(_loc2_);
         var _loc4_:Boolean = isGlobalPVPFadeState(this.globalPVPUIState);
         if(_loc3_ != _loc4_)
         {
            if(_loc4_)
            {
               InputManager.disableInput();
               InputManager.disableButtonInput();
               this.disableUIInput();
            }
            else
            {
               InputManager.enableInput();
               InputManager.enableButtonInput();
               this.enableUIInput();
            }
         }
      }
      
      public function globalPVPSlotClaimable(param1:int) : Boolean
      {
         if(!this.hasGlobalPVPFightBatch)
         {
            return false;
         }
         if(this.m_globalPVPState.cfb.wins != param1)
         {
            return false;
         }
         if(this.m_globalPVPState.cfb.wins != globalPVPMaxProgress && this.globalPVPCurrentAwardClaimed)
         {
            return false;
         }
         return true;
      }
      
      public function awardClaimed() : void
      {
         if(this.hasGlobalPVPFightBatch)
         {
            if(!this.m_globalPVPState.cfb.awardClaimed)
            {
               this.m_globalPVPState.cfb.awardClaimed = true;
               dispatchEvent(new WorldEvent(GPVP_AWARD_CLAIMED));
            }
         }
      }
      
      public function handleFightBatchExpired() : void
      {
         PVPManager.instance.hideGlobalPVPBar();
         delete this.m_globalPVPState.cfb;
      }
      
      public function getFeaturedRewardInfo(param1:int) : Object
      {
         var _loc3_:XMLList = null;
         var _loc4_:XMLList = null;
         var _loc5_:int = 0;
         var _loc6_:XML = null;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:String = null;
         var _loc2_:XML = ZGlobal.gameSettings.getXML();
         if(_loc2_)
         {
            if(_loc2_.slotMachineFeatured != undefined && Boolean(_loc2_.slotMachineFeatured.set as XMLList))
            {
               _loc3_ = _loc2_.slotMachineFeatured.set;
               if(this.m_globalPVPPrizeSet <= _loc3_.length() && Boolean(_loc3_[this.m_globalPVPPrizeSet].info as XMLList))
               {
                  _loc4_ = _loc3_[this.m_globalPVPPrizeSet].info;
                  _loc5_ = 0;
                  while(_loc5_ < _loc4_.length())
                  {
                     _loc6_ = _loc4_[_loc5_];
                     if(_loc6_.@tier != undefined && _loc6_.@itemName != undefined)
                     {
                        _loc7_ = int(_loc6_.@tier);
                        if(_loc7_ == param1)
                        {
                           _loc8_ = _loc6_.@itemName.toString();
                           _loc9_ = 1;
                           if(_loc6_.@amount != undefined)
                           {
                              _loc9_ = int(_loc6_.@amount);
                           }
                           _loc10_ = ZGlobal.gameSettings.getImageByName(_loc8_,"icon");
                           if(_loc10_)
                           {
                              return {
                                 "image":_loc10_,
                                 "amount":_loc9_,
                                 "itemName":_loc8_
                              };
                           }
                        }
                     }
                     _loc5_++;
                  }
               }
            }
         }
         return null;
      }
      
      private function onGlobalPVPInaction(param1:Object) : void
      {
         this.m_globalPVPInactionTimer.dispose();
         this.m_globalPVPInactionTimer = new TimerHandler(5000,this,this.onGlobalPVPInactionDialogWait);
         this.m_globalPVPInactionTimer.start();
      }
      
      private function onGlobalPVPInactionDialogWait(param1:Object) : void
      {
         if(this.globalPVPOptedIn && this.canShowGlobalPVPBar() && GameModeManager.instance.getTopGameMode() is GMIsland)
         {
            this.m_globalPVPInactionTimer.dispose();
            this.m_globalPVPInactionTimer = null;
            if(ZGlobal.player.enableIdlePopup)
            {
               if(PromoManager.instance.meetsCriteriaStarterPack())
               {
                  PromoManager.instance.openStarterPackPopup();
               }
            }
         }
         else
         {
            this.m_globalPVPInactionTimer.start();
         }
      }
      
      public function cheatGPVPWin() : void
      {
         this.handleGlobalPVPWin();
      }
      
      public function beginGlobalPVPMOTDFlow() : void
      {
         var _loc1_:IWindow = new GlobalPVPLegalPopup();
         PopupManager.instance.push(_loc1_);
      }
      
      public function globalPVPLegalScreenClosed() : void
      {
         dispatchEvent(new WorldEvent(GLOBALPVP_MOTD_DONE));
      }
      
      public function onStrangerBarTogglePressed() : void
      {
         if(this.m_globalPVPMOTDActive)
         {
            this.cleanUpGlobalPVPMOTD();
         }
      }
      
      private function onWorldLoaded(param1:Event) : void
      {
         if(this.m_globalPVPMOTDActive)
         {
            this.cleanUpGlobalPVPMOTD();
         }
      }
      
      private function cleanUpGlobalPVPMOTD() : void
      {
         TutorialManager.instance.sendEvent(TutorialManager.UI_CLEAR_STENCIL);
         TutorialManager.instance.sendEvent(TutorialManager.UI_DISABLE);
         TutorialManager.instance.sendEvent(TutorialManager.UI_ENABLE);
         this.m_globalPVPMOTDActive = false;
         dispatchEvent(new WorldEvent(GLOBALPVP_MOTD_DONE));
         VisitorManager.instance.removeEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded);
      }
      
      public function initialize(param1:DisplayObjectContainer) : void
      {
         this.m_windowParent = param1;
         Zlab.inputManager.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen,false,0,true);
         this.m_container.backgroundColor = 0;
         this.m_container.backgroundAlpha = 0;
         this.m_container.mouseEnabled = true;
         this.m_container.useHandCursor = false;
      }
      
      private function onFullScreen(param1:FullScreenEvent) : void
      {
         this.m_container.contentWidth = Zlab.mainStage.stageWidth;
         this.m_container.contentHeight = Zlab.mainStage.stageHeight;
      }
      
      private function disableUIInput() : void
      {
         if(!this.m_container.parent)
         {
            this.m_windowParent.addChild(this.m_container);
         }
      }
      
      private function enableUIInput() : void
      {
         if(Boolean(this.m_windowParent) && this.m_windowParent.contains(this.m_container))
         {
            this.m_windowParent.removeChild(this.m_container as DisplayObject);
         }
      }
      
      public function canAttackWithImmunityCooldown() : Boolean
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:GenericPopup = null;
         var _loc1_:Object = this.getImmunityStartReinvadeCooldownInfo();
         if(_loc1_.active)
         {
            _loc2_ = ZGameTimeUtil.instance.getTimeString(_loc1_.remaining);
            _loc3_ = ZGameUtils.ZlocT("Dialogs","PVPImmunityReinvadeMessage",{"timeString":_loc2_});
            _loc4_ = GenericPopup1B.NewOk(_loc3_,null);
            PopupManager.instance.push(_loc4_);
            return false;
         }
         return true;
      }
      
      public function canAttackWithNeighborAssist(param1:String) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:GenericPopup = null;
         var _loc2_:Object = this.getNeighborAssist(param1);
         if(_loc2_)
         {
            _loc3_ = ZGameUtils.ZlocT("Dialogs","PVPCannotVisitDefending");
            _loc4_ = GenericPopup1B.NewOk(_loc3_,null);
            PopupManager.instance.push(_loc4_);
            return false;
         }
         return true;
      }
      
      public function checkImmunityCancel(param1:Function, param2:Object) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:GenericPopup = null;
         if(this.isImmune)
         {
            _loc3_ = ZGlobal.gameSettings.getInt("PVPImmunityCooldownTimeout",21600);
            _loc4_ = ZGameTimeUtil.instance.getTimeString(_loc3_);
            _loc5_ = ZGameUtils.ZlocT("Dialogs","PVPImmunityAttackWarning",{"timeString":_loc4_});
            _loc6_ = GenericPopup2B.NewAcceptCancel(_loc5_,null,param1);
            _loc6_.userData = param2;
            PopupManager.instance.push(_loc6_);
            return false;
         }
         return true;
      }
      
      public function AccelerationPillageMultiplier() : Number
      {
         var _loc3_:Object = null;
         var _loc4_:GameDataComponent = null;
         var _loc5_:BuildingFSMComponent = null;
         var _loc6_:BehaviorStateMachine = null;
         var _loc1_:Number = 1;
         var _loc2_:Dictionary = WorldObjectManager.instance.getObjectsBySubType(GameItem.TYPE_BUILDING,"military");
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = GameDataComponent(_loc3_.lookupComponentByType(GameDataComponent));
            if((Boolean(_loc4_)) && Boolean(_loc4_.gameData) && _loc4_.gameData.getStateMachineName(null) == "AccelerationCenterStateMachine")
            {
               _loc5_ = BuildingFSMComponent(_loc3_.lookupComponentByType(BuildingFSMComponent));
               if(Boolean(_loc5_.isBuilt) && Boolean(_loc5_.stateMachine) && !BehaviorStateMachine(_loc5_.stateMachine).referenceItemName)
               {
                  _loc6_ = BehaviorStateMachine(_loc5_.stateMachine);
                  if(_loc6_.currentState is AutoDialogState && _loc6_.currentStateName == _loc6_.activatedState)
                  {
                     _loc1_ = 3;
                     break;
                  }
               }
            }
         }
         return _loc1_;
      }
      
      public function showPrisonCampNotifications(param1:Event) : void
      {
         var _loc5_:String = null;
         var _loc7_:Object = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EMPIRE_PRISONCAMP_MASTER) != ExperimentsManager.EMPIRE_PRISONCAMP_MASTER_VARIANT)
         {
            return;
         }
         var _loc2_:Array = new Array();
         var _loc3_:IPVPPlayer = null;
         var _loc4_:Boolean = false;
         for(_loc5_ in this.m_pcCapturedNotify)
         {
            if(this.m_pcCapturedNotify[_loc5_])
            {
               _loc4_ = true;
               break;
            }
         }
         if(_loc4_)
         {
            for(_loc9_ in this.m_pcCapturedNotify)
            {
               _loc3_ = PVPManager.instance.getPVPPlayer(_loc9_);
               _loc2_.push({
                  "name":_loc3_.firstName,
                  "icon":_loc3_.portraitURL,
                  "uid":_loc3_.uid
               });
            }
         }
         var _loc6_:Array = new Array();
         for each(_loc7_ in PrisonCampManager.instance.getInfo())
         {
            _loc10_ = this.m_pcEscapedNotify.indexOf(String(_loc7_.uid));
            if(_loc10_ >= 0)
            {
               this.m_pcEscapedNotify.splice(_loc10_,1);
            }
         }
         for each(_loc8_ in this.m_pcEscapedNotify)
         {
            _loc3_ = PVPManager.instance.getPVPPlayer(_loc8_);
            _loc6_.push({
               "name":_loc3_.firstName,
               "icon":_loc3_.portraitURL,
               "uid":_loc3_.uid
            });
         }
         if(_loc6_.length)
         {
            PopupManager.instance.push(new PrisonCampNotification(PrisonCampNotification.TYPE_ESCAPED,_loc6_,this.clearPCEscapers));
         }
         else if(_loc2_.length)
         {
            PopupManager.instance.push(new PrisonCampNotification(PrisonCampNotification.TYPE_CAPTURED,_loc2_,this.clearPCInvaders));
         }
      }
      
      protected function clearPCInvaders(param1:Event) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in this.m_pcCapturedNotify)
         {
            TransactionManager.addTransaction(new TSeenPrisonCampNotification(TSeenPrisonCampNotification.CAPTURED,_loc2_));
         }
         this.m_pcCapturedNotify = new Object();
      }
      
      protected function clearPCEscapers(param1:Event) : void
      {
         var _loc2_:String = null;
         for each(_loc2_ in this.m_pcEscapedNotify)
         {
            TransactionManager.addTransaction(new TSeenPrisonCampNotification(TSeenPrisonCampNotification.ESCAPED,_loc2_));
         }
         this.m_pcEscapedNotify = new Array();
      }
   }
}

