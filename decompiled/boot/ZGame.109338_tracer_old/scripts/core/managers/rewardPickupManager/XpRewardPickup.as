package core.managers.rewardPickupManager
{
   import core.ZGlobal;
   import core.ui.feedbacktext.ExperienceFeedbackText;
   
   public class XpRewardPickup extends RewardPickup
   {
      
      public function XpRewardPickup(param1:int, param2:Boolean)
      {
         m_feedbackText = new ExperienceFeedbackText(param1);
         super(param1,"xp",param2);
      }
      
      override protected function doReward(param1:int) : void
      {
         super.doReward(param1);
         ZGlobal.player.xp += param1;
      }
      
      override protected function getImageUrl(param1:int) : String
      {
         if(param1 < 3)
         {
            return ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/StarStack_01_60.png");
         }
         if(param1 < 10)
         {
            return ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/StarStack_02_60.png");
         }
         return ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/StarStack_03_60.png");
      }
      
      override protected function get uiName() : String
      {
         return "xp";
      }
      
      override public function get pickupName() : String
      {
         return "xp";
      }
      
      override protected function get soundEvent() : String
      {
         return "xpPickup";
      }
   }
}

