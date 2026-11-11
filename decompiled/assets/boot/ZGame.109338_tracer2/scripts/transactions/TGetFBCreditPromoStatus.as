package transactions
{
   import Engine.Transactions.Transaction;
   import zlabs.debug.Logger;
   
   public class TGetFBCreditPromoStatus extends Transaction
   {
      
      private var m_callback:Function = null;
      
      public function TGetFBCreditPromoStatus(param1:Function = null)
      {
         this.m_callback = param1;
         super();
      }
      
      override public function perform() : void
      {
         Logger.print(this,"**** TGetFBCreditPromoStatus/perform(), sending transaction...");
         signedCall("UserService.getFBCreditPromoStatus");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         Logger.print(this,"**** TGetFBCreditPromoStatus/onComplete(), result.result is " + param1.result);
         if(param1.result != undefined && param1.result != null && param1.result != 0 && this.m_callback != null)
         {
            Logger.print(this,"**** TGetFBCreditPromoStatus/onComplete(), calling callback function");
            this.m_callback(param1);
         }
      }
   }
}

