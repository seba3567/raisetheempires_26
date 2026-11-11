package displays.screens.warehouseScreen
{
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import entity.WarehouseComponent;
   import flash.display.MovieClip;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class WarehouseUnitsGrid extends GridScreen
   {
      
      public static const BUY_MORE_SLOTS_CARD:String = "buyMoreSlotsCard";
      
      public static const SPACE_AVAILABLE_SLOTS_CARD:String = "spaceAvailableSlotsCard";
      
      protected static var m_pageNum:int = 0;
      
      protected var m_type:String = null;
      
      protected var m_subtype:String = null;
      
      protected var m_units:Array = new Array();
      
      protected var m_warehouse:WarehouseComponent;
      
      public function WarehouseUnitsGrid(param1:MovieClip, param2:SWFResource, param3:String, param4:String, param5:WarehouseComponent)
      {
         this.m_type = param3;
         this.m_subtype = param4;
         this.m_warehouse = param5;
         super();
         this.init(param1,param2);
      }
      
      public static function setPageNum(param1:int) : void
      {
         m_pageNum = param1;
      }
      
      protected function init(param1:MovieClip, param2:SWFResource) : void
      {
         setDimensions(4,2);
         this.load(param1,param2);
         goToPage(m_pageNum,false);
      }
      
      override public function dispose() : void
      {
         super.dispose();
      }
      
      override public function get numCards() : int
      {
         return this.m_units.length;
      }
      
      override protected function getMultFactor() : Number
      {
         return 1.045;
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         var _loc6_:Object = null;
         var _loc7_:GridSlot = null;
         var _loc8_:int = 0;
         _loc6_ = this.m_units[param5];
         if(_loc6_ is String)
         {
            if(String(_loc6_) == BUY_MORE_SLOTS_CARD)
            {
               _loc7_ = new WarehouseBuyMoreSpaceSlot(param1,param2,screen,param3,param4,this.getMultFactor());
            }
            else
            {
               _loc7_ = new WarehouseSpaceAvailableSlot(param1,param2,screen,param3,param4,this.getMultFactor());
            }
         }
         else
         {
            _loc8_ = this.getSlotIndex(this.m_units[param5].code,param5);
            _loc7_ = new WarehouseUnitSlot(param1,param2,screen,param3,param4,this.m_units[param5],this.getMultFactor(),this.m_warehouse,_loc8_);
         }
         return _loc7_;
      }
      
      private function getSlotIndex(param1:String, param2:int) : int
      {
         var _loc3_:int = -1;
         param1 = this.m_units[param2].code;
         var _loc4_:int = 0;
         while(_loc4_ <= param2)
         {
            if(this.m_units[_loc4_].code == param1)
            {
               _loc3_++;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return false;
      }
      
      override protected function load(param1:MovieClip, param2:SWFResource) : void
      {
         this.createUnitList();
         super.load(param1,param2);
         setAnchor(43,110);
         this.fillOutHeader();
      }
      
      protected function fillOutHeader() : void
      {
         screen.title_tf.text = "";
      }
      
      protected function createUnitList() : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:UnitItem = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc1_:Object = this.m_warehouse.items;
         this.m_units = [];
         for(_loc2_ in _loc1_)
         {
            _loc3_ = int(_loc1_[_loc2_]);
            _loc5_ = 0;
            while(_loc5_ < _loc3_)
            {
               _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc2_,UnitItem) as UnitItem;
               this.m_units.push(_loc4_);
               _loc5_++;
            }
         }
         _loc6_ = 0;
         while(_loc6_ < this.m_warehouse.slotsLeft)
         {
            this.m_units.push(SPACE_AVAILABLE_SLOTS_CARD);
            _loc6_++;
         }
         _loc6_ = 0;
         while(_loc6_ < this.m_warehouse.slotsLeftToUnlock)
         {
            this.m_units.push(BUY_MORE_SLOTS_CARD);
            _loc6_++;
         }
      }
      
      private function onUpdateSlots(param1:WorldEvent) : void
      {
         updateCards();
      }
   }
}

