package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.managers.ChallengeModeManager;
   
   public class TLoadChallenge extends Transaction
   {
      
      private var m_data:Object = null;
      
      public function TLoadChallenge(param1:String, param2:String = null)
      {
         super();
         this.m_data = new Object();
         this.m_data.challengeFleetName = param1;
         if(param2 != null)
         {
            this.m_data.challengeeFleet = ZGlobal.player.fleets.getSerialisableFleet(param2);
         }
      }
      
      public function get challengeFleetName() : String
      {
         return this.m_data.challengeFleetName;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.loadChallenge",this.m_data);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         ChallengeModeManager.instance.onAcceptReceivedChallenge(param1);
      }
   }
}

