package core.managers.promoManager
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import dispatchers.UIDispatcher;
   import displays.popups.LowEPPopup;
   import flash.events.Event;
   import utils.ZGameTimeUtil;
   import zlabs.managers.PopupManager;
   
   public class LowEPPromotion
   {
      
      public static const EVENT_LOW_EP_PROMO_READY:String = "lowEPPromoReady";
      
      private static var m_instance:LowEPPromotion = null;
      
      private static const SECONDS_PER_DAY:int = 24 * 60 * 60;
      
      private var m_canRunPromotion:Boolean = false;
      
      private var m_zrtObject:Object = null;
      
      public function LowEPPromotion()
      {
         super();
      }
      
      public static function get instance() : LowEPPromotion
      {
         if(!m_instance)
         {
            m_instance = new LowEPPromotion();
         }
         return m_instance;
      }
      
      public function initialize() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(ZGlobal.player.isPayingUser() && ExperimentsManager.instance.experimentObjectEnabled(ExperimentsManager.EXPERIMENT_LOWEP_POPUP))
         {
            _loc1_ = ZGlobal.player.secondsSinceLastEPPurchase;
            _loc2_ = ZGameTimeUtil.instance.parseTimeAsSeconds(this.m_zrtObject.timeSinceLastPurchase,0);
            if(ZGlobal.player.cash < this.m_zrtObject.wallet && ZGlobal.player.secondsSinceLastEPPurchase > ZGameTimeUtil.instance.parseTimeAsSeconds(this.m_zrtObject.timeSinceLastPurchase,0))
            {
               _loc3_ = int(ZGlobal.player.getTag(LowEPPopup.TAG_LOW_EP_POPUP_VIEWCOUNT));
               _loc4_ = ZGameTimeUtil.instance.parseTimeAsSeconds(_loc3_ < 3 ? "22h" : "70h",0);
               _loc5_ = Number(ZGlobal.player.getTag(LowEPPopup.TAG_LOW_EP_POPUP_VIEWLASTTS));
               _loc6_ = (GlobalEngine.serverTime - _loc5_) / 1000;
               if(_loc6_ + ZGlobal.player.timeWarpSeconds > _loc4_)
               {
                  this.m_canRunPromotion = true;
                  UIDispatcher.instance.dispatchEvent(new Event(LowEPPromotion.EVENT_LOW_EP_PROMO_READY));
               }
            }
         }
      }
      
      public function set zrtObject(param1:Object) : void
      {
         this.m_zrtObject = param1;
      }
      
      public function get canRunPromotion() : Boolean
      {
         return this.m_canRunPromotion;
      }
      
      public function get popupDelay() : int
      {
         return ZGameTimeUtil.instance.parseTimeAsSeconds(this.m_zrtObject.popupDelay,0);
      }
      
      public function get inactiveDelay() : int
      {
         return ZGameTimeUtil.instance.parseTimeAsSeconds(this.m_zrtObject.popupInactive,0);
      }
      
      public function get walletThreshold() : int
      {
         return parseInt(this.m_zrtObject.wallet);
      }
      
      public function runPromotion() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:XML = null;
         var _loc5_:int = 0;
         var _loc6_:XML = null;
         if(this.m_canRunPromotion)
         {
            _loc1_ = new Array();
            _loc2_ = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_LOWEP_POPUP_PACKAGES);
            switch(_loc2_)
            {
               case 0:
                  this.addOffersForPricePoints(_loc1_,[10,20,50]);
                  break;
               case 1:
                  this.addOffersForPricePoints(_loc1_,[20,50,100]);
                  break;
               case 2:
                  this.addOffersForPricePoints(_loc1_,[5,50,200]);
                  break;
               case 3:
                  _loc3_ = ZGlobal.player.mostEPPurchasedRecently(60 * SECONDS_PER_DAY);
                  _loc4_ = PromoManager.instance.getEPItemXMLForEP(_loc3_);
                  switch(int(_loc4_.@cost))
                  {
                     case 2:
                        this.addOffersForPricePoints(_loc1_,[2,5,10]);
                        break;
                     case 5:
                        this.addOffersForPricePoints(_loc1_,[5,10,20]);
                        break;
                     case 10:
                        this.addOffersForPricePoints(_loc1_,[10,20,50]);
                        break;
                     case 20:
                        this.addOffersForPricePoints(_loc1_,[20,50,100]);
                        break;
                     default:
                        this.addOffersForPricePoints(_loc1_,[50,100,200]);
                  }
                  break;
               case 4:
                  _loc5_ = ZGlobal.player.getMostRecentlyPurchasedEP();
                  _loc6_ = PromoManager.instance.getEPItemXMLForEP(_loc5_);
                  switch(int(_loc6_.@cost))
                  {
                     case 2:
                        this.addOffersForPricePoints(_loc1_,[2,50,200]);
                        break;
                     case 5:
                        this.addOffersForPricePoints(_loc1_,[5,50,200]);
                        break;
                     case 10:
                        this.addOffersForPricePoints(_loc1_,[10,50,200]);
                        break;
                     case 20:
                        this.addOffersForPricePoints(_loc1_,[20,50,200]);
                        break;
                     case 50:
                        this.addOffersForPricePoints(_loc1_,[5,50,200]);
                        break;
                     case 100:
                        this.addOffersForPricePoints(_loc1_,[5,100,200]);
                        break;
                     case 200:
                        this.addOffersForPricePoints(_loc1_,[5,50,200]);
                  }
                  break;
               default:
                  this.addOffersForPricePoints(_loc1_,[5,50,200]);
            }
            PopupManager.instance.push(new LowEPPopup(_loc1_));
         }
      }
      
      private function addOffersForPricePoints(param1:Array, param2:Array) : void
      {
         var _loc3_:int = 0;
         if(param1)
         {
            for each(_loc3_ in param2)
            {
               param1.push(PromoManager.instance.getEPItemXMLForPricePoint(_loc3_));
            }
         }
      }
   }
}

