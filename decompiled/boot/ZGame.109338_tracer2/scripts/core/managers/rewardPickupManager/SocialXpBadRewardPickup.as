package core.managers.rewardPickupManager
{
   import core.ZGlobal;
   import core.ui.feedbacktext.SocialExperienceBadFeedbackText;
   
   public class SocialXpBadRewardPickup extends RewardPickup
   {
      
      public static const NAME:String = "socialXpBad";
      
      public function SocialXpBadRewardPickup(param1:int, param2:Boolean)
      {
         m_feedbackText = new SocialExperienceBadFeedbackText(param1);
         super(param1,NAME,param2);
      }
      
      override protected function doReward(param1:int) : void
      {
         super.doReward(param1);
         ZGlobal.player.socialXpBad += param1;
      }
      
      override protected function getImageUrl(param1:int) : String
      {
         return ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/BlackHeart_01_60.png");
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

