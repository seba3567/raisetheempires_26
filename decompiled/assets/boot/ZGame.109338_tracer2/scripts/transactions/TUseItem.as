package transactions
{
   import Engine.Transactions.Transaction;
   import core.ZGlobal;
   
   public class TUseItem extends Transaction
   {
      
      private var m_itemCode:String = null;
      
      private var m_currentEnergy:int = 0;
      
      public function TUseItem(param1:String)
      {
         super();
         this.m_itemCode = param1;
         this.m_currentEnergy = ZGlobal.player.m_energy.energy;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.useItem",this.m_itemCode);
      }
      
      override protected function onAmfComplete(param1:Object) : void
      {
         super.onAmfComplete(param1);
      }
   }
}

