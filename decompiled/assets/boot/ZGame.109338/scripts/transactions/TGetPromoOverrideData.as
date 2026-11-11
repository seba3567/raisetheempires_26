package transactions
{
   public class TGetPromoOverrideData extends TGameTransaction
   {
      
      private var m_callback:Function;
      
      private var m_starterPackPaymentCodes:Array;
      
      public function TGetPromoOverrideData(param1:Array, param2:Function)
      {
         super();
         this.m_starterPackPaymentCodes = param1;
         this.m_callback = param2;
      }
      
      override public function perform() : void
      {
         super.perform();
         signedCall("DataServicesService.getPromoData",this.data);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         this.m_callback(param1);
      }
      
      protected function get data() : Object
      {
         return {"starterPackPaymentCodes":this.m_starterPackPaymentCodes};
      }
   }
}

