package core.ui
{
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import core.managers.promoManager.PromoManager;
   import core.managers.unitClassManager.UnitClassManager;
   import displays.ImageLoaderFactory;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class LightningDealPurchasePopup extends ImpulsePurchasePopUp
   {
      
      private static const X_OFFSET:int = 20;
      
      private var m_timer:Timer = new Timer(1000);
      
      private var m_claimBarOriginalWidth:uint;
      
      public function LightningDealPurchasePopup(param1:String)
      {
         var _loc2_:String = ZGlobal.player.getLightningDealInfo(PromoManager.LD_MC_KEY_TOASTER_DURATION);
         var _loc3_:int = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc2_,0);
         var _loc4_:Object = {
            "code":param1,
            "discount":0
         };
         super(_loc4_,_loc3_);
         x += X_OFFSET;
      }
      
      override protected function get assetClass() : String
      {
         return "lightningSale_mc";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
      }
      
      override protected function initialize() : void
      {
         super.initialize();
         this.m_claimBarOriginalWidth = m_mc.claim_mc.loadingBar_mc.width;
         PromoManager.instance.addEventListener(PromoManager.LIGHTNINGDEAL_ITEMCOUNT_UPDATED,this.onItemCountChanged,false,0,true);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer,false,0,true);
         this.m_timer.start();
         this.updateTimeRemainingString();
         var _loc1_:int = ZGlobal.player.lightningDealFractionClaimed;
         this.updateFractionClaimedString(_loc1_);
         this.updateClaimBarWidth(_loc1_);
         this.updateClaimButton(ZGlobal.player.getLightningDealInfo(PromoManager.LD_MC_KEY_CURRENT));
         var _loc2_:String = UnitClassManager.instance.getIconURLForUnit(m_item as UnitItem);
         if(_loc2_)
         {
            ImageLoaderFactory.CreateImageLoader(_loc2_,m_mc.class_icon);
         }
      }
      
      override public function applyDiscount(param1:int) : int
      {
         return param1;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         PromoManager.instance.removeEventListener(PromoManager.LIGHTNINGDEAL_ITEMCOUNT_UPDATED,this.onItemCountChanged);
         if(this.m_timer)
         {
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer.stop();
            this.m_timer = null;
         }
      }
      
      override protected function get discountStringKey() : String
      {
         return "LightningDeal_ImpulseMsg";
      }
      
      override protected function get noDiscountStringKey() : String
      {
         return this.discountStringKey;
      }
      
      override protected function get resizable() : Boolean
      {
         return false;
      }
      
      override protected function get exit_bt() : EventDispatcher
      {
         return m_mc.exit_bt;
      }
      
      override protected function get showDiscount() : Boolean
      {
         return false;
      }
      
      override protected function get hasUnlockButton() : Boolean
      {
         return false;
      }
      
      override protected function get priceTestType() : String
      {
         return null;
      }
      
      override protected function get showConfirmation() : Boolean
      {
         return true;
      }
      
      private function updateTimeRemainingString() : void
      {
         var _loc1_:String = ZGlobal.player.lightingDealTimeRemainingString;
         TextFieldUtil.compactTextField(m_mc.timer_tf,_loc1_);
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         this.updateTimeRemainingString();
      }
      
      private function onItemCountChanged(param1:WorldEvent) : void
      {
         this.updateFractionClaimedString(param1.eventData.fractionClaimed);
         this.updateClaimBarWidth(param1.eventData.fractionClaimed);
         this.updateClaimButton(param1.eventData.count);
      }
      
      private function updateFractionClaimedString(param1:int) : void
      {
         var _loc2_:String = ZGlobal.player.getFriendlyClaimProgressString(param1);
         TextFieldUtil.processTextField(m_mc.claim_mc.cliam_tf,_loc2_);
      }
      
      private function updateClaimBarWidth(param1:int) : void
      {
         m_mc.claim_mc.loadingBar_mc.width = this.m_claimBarOriginalWidth * param1 / 100;
      }
      
      private function updateClaimButton(param1:int) : void
      {
         if(!param1)
         {
            m_button.disable();
            m_button.hide();
         }
      }
   }
}

