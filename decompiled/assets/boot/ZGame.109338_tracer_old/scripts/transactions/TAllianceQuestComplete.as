package transactions
{
   import Engine.Transactions.Transaction;
   import ZQuest.Init.QuestSettingsInit;
   import core.ZGlobal;
   import core.gameobjects.RewardHelper;
   import core.managers.questManager.ZGameQuest;
   import core.managers.questManager.ZGameTask;
   import displays.popups.quest.QuestCompletePopup;
   import utils.ZGameTimeUtil;
   import zlabs.managers.PopupManager;
   
   public class TAllianceQuestComplete extends Transaction
   {
      
      private var m_questName:String;
      
      public function TAllianceQuestComplete(param1:String)
      {
         super();
         this.m_questName = param1;
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.completeQuest",this.m_questName);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:QuestCompletePopup = null;
         var _loc3_:ZGameQuest = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:RewardHelper = null;
         var _loc7_:XML = null;
         var _loc8_:ZGameTask = null;
         if(Boolean(param1) && Boolean(param1.numRewards))
         {
            _loc2_ = new QuestCompletePopup(this.m_questName,null);
            _loc2_.allianceRewards = param1.numRewards;
            PopupManager.instance.push(_loc2_);
            _loc3_ = QuestSettingsInit.getInstance().getItemByName(this.m_questName) as ZGameQuest;
            _loc4_ = _loc3_.createTasks();
            _loc5_ = int(param1.numRewards);
            if(_loc4_.length > 0)
            {
               _loc8_ = _loc4_[0];
               if(ZGlobal.player.inventory[_loc8_.item] > 0)
               {
                  ZGlobal.player.removeInventoryItem(_loc8_.item,ZGlobal.player.inventory[_loc8_.item]);
               }
            }
            for each(_loc7_ in _loc3_.xml.reward)
            {
               if(_loc5_ == 0)
               {
                  break;
               }
               _loc5_--;
               if(_loc7_.@type.toString() != "mysteryItem")
               {
                  if(!(ZGameTimeUtil.instance.getDateStatus(null,_loc7_) == ZGameTimeUtil.DATE_STATUS_LATE || ZGameTimeUtil.instance.getDateStatus(null,_loc7_) == ZGameTimeUtil.DATE_STATUS_EARLY))
                  {
                     _loc6_ = new RewardHelper(_loc7_);
                     _loc6_.execute();
                  }
               }
            }
         }
      }
   }
}

