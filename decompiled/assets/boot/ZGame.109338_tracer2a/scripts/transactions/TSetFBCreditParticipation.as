package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.promoManager.PromoManager;
   import zlabs.debug.Logger;
   
   public class TSetFBCreditParticipation extends Transaction
   {
      
      public function TSetFBCreditParticipation()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.setFBCreditParticipation");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         Logger.print(this,"**** TSetFBCreditParticipation/onComplete(), result.result is " + param1.result + ", result.offer is " + param1.offer);
         if(param1.result == 1 && Boolean(param1.offer))
         {
            PromoManager.instance.grantRewardBundle(param1.offer,1);
         }
      }
   }
}

