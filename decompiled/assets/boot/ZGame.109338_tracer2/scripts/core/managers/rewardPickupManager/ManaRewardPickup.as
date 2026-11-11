package core.managers.rewardPickupManager
{
   import core.ZGlobal;
   import core.ui.feedbacktext.ManaFeedbackText;
   
   public class ManaRewardPickup extends RewardPickup
   {
      
      private static const NAME:String = "mana";
      
      public function ManaRewardPickup(param1:int, param2:Boolean)
      {
         m_feedbackText = new ManaFeedbackText(param1);
         super(param1,NAME,param2);
      }
      
      override protected function doReward(param1:int) : void
      {
         super.doReward(param1);
         ZGlobal.player.mana.give(param1);
      }
      
      override protected function getImageUrl(param1:int) : String
      {
         return ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/ElementZ_01_60.png");
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

