package transactions.clans
{
   import Engine.Transactions.Transaction;
   
   public class TBuySlot extends Transaction
   {
      
      public function TBuySlot()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.buySlots");
      }
   }
}

