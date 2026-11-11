package transactions.clans
{
   import Engine.Transactions.Transaction;
   
   public class TSendTaunt extends Transaction
   {
      
      private var m_taunt:String = null;
      
      private var m_targetClanId:String = null;
      
      public function TSendTaunt(param1:String, param2:String)
      {
         super();
         this.m_taunt = param1;
         this.m_targetClanId = param2;
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.addTaunt",this.m_taunt,this.m_targetClanId);
      }
   }
}

