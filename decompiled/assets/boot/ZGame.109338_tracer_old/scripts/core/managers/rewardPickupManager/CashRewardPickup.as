package core.managers.rewardPickupManager
{
   import core.ZGlobal;
   import core.ui.feedbacktext.CashFeedbackText;
   
   public class CashRewardPickup extends RewardPickup
   {
      
      public function CashRewardPickup(param1:int)
      {
         m_feedbackText = new CashFeedbackText(param1);
         super(param1,"cash",false);
      }
      
      override protected function doReward(param1:int) : void
      {
         super.doReward(param1);
         ZGlobal.player.cash += param1;
      }
      
      override protected function getImageUrl(param1:int) : String
      {
         return ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/EmpirePoints_60.png");
      }
      
      override protected function get uiName() : String
      {
         return "cash";
      }
      
      override public function get pickupName() : String
      {
         return "cash";
      }
      
      override protected function get soundEvent() : String
      {
         return "CashPickup";
      }
   }
}

