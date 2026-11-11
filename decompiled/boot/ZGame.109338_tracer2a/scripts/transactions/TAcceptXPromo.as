package transactions
{
   import core.managers.promoManager.PromoManager;
   import zlabs.events.WorldEvent;
   
   public class TAcceptXPromo extends TZGameTransaction
   {
      
      private var m_promoId:int;
      
      public function TAcceptXPromo(param1:int)
      {
         super();
         this.m_promoId = param1;
      }
      
      override public function perform() : void
      {
         signedCall("CrossPromoService.accepted",this.m_promoId);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         var _loc2_:WorldEvent = new WorldEvent(PromoManager.XPROMO_ACCEPT_TRANSACTION_COMPLETED);
         PromoManager.instance.dispatchEvent(_loc2_);
      }
   }
}

