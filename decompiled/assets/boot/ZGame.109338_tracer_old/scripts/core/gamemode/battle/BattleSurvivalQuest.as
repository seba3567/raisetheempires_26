package core.gamemode.battle
{
   import ZQuest.Managers.QuestManager;
   import core.gameobjects.Fleet;
   import core.managers.QuestSurvivalModeManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.managers.questManager.ZGameTask;
   import displays.popups.battlelost.BattleDefeatedPopup;
   import displays.popups.battlelost.BattleQuestLostPopup;
   import displays.popups.battlewon.BattleQuestWonPopup;
   import flash.utils.Dictionary;
   import zlabs.managers.PopupManager;
   
   public class BattleSurvivalQuest extends BattleHost
   {
      
      private var m_questData:Object = null;
      
      public function BattleSurvivalQuest(param1:Fleet, param2:Fleet, param3:Object)
      {
         this.m_questData = param3;
         super(param1,param2);
      }
      
      override public function get isQuestSurvival() : Boolean
      {
         return true;
      }
      
      public function get questData() : Object
      {
         return QuestSurvivalModeManager.instance.questData;
      }
      
      public function get villain() : String
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
      
      override public function showWonPopup(param1:Array, param2:Array, param3:Dictionary, param4:Function) : void
      {
         PopupManager.instance.push(new BattleQuestWonPopup(this.m_questData,m_enemyFleetName,param2,param3,param4));
      }
      
      override public function showLosePopup(param1:Array, param2:Dictionary, param3:Function) : void
      {
         if(showWinLosePopup)
         {
            PopupManager.instance.push(new BattleQuestLostPopup(this.villain,param1,param2,param3));
         }
         else
         {
            PopupManager.instance.push(new BattleDefeatedPopup(param1,param2,param3));
         }
      }
   }
}

