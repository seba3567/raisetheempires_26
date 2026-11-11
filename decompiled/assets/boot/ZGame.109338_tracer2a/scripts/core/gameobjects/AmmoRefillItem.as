package core.gameobjects
{
   public class AmmoRefillItem extends EnergyRefillItem
   {
      
      public static const ITEM_CODE:String = "ARX";
      
      public function AmmoRefillItem(param1:XML)
      {
         super(param1);
      }
      
      override public function get energyYield() : int
      {
         return 0;
      }
      
      override public function get ammoYield() : int
      {
         return super.energyYield;
      }
   }
}

