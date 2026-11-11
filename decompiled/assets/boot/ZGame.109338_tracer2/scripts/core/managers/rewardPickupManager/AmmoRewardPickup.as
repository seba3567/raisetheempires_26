package core.managers.rewardPickupManager
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.ui.feedbacktext.AmmoFeedbackText;
   
   public class AmmoRewardPickup extends RewardPickup
   {
      
      private static const NAME:String = "ammo";
      
      private var m_emphasizeAmmoDoober:Boolean = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_EMPHASIZE_ENERGY_DOOBER) == ExperimentsManager.VARIANT_VALUE_EMPHASIZE_ENERGY_DOOBER_ON;
      
      public function AmmoRewardPickup(param1:int, param2:Boolean)
      {
         m_feedbackText = new AmmoFeedbackText(param1);
         super(param1,NAME,param2);
         if(this.m_emphasizeAmmoDoober)
         {
            m_numOnCurveCompleteParticles = 7;
         }
      }
      
      override protected function doReward(param1:int) : void
      {
         super.doReward(param1);
         ZGlobal.player.m_ammo.ammo += param1;
      }
      
      override protected function getImageUrl(param1:int) : String
      {
         return ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/Ammo_01_60.png");
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

