package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TClearFlashFeedTokens extends Transaction
   {
      
      public function TClearFlashFeedTokens()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.clearOldFlashTokens");
      }
   }
}

