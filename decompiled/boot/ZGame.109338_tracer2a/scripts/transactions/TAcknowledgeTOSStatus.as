package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TAcknowledgeTOSStatus extends Transaction
   {
      
      public function TAcknowledgeTOSStatus()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.acknowledgeTOSStatus");
      }
   }
}

