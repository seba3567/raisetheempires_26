package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TUnitDropRevealAll extends Transaction
   {
      
      public function TUnitDropRevealAll()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.unitDropRevealAll");
      }
   }
}

