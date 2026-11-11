package core.managers
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.GMBattle;
   import core.gamemode.prebattle.GMPreBattle;
   import core.gameobjects.Fleet;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   import core.managers.survivalModeManager.SurvivalModeInfo;
   import displays.popups.battlewon.BattleQuestWonPopup;
   import displays.popups.genericPopup.ModalPopup;
   import displays.popups.survivalMode.SurvivalModeTransition;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import transactions.TLoadQuestSurvivalMode;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class QuestSurvivalModeManager
   {
      
      public static var instance:QuestSurvivalModeManager = new QuestSurvivalModeManager();
      
      public static const LOAD_SURVIVAL_NEW:int = 1;
      
      public static const LOAD_SURVIVAL_PLAYER_SETUP:int = 2;
      
      public static const LOAD_SURVIVAL_IN_PROGRESS:int = 3;
      
      private static const TRANSITION_HOLD_DELAY_EMPTY:int = 10;
      
      private var m_inQuestSurvivalBattle:Boolean = false;
      
      private var m_playerFleetName:String = "";
      
      private var m_enemyFleetName:String = "";
      
      private var m_survivalModeInfo:SurvivalModeInfo = null;
      
      private var m_questData:Object = new Object();
      
      private var m_loadingScreenPopup:ModalPopup;
      
      public function QuestSurvivalModeManager()
      {
         super();
      }
      
      public function setInSurvivalBattle(param1:String, param2:String) : void
      {
         this.m_inQuestSurvivalBattle = true;
         this.m_playerFleetName = param1;
         this.m_enemyFleetName = param2;
      }
      
      public function exitSurvivalBattle(param1:Boolean = false) : void
      {
         this.m_inQuestSurvivalBattle = false;
         this.m_playerFleetName = "";
         this.m_enemyFleetName = "";
      }
      
      public function cancelFight() : void
      {
         ZGlobal.player.fleets.battleOver(this.m_playerFleetName,this.m_enemyFleetName,Battle.BATTLE_RESULT_CANCEL);
         ZGlobal.player.fleets.returnFleetName();
         this.exitSurvivalBattle();
      }
      
      public function isInQuestSurvivalBattle() : Boolean
      {
         return this.m_inQuestSurvivalBattle;
      }
      
      public function createQuestSurvivalBattle(param1:Object, param2:String = null, param3:String = null, param4:ZGameTask = null) : void
      {
         this.m_questData = param1;
         this.m_loadingScreenPopup = new ModalPopup(ZGameUtils.ZlocT("Dialogs","SurvivalModeLoading"));
         PopupManager.instance.push(this.m_loadingScreenPopup);
         TransactionManager.addTransaction(new TLoadQuestSurvivalMode(param1),true);
      }
      
      public function get questData() : Object
      {
         return this.m_questData;
      }
      
      public function getVillain() : String
      {
         var _loc1_:Array = null;
         var _loc2_:ZGameTask = null;
         if(!this.m_questData.villain)
         {
            _loc1_ = (QuestManager.getInstance() as ZGameQuestManager).getQuestTasks(this.m_questData.id);
            _loc2_ = _loc1_[this.m_questData.index];
            this.m_questData.villain = _loc2_.villain;
            if(!this.m_questData.villain)
            {
               this.m_questData.villain = _loc2_.pveVillain;
            }
         }
         return this.m_questData.villain;
      }
      
      public function completeSurvivalBattle(param1:int, param2:Dictionary, param3:Array) : Boolean
      {
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:Boolean = false;
         var _loc8_:String = null;
         var _loc4_:Boolean = true;
         if(param1 == Battle.BATTLE_RESULT_WON)
         {
            _loc4_ = false;
            _loc5_ = new Object();
            _loc5_.round = this.getCurrentRound();
            _loc5_.set = this.m_survivalModeInfo.curSet;
            _loc6_ = ZGlobal.gameSettings.getMaxWaveForSet(_loc5_.set);
            _loc7_ = _loc6_ == _loc5_.round;
            if(_loc7_)
            {
               ZGlobal.player.fleets.destroyFleet(this.m_survivalModeInfo.curPlayerFleet,Battle.BATTLE_RESULT_CANCEL);
               this.getVillain();
               PopupManager.instance.push(new BattleQuestWonPopup(this.m_questData,this.m_enemyFleetName,param3,param2,this.popupClosed));
               this.m_survivalModeInfo.reset();
               _loc4_ = true;
            }
            else
            {
               _loc8_ = ZGameUtils.ZlocT("Dialogs","SurvivalModeTransitionCompleteWave",{"wave":_loc5_.round});
               this.loadSurvivalModeTransition(_loc8_);
            }
         }
         return _loc4_;
      }
      
      private function popupClosed(param1:GenericPopupEvent) : void
      {
      }
      
      public function onLoadQuestSurvivalMode(param1:Object) : void
      {
         var _loc2_:Fleet = null;
         var _loc3_:Fleet = null;
         var _loc4_:Fleet = null;
         this.m_loadingScreenPopup.pop();
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
                  GameModeManager.instance.addGameMode(new GMBattle(_loc2_,Fleet.getFleet(param1.enemyWaveFleet.name),false,false,this.m_questData));
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
                     GameModeManager.instance.addGameMode(new GMBattle(_loc3_,_loc4_,false,false,this.m_questData));
                     BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_RESUME));
                  }
            }
         }
      }
      
      public function startFight() : void
      {
         var _loc1_:int = this.getCurrentRound();
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","SurvivalModeTransitionStartWave",{"wave":_loc1_});
         this.loadSurvivalModeTransition(_loc2_,null,this.m_playerFleetName,false,false);
      }
      
      public function loadSurvivalModeTransition(param1:String, param2:String = null, param3:String = null, param4:Boolean = false, param5:Boolean = true) : void
      {
         var _loc10_:XML = null;
         var _loc6_:Boolean = false;
         var _loc7_:int = this.getCurrentRound();
         var _loc8_:int = TRANSITION_HOLD_DELAY_EMPTY;
         var _loc9_:Function = param5 ? this.onSurvivalModeTransition : null;
         var _loc11_:SurvivalModeTransition = new SurvivalModeTransition(_loc10_,param1,_loc9_,_loc8_);
         WindowManager.instance.push(_loc11_,0,true,false);
         TransactionManager.addTransaction(new TLoadQuestSurvivalMode(this.m_questData,param2,param3),true);
      }
      
      private function onSurvivalModeTransition(param1:Event) : void
      {
         var _loc2_:XML = null;
         var _loc3_:int = this.getCurrentRound() + 1;
         var _loc4_:int = TRANSITION_HOLD_DELAY_EMPTY;
         var _loc5_:String = ZGameUtils.ZlocT("Dialogs","SurvivalModeTransitionStartWave",{"wave":_loc3_});
         var _loc6_:SurvivalModeTransition = new SurvivalModeTransition(_loc2_,_loc5_,null,_loc4_);
         WindowManager.instance.push(_loc6_,0,true,false);
      }
      
      public function getCurrentRound() : int
      {
         return this.m_survivalModeInfo.curWave;
      }
      
      public function getMaxWaves() : int
      {
         var _loc1_:String = this.m_survivalModeInfo.curSet;
         return ZGlobal.gameSettings.getMaxWaveForSet(_loc1_);
      }
   }
}

