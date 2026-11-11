package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.PVPManager;
   import zlabs.events.WorldEvent;
   
   public class TPVPGlobalSlotMachineSpin extends Transaction
   {
      
      private var m_mode:uint;
      
      public function TPVPGlobalSlotMachineSpin(param1:uint)
      {
         super();
         this.m_mode = param1;
         PVPManager.instance.dispatchEvent(new WorldEvent(PVPManager.SPIN_START));
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.slotMachineSpin",this.m_mode);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         PVPManager.instance.dispatchEvent(new WorldEvent(PVPManager.SPIN_RESULTS,param1));
      }
   }
}

