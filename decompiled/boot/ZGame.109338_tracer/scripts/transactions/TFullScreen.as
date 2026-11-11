package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TFullScreen extends Transaction
   {
      
      public function TFullScreen()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.fullScreen");
      }
   }
}

