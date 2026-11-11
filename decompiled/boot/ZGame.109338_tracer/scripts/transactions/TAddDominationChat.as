package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TAddDominationChat extends Transaction
   {
      
      private var m_data:Object = null;
      
      public function TAddDominationChat(param1:String, param2:String)
      {
         super();
         this.m_data = new Object();
         this.m_data.msg = param1;
         this.m_data.enemyID = param2;
      }
      
      override public function perform() : void
      {
         signedCall("DominationModeService.addDominationChat",this.m_data);
      }
   }
}

