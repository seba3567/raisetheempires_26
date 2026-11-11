package transactions.clans
{
   import Engine.Transactions.Transaction;
   
   public class TBuyCrest extends Transaction
   {
      
      private var m_crestId:int;
      
      public function TBuyCrest(param1:int)
      {
         this.m_crestId = param1;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.buyCrest",this.m_crestId);
      }
   }
}

