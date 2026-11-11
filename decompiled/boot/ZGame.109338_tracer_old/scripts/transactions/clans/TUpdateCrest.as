package transactions.clans
{
   import Engine.Transactions.Transaction;
   
   public class TUpdateCrest extends Transaction
   {
      
      private var m_crestId:int;
      
      public function TUpdateCrest(param1:int)
      {
         super();
         this.m_crestId = param1;
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.updateCrest",this.m_crestId);
      }
   }
}

