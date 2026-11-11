package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import core.managers.domination.DominationModeManager;
   
   public class TUpdateDefenseForce extends Transaction
   {
      
      private var m_data:Object = null;
      
      public function TUpdateDefenseForce(param1:int)
      {
         super();
         this.m_data = new Object();
         this.m_data.playerFleet = ZGlobal.player.fleets.getSerialisableFleet(DominationModeManager.FLEET_DEFENSE_DUMMY_PLAYER);
         this.m_data.index = param1;
      }
      
      override public function perform() : void
      {
         signedCall("DominationModeService.updateDefenseForce",this.m_data);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         DominationModeManager.instance.onUpdateDefenseForce(param1);
      }
   }
}

