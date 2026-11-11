package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.ChallengeModeManager;
   import core.managers.PVPManager;
   
   public class TGetAllChallenges extends Transaction
   {
      
      private var m_onWorldLoad:Boolean = true;
      
      public function TGetAllChallenges(param1:Boolean = true)
      {
         super();
         this.m_onWorldLoad = param1;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.getAllChallenges");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         ChallengeModeManager.instance.storeChallenges(param1);
         if(this.m_onWorldLoad)
         {
            PVPManager.instance.onVisit();
         }
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
         super.onFault(param1,param2);
      }
   }
}

