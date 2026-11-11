package transactions.clans
{
   import Engine.Transactions.Transaction;
   
   public class TClearNotifications extends Transaction
   {
      
      public function TClearNotifications()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.clearNotifications");
      }
   }
}

