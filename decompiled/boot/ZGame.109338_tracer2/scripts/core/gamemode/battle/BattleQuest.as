package core.gamemode.battle
{
   import ZQuest.Init.QuestSettingsInit;
   import ZQuest.Managers.QuestManager;
   import core.ZGlobal;
   import core.gameobjects.Fleet;
   import core.gameobjects.VillainItem;
   import core.managers.questManager.FightItemTask;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   import core.player.questTrees.QuestTree;
   import displays.popups.GoldenStatuePopUp1;
   import displays.popups.battlelost.BattleDefeatedPopup;
   import displays.popups.battlelost.BattleQuestLostPopup;
   import displays.popups.battlewon.BattleQuestWonPopup;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import zlabs.core.PBGroup;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class BattleQuest extends BattleHost
   {
      
      public static const TITAN_KILLS:String = "titanKills";
      
      public static const TITAN_COMPLETE:String = "titanComplete";
      
      private static var m_rematchTarget:String = null;
      
      private var m_questData:Object = null;
      
      private var m_showWinLosePopup:Boolean = false;
      
      private var m_storeWinInSeenFlag:Boolean = false;
      
      public function BattleQuest(param1:Fleet, param2:Fleet, param3:Object)
      {
         var _loc5_:Array = null;
         var _loc6_:ZGameTask = null;
         var _loc7_:VillainItem = null;
         this.m_questData = param3;
         if(!this.m_questData.villain)
         {
            _loc5_ = (QuestManager.getInstance() as ZGameQuestManager).getQuestTasks(this.m_questData.id);
            _loc6_ = _loc5_[this.m_questData.index];
            this.m_questData.villain = _loc6_.villain;
            if(!this.m_questData.villain)
            {
               this.m_questData.villain = _loc6_.pveVillain;
            }
         }
         if(this.m_questData.villain)
         {
            _loc7_ = ZGlobal.gameSettings.getItemByCode(this.m_questData.villain,VillainItem) as VillainItem;
            if(_loc7_.megaUnit())
            {
               this.m_storeWinInSeenFlag = true;
            }
         }
         var _loc4_:ZGameQuest = QuestSettingsInit.getInstance().getItemByName(param3.id ? param3.id : param3.quest) as ZGameQuest;
         if(_loc4_.tasks[param3.index].battleBackground)
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_BACKGROUND_CHANGE,{"battleBackgroundUrl":_loc4_.tasks[param3.index].battleBackground}));
         }
         super(param1,param2);
      }
      
      public static function get rematchTarget() : String
      {
         return m_rematchTarget;
      }
      
      public static function set rematchTarget(param1:String) : void
      {
         m_rematchTarget = param1;
      }
      
      override public function get isQuest() : Boolean
      {
         return true;
      }
      
      override public function get isQuestTreeBattle() : Boolean
      {
         var _loc1_:String = ZGlobal.player.questTrees.getQuestTreeNameForQuest(this.m_questData.quest);
         return _loc1_ != null;
      }
      
      override public function get getQuestId() : String
      {
         return this.m_questData.id;
      }
      
      override protected function onStartBattle(param1:Event) : void
      {
         super.onStartBattle(param1);
         var _loc2_:Fleet = Fleet.getFleet(m_playerFleetName);
         this.m_showWinLosePopup = !_loc2_.hasStatus(Fleet.FREE) || !(QuestManager.getInstance() as ZGameQuestManager).fightTaskWinPopupUsesFirstVictory(this.m_questData.quest);
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.QUEST_BATTLE_STARTED,m_enemyFleetName));
      }
      
      override protected function removeFleets() : void
      {
         var _loc2_:Fleet = null;
         var _loc1_:String = m_enemyFleetName;
         if(m_battleResult == BATTLE_RESULT_RETREAT || m_battleResult == BATTLE_RESULT_LOST || m_battleResult == BATTLE_RESULT_CANCEL)
         {
            _loc2_ = Fleet.getFleet(_loc1_);
            _loc2_.battleTarget = null;
            if(m_battleResult == BATTLE_RESULT_RETREAT)
            {
               _loc2_.restore();
            }
            else if(m_battleResult == BATTLE_RESULT_LOST)
            {
               _loc2_.removeConsumables();
            }
            _loc1_ = null;
            if(this.m_questData.id != GoldenStatuePopUp1.QUEST_ID && this.m_questData.id != m_enemyFleetName)
            {
               BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.PLAYER_FLEET_DESTROYED,m_enemyFleetName));
            }
         }
         else if(this.m_storeWinInSeenFlag && m_battleResult == BATTLE_RESULT_WON)
         {
            ZGlobal.player.setSeenFlag(TITAN_KILLS);
         }
         ZGlobal.player.fleets.battleOver(m_playerFleetName,_loc1_,m_battleResult);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         var _loc1_:String = ZGlobal.player.questTrees.getQuestTreeNameForQuest(this.m_questData.id);
         if(_loc1_)
         {
            QuestTree.showScreen(_loc1_,"other");
         }
         this.m_questData = null;
      }
      
      override public function rematch() : void
      {
         m_rematchTarget = m_enemyFleetName;
      }
      
      override public function get showWinLosePopup() : Boolean
      {
         return this.m_showWinLosePopup;
      }
      
      override public function showWonPopup(param1:Array, param2:Array, param3:Dictionary, param4:Function) : void
      {
         PopupManager.instance.push(new BattleQuestWonPopup(this.m_questData,m_enemyFleetName,param2,param3,param4));
      }
      
      override public function showLosePopup(param1:Array, param2:Dictionary, param3:Function) : void
      {
         if(this.showWinLosePopup)
         {
            PopupManager.instance.push(new BattleQuestLostPopup(this.m_questData.villain,param1,param2,param3));
         }
         else
         {
            PopupManager.instance.push(new BattleDefeatedPopup(param1,param2,param3));
         }
      }
      
      override protected function isPVEChallenge() : Boolean
      {
         return Boolean(this.m_questData.pve) || Boolean(super.isPVEChallenge());
      }
      
      override protected function killUnit(param1:BattleObject, param2:BattleObject, param3:Object, param4:Boolean) : void
      {
         var _loc5_:PBGroup = null;
         var _loc6_:int = 0;
         var _loc7_:IEntity = null;
         var _loc8_:GameDataComponent = null;
         if(param2.fleet.hasStatus(Fleet.QUEST))
         {
            _loc5_ = ZGlobal.game.getObjectGroup(param2.fleet.name);
            _loc6_ = 0;
            while(_loc6_ < _loc5_.length)
            {
               _loc7_ = _loc5_.getItem(_loc6_) as IEntity;
               _loc8_ = GameDataComponent.getGameDataComponent(_loc7_);
               if(_loc8_.gameData.code == param2.unitItem.code)
               {
                  _loc7_.destroy();
                  break;
               }
               _loc6_++;
            }
         }
         super.killUnit(param1,param2,param3,param4);
      }
      
      override protected function checkForRetreat(param1:String) : Boolean
      {
         var _loc4_:FightItemTask = null;
         var _loc5_:Number = NaN;
         var _loc6_:Fleet = null;
         var _loc7_:Number = NaN;
         var _loc2_:Array = (QuestManager.getInstance() as ZGameQuestManager).getQuestTasks(this.m_questData.id);
         var _loc3_:ZGameTask = _loc2_[this.m_questData.index];
         if(_loc3_ is FightItemTask)
         {
            _loc4_ = _loc3_ as FightItemTask;
            _loc5_ = _loc4_.percentageRetreat;
            if(_loc5_ != 0)
            {
               if(_loc4_.fleetName == param1)
               {
                  _loc6_ = Fleet.getFleet(param1);
                  _loc7_ = _loc6_.getStrengthPercentage();
                  if(_loc7_ <= _loc5_)
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
   }
}

