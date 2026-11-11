package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.ChallengeModeManager;
   import core.managers.PVPManager;
   import core.managers.dooberManager.DooberManager;
   
   public class TGetNeighborVisitChallenges extends Transaction
   {
      
      private var m_visitID:String = null;
      
      private var m_onWorldLoad:Boolean = true;
      
      public function TGetNeighborVisitChallenges(param1:String, param2:Boolean = true)
      {
         super();
         this.m_visitID = param1;
         this.m_onWorldLoad = param2;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.getNeighborVisitChallenges",this.m_visitID);
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
         if(param1.hasOwnProperty("loot"))
         {
            DooberManager.instance.setMysteryDooberResult(DooberManager.MYSTERY_DOOBER_ITEM,param1.loot);
         }
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
         super.onFault(param1,param2);
      }
   }
}

