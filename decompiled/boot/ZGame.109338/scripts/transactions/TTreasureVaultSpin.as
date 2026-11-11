package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.TreasureVaultManager;
   import zlabs.events.WorldEvent;
   
   public class TTreasureVaultSpin extends Transaction
   {
      
      private var m_mode:uint;
      
      private var m_tier:uint;
      
      public function TTreasureVaultSpin(param1:uint, param2:uint)
      {
         super();
         this.m_mode = param1;
         this.m_tier = param2;
         TreasureVaultManager.instance.dispatchEvent(new WorldEvent(TreasureVaultManager.SPIN_START));
      }
      
      override public function perform() : void
      {
         signedCall("UserService.treasureVaultSpin",this.m_mode,this.m_tier);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         TreasureVaultManager.instance.initHighlights(param1);
         TreasureVaultManager.instance.dispatchEvent(new WorldEvent(TreasureVaultManager.SPIN_RESULTS,param1));
      }
   }
}

