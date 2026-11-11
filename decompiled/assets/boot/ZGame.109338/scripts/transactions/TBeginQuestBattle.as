package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TBeginQuestBattle extends Transaction
   {
      
      private var m_code:String = null;
      
      private var m_fleetName:String = null;
      
      public function TBeginQuestBattle(param1:String, param2:String)
      {
         super();
         this.m_code = param1;
         this.m_fleetName = param2;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.beginQuestBattle",{
            "code":this.m_code,
            "fleet":this.m_fleetName
         });
      }
   }
}

