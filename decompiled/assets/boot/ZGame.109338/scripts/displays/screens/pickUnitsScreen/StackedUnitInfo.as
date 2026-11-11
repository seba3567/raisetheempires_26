package displays.screens.pickUnitsScreen
{
   import core.gamemode.prebattle.PreBattleUI;
   import core.gameobjects.UnitItem;
   
   public class StackedUnitInfo
   {
      
      private var m_unitItem:UnitItem;
      
      private var m_quantity:int;
      
      public function StackedUnitInfo(param1:UnitItem, param2:int = 0)
      {
         super();
         this.m_unitItem = param1;
         this.m_quantity = param2;
      }
      
      public function get unitItem() : UnitItem
      {
         return this.m_unitItem;
      }
      
      public function get quantity() : int
      {
         return this.m_quantity;
      }
      
      public function incrementQuantity(param1:int, param2:String) : Boolean
      {
         var _loc3_:Boolean = false;
         this.m_quantity += param1;
         if(PreBattleUI.TITAN_MODE && this.m_unitItem.hasType(UnitItem.MEGA_UNIT_WEAPON))
         {
            _loc3_ = (PreBattleUI.getPreBattleUI() as PreBattleUI).titanUI.updateSlot([param2],param1);
         }
         return _loc3_;
      }
   }
}

