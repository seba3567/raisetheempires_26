package core.gameobjects
{
   import Engine.Transactions.Transaction;
   import core.managers.PriceTestManager;
   import transactions.TPurchaseAmmoRefill;
   import transactions.TPurchaseEnergyRefill;
   import transactions.TPurchaseManaRefill;
   
   public class EnergyRefillItem extends GameItem
   {
      
      public static const ITEM_CODE:String = "ERX";
      
      private var m_amount:int = 0;
      
      public function EnergyRefillItem(param1:XML)
      {
         super(param1);
      }
      
      public static function getRefillPurchaseTransaction(param1:String, param2:Boolean, param3:int, param4:Object) : Transaction
      {
         if(param1 == EnergyRefillItem.ITEM_CODE)
         {
            return new TPurchaseEnergyRefill(param1,param2,param3,param4);
         }
         if(param1 == AmmoRefillItem.ITEM_CODE)
         {
            return new TPurchaseAmmoRefill(param4);
         }
         if(param1 == ManaRefillItem.ITEM_CODE)
         {
            return new TPurchaseManaRefill(param4);
         }
         return null;
      }
      
      public function set refillAmount(param1:int) : void
      {
         this.m_amount = param1;
      }
      
      override public function usesCash() : Boolean
      {
         return true;
      }
      
      override public function get cash() : int
      {
         return int(Math.ceil(this.m_amount * PriceTestManager.instance.costMultiplierByType("energypurchase")));
      }
      
      public function getBaseCost() : int
      {
         return this.m_amount;
      }
      
      override public function get energyYield() : int
      {
         return this.m_amount;
      }
   }
}

