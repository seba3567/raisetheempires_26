package core.managers.survivalModeManager
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.GMBattle;
   import core.gamemode.prebattle.GMPreBattle;
   import core.gameobjects.Fleet;
   import core.gameobjects.RewardHelper;
   import core.managers.ExperimentsManager;
   import core.managers.tutorialManager.TutorialHighlighter;
   import core.ui.menuitem.OptionUIItem;
   import dispatchers.StrategicDispatcher;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.popups.genericPopup.ModalPopup;
   import displays.popups.survivalMode.SurvivalModeIntroPopup;
   import displays.popups.survivalMode.SurvivalModeRewardPopup;
   import displays.popups.survivalMode.SurvivalModeSelect;
   import displays.popups.survivalMode.SurvivalModeTransition;
   import displays.popups.survivalMode.SurvivalModeWelcomePopup;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import transactions.TLoadSurvivalMode;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class SurvivalModeManager
   {
      
      public static const LOAD_SURVIVAL_NEW:int = 1;
      
      public static const LOAD_SURVIVAL_PLAYER_SETUP:int = 2;
      
      public static const LOAD_SURVIVAL_IN_PROGRESS:int = 3;
      
      public static const BONUS_WAVE_MULTIPLE:int = 5;
      
      public static var instance:SurvivalModeManager = new SurvivalModeManager();
      
      public static var eventDispatcher:EventDispatcher = new EventDispatcher();
      
      public static const EXPERIMENT_SURVIVALMODE_MASTER:String = "empire_survivalMode_master";
      
      public static const EXPERIMENT_SURVIVALMODE_CONTINUE_COST:String = "empire_survivalMode_continue_cost";
      
      public static const EXPERIMENT_SURVIVALMODE_CARD_ACCESS:String = "empire_survivalMode_card_access";
      
      public static const EXPERIMENT_SURVIVALMODE_SET2:String = "empire_survivalMode_set2";
      
      public static const EXPERIMENT_SURVIVALMODE_RETREAT:String = "empire_survivalmoderetreat";
      
      public static const EXPERIMENT_SURVIVALMODE3_MASTER:String = "empire_survivalmode3_master";
      
      public static const VARIANT_SURVIVALMODE3_MASTER_ENABLED:int = 3;
      
      public static const EXPERIMENT_SURVIVALMODE_REFRESHREWARDS:String = "empire_survivalmode_refreshrewards";
      
      public static const VARIANT_SURVIVALMODE_REFRESHREWARDS_ENABLED:int = 1;
      
      public static const SET_NAME_1:String = "set1";
      
      public static const SET_NAME_2:String = "set2";
      
      public static const SET_NAME_3:String = "set3";
      
      public static const SET_NAME_4:String = "set3";
      
      public static const SET_NAME_5:String = "eliteSet1";
      
      public static const SET_NAME_6:String = "eliteSet2";
      
      public static const RETREAT_VARIANT_PENALTY_ON:int = 3;
      
      public static const ELITE_SURVIVAL_UNLOCK_LEVEL:int = 40;
      
      public static const SEEN_FLAG_RETREAT_NOTICE:String = "survival_retreatNotice";
      
      public static const ENTRY_POINT_BUILDING:String = "building";
      
      public static const ENTRY_POINT_CARD:String = "card";
      
      public static const ENTRY_POINT_UNIT:String = "unit";
      
      public static const ENTRY_POINT_OPTIONSMENU:String = "options";
      
      public static const EVENT_UPDATE_HQ_UI:String = "updateSurvivalModeHQUI";
      
      public static const ICON_NAME:Array = ["SurvivorMode_62_01.png","SurvivorMode_62_02.png","SurvivorMode_62_03.png","SurvivorMode_62_04.png","SurvivorMode_62_05.png","SurvivorMode_62_06.png"];
      
      public static const QUEST_ICON_NAME:Array = ["PVP01_96.png","PVP02_96.png","PVP03_96.png","PVP04_96.png","PVP05_96.png","PVP06_96.png"];
      
      public static const DEFAULT_CONTINUE_COST:int = 5;
      
      private static const TRANSITION_HOLD_DELAY_EMPTY:int = 10;
      
      private static const TRANSITION_HOLD_DELAY_REWARDS:int = 2000;
      
      private var m_survivalModeInfo:SurvivalModeInfo = null;
      
      private var m_loadingPopup:ModalPopup = null;
      
      private var m_inSurvivalBattle:Boolean = false;
      
      private var m_playerFleetName:String = "";
      
      private var m_enemyFleetName:String = "";
      
      private var m_seenIntro:Boolean = false;
      
      private var m_transitionNextRoundRewards:XML;
      
      private var m_transitionNextRoundNum:int = 0;
      
      private var m_entryPoint:String = "";
      
      public var bIsInBattle:Boolean = true;
      
      public var isEliteMode:Boolean = false;
      
      public var autoRefreshVariant:Number = ExperimentsManager.instance.getExperimentVariant("empires_survival_autorefresh");
      
      private var m_tutorial:TutorialHighlighter;
      
      private var m_timer:Timer;
      
      public function SurvivalModeManager()
      {
         super();
      }
      
      public static function get continuePurchaseCost() : int
      {
         var _loc1_:uint = uint(ExperimentsManager.instance.getExperimentVariant(EXPERIMENT_SURVIVALMODE_CONTINUE_COST));
         var _loc2_:String = ZGlobal.gameSettings.getString("SurvivalModeContinueCost","");
         var _loc3_:Array = _loc2_.split(",");
         if(_loc1_ < _loc3_.length)
         {
            return _loc3_[_loc1_];
         }
         return DEFAULT_CONTINUE_COST;
      }
      
      public function init(param1:Object) : void
      {
         var _loc2_:Number = NaN;
         if(param1.survivalMode)
         {
            this.m_survivalModeInfo = new SurvivalModeInfo(param1.survivalMode);
            if(this.autoRefreshVariant > 2)
            {
               _loc2_ = this.m_survivalModeInfo.rewardRefreshCount % 6;
               OptionUIItem.instance.updateSurvivalModeButtonUI(ICON_NAME[_loc2_]);
            }
         }
      }
      
      public function showTutorial() : void
      {
         this.removeTutorial();
         this.m_tutorial = new TutorialHighlighter();
         var _loc1_:Point = new Point(0,20);
         this.m_timer = new Timer(15000);
         var _loc2_:MovieClip = OptionUIItem.instance.survivalModeButtonMC;
         this.m_tutorial.setDisplayObject(Sprite(_loc2_),true,0,false,_loc1_);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.timerExpired);
         this.m_timer.start();
      }
      
      public function timerExpired(param1:TimerEvent) : void
      {
         this.removeTutorial();
         this.m_timer.removeEventListener(TimerEvent.TIMER,this.timerExpired);
         this.m_timer.stop();
      }
      
      public function removeTutorial() : void
      {
         if(this.m_tutorial)
         {
            this.m_tutorial.dispose();
            this.m_tutorial = null;
         }
      }
      
      public function launchSurvivalMode(param1:String) : void
      {
         var _loc3_:SurvivalModeSelect = null;
         this.m_entryPoint = param1;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVAL_ELITE) == ExperimentsManager.VARIANT_EXPERIMENT_SURVIVAL_ELITE_ON)
         {
            if(this.isInSurvivalBattle())
            {
               this.m_seenIntro = true;
            }
            if(this.m_survivalModeInfo.curSet != null && (this.m_survivalModeInfo.curSet == SET_NAME_5 || this.m_survivalModeInfo.curSet == SET_NAME_6))
            {
               PopupManager.instance.push(new SurvivalModeWelcomePopup(SET_NAME_3,this.onSetSelect,this.m_survivalModeInfo.curSet));
            }
            else if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVALMODE_ENHANCEMENTS) == ExperimentsManager.VARIANT_SURVIVALMODE_ENHANCEMENTS_ENABLED)
            {
               PopupManager.instance.push(new SurvivalModeWelcomePopup(SET_NAME_3,this.onSetSelect,SET_NAME_6));
            }
            else
            {
               PopupManager.instance.push(new SurvivalModeWelcomePopup(SET_NAME_3,this.onSetSelect,SET_NAME_5));
            }
            return;
         }
         if(ExperimentsManager.instance.getExperimentVariant(EXPERIMENT_SURVIVALMODE3_MASTER) == VARIANT_SURVIVALMODE3_MASTER_ENABLED)
         {
            this.bIsInBattle = false;
            PopupManager.instance.push(new SurvivalModeWelcomePopup(SET_NAME_3,this.onSetSelect));
            return;
         }
         var _loc2_:uint = uint(ExperimentsManager.instance.getExperimentVariant(EXPERIMENT_SURVIVALMODE_SET2));
         if(_loc2_ == 2)
         {
            this.m_seenIntro = true;
            if(param1 == ENTRY_POINT_UNIT)
            {
               this.launchSurvivalModeSetSelected();
            }
            else
            {
               _loc3_ = new SurvivalModeSelect(this.onSetSelect);
               PopupManager.instance.push(_loc3_);
            }
         }
         else
         {
            this.launchSurvivalModeSetSelected();
         }
      }
      
      public function isEliteModeUnlocked() : Boolean
      {
         if(ZGlobal.player.level > ELITE_SURVIVAL_UNLOCK_LEVEL)
         {
            return true;
         }
         return false;
      }
      
      public function get hudIconName() : String
      {
         return ICON_NAME[this.m_survivalModeInfo.rewardRefreshCount % 6];
      }
      
      public function get questIconName() : String
      {
         return "assets/game/quests/Quests_Icons_1.swf/" + QUEST_ICON_NAME[this.m_survivalModeInfo.rewardRefreshCount % 6];
      }
      
      public function get hudIconNumber() : Number
      {
         return this.m_survivalModeInfo.rewardRefreshCount % 6;
      }
      
      private function onSetSelect(param1:String) : void
      {
         this.launchSurvivalModeSetSelected(param1);
      }
      
      public function get survivalModeRewards() : Object
      {
         return this.m_survivalModeInfo.rewards;
      }
      
      public function get survivalModeRewardsChanged() : Boolean
      {
         return this.m_survivalModeInfo.rewardChanged;
      }
      
      public function pointerToHudIcon() : void
      {
      }
      
      private function launchSurvivalModeSetSelected(param1:String = "set1") : void
      {
         if(!this.m_seenIntro)
         {
            if(this.m_entryPoint != ENTRY_POINT_UNIT)
            {
               PopupManager.instance.push(new SurvivalModeIntroPopup());
            }
            this.m_seenIntro = true;
         }
         var _loc2_:String = param1;
         var _loc3_:String = null;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVAL_ELITE) == ExperimentsManager.VARIANT_EXPERIMENT_SURVIVAL_ELITE_ON && this.isEliteMode)
         {
            _loc3_ = ZGameUtils.ZlocT("Dialogs","EliteSurvivalModeLoading");
         }
         else
         {
            _loc3_ = ZGameUtils.ZlocT("Dialogs","SurvivalModeLoading");
         }
         this.loadSurvivalMode(_loc3_,_loc2_);
         StatsManager.count("survival_mode","entry",this.m_entryPoint);
      }
      
      public function loadSurvivalMode(param1:String, param2:String = null, param3:String = null, param4:Boolean = false) : void
      {
         var _loc5_:String = null;
         var _loc6_:uint = 0;
         var _loc7_:String = null;
         var _loc8_:GenericPopup1B = null;
         if(!this.m_loadingPopup && !param4)
         {
            _loc5_ = "assets/displays/dialogs/PU_ModalPopUp_BattleBlitz.swf";
            this.m_loadingPopup = new ModalPopup(param1,null,_loc5_);
            WindowManager.instance.push(this.m_loadingPopup,0,false,true);
            _loc6_ = uint(ExperimentsManager.instance.getExperimentVariant(SurvivalModeManager.EXPERIMENT_SURVIVALMODE_RETREAT));
            if(_loc6_ == SurvivalModeManager.RETREAT_VARIANT_PENALTY_ON && ZGlobal.player.getSeenFlag(SEEN_FLAG_RETREAT_NOTICE) < 3)
            {
               _loc7_ = ZGameUtils.ZlocT("Dialogs","CombatSurvivalRetreatNotice");
               _loc8_ = GenericPopup1B.NewOk(_loc7_,null);
               PopupManager.instance.push(_loc8_);
               ZGlobal.player.setSeenFlag(SEEN_FLAG_RETREAT_NOTICE);
            }
         }
         TransactionManager.addTransaction(new TLoadSurvivalMode(param2,param3,param4,this.isEliteMode),true);
      }
      
      public function loadSurvivalModeTransition(param1:String, param2:String = null, param3:String = null, param4:Boolean = false, param5:Boolean = true) : void
      {
         var _loc7_:XML = null;
         var _loc6_:Boolean = this.m_survivalModeInfo.curSet != null ? true : !param5;
         if(this.isInExperimentReward && !this.bIsInBattle)
         {
            _loc7_ = _loc6_ ? new XML(this.getSurvivalModeWaveReward(this.m_survivalModeInfo.curSet,this.m_survivalModeInfo.curWave).experimentalrewards.toXMLString()) : null;
         }
         else
         {
            _loc7_ = _loc6_ ? this.getSurvivalModeWaveReward(this.m_survivalModeInfo.curSet,this.m_survivalModeInfo.curWave) : null;
         }
         var _loc8_:Boolean = _loc7_ != null && _loc7_.reward.length() > 0;
         var _loc9_:int = this.getCurrentRound();
         this.m_transitionNextRoundRewards = this.getNextWaveRewards();
         this.m_transitionNextRoundNum = _loc9_ + 1;
         var _loc10_:int = _loc6_ && _loc8_ ? TRANSITION_HOLD_DELAY_REWARDS : TRANSITION_HOLD_DELAY_EMPTY;
         var _loc11_:Function = param5 ? this.onSurvivalModeTransition : null;
         var _loc12_:SurvivalModeTransition = new SurvivalModeTransition(_loc7_,param1,_loc11_,_loc10_);
         WindowManager.instance.push(_loc12_,0,true,false);
         TransactionManager.addTransaction(new TLoadSurvivalMode(param2,param3,param4,this.isEliteMode),true);
      }
      
      private function onSurvivalModeTransition(param1:Event) : void
      {
         var _loc2_:XML = this.m_survivalModeInfo.curSet == null ? null : this.m_transitionNextRoundRewards;
         var _loc3_:int = this.m_transitionNextRoundNum;
         var _loc4_:int = _loc2_ != null ? TRANSITION_HOLD_DELAY_REWARDS : TRANSITION_HOLD_DELAY_EMPTY;
         var _loc5_:String = ZGameUtils.ZlocT("Dialogs","SurvivalModeTransitionStartWave",{"wave":_loc3_});
         var _loc6_:SurvivalModeTransition = new SurvivalModeTransition(_loc2_,_loc5_,null,_loc4_);
         WindowManager.instance.push(_loc6_,0,true,false);
      }
      
      public function onLoadSurvivalMode(param1:Object) : void
      {
         var _loc2_:Fleet = null;
         var _loc3_:Fleet = null;
         var _loc4_:Fleet = null;
         if(Boolean(param1) && Boolean(param1.state) && Boolean(param1.storage))
         {
            this.m_survivalModeInfo = new SurvivalModeInfo(param1.storage);
            switch(param1.state)
            {
               case LOAD_SURVIVAL_NEW:
                  break;
               case LOAD_SURVIVAL_PLAYER_SETUP:
                  ZGlobal.player.fleets.addServerGeneratedFleetFromData(param1.enemyWaveFleet,param1.enemyWaveFleet.type,param1.enemyWaveFleet.uid);
                  _loc2_ = ZGlobal.player.fleets.createFleet(param1.enemyWaveFleet.type,true);
                  _loc2_.setStatus(Fleet.SURVIVAL_PLAYER);
                  _loc2_.battleTarget = param1.enemyWaveFleet.name;
                  this.setInSurvivalBattle(_loc2_.name,param1.enemyWaveFleet.name);
                  GameModeManager.instance.addGameMode(new GMBattle(_loc2_,Fleet.getFleet(param1.enemyWaveFleet.name)));
                  if(GMPreBattle.ENABLED)
                  {
                     GMPreBattle.ACTIVE = true;
                     GameModeManager.instance.addGameMode(new GMPreBattle(_loc2_,Fleet.getFleet(param1.enemyWaveFleet.name),Fleet.MAX_UNITS),false);
                  }
                  break;
               case LOAD_SURVIVAL_IN_PROGRESS:
                  if(!param1.newStart)
                  {
                     ZGlobal.player.fleets.addServerGeneratedFleetFromData(param1.enemyWaveFleet,param1.enemyWaveFleet.type,param1.enemyWaveFleet.uid);
                     ZGlobal.player.fleets.addServerGeneratedFleetFromData(param1.playerFleet,param1.playerFleet.type,param1.playerFleet.uid);
                     _loc3_ = Fleet.getFleet(param1.playerFleet.name);
                     _loc4_ = Fleet.getFleet(param1.enemyWaveFleet.name);
                     this.setInSurvivalBattle(param1.playerFleet,param1.enemyWaveFleet);
                     GameModeManager.instance.addGameMode(new GMBattle(_loc3_,_loc4_));
                     BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_RESUME));
                  }
            }
         }
         if(this.m_loadingPopup)
         {
            this.m_loadingPopup.pop();
            this.m_loadingPopup = null;
         }
      }
      
      public function startFight() : void
      {
         var _loc1_:int = this.getCurrentRound();
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","SurvivalModeTransitionStartWave",{"wave":_loc1_});
         this.loadSurvivalModeTransition(_loc2_,null,this.m_playerFleetName,false,false);
      }
      
      public function cancelFight() : void
      {
         ZGlobal.player.fleets.battleOver(this.m_playerFleetName,this.m_enemyFleetName,Battle.BATTLE_RESULT_CANCEL);
         ZGlobal.player.fleets.returnFleetName();
         this.exitSurvivalBattle();
      }
      
      public function get survivalModeFeaturedRewards() : Array
      {
         var _loc1_:Number = this.m_survivalModeInfo.rewardRefreshCount % 6;
         this.m_survivalModeInfo.rewards;
         var _loc2_:Array = new Array();
         var _loc3_:int = 0;
         while(_loc3_ < this.m_survivalModeInfo.rewards.length)
         {
            _loc2_.push(this.m_survivalModeInfo.rewards[_loc3_]);
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function completeSurvivalBattle(param1:int, param2:Dictionary, param3:Array) : Boolean
      {
         var _loc5_:Object = null;
         var _loc6_:SurvivalModeDataHelper = null;
         var _loc7_:String = null;
         var _loc4_:Boolean = true;
         if(param1 == Battle.BATTLE_RESULT_WON)
         {
            _loc4_ = false;
            this.giveRewards();
            _loc5_ = new Object();
            _loc5_.round = this.getCurrentRound();
            _loc5_.set = this.m_survivalModeInfo.curSet;
            StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.SURVIVAL_BATTLE_WON,_loc5_));
            _loc6_ = new SurvivalModeDataHelper(this.getSetInProgress());
            if((this.isInSurvivalMode3Battle || this.isInEliteSurvivalModeBattle) && this.m_survivalModeInfo.curWave == _loc6_.lastWaveIndex)
            {
               ZGlobal.player.fleets.destroyFleet(this.m_survivalModeInfo.curPlayerFleet,Battle.BATTLE_RESULT_CANCEL);
               PopupManager.instance.push(new SurvivalModeRewardPopup(this.m_survivalModeInfo.curSet,param2,param3));
               this.m_survivalModeInfo.reset();
               _loc4_ = true;
            }
            else
            {
               _loc7_ = ZGameUtils.ZlocT("Dialogs","SurvivalModeTransitionCompleteWave",{"wave":_loc5_.round});
               this.loadSurvivalModeTransition(_loc7_);
            }
         }
         SurvivalModeManager.eventDispatcher.dispatchEvent(new WorldEvent(SurvivalModeManager.EVENT_UPDATE_HQ_UI));
         return _loc4_;
      }
      
      public function setInSurvivalBattle(param1:String, param2:String) : void
      {
         this.m_inSurvivalBattle = true;
         this.m_playerFleetName = param1;
         this.m_enemyFleetName = param2;
      }
      
      public function exitSurvivalBattle(param1:Boolean = false) : void
      {
         if(param1)
         {
            this.m_survivalModeInfo.reset();
         }
         this.m_inSurvivalBattle = false;
         this.m_playerFleetName = "";
         this.m_enemyFleetName = "";
      }
      
      public function isInSurvivalBattle() : Boolean
      {
         return this.m_inSurvivalBattle;
      }
      
      public function getCurrentRound() : int
      {
         return int(this.m_survivalModeInfo.curWave + this.m_survivalModeInfo.curLoop * this.getMaxWave(this.m_survivalModeInfo.curSet));
      }
      
      public function getMaxWave(param1:String) : int
      {
         var _loc3_:XMLList = null;
         var _loc4_:int = 0;
         var _loc5_:XML = null;
         var _loc6_:XMLList = null;
         var _loc2_:XML = ZGlobal.gameSettings.getXML();
         if(_loc2_)
         {
            if(_loc2_.survivalModeSets != undefined)
            {
               _loc3_ = _loc2_.survivalModeSets..set;
               _loc4_ = 0;
               while(_loc4_ < _loc3_.length())
               {
                  _loc5_ = _loc3_[_loc4_];
                  if(_loc5_.@name != undefined && _loc5_.@name == param1)
                  {
                     if(ExperimentsManager.instance.experimentGateEnabled(_loc5_.@experiment,_loc5_.@variants))
                     {
                        _loc6_ = _loc5_.wave;
                        return _loc6_.length();
                     }
                  }
                  _loc4_++;
               }
            }
         }
         return 1;
      }
      
      public function getXMLForSet(param1:String) : XML
      {
         var _loc3_:XML = null;
         var _loc2_:XML = ZGlobal.gameSettings.getXML();
         if(Boolean(_loc2_) && _loc2_.survivalModeSets != undefined)
         {
            for each(_loc3_ in _loc2_.survivalModeSets.set)
            {
               if(_loc3_.@name != undefined && _loc3_.@name == param1)
               {
                  if(ExperimentsManager.instance.experimentGateEnabled(_loc3_.@experiment,_loc3_.@variants))
                  {
                     return _loc3_;
                  }
               }
            }
         }
         return null;
      }
      
      public function giveRewards() : void
      {
         var _loc1_:XML = this.getSurvivalModeWaveReward(this.m_survivalModeInfo.curSet,this.m_survivalModeInfo.curWave);
         if(_loc1_)
         {
            if(ExperimentsManager.instance.experimentGateEnabled(_loc1_.@experiment,_loc1_.@variants))
            {
               if(_loc1_.experimentalrewards != undefined)
               {
                  this.getRewards(true,_loc1_);
               }
            }
            else if(_loc1_.reward != undefined)
            {
               this.getRewards(false,_loc1_);
            }
         }
      }
      
      private function getRewardsFromZRT(param1:int) : void
      {
         var _loc2_:Object = this.m_survivalModeInfo.rewards;
         var _loc3_:int = param1 == 20 ? 0 : (param1 == 40 ? 1 : 2);
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            ZGlobal.player.addToInventory(_loc2_[_loc3_][_loc4_]);
            _loc4_++;
         }
      }
      
      private function getRewards(param1:Boolean, param2:XML) : void
      {
         var _loc4_:XML = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:RewardHelper = null;
         var _loc3_:XMLList = param1 ? param2.experimentalrewards.reward : param2.reward;
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_.@rewardFeature.toString() == "true" && this.autoRefreshVariant > 2 && this.m_survivalModeInfo.curWave % 20 == 0 && !this.isInEliteSurvivalModeBattle)
            {
               _loc5_ = this.m_survivalModeInfo.curWave;
               _loc6_ = _loc5_ == 20 ? 0 : (_loc5_ == 40 ? 1 : 2);
               ZGlobal.player.addToInventory(this.m_survivalModeInfo.rewards[_loc6_]);
            }
            else
            {
               _loc7_ = new RewardHelper(_loc4_);
               _loc7_.execute();
            }
         }
      }
      
      public function getNextWaveRewards() : XML
      {
         var _loc1_:int = this.m_survivalModeInfo.curWave + 1;
         if(_loc1_ > this.getMaxWave(this.m_survivalModeInfo.curSet))
         {
            _loc1_ = 1;
         }
         return this.getSurvivalModeWaveReward(this.m_survivalModeInfo.curSet,_loc1_);
      }
      
      public function getNextBonusWaveRewards() : Object
      {
         var _loc1_:Object = new Object();
         var _loc2_:int = this.m_survivalModeInfo.curWave;
         _loc2_ += BONUS_WAVE_MULTIPLE - 1;
         var _loc3_:int = _loc2_ - _loc2_ % BONUS_WAVE_MULTIPLE;
         var _loc4_:int = this.getCurrentRound();
         _loc1_.round = _loc4_ + (_loc3_ - this.m_survivalModeInfo.curWave);
         _loc1_.xml = this.isInExperimentReward && !this.bIsInBattle ? new XML(this.getSurvivalModeWaveReward(this.m_survivalModeInfo.curSet,_loc3_).experimentalrewards.toXMLString()) : this.getSurvivalModeWaveReward(this.m_survivalModeInfo.curSet,_loc3_);
         return _loc1_;
      }
      
      public function getSurvivalModeWaveReward(param1:String, param2:int) : XML
      {
         var _loc4_:XMLList = null;
         var _loc5_:int = 0;
         var _loc6_:XML = null;
         var _loc7_:XMLList = null;
         var _loc8_:int = 0;
         var _loc9_:XML = null;
         var _loc3_:XML = ZGlobal.gameSettings.getXML();
         if(_loc3_)
         {
            if(_loc3_.survivalModeSets != undefined)
            {
               _loc4_ = _loc3_.survivalModeSets..set;
               _loc5_ = 0;
               for(; _loc5_ < _loc4_.length(); _loc5_++)
               {
                  _loc6_ = _loc4_[_loc5_];
                  if(_loc6_.@name != undefined && _loc6_.@name == param1)
                  {
                     if(ExperimentsManager.instance.experimentGateEnabled(_loc6_.@experiment,_loc6_.@variants))
                     {
                        _loc7_ = _loc6_.wave;
                        _loc8_ = 0;
                        while(_loc8_ < _loc7_.length())
                        {
                           _loc9_ = _loc7_[_loc8_];
                           if(_loc9_.@index == param2)
                           {
                              return _loc9_;
                           }
                           _loc8_++;
                        }
                     }
                  }
               }
            }
         }
         return null;
      }
      
      public function getCurrentSet() : String
      {
         return this.m_survivalModeInfo.curSet;
      }
      
      public function getCurrentWave() : int
      {
         return this.m_survivalModeInfo.curWave;
      }
      
      public function getSetInProgress() : String
      {
         var _loc1_:String = null;
         if(Boolean(this.m_survivalModeInfo) && Boolean(this.m_survivalModeInfo.curPlayerFleet != null) && this.m_survivalModeInfo.curPlayerFleet != "")
         {
            return this.m_survivalModeInfo.curSet;
         }
         return _loc1_;
      }
      
      public function get isInBattle() : Boolean
      {
         return this.m_survivalModeInfo.isInBattle;
      }
      
      public function get isInSurvivalMode3Battle() : Boolean
      {
         return ExperimentsManager.instance.getExperimentVariant(EXPERIMENT_SURVIVALMODE3_MASTER) == VARIANT_SURVIVALMODE3_MASTER_ENABLED && (this.isInBattle && this.getSetInProgress() == SET_NAME_3);
      }
      
      public function get isInEliteSurvivalModeBattle() : Boolean
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVALMODE_ENHANCEMENTS) == ExperimentsManager.VARIANT_SURVIVALMODE_ENHANCEMENTS_ENABLED)
         {
            return ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVAL_ELITE) == ExperimentsManager.VARIANT_EXPERIMENT_SURVIVAL_ELITE_ON && (this.isInBattle && this.getSetInProgress() == SET_NAME_6);
         }
         return ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVAL_ELITE) == ExperimentsManager.VARIANT_EXPERIMENT_SURVIVAL_ELITE_ON && (this.isInBattle && this.getSetInProgress() == SET_NAME_5);
      }
      
      public function get isInExperimentReward() : Boolean
      {
         return ExperimentsManager.instance.getExperimentVariant(EXPERIMENT_SURVIVALMODE_REFRESHREWARDS) >= VARIANT_SURVIVALMODE_REFRESHREWARDS_ENABLED;
      }
      
      public function get enabled() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SURVIVALMODE_MASTER);
         if(_loc1_ != ExperimentsManager.VARIANT_SURVIVALMODE_MASTER)
         {
            return false;
         }
         var _loc2_:int = ZGlobal.gameSettings.getInt("SurvivalModeMinLevel",15);
         if(ZGlobal.player.level < _loc2_)
         {
            return false;
         }
         return true;
      }
   }
}

