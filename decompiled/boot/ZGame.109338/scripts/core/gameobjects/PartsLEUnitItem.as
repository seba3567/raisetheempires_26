package core.gameobjects
{
   import core.ZGlobal;
   import core.managers.LEUnitFactoryManager;
   import flash.utils.Dictionary;
   import zlabs.debug.Logger;
   
   public class PartsLEUnitItem extends PartsItem
   {
      
      private static var m_unitDataLookup:Dictionary = new Dictionary();
      
      private var m_unitCode:String;
      
      private var m_slotIndex:int;
      
      private var m_unit:UnitItem;
      
      public function PartsLEUnitItem(param1:XML)
      {
         super(param1);
         this.m_slotIndex = int(this.code.split("F")[1]) - 1;
         this.m_unitCode = LEUnitFactoryManager.instance.lufCodes[code];
         this.m_unit = ZGlobal.gameSettings.getItemByCode(this.m_unitCode,UnitItem) as UnitItem;
      }
      
      override public function getPartCountForIndex(param1:int) : int
      {
         return LEUnitFactoryManager.instance.getPartCountForIndex(this.m_unitCode,param1);
      }
      
      override public function getPartCodeForIndex(param1:int) : String
      {
         Logger.print(this,"JMR: using PartsLEUnitItem getPartCodeForIndex: " + param1);
         return LEUnitFactoryManager.instance.getPartCodeForIndex(this.m_unitCode,param1);
      }
      
      public function get unitCode() : String
      {
         return this.m_unitCode;
      }
      
      override public function get numParts() : int
      {
         return 4;
      }
      
      override public function get cash() : int
      {
         return this.m_unit.cash;
      }
      
      public function get unit() : UnitItem
      {
         return this.m_unit;
      }
   }
}

