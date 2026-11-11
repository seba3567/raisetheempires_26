package core.managers.rewardPickupManager
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.RewardHelper;
   import core.ui.feedbacktext.ScrapFeedbackText;
   
   public class ScrapRewardPickup extends RewardPickup
   {
      
      private static const NAME:String = "scrap";
      
      private var m_emphasizeAmmoDoober:Boolean = false;
      
      public function ScrapRewardPickup(param1:int, param2:Boolean)
      {
         m_feedbackText = new ScrapFeedbackText(param1);
         super(param1,NAME,param2);
      }
      
      override protected function doReward(param1:int) : void
      {
         super.doReward(param1);
         var _loc2_:String = ZGlobal.gameSettings.getString("combaScrapType","SC01");
         var _loc3_:RewardHelper = new RewardHelper(null);
         _loc3_.init("item",1,_loc2_);
         if(ZGlobal.player.canAddItemToInventory(GameItem(ZGlobal.gameSettings.getItemByCode("SC01",GameItem))))
         {
            _loc3_.execute();
         }
      }
      
      override protected function getImageUrl(param1:int) : String
      {
         return ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/doober_scrap_01_60.png");
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
         var _loc1_:String = null;
         if(this.m_emphasizeAmmoDoober)
         {
            _loc1_ = "energyGain";
         }
         else
         {
            _loc1_ = "xpPickup";
         }
         return _loc1_;
      }
      
      override protected function get particleCount() : int
      {
         var _loc1_:int = 0;
         if(this.m_emphasizeAmmoDoober)
         {
            _loc1_ = 7;
         }
         else
         {
            _loc1_ = 2;
         }
         return _loc1_;
      }
      
      override protected function get alwaysCreateParticlesOnLootPickup() : Boolean
      {
         var _loc1_:Boolean = false;
         if(this.m_emphasizeAmmoDoober)
         {
            _loc1_ = true;
         }
         else
         {
            _loc1_ = false;
         }
         return _loc1_;
      }
   }
}

