package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TCancelUnstartedChallenge extends Transaction
   {
      
      private var m_challengeFleetName:String;
      
      public function TCancelUnstartedChallenge(param1:String)
      {
         super();
         this.m_challengeFleetName = param1;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.cancelUnstartedChallenge",this.m_challengeFleetName);
      }
   }
}

