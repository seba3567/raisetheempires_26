package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TClearIncentivePopup extends Transaction
   {
      
      public function TClearIncentivePopup()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.clearIncentive");
      }
   }
}

