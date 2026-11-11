package transactions
{
   import core.ZGlobal;
   import core.managers.QuestBuildableManager;
   import displays.popups.QuestBuildableRewardPopup;
   import zlabs.entity.IEntity;
   import zlabs.managers.PopupManager;
   
   public class TQuestBuildable extends TWorldState
   {
      
      public static const GIVE_STATUE:int = 1;
      
      private var m_type:int = 0;
      
      public function TQuestBuildable(param1:IEntity, param2:int)
      {
         super(param1);
         this.m_type = param2;
      }
      
      override public function perform() : void
      {
         switch(this.m_type)
         {
            case GIVE_STATUE:
               signedWorldAction("GiveStatue");
               break;
            default:
               signedWorldAction("DummyTransaction");
         }
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:String = null;
         super.onComplete(param1);
         if(param1.item)
         {
            for(_loc2_ in param1.item)
            {
               if(_loc2_ == QuestBuildableManager.GOLDEN_STATUE && param1.item[_loc2_] > 0)
               {
                  ZGlobal.player.addToInventory(_loc2_,param1.item[_loc2_],true);
                  PopupManager.instance.push(new QuestBuildableRewardPopup(QuestBuildableManager.GOLDEN_STATUE));
               }
            }
         }
      }
   }
}

