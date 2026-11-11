package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TAcceptAllianceQuest extends Transaction
   {
      
      private var m_questName:String;
      
      public function TAcceptAllianceQuest(param1:String)
      {
         this.m_questName = param1;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.acceptQuest",this.m_questName);
      }
   }
}

