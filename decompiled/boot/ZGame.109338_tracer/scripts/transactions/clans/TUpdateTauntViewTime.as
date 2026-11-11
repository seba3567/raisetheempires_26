package transactions.clans
{
   import Engine.Transactions.Transaction;
   
   public class TUpdateTauntViewTime extends Transaction
   {
      
      public function TUpdateTauntViewTime()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.updateTauntViewTime");
      }
   }
}

