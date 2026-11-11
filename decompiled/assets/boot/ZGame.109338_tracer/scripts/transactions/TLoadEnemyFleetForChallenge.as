package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.ChallengeModeManager;
   import core.managers.PVPManager;
   
   public class TLoadEnemyFleetForChallenge extends Transaction
   {
      
      private var m_challengeID:String;
      
      public function TLoadEnemyFleetForChallenge(param1:String)
      {
         super();
         this.m_challengeID = param1;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.loadEnemyFleetForChallenge",this.m_challengeID);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         ChallengeModeManager.instance.onLoadEnemyFleetForChallenge(param1);
         PVPManager.instance.clearCombatPopup();
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
         super.onFault(param1,param2);
         PVPManager.instance.clearCombatPopup();
      }
   }
}

