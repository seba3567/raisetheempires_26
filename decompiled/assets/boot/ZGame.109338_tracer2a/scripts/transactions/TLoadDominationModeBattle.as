package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.managers.domination.DominationModeManager;
   import core.managers.dooberManager.DooberManager;
   
   public class TLoadDominationModeBattle extends Transaction
   {
      
      private var m_data:Object = null;
      
      private var m_enemyID:String = null;
      
      public function TLoadDominationModeBattle(param1:String = null, param2:String = null)
      {
         super();
         this.m_data = new Object();
         if(param1 != null)
         {
            this.m_data.playerFleet = ZGlobal.player.fleets.getSerialisableFleet(param1);
         }
         if(param2 != null)
         {
            this.m_data.enemyID = param2;
            this.m_enemyID = param2;
         }
      }
      
      override public function perform() : void
      {
         signedCall("DominationModeService.loadDominationModeBattle",this.m_data);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         DominationModeManager.instance.onLoadDominationModeBattle(param1,this.m_enemyID);
         if(param1.hasOwnProperty("loot") && Boolean(param1.loot))
         {
            DooberManager.instance.setMysteryDooberResult(DooberManager.MYSTERY_DOOBER_ITEM,param1.loot);
         }
      }
   }
}

