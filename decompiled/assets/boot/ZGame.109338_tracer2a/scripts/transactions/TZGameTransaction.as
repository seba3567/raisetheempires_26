package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   import transactions.utils.ZGameTransactionUtils;
   
   public class TZGameTransaction extends Transaction
   {
      
      public function TZGameTransaction()
      {
         super();
      }
      
      protected function modifiedData(param1:Object) : Object
      {
         param1.ch = ZGameTransactionUtils.getCheckSum(param1);
         return param1;
      }
      
      final override protected function onAmfComplete(param1:Object) : void
      {
         super.onAmfComplete(param1);
         if(param1.energy >= 0)
         {
            ZGlobal.player.m_energy.energyTimer.lastEnergyCheck = param1.lastEnergyCheck;
         }
      }
   }
}

