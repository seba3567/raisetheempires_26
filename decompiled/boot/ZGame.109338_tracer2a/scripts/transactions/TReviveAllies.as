package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TReviveAllies extends Transaction
   {
      
      private var m_revCount:int = 0;
      
      public function TReviveAllies(param1:int)
      {
         super();
         this.m_revCount = param1;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.reviveAllies",this.m_revCount);
      }
   }
}

