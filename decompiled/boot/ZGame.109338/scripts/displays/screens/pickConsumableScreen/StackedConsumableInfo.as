package displays.screens.pickConsumableScreen
{
   import core.gameobjects.ConsumableItem;
   
   public class StackedConsumableInfo
   {
      
      private var m_consumable:ConsumableItem;
      
      private var m_quantity:int;
      
      private var m_cash:int;
      
      public function StackedConsumableInfo(param1:ConsumableItem, param2:int = 0)
      {
         super();
         this.m_consumable = param1;
         this.m_quantity = param2;
         this.m_cash = param1.usesCash() ? param1.cash : 0;
      }
      
      public function get consumable() : ConsumableItem
      {
         return this.m_consumable;
      }
      
      public function get quantity() : int
      {
         return this.m_quantity;
      }
      
      public function get cash() : int
      {
         return this.m_cash;
      }
      
      public function incrementQuantity(param1:int) : int
      {
         this.m_quantity += param1;
         return this.m_quantity;
      }
   }
}

