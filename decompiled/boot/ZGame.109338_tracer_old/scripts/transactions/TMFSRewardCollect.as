package transactions
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.RewardHelper;
   import core.ui.PlayerFeedbackManager;
   import utils.ZGameUtils;
   
   public class TMFSRewardCollect extends TZGameTransaction
   {
      
      public function TMFSRewardCollect()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("MFSService.collectReward");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:XML = null;
         var _loc3_:RewardHelper = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         super.onComplete(param1);
         if(Boolean(param1) && Boolean(param1.claimed))
         {
            _loc2_ = <reward/>;
            _loc2_.@type = param1.Rtype;
            _loc2_.@count = param1.Rcount;
            _loc2_.@item = param1.Ritem;
            _loc3_ = new RewardHelper(_loc2_);
            _loc3_.execute();
            _loc4_ = "MFS_Feedback_Plural";
            if(param1.Rcount == 1)
            {
               _loc4_ = "MFS_Feedback_Singular";
            }
            _loc5_ = ZGameUtils.ZlocT("Dialogs",_loc4_,{
               "requests":param1.Rpoints,
               "count":param1.Rcount,
               "reward":(ZGlobal.gameSettings.getItemByCode(param1.Ritem,GameItem) as GameItem).getFriendlyName(GameItem.MENU_FRIENDLYNAME)
            });
            PlayerFeedbackManager.instance.displayToaster(_loc5_);
         }
      }
   }
}

