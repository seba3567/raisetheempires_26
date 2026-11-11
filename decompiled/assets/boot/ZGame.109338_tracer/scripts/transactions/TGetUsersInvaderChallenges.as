package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.ChallengeModeManager;
   import core.managers.PVPManager;
   
   public class TGetUsersInvaderChallenges extends Transaction
   {
      
      private var m_onWorldLoad:Boolean = true;
      
      public function TGetUsersInvaderChallenges(param1:Boolean = true)
      {
         super();
         this.m_onWorldLoad = param1;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.getUsersInvaderChallenges");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         ChallengeModeManager.instance.updateChallenges(param1);
         if(this.m_onWorldLoad)
         {
            PVPManager.instance.postInit();
            PVPManager.instance.onVisit();
         }
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
         super.onFault(param1,param2);
      }
   }
}

