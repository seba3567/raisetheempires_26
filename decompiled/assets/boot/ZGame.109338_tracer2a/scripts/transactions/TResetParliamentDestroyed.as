package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TResetParliamentDestroyed extends Transaction
   {
      
      private var m_params:Object = new Object();
      
      public function TResetParliamentDestroyed()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.resetParliamentDestroyed",this.m_params);
      }
   }
}

