package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   
   public class TUnlimitedEnergyBuy extends Transaction
   {
      
      private var m_index:int;
      
      public function TUnlimitedEnergyBuy(param1:int)
      {
         this.m_index = param1;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.buyUnlimitedEnergy",this.m_index);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(Boolean(param1) && param1.hasOwnProperty("success"))
         {
            ZGlobal.player.m_energy.updateUnlimitedEnergyTS(param1.ts);
         }
      }
   }
}

