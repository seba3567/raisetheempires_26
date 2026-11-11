package core.managers.rewardPickupManager
{
   import core.ZGlobal;
   import core.ui.feedbacktext.SocialExperienceGoodFeedbackText;
   
   public class SocialXpGoodRewardPickup extends RewardPickup
   {
      
      public static const NAME:String = "socialXpGood";
      
      public function SocialXpGoodRewardPickup(param1:int, param2:Boolean)
      {
         m_feedbackText = new SocialExperienceGoodFeedbackText(param1);
         super(param1,NAME,param2);
      }
      
      override protected function doReward(param1:int) : void
      {
         super.doReward(param1);
         ZGlobal.player.socialXpGood += param1;
      }
      
      override protected function getImageUrl(param1:int) : String
      {
         return ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/RedHeart_01_60.png");
      }
      
      override protected function get uiName() : String
      {
         return NAME;
      }
      
      override public function get pickupName() : String
      {
         return NAME;
      }
      
      override protected function get soundEvent() : String
      {
         return "xpPickup";
      }
   }
}

