package core.gameobjects
{
   public class ManaRefillItem extends EnergyRefillItem
   {
      
      public static const ITEM_CODE:String = "MRX";
      
      public function ManaRefillItem(param1:XML)
      {
         super(param1);
      }
      
      override public function get energyYield() : int
      {
         return 0;
      }
      
      override public function get cash() : int
      {
         return super.cash * ManaItem.getCashMultiplier();
      }
      
      override public function get manaYield() : int
      {
         return super.energyYield;
      }
   }
}

