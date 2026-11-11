package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TMegaSeriesReset extends Transaction
   {
      
      private var ms_id:String;
      
      public function TMegaSeriesReset(param1:String)
      {
         this.ms_id = param1;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.megaSeriesReset",this.ms_id);
      }
   }
}

