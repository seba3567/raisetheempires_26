package core.managers.domination
{
   import Engine.Classes.SocialNetworkUser;
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleHost;
   import core.gamemode.battle.GMBattle;
   import core.gamemode.prebattle.GMPreBattle;
   import core.gameobjects.Fleet;
   import core.gameobjects.Unit;
   import core.gameobjects.UnitItem;
   import core.managers.AlliancesManager;
   import core.managers.ExperimentsManager;
   import core.managers.ZRTManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.viralsManager.ViralsManager;
   import core.managers.visitorManager.VisitorManager;
   import core.player.IPVPPlayer;
   import core.player.Player;
   import core.ui.UI;
   import core.ui.ZGameButton;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.popups.genericPopup.ModalPopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.dominationMode.DominationModeChatHistoryScreen;
   import displays.screens.dominationMode.DominationModeDescriptionPopup;
   import displays.screens.dominationMode.DominationModeScreen;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import transactions.TGetDominationChat;
   import transactions.TGetDominationModeOpponentList;
   import transactions.TLoadDominationModeBattle;
   import transactions.TSetSeenFlag;
   import transactions.TUpdateDefenseForce;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class DominationModeManager extends EventDispatcher
   {
      
      public static const ABUSE_REPORT_URL:String = "http://support.zynga.com";
      
      public static const DOMINATION_MOTD_DONE:String = "motdDone";
      
      public static const SEEN_DESCRIPTION:String = "seen_domination_description";
      
      public static const SEEN_DEFENSEFORCESETUP:String = "seen_domination_defenseforce_setup";
      
      public static const SEEN_MAIN_SCREEN_HELP:String = "seen_domination_mainscreen_help";
      
      public static const SEEN_FIRST_FIGHT:String = "seen_domination_first_fight";
      
      public static const SEEN_FIRST_DEFENSE_SETUP:String = "seen_domination_first_defense_setup";
      
      public static const SEEN_FIRST_DEFENSE_SAVE:String = "seen_domination_first_defense_save";
      
      public static const SEEN_TAUNT_DISCLAIMER:String = "seen_domination_taunt_intro";
      
      public static const DVTS_UPDATED:String = "dvtsUpdated";
      
      public static const PCT_UPDATED:String = "pctUpdated";
      
      public static const DEFENSE_ALERT_CHANGED:String = "defenseAlertChanged";
      
      public static const DOMINATION_REWARD_UNLOCKED:String = "rewardUnlocked";
      
      public static const DOMINANCE_RANK_UPDATED:String = "dominance_rank_updated";
      
      public static const NUM_REVENGEFIGHTS_CHANGED:String = "numRevengeFightsChanged";
      
      public static const HIDE_DOMINATION_SCREEN:String = "hide_domination_screen";
      
      public static const FIGHT_LIST_UPDATED:String = "fight_list_updated";
      
      public static const EXIT_DOMINATION_PREBATTLE:String = "exitDominationPreBattle";
      
      public static const FIGHT_LIST_TARGET_SELECTED:String = "fightListTargetSelected";
      
      public static const UPDATED_DOMINANCE_RANK:String = "updatedDomRank";
      
      public static const UPDATED_DOMINANCE_SCORE:String = "updatedDomScore";
      
      public static const MAX_FLEET_STRENGTH_UPDATED:String = "maxFleetStrengthUpdated";
      
      public static const instance:DominationModeManager = new DominationModeManager();
      
      public static const FLEET_DEFENSE_PREFIX:String = "fleet_defense_";
      
      public static const FLEET_DOMINATION_PLAYER_NAME:String = "fleet_domination_player";
      
      public static const FLEET_DOMINATION_ENEMY_NAME:String = "fleet_domination_enemy";
      
      public static const FLEET_DEFENSE_DUMMY_PLAYER:String = "fleet_defense_dummy_player";
      
      public static const FLEET_DEFENSE_DUMMY_ENEMY:String = "fleet_defense_dummy_enemy";
      
      public static const STRENGTH_TYPE_LOW:String = "DominationLowStrengthPercent";
      
      public static const STRENGTH_TYPE_MED:String = "DominationMedStrengthPercent";
      
      public static const STRENGTH_TYPE_MED_HIGH:String = "DominationMedHighStrengthPercent";
      
      public static const STRENGTH_TYPE_HIGH:String = "DominationHighStrengthPercent";
      
      private static const STRENGTH_COLOR_RED:int = 16711680;
      
      private static const STRENGTH_COLOR_ORANGE:int = 16750848;
      
      private static const STRENGTH_COLOR_YELLOW:int = 16776960;
      
      private static const STRENGTH_COLOR_GREEN:int = 65280;
      
      public static const DOM_VICTIMSTATUS_WAITING:int = 1;
      
      public static const LOAD_DOMINATION_BATTLE_PLAYER_SETUP:int = 1;
      
      public static const LOAD_DOMINATION_BATTLE_IN_PROGRESS:int = 2;
      
      public static const LOAD_DOMINATION_BATTLE_ERROR:int = 3;
      
      public static const DOMINATION_ERROR_UNKNOWN:int = 0;
      
      public static const DOMINATION_ERROR_INVALID_FLEET_STRENGTH:int = 1;
      
      public static const DOMINATION_ERROR_NO_ENEMY_FLEET:int = 2;
      
      public static const DOMINATION_ERROR_NO_DEFENSE_FORCE:int = 3;
      
      public static const DOMINATION_ERROR_NOT_VALID_VICTIM:int = 4;
      
      public static const DOMINATION_ERROR_NO_TITANS_ALLOWED:int = 5;
      
      public static const DOMINATION_PREBATTLE_DEFENSE_EDITOR:int = 0;
      
      public static const DOMINATION_PREBATTLE_ATTACK_EDITOR:int = 1;
      
      private var m_inDominationExperiment:Boolean = false;
      
      private var m_dominationList:Array = null;
      
      private var m_rivalsList:Array = null;
      
      private var m_haveDominationList:Boolean = false;
      
      private var m_inDominationBattle:Boolean = false;
      
      private var m_enemyUID:String = null;
      
      private var m_inDefenseForceEditMode:Boolean = false;
      
      private var m_defenseForceEditIndex:int = 0;
      
      private var m_currentDefenceForceIndex:int = 0;
      
      private var m_prevDefenseForceFleet:Fleet = null;
      
      private var m_setupFleetStrength:int = 0;
      
      private var m_loadingPopup:ModalPopup = null;
      
      private var m_showingDescription:Boolean = false;
      
      private var m_dominationScreenActive:Boolean = false;
      
      private var m_victimInfo:Dictionary = new Dictionary();
      
      private var m_motdActive:Boolean;
      
      private var m_newChats:Dictionary;
      
      private var m_tauntDisclaimer:MovieClip;
      
      private var m_tauntDisclaimerOK:ZGameButton;
      
      private var m_tooltipOptions:Object = {"alpha":1};
      
      private var m_playerInfo:Object = {
         "defenseAlert":false,
         "w":0,
         "l":0,
         "dfw":0,
         "dfl":0,
         "nr":0,
         "ds":0,
         "dr":0,
         "dvts":0,
         "pct":0
      };
      
      private var m_playerInfoInitialized:Boolean;
      
      private var m_enabled:Boolean;
      
      private var m_defaultFleets:Object;
      
      private var m_allianceFightList:Array = null;
      
      private var m_allianceRivalList:Array = null;
      
      private var m_allianceMemberList:Array = null;
      
      public var m_mysteryDooberResults:Object = new Object();
      
      public function DominationModeManager()
      {
         super();
         this.init();
         TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,this.onTransactionComplete,false,0,true);
      }
      
      public function get inDominationExperiment() : Boolean
      {
         return this.m_inDominationExperiment;
      }
      
      public function get tooltipOptions() : Object
      {
         return this.m_tooltipOptions;
      }
      
      public function initData(param1:Object) : void
      {
         if(param1)
         {
            this.m_playerInfo.defenseAlert = param1.domDefenseAlert;
            this.m_playerInfo.w = param1.dominanceWins;
            this.m_playerInfo.l = param1.dominanceLosses;
            this.m_playerInfo.ds = param1.dominance;
            this.m_playerInfo.dr = param1.dominanceRank;
            this.m_playerInfo.dfw = param1.dfw;
            this.m_playerInfo.dfl = param1.dfl;
            this.m_playerInfo.nr = param1.nr;
            this.m_playerInfo.dvts = param1.dvts;
            this.m_playerInfo.pct = param1.percentile;
            this.m_playerInfoInitialized = true;
         }
      }
      
      private function init() : void
      {
         this.m_dominationList = new Array();
         this.m_rivalsList = new Array();
         this.m_allianceFightList = new Array();
         this.m_allianceRivalList = new Array();
         this.m_allianceMemberList = new Array();
      }
      
      public function get dvts() : int
      {
         return this.m_playerInfo.dvts;
      }
      
      public function setDefaultFleets(param1:Object) : void
      {
         if(!(param1 as Array))
         {
            this.m_defaultFleets = param1;
         }
      }
      
      public function setDefaultFleet(param1:String, param2:Array) : void
      {
         if(!this.m_defaultFleets)
         {
            this.m_defaultFleets = {};
         }
         this.m_defaultFleets[param1] = param2;
      }
      
      public function initExperimentVars() : void
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_DOMINATION_MASTER) == ExperimentsManager.VARIANT_DOMINATION_MASTER_ENABLED)
         {
            this.m_inDominationExperiment = true;
         }
      }
      
      public function refreshFightList() : void
      {
         TransactionManager.addTransaction(new TGetDominationModeOpponentList(),true);
      }
      
      public function launchDominationScreen(param1:String = "") : void
      {
         var _loc2_:DominationModeDescriptionPopup = null;
         if(this.m_motdActive)
         {
            this.cleanupMOTDFlow();
         }
         if(!this.m_haveDominationList || this.m_dominationList.length == 0)
         {
            this.m_haveDominationList = false;
            TransactionManager.addTransaction(new TGetDominationModeOpponentList(),true);
         }
         if(!ZGlobal.player.getSeenFlag(SEEN_DESCRIPTION))
         {
            this.m_showingDescription = true;
            _loc2_ = new DominationModeDescriptionPopup(DominationModeDescriptionPopup.TYPE_INTRO);
            PopupManager.instance.push(_loc2_);
            _loc2_.addEventListener(ZGamePopUp.CLOSED,this.onDescriptionClosed);
         }
         else
         {
            this.showDominationScreen(param1);
         }
      }
      
      public function onGetDominationModeOpponentList(param1:Object) : void
      {
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:Object = null;
         var _loc11_:Dictionary = null;
         var _loc12_:String = null;
         var _loc13_:Object = null;
         var _loc14_:Array = null;
         this.m_playerInfo.dvts = param1.dvts;
         dispatchEvent(new Event(DVTS_UPDATED));
         if(param1.errors as Array)
         {
            for each(_loc7_ in param1.errors as Array)
            {
               Logger.print(this,_loc7_);
            }
         }
         this.m_newChats = new Dictionary();
         if(param1.newChats as Array)
         {
            for each(_loc8_ in param1.newChats)
            {
               _loc9_ = _loc8_.slice(1);
               this.m_newChats[_loc9_] = true;
            }
         }
         var _loc2_:Array = param1.victims;
         if(this.m_dominationList.length > 0)
         {
            this.m_dominationList = [];
         }
         if(this.m_rivalsList.length > 0)
         {
            this.m_rivalsList = [];
         }
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(_loc2_[_loc4_] != null)
            {
               if(_loc2_[_loc4_].d_info.int)
               {
                  this.m_rivalsList.push(_loc2_[_loc4_]);
               }
               else
               {
                  this.m_dominationList.push(_loc2_[_loc4_]);
               }
            }
            _loc4_++;
         }
         this.newRevengeFights = 0;
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         if(AlliancesManager.isValid() && Boolean(param1.allianceVictims))
         {
            _loc10_ = param1.allianceVictims;
            _loc11_ = new Dictionary();
            for(_loc12_ in _loc10_)
            {
               _loc13_ = this.getAllianceInfo(_loc12_);
               if(_loc10_[_loc12_])
               {
                  if(_loc10_[_loc12_]["members"])
                  {
                     _loc14_ = _loc10_[_loc12_]["members"];
                     _loc11_[_loc12_] = new Array();
                     _loc11_[_loc12_] = _loc10_[_loc12_]["members"];
                  }
                  if(Boolean(_loc13_) && _loc10_[_loc12_]["membersInfo"] == 0)
                  {
                     _loc10_[_loc12_]["membersInfo"] = _loc13_.membersInfo;
                  }
                  if(_loc10_[_loc12_]["id"])
                  {
                     if(Boolean(_loc13_) && Boolean(_loc13_.totalBonus))
                     {
                        _loc10_[_loc12_].totalBonus = _loc13_.totalBonus;
                     }
                     if(!_loc10_[_loc12_]["int"])
                     {
                        _loc5_.push(_loc10_[_loc12_]);
                     }
                     else
                     {
                        _loc6_.push(_loc10_[_loc12_]);
                     }
                  }
               }
            }
            this.m_allianceFightList = _loc5_;
            this.m_allianceRivalList = _loc6_;
            AlliancesManager.instance.populateAllianceData(_loc11_);
            AlliancesManager.instance.initBattleData();
            if(Boolean(param1.allianceTS) && Boolean(param1.allianceDuration))
            {
               AlliancesManager.instance.updateTimestamp(param1.allianceTS,param1.allianceDuration);
            }
         }
         dispatchEvent(new Event(FIGHT_LIST_UPDATED));
      }
      
      public function updateAllianceMemberList(param1:String, param2:Object) : void
      {
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Array = new Array();
         if(Boolean(param2) && Boolean(this.m_allianceMemberList))
         {
            for(_loc5_ in param2)
            {
               _loc6_ = int(_loc5_);
               _loc3_ = this.getDominationInfo(param2[_loc6_].u_info.zid,true);
               if(_loc3_)
               {
                  _loc3_.d_info = param2[_loc6_].d_info;
                  _loc3_.u_info = param2[_loc6_].u_info;
               }
               else
               {
                  _loc4_.push(param2[_loc6_]);
               }
            }
            if(_loc4_.length > 0)
            {
               this.m_allianceMemberList = this.m_allianceMemberList.concat(_loc4_);
            }
            _loc3_ = this.getAllianceInfo(param1);
            _loc3_.membersInfo = true;
         }
      }
      
      public function getAllianceFightList() : Array
      {
         if(this.m_allianceFightList.length < 1)
         {
            return null;
         }
         return this.m_allianceFightList;
      }
      
      public function getAllianceRivalList() : Array
      {
         if(this.m_allianceRivalList.length < 1)
         {
            return null;
         }
         return this.m_allianceRivalList;
      }
      
      public function getDominationFightList() : Array
      {
         if(this.m_dominationList.length < 1)
         {
            return null;
         }
         return this.m_dominationList;
      }
      
      public function getRivalsFightList() : Array
      {
         if(this.m_rivalsList.length < 1)
         {
            return null;
         }
         return this.m_rivalsList;
      }
      
      private function onDescriptionClosed(param1:Event) : void
      {
         ZGlobal.player.setSeenFlag(SEEN_DESCRIPTION);
         this.m_showingDescription = false;
         this.showDominationScreen();
      }
      
      private function showDominationScreen(param1:String = "") : void
      {
         var _loc2_:DominationModeScreen = null;
         if(!this.m_dominationScreenActive)
         {
            addEventListener(HIDE_DOMINATION_SCREEN,this.onCloseDominationScreen);
            _loc2_ = new DominationModeScreen();
            _loc2_.setCurrentTab(param1);
            PopupManager.instance.push(_loc2_);
            this.m_dominationScreenActive = true;
         }
      }
      
      public function onCloseDominationScreen(param1:Event) : void
      {
         this.hideDominationScreen();
      }
      
      private function hideDominationScreen() : void
      {
         removeEventListener(HIDE_DOMINATION_SCREEN,this.onCloseDominationScreen);
         this.m_dominationScreenActive = false;
      }
      
      public function onOpponentListReceived(param1:WorldEvent) : void
      {
         var _loc2_:Object = param1.eventData;
         this.m_haveDominationList = true;
      }
      
      private function onOpponentSelected(param1:WorldEvent) : void
      {
         var _loc2_:Object = this.getOpponentFromIndex(param1.eventData.index);
         this.enterBattleMode(_loc2_);
      }
      
      private function getOpponentFromIndex(param1:int) : Object
      {
         return new Object();
      }
      
      private function enterBattleMode(param1:Object) : void
      {
      }
      
      public function get dfw() : int
      {
         return this.m_playerInfo.dfw;
      }
      
      public function set dfw(param1:int) : void
      {
         this.m_playerInfo.dfw = param1;
      }
      
      public function get dfl() : int
      {
         return this.m_playerInfo.dfl;
      }
      
      public function set dfl(param1:int) : void
      {
         this.m_playerInfo.dfl = param1;
      }
      
      public function hasNewChat(param1:String) : Boolean
      {
         return this.m_newChats[param1] != undefined;
      }
      
      public function clearHasNewChat(param1:String) : void
      {
         delete this.m_newChats[param1];
      }
      
      public function get dominance() : int
      {
         return this.m_playerInfo.ds;
      }
      
      public function get dominanceRank() : int
      {
         return this.m_playerInfo.dr;
      }
      
      public function set dominanceRank(param1:int) : void
      {
         var _loc2_:int = int(this.m_playerInfo.dr);
         this.m_playerInfo.dr = param1;
         if(param1 > _loc2_)
         {
            this.showDefenseAlert = true;
         }
         dispatchEvent(new Event(UPDATED_DOMINANCE_RANK));
      }
      
      public function set dominance(param1:int) : void
      {
         var _loc2_:int = this.dominance;
         var _loc3_:int = int(this.m_playerInfo.dr);
         var _loc4_:int = this.getRequiredDominanceForRank(_loc3_);
         param1 = Math.max(param1,_loc4_);
         if(param1 != this.dominance)
         {
            this.updateDominanceRank(param1);
            this.m_playerInfo.ds = param1;
         }
         dispatchEvent(new Event(UPDATED_DOMINANCE_SCORE));
      }
      
      public function getRequiredDominanceForRank(param1:int) : int
      {
         var _loc2_:XML = ZGlobal.gameSettings.getXML();
         var _loc3_:XMLList = _loc2_.dominance.rank;
         if(param1 < _loc3_.length())
         {
            return _loc3_[param1].@requiredDominance;
         }
         return 0;
      }
      
      public function get maxRank() : int
      {
         var _loc1_:XML = ZGlobal.gameSettings.getXML();
         var _loc2_:XMLList = _loc1_.dominance.rank;
         var _loc3_:int = _loc2_.length();
         if(_loc3_ < 1)
         {
            return -1;
         }
         return _loc2_[_loc3_ - 1].@num;
      }
      
      public function get dominanceRequiredForNextLevel() : int
      {
         if(this.dominanceRank == this.maxRank)
         {
            return 0;
         }
         var _loc1_:XML = ZGlobal.gameSettings.getXML();
         var _loc2_:XMLList = _loc1_.dominance.rank;
         return int(_loc2_[this.dominanceRank + 1].@requiredDominance);
      }
      
      public function get percentThroughLevel() : Number
      {
         if(this.dominanceRank == this.maxRank)
         {
            return 0;
         }
         var _loc1_:XML = ZGlobal.gameSettings.getXML();
         var _loc2_:XMLList = _loc1_.dominance.rank;
         var _loc3_:int = int(_loc2_[this.dominanceRank].@requiredDominance);
         var _loc4_:int = int(_loc2_[this.dominanceRank + 1].@requiredDominance);
         return (this.dominance - _loc3_) / (_loc4_ - _loc3_);
      }
      
      public function getRankName(param1:int) : String
      {
         return "Unknown Rank";
      }
      
      private function updateDominanceRank(param1:int) : void
      {
         var _loc7_:XML = null;
         var _loc2_:XML = ZGlobal.gameSettings.getXML();
         var _loc3_:XMLList = _loc2_.dominance.rank;
         var _loc4_:int = 1;
         var _loc5_:XML = null;
         var _loc6_:* = int(_loc3_.length() - 1);
         while(_loc6_ >= 0)
         {
            _loc5_ = _loc7_ = _loc3_[_loc6_];
            _loc4_ = _loc6_;
            if(param1 >= _loc7_.@requiredDominance)
            {
               break;
            }
            _loc6_--;
         }
         if(this.dominanceRank < _loc4_ && _loc4_ >= 1)
         {
            this.dominanceRank = _loc4_;
            if(this.m_playerInfoInitialized)
            {
               UI.displayDominanceLevelUpDialog(this.dominanceRank);
               dispatchEvent(new WorldEvent(DOMINANCE_RANK_UPDATED,{"rank":_loc4_}));
            }
         }
      }
      
      public function get maxForceStrengthDefend() : uint
      {
         return this.dominanceRank * 50 + 500;
      }
      
      public function get dominancePercentile() : uint
      {
         return this.m_playerInfo.pct;
      }
      
      public function get wins() : uint
      {
         return this.m_playerInfo.w;
      }
      
      public function get losses() : uint
      {
         return this.m_playerInfo.l;
      }
      
      public function getMaxRemainingSetupFleetStrength() : int
      {
         return int(this.maxForceStrengthDefend - this.m_setupFleetStrength);
      }
      
      private function fleetStrengthUpdated() : void
      {
         var _loc1_:int = this.getMaxRemainingSetupFleetStrength();
         dispatchEvent(new WorldEvent(MAX_FLEET_STRENGTH_UPDATED,{
            "strength":this.m_setupFleetStrength,
            "remaining":_loc1_
         }));
      }
      
      public function updateSetupFleetStrength(param1:int) : void
      {
         this.m_setupFleetStrength += param1;
         this.fleetStrengthUpdated();
      }
      
      public function resetSetupFleetStrength() : void
      {
         this.m_setupFleetStrength = 0;
         this.fleetStrengthUpdated();
      }
      
      public function isInSetupFleetEditMode() : Boolean
      {
         return GMPreBattle.ACTIVE && (DominationModeManager.instance.isInDefenseForceEditMode() || DominationModeManager.instance.isInDominationBattle());
      }
      
      public function enterDefenseForceEditor(param1:int = 0) : void
      {
         var _loc2_:Fleet = ZGlobal.player.fleets.getFleetByName(FLEET_DEFENSE_DUMMY_PLAYER);
         if(!_loc2_)
         {
            _loc2_ = ZGlobal.player.fleets.createTempFleet(UnitItem.ARMY,"0");
            _loc2_.name = FLEET_DEFENSE_DUMMY_PLAYER;
            _loc2_.setStatus(Fleet.DOMINATION_DEFENSE);
         }
         else
         {
            _loc2_.clearUnits();
         }
         var _loc3_:Fleet = ZGlobal.player.fleets.getFleetByName(FLEET_DEFENSE_DUMMY_ENEMY);
         if(!_loc3_)
         {
            _loc3_ = ZGlobal.player.fleets.createTempFleet(UnitItem.ARMY,"0");
            _loc3_.name = FLEET_DEFENSE_DUMMY_ENEMY;
         }
         this.resetSetupFleetStrength();
         this.setInDefenseForceEditMode(param1);
         _loc2_.type = this.m_prevDefenseForceFleet.type;
         _loc3_.type = this.m_prevDefenseForceFleet.type;
         GameModeManager.instance.addGameMode(new GMBattle(_loc2_,_loc3_));
         if(GMPreBattle.ENABLED)
         {
            GMPreBattle.ACTIVE = true;
            GameModeManager.instance.addGameMode(new GMPreBattle(_loc2_,_loc3_,Fleet.MAX_UNITS),false);
         }
      }
      
      public function updateDefenseForce() : void
      {
         var _loc1_:String = null;
         if(!this.m_loadingPopup)
         {
            _loc1_ = ZGameUtils.ZlocT("Dialogs","DominationUpdatingDefenseForce");
            this.m_loadingPopup = new ModalPopup(_loc1_,null,"assets/displays/dialogs/PU_ModalPopUp_Dominance.swf");
            WindowManager.instance.push(this.m_loadingPopup,0,false,true);
         }
         TransactionManager.addTransaction(new TUpdateDefenseForce(this.m_defenseForceEditIndex),true);
      }
      
      public function onUpdateDefenseForce(param1:Object) : void
      {
         var _loc2_:Fleet = null;
         var _loc3_:TSetSeenFlag = null;
         if(this.m_loadingPopup)
         {
            this.m_loadingPopup.pop();
            this.m_loadingPopup = null;
         }
         if(param1.success)
         {
            if(param1.fleet)
            {
               ZGlobal.player.fleets.destroyFleet(param1.fleet.name,Battle.BATTLE_RESULT_NONE);
               ZGlobal.player.fleets.addServerGeneratedFleetFromData(param1.fleet,param1.fleet.type,param1.fleet.uid);
               _loc2_ = ZGlobal.player.fleets.getFleetByName(param1.fleet.name);
               if(_loc2_)
               {
                  _loc2_.deploy();
               }
            }
            this.showDefenseAlert = false;
         }
         if(!ZGlobal.player.getSeenFlag(SEEN_FIRST_DEFENSE_SAVE))
         {
            ZGlobal.player.setSeenFlag(SEEN_FIRST_DEFENSE_SAVE);
            _loc3_ = new TSetSeenFlag(SEEN_FIRST_DEFENSE_SAVE);
            TransactionManager.addTransaction(_loc3_);
            this.showFirstDefenseSaveDialog();
         }
         else
         {
            DominationModeManager.instance.launchDominationScreen();
         }
      }
      
      private function showFirstDefenseSaveDialog() : void
      {
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","DominationDefenseSaveTitle");
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","DominationDefenseSaveText");
         var _loc3_:GenericPopup1B = GenericPopup1B.NewOk(_loc2_,_loc1_,this.onFirstDefenseSaveDialogClosed);
         PopupManager.instance.push(_loc3_);
      }
      
      private function onFirstDefenseSaveDialogClosed(param1:GenericPopupEvent) : void
      {
         DominationModeManager.instance.launchDominationScreen();
      }
      
      private function DominationBattleErrorDialog(param1:String, param2:int) : void
      {
         var _loc3_:String = "DominationBattleError" + param2;
         var _loc4_:String = ZGameUtils.ZlocT("Dialogs",_loc3_);
         var _loc5_:GenericPopup1B = GenericPopup1B.NewOk(_loc4_,null);
         PopupManager.instance.push(_loc5_);
         if(!param1)
         {
            param1 = "no uid";
         }
         Logger.print(this,"Domination Battle error for uid " + param1 + ": " + _loc4_);
      }
      
      public function loadDominationModeBattle(param1:String = null, param2:String = null) : void
      {
         var _loc5_:String = null;
         var _loc3_:String = FLEET_DEFENSE_PREFIX + "0";
         var _loc4_:Fleet = ZGlobal.player.fleets.getFleetByName(_loc3_);
         if(!_loc4_)
         {
            this.DominationBattleErrorDialog(param2,DOMINATION_ERROR_NO_DEFENSE_FORCE);
            return;
         }
         if(!this.m_loadingPopup)
         {
            _loc5_ = ZGameUtils.ZlocT("Dialogs","DominationLaunchBattle");
            this.m_loadingPopup = new ModalPopup(_loc5_,null,"assets/displays/dialogs/PU_ModalPopUp_Dominance.swf");
            WindowManager.instance.push(this.m_loadingPopup,0,false,true);
         }
         TransactionManager.addTransaction(new TLoadDominationModeBattle(param1,param2),true);
      }
      
      public function onLoadDominationModeBattle(param1:Object, param2:String) : void
      {
         if(Boolean(param1) && Boolean(param1.state))
         {
            switch(param1.state)
            {
               case LOAD_DOMINATION_BATTLE_PLAYER_SETUP:
                  this.dominationBattlePlayerSetup(param2,param1.type);
                  break;
               case LOAD_DOMINATION_BATTLE_IN_PROGRESS:
                  this.launchDominationBattle(param1);
                  break;
               case LOAD_DOMINATION_BATTLE_ERROR:
                  if(param1.error)
                  {
                     this.DominationBattleErrorDialog(param2,param1.error);
                  }
            }
         }
         if(this.m_loadingPopup)
         {
            this.m_loadingPopup.pop();
            this.m_loadingPopup = null;
         }
      }
      
      public function dominationBattlePlayerSetup(param1:String, param2:String) : void
      {
         if(param2 == null || param2 != UnitItem.ARMY && param2 != UnitItem.NAVY && param2 != UnitItem.AIR)
         {
            param2 = UnitItem.ARMY;
         }
         var _loc3_:Fleet = ZGlobal.player.fleets.getFleetByName(FLEET_DEFENSE_DUMMY_PLAYER);
         if(!_loc3_)
         {
            _loc3_ = ZGlobal.player.fleets.createTempFleet(param2,"0");
            _loc3_.name = FLEET_DEFENSE_DUMMY_PLAYER;
            _loc3_.setStatus(Fleet.DOMINATION_DEFENSE);
            if(!this.isNewBattle(param1))
            {
               _loc3_.setStatus(Fleet.DOMINATION_RETAL);
            }
         }
         else
         {
            _loc3_.clearUnits();
            _loc3_.type = param2;
            if(this.isNewBattle(param1))
            {
               _loc3_.clearStatus(Fleet.DOMINATION_RETAL);
            }
            else
            {
               _loc3_.setStatus(Fleet.DOMINATION_RETAL);
            }
         }
         var _loc4_:Fleet = ZGlobal.player.fleets.getFleetByName(FLEET_DEFENSE_DUMMY_ENEMY);
         if(!_loc4_)
         {
            _loc4_ = ZGlobal.player.fleets.createTempFleet(param2,"0");
            _loc4_.name = FLEET_DEFENSE_DUMMY_ENEMY;
         }
         else
         {
            _loc4_.type = param2;
         }
         this.resetSetupFleetStrength();
         this.setInDominationBattle(param1);
         GameModeManager.instance.addGameMode(new GMBattle(_loc3_,_loc4_));
         if(GMPreBattle.ENABLED)
         {
            GMPreBattle.ACTIVE = true;
            GameModeManager.instance.addGameMode(new GMPreBattle(_loc3_,_loc4_,Fleet.MAX_UNITS),false);
         }
      }
      
      public function launchDominationBattle(param1:Object) : void
      {
         var _loc4_:Object = null;
         ZGlobal.player.fleets.addServerGeneratedFleetFromData(param1.playerFleet,param1.playerFleet.type,param1.playerFleet.uid);
         ZGlobal.player.fleets.addServerGeneratedFleetFromData(param1.enemyFleet,param1.enemyFleet.type,param1.enemyFleet.uid);
         var _loc2_:Fleet = Fleet.getFleet(param1.playerFleet.name);
         var _loc3_:Fleet = Fleet.getFleet(param1.enemyFleet.name);
         if(param1.newStart)
         {
            _loc2_.deploy();
            dispatchEvent(new Event(EXIT_DOMINATION_PREBATTLE));
            this.saveDefaultFleet(_loc2_);
         }
         this.setInDominationBattle(param1.enemyFleet.uid);
         GameModeManager.instance.addGameMode(new GMBattle(_loc2_,_loc3_));
         BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_RESUME));
         if(param1.hasOwnProperty("scDec"))
         {
            _loc4_ = this.getDominationInfo(this.m_enemyUID);
            if(_loc4_)
            {
               _loc4_.scDec = param1.scDec;
            }
         }
      }
      
      private function battleLost(param1:Object, param2:BattleHost) : void
      {
         var _loc3_:int = this.getBattleLostPenalty(param1,param2);
         if(_loc3_ > 0)
         {
            this.dominance -= _loc3_;
         }
      }
      
      private function playerFleetHasScoutingPenalty(param1:Battle) : Boolean
      {
         var _loc2_:Fleet = param1 ? param1.playerFleet : null;
         return _loc2_ ? this.fleetHasScoutingPenalty(param1.playerUnitTally(true),_loc2_) : false;
      }
      
      private function fleetHasScoutingPenalty(param1:Object, param2:Fleet) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:UnitItem = null;
         var _loc6_:int = 0;
         for(_loc4_ in param1)
         {
            _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_,UnitItem) as UnitItem;
            if(_loc5_)
            {
               _loc6_ = _loc5_.getUpgradedStrength(param2);
               _loc3_ += _loc6_ * param1[_loc4_];
            }
         }
         return this.isUnderStrengthPercent(_loc3_,STRENGTH_TYPE_LOW);
      }
      
      public function isUnderStrengthPercent(param1:int, param2:String = "DominationLowStrengthPercent") : Boolean
      {
         var _loc3_:int = int(DominationModeManager.instance.maxForceStrengthDefend);
         var _loc4_:int = ZGlobal.gameSettings.getInt(param2,40);
         var _loc5_:int = _loc4_ * _loc3_ / 100;
         return param1 < _loc5_;
      }
      
      public function getStrengthColor(param1:int) : int
      {
         var _loc2_:int = STRENGTH_COLOR_GREEN;
         if(this.isUnderStrengthPercent(param1,STRENGTH_TYPE_LOW))
         {
            _loc2_ = STRENGTH_COLOR_RED;
         }
         else if(this.isUnderStrengthPercent(param1,STRENGTH_TYPE_MED))
         {
            _loc2_ = STRENGTH_COLOR_ORANGE;
         }
         else if(this.isUnderStrengthPercent(param1,STRENGTH_TYPE_MED_HIGH))
         {
            _loc2_ = STRENGTH_COLOR_YELLOW;
         }
         else if(this.isUnderStrengthPercent(param1,STRENGTH_TYPE_HIGH))
         {
            _loc2_ = STRENGTH_COLOR_GREEN;
         }
         return _loc2_;
      }
      
      public function getBattleLostPenalty(param1:Object, param2:BattleHost) : int
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this.playerFleetHasScoutingPenalty(param2))
         {
            _loc3_ = ZGlobal.gameSettings.getInt("DominationLowStrengthLosePenaltyPercent",40);
            return int(_loc3_ * param1.scInc / 100);
         }
         return 0;
      }
      
      public function getRetreatPenalty(param1:Object) : int
      {
         var _loc2_:int = ZGlobal.gameSettings.getInt("DominationLowStrengthRetreatPenaltyPercent",50);
         var _loc3_:int = param1.scInc * _loc2_ / 100;
         if(Boolean(ZGlobal.player.combatSpecialBits & Fleet.HALF_RANSOM) && Boolean(ExperimentsManager.instance.getExperimentVariant("empire_combat_half_ransom") > 1) && ZRTManager.instance.isZRTOn(ZGlobal.player.COMBAT_HALF_RANSOM))
         {
            _loc3_ *= 0.5;
         }
         return _loc3_;
      }
      
      private function battleRetreated(param1:Object) : void
      {
         this.dominance -= this.getRetreatPenalty(param1);
      }
      
      private function updateDominanceScores(param1:Object, param2:BattleHost) : Object
      {
         if(param2.battleResult == Battle.BATTLE_RESULT_RETREAT)
         {
            this.battleRetreated(param1);
         }
         else if(param2.battleResult == Battle.BATTLE_RESULT_LOST)
         {
            this.battleLost(param1,param2);
         }
         else if(param2.battleResult == Battle.BATTLE_RESULT_WON)
         {
         }
         return param1;
      }
      
      public function completeDominationBattle(param1:BattleHost) : void
      {
         if(param1.battleResult == Battle.BATTLE_RESULT_NONE)
         {
            return;
         }
         var _loc2_:Object = this.getDominationInfo(this.m_enemyUID,true);
         if(!_loc2_)
         {
            return;
         }
         this.updateDominanceScores(_loc2_.d_info,param1);
         if(param1.battleResult == Battle.BATTLE_RESULT_WON)
         {
            ++this.m_playerInfo.w;
            this.removeRival(this.m_enemyUID);
            _loc2_.d_info.status |= DOM_VICTIMSTATUS_WAITING;
            _loc2_.d_info.int += 1;
            _loc2_.d_info.ts = int(GlobalEngine.serverTime / 1000);
            this.m_rivalsList.push(_loc2_);
         }
         else
         {
            ++this.m_playerInfo.l;
         }
      }
      
      public function setInDominationBattle(param1:String) : void
      {
         this.m_inDominationBattle = true;
         this.m_enemyUID = param1;
      }
      
      public function exitDominationBattle() : void
      {
         this.m_inDominationBattle = false;
         this.m_enemyUID = null;
      }
      
      public function isInDominationBattle() : Boolean
      {
         return this.m_inDominationBattle;
      }
      
      public function getDominationEnemyUID() : String
      {
         return this.m_enemyUID;
      }
      
      public function set defenseForceIndex(param1:int) : void
      {
         this.m_currentDefenceForceIndex = param1;
      }
      
      public function setInDefenseForceEditMode(param1:int = 0) : void
      {
         this.m_inDefenseForceEditMode = true;
         this.m_defenseForceEditIndex = param1;
         this.m_prevDefenseForceFleet = this.getDefenseForce();
      }
      
      public function getDefenseForce() : Fleet
      {
         var _loc1_:String = FLEET_DEFENSE_PREFIX + this.m_currentDefenceForceIndex;
         return Fleet.getFleet(_loc1_);
      }
      
      public function exitDefenseForceEditMode() : void
      {
         this.m_prevDefenseForceFleet = null;
         this.m_inDefenseForceEditMode = false;
      }
      
      public function getPrevDefenseForceFleet() : Fleet
      {
         return this.m_prevDefenseForceFleet;
      }
      
      public function isInDefenseForceEditMode() : Boolean
      {
         return this.m_inDefenseForceEditMode;
      }
      
      public function getDominationModeChatHistory(param1:String) : void
      {
         var _loc2_:String = null;
         if(!this.m_loadingPopup)
         {
            _loc2_ = ZGameUtils.ZlocT("Dialogs","DominationChatRetrieval");
            this.m_loadingPopup = new ModalPopup(_loc2_,null,"assets/displays/dialogs/PU_ModalPopUp_Dominance.swf");
            PopupManager.instance.push(this.m_loadingPopup,0,false);
         }
         TransactionManager.addTransaction(new TGetDominationChat(param1),true);
      }
      
      public function onReceivedDominationChat(param1:Object, param2:String) : void
      {
         if(this.m_loadingPopup)
         {
            this.m_loadingPopup.pop();
            this.m_loadingPopup = null;
         }
         if(Boolean(param1.eChat) && Boolean(param1.pChat))
         {
            PopupManager.instance.push(new DominationModeChatHistoryScreen(param1.pChat,param1.eChat,param2),0,false);
         }
      }
      
      public function get newRevengeFights() : uint
      {
         return this.m_playerInfo.nr;
      }
      
      public function set newRevengeFights(param1:uint) : void
      {
         this.m_playerInfo.nr = param1;
         if(this.m_playerInfoInitialized)
         {
            dispatchEvent(new Event(NUM_REVENGEFIGHTS_CHANGED));
         }
      }
      
      public function get requiredLevel() : uint
      {
         return uint(ZGlobal.gameSettings.getInt("DominanceMinLevel"));
      }
      
      public function get enabled() : Boolean
      {
         return this.m_enabled;
      }
      
      public function isNewBattle(param1:String) : Boolean
      {
         var _loc2_:Object = this.getDominationInfo(param1);
         if(Boolean(_loc2_) && Boolean(_loc2_.int))
         {
            return false;
         }
         return true;
      }
      
      public function getDominationPlayer(param1:String) : IPVPPlayer
      {
         var _loc2_:IPVPPlayer = null;
         if(this.m_victimInfo[param1])
         {
            return this.m_victimInfo[param1];
         }
         _loc2_ = this.getDominationVictimFromList(param1,this.m_dominationList);
         if(_loc2_)
         {
            this.m_victimInfo[param1] = _loc2_;
            return _loc2_;
         }
         _loc2_ = this.getDominationVictimFromList(param1,this.m_rivalsList);
         if(_loc2_)
         {
            this.m_victimInfo[param1] = _loc2_;
            return _loc2_;
         }
         _loc2_ = this.getDominationVictimFromList(param1,this.m_allianceMemberList);
         if(_loc2_)
         {
            this.m_victimInfo[param1] = _loc2_;
            return _loc2_;
         }
         return null;
      }
      
      private function getDominationInfoFromList(param1:String, param2:Boolean, param3:Array) : Object
      {
         var _loc4_:Object = null;
         for each(_loc4_ in param3)
         {
            if(String(_loc4_.d_info.zid) == param1)
            {
               if(param2)
               {
                  return _loc4_;
               }
               return _loc4_.d_info;
            }
         }
         return null;
      }
      
      public function getDominationVictimFromList(param1:String, param2:Array) : IPVPPlayer
      {
         var _loc3_:Object = null;
         var _loc4_:SocialNetworkUser = null;
         for each(_loc3_ in param2)
         {
            if(_loc3_.d_info.zid == param1)
            {
               _loc4_ = new SocialNetworkUser(parseInt(param1));
               _loc4_.firstName = _loc4_.name = _loc3_.u_info.name;
               _loc4_.picture = _loc3_.u_info.image;
               _loc4_.gender = _loc3_.u_info.gender;
               return new Player(_loc4_);
            }
         }
         return null;
      }
      
      public function get firstNewVictimID() : String
      {
         if(Boolean(this.m_dominationList) && Boolean(this.m_dominationList.length))
         {
            return this.m_dominationList[0].d_info.zid;
         }
         return null;
      }
      
      public function getDominationInfo(param1:String, param2:Boolean = false) : Object
      {
         var _loc3_:Object = null;
         if(param1 == ZGlobal.player.uid)
         {
            return this.m_playerInfo;
         }
         _loc3_ = this.getDominationInfoFromList(param1,param2,this.m_dominationList);
         if(_loc3_)
         {
            return _loc3_;
         }
         _loc3_ = this.getDominationInfoFromList(param1,param2,this.m_rivalsList);
         if(_loc3_)
         {
            return _loc3_;
         }
         if(AlliancesManager.isValid() && !_loc3_)
         {
            _loc3_ = this.getDominationInfoFromList(param1,param2,this.m_allianceMemberList);
            if(_loc3_)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function handleDefenseForceIntro() : void
      {
         if(!ZGlobal.player.getSeenFlag(SEEN_DEFENSEFORCESETUP))
         {
            this.displayDefenseForceDescription();
         }
         this.updateDominationSeenFlag(SEEN_DEFENSEFORCESETUP);
         this.updateDominationSeenFlag(SEEN_FIRST_DEFENSE_SETUP);
      }
      
      public function updateDominationSeenFlag(param1:String) : void
      {
         var _loc2_:TSetSeenFlag = null;
         if(!ZGlobal.player.getSeenFlag(param1))
         {
            ZGlobal.player.setSeenFlag(param1);
            _loc2_ = new TSetSeenFlag(param1);
            TransactionManager.addTransaction(_loc2_);
         }
      }
      
      public function displayDefenseForceDescription() : void
      {
         var _loc1_:DominationModeDescriptionPopup = new DominationModeDescriptionPopup(DominationModeDescriptionPopup.TYPE_DEFENSEFORCE);
         PopupManager.instance.push(_loc1_);
      }
      
      private function removeRivalFromList(param1:String, param2:Array) : void
      {
         var _loc3_:int = 0;
         if(param2)
         {
            _loc3_ = 0;
            while(_loc3_ < param2.length)
            {
               if(param2[_loc3_].d_info.zid == param1)
               {
                  param2.splice(_loc3_,1);
               }
               else
               {
                  _loc3_++;
               }
            }
         }
      }
      
      private function removeRival(param1:String) : void
      {
         this.removeRivalFromList(param1,this.m_dominationList);
         this.removeRivalFromList(param1,this.m_rivalsList);
      }
      
      private function updateVictimInfoInList(param1:String, param2:Object, param3:Array) : void
      {
         var _loc4_:int = 0;
         if(param3)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc4_ < param3.length)
            {
               if(param3[_loc4_].d_info.zid == param1)
               {
                  param3[_loc4_].d_info = param2;
                  break;
               }
               _loc4_++;
            }
         }
      }
      
      private function updateVictimInfo(param1:String, param2:Object) : void
      {
         if(this.updateVictimInfoInList(param1,param2,this.m_dominationList))
         {
            return;
         }
         if(this.updateVictimInfoInList(param1,param2,this.m_rivalsList))
         {
            return;
         }
      }
      
      public function beginMOTDFlow() : void
      {
         this.m_motdActive = true;
         TutorialManager.instance.sendEvent(TutorialManager.UI_DOMINATION,true);
         VisitorManager.instance.addEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded,false,0,true);
      }
      
      private function cleanupMOTDFlow() : void
      {
         TutorialManager.instance.sendEvent(TutorialManager.UI_CLEAR_STENCIL);
         TutorialManager.instance.sendEvent(TutorialManager.UI_DISABLE);
         TutorialManager.instance.sendEvent(TutorialManager.UI_ENABLE);
         this.m_motdActive = false;
         dispatchEvent(new WorldEvent(DOMINATION_MOTD_DONE));
         VisitorManager.instance.removeEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded);
      }
      
      private function onWorldLoaded(param1:Event) : void
      {
         if(this.m_motdActive)
         {
            this.cleanupMOTDFlow();
         }
      }
      
      public function get iconLargeURL() : String
      {
         var _loc1_:String = ZGlobal.gameSettings.getString("DominationBattleListIcon");
         return ZGlobal.getAssetURL(_loc1_);
      }
      
      public function get shouldShowDefenseAlert() : Boolean
      {
         return this.m_playerInfo.defenseAlert;
      }
      
      public function set showDefenseAlert(param1:Boolean) : void
      {
         this.m_playerInfo.defenseAlert = param1;
         dispatchEvent(new Event(DEFENSE_ALERT_CHANGED));
      }
      
      public function postInit() : void
      {
         this.updateEnabled();
      }
      
      private function updateEnabled() : void
      {
         this.m_enabled = false;
         if(!this.m_inDominationExperiment)
         {
            return;
         }
         var _loc1_:uint = this.requiredLevel;
         if(ZGlobal.player.level < _loc1_)
         {
            return;
         }
         this.m_enabled = true;
      }
      
      public function getWinnerWinAmount(param1:Object) : int
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = int(param1.scInc);
         if(Boolean(param1.int) && Boolean(param1.ts))
         {
            _loc4_ = ZGlobal.gameSettings.getString("DominanceRevengeDuration","24h");
            _loc5_ = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc4_,0);
            _loc6_ = param1.ts + _loc5_;
            _loc7_ = GlobalEngine.serverTime / 1000;
            if(_loc7_ < _loc6_)
            {
               _loc3_ = int(param1.scBns);
            }
         }
         return _loc2_ + _loc3_;
      }
      
      public function handleTauntDisclaimer(param1:MovieClip) : void
      {
         if(ZGlobal.player.getSeenFlag(SEEN_TAUNT_DISCLAIMER))
         {
            param1.visible = false;
            return;
         }
         ZGlobal.player.setSeenFlag(SEEN_TAUNT_DISCLAIMER);
         var _loc2_:TSetSeenFlag = new TSetSeenFlag(SEEN_TAUNT_DISCLAIMER);
         TransactionManager.addTransaction(_loc2_);
         this.shutdownTauntDisclaimer();
         this.m_tauntDisclaimer = param1;
         this.m_tauntDisclaimer.visible = true;
         this.m_tauntDisclaimer.mouseEnabled = true;
         this.m_tauntDisclaimer.useHandCursor = false;
         TextFieldUtil.compactTextField(this.m_tauntDisclaimer.header_tf,ZGameUtils.ZlocT("Dialogs","DominationTauntWarningTitle"));
         TextFieldUtil.compactTextField(this.m_tauntDisclaimer.info_tf,ZGameUtils.ZlocT("Dialogs","DominationTauntWarningMsg"),{"maxLines":6});
         this.m_tauntDisclaimerOK = new ZGameButton(this.m_tauntDisclaimer.green_bt,this.onTauntDisclaimerClicked);
         this.m_tauntDisclaimerOK.text = ZGameUtils.ZlocT("Dialogs","Okay");
      }
      
      public function onTauntDisclaimerClicked(param1:MouseEvent) : void
      {
         this.shutdownTauntDisclaimer();
      }
      
      public function unregisterTauntDisclaimer() : void
      {
         this.shutdownTauntDisclaimer();
      }
      
      private function shutdownTauntDisclaimer() : void
      {
         if(this.m_tauntDisclaimer)
         {
            this.m_tauntDisclaimer.visible = true;
            this.m_tauntDisclaimer.mouseEnabled = false;
            this.m_tauntDisclaimer.useHandCursor = false;
            this.m_tauntDisclaimer.visible = false;
            this.m_tauntDisclaimer = null;
         }
         if(this.m_tauntDisclaimerOK)
         {
            this.m_tauntDisclaimerOK.dispose();
            this.m_tauntDisclaimerOK = null;
         }
      }
      
      public function get currentDominancePointsTooltip() : String
      {
         var _loc1_:int = DominationModeManager.instance.dominance;
         var _loc2_:int = DominationModeManager.instance.dominanceRequiredForNextLevel;
         var _loc3_:Object = {
            "amount":_loc1_,
            "amountNext":_loc2_
         };
         var _loc4_:String = _loc2_ ? "DominanceBarTooltipCanLevelUp" : "DominanceBarTooltip";
         return ZGameUtils.ZlocT("Dialogs",_loc4_,_loc3_);
      }
      
      public function sendHitListRequest(param1:String) : void
      {
         var _loc2_:String = "dominance_hit_list";
         ViralsManager.instance.sendFeed(_loc2_,{"hitlist_target_id":param1},null);
      }
      
      private function onTransactionComplete(param1:TransactionEvent) : void
      {
         var _loc2_:int = int(param1.transaction.rawResult.metadata.dominanceGained);
         if(Boolean(_loc2_) && !AlliancesManager.instance.allianceBattle)
         {
            this.dominance += _loc2_;
         }
      }
      
      private function saveDefaultFleet(param1:Fleet) : void
      {
         var _loc4_:Unit = null;
         var _loc2_:String = param1.type;
         var _loc3_:Array = new Array();
         for each(_loc4_ in param1.units)
         {
            _loc3_.push(_loc4_.code);
         }
         if(_loc3_.length)
         {
            this.setDefaultFleet(_loc2_,_loc3_);
         }
      }
      
      public function getDefaultFleet(param1:String) : Array
      {
         if(!this.m_defaultFleets || !this.m_defaultFleets.hasOwnProperty(param1))
         {
            return null;
         }
         var _loc2_:Array = this.m_defaultFleets[param1] as Array;
         if(!_loc2_ || !_loc2_.length)
         {
            return null;
         }
         return _loc2_;
      }
      
      public function setMysteryDooberResult(param1:String, param2:Object) : void
      {
         this.m_mysteryDooberResults = new Object();
         this.m_mysteryDooberResults = param2;
      }
      
      public function get mysteryDooberResult() : Object
      {
         return this.m_mysteryDooberResults;
      }
      
      public function get rivalsDominationRank() : Number
      {
         var _loc1_:Object = this.getDominationInfo(this.m_enemyUID);
         if(Boolean(_loc1_) && _loc1_.hasOwnProperty("dr"))
         {
            return _loc1_.dr;
         }
         return -1;
      }
      
      public function getAllianceInfo(param1:String) : Object
      {
         var _loc2_:Object = null;
         for each(_loc2_ in this.m_allianceFightList)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         for each(_loc2_ in this.m_allianceRivalList)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function updateAllianceWaveWonScore(param1:BattleHost, param2:Object = null, param3:Boolean = false) : void
      {
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param2)
         {
            _loc5_ = int(param2.attackBonus);
            if(param3)
            {
               _loc6_ = int(param2.revengeBonus);
            }
            _loc7_ = int(param2.scInc);
         }
         if(param1.battleResult == Battle.BATTLE_RESULT_WON)
         {
            ++this.m_playerInfo.w;
            this.dominance += _loc5_;
            this.dominance += _loc7_;
            if(param3)
            {
               this.dominance += _loc6_;
            }
         }
         else
         {
            ++this.m_playerInfo.l;
         }
      }
      
      public function hasDefenceForceFleet(param1:String) : Boolean
      {
         var _loc2_:String = FLEET_DEFENSE_PREFIX + "0";
         var _loc3_:Fleet = ZGlobal.player.fleets.getFleetByName(_loc2_);
         if(!_loc3_)
         {
            this.DominationBattleErrorDialog(param1,DOMINATION_ERROR_NO_DEFENSE_FORCE);
            return false;
         }
         return true;
      }
      
      public function updateAllianceList(param1:String) : void
      {
         var _loc2_:Object = this.getAllianceInfo(param1);
         this.removeAllianceRivalFromList(param1,this.m_allianceFightList);
         this.removeAllianceRivalFromList(param1,this.m_allianceRivalList);
         _loc2_.status |= DOM_VICTIMSTATUS_WAITING;
         _loc2_.int += 1;
         _loc2_.ts = int(GlobalEngine.serverTime / 1000);
         this.m_allianceRivalList.push(_loc2_);
      }
      
      private function removeAllianceRivalFromList(param1:String, param2:Array) : void
      {
         var _loc3_:int = 0;
         if(param2)
         {
            _loc3_ = 0;
            while(_loc3_ < param2.length)
            {
               if(param2[_loc3_].id == param1)
               {
                  param2.splice(_loc3_,1);
               }
               else
               {
                  _loc3_++;
               }
            }
         }
      }
      
      public function clearAllianceList() : void
      {
         this.m_allianceFightList = new Array();
      }
      
      public function clearAllianceRivalsList() : void
      {
         this.m_allianceRivalList = new Array();
      }
   }
}

