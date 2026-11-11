package displays.screens.pickUnitsScreen
{
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import core.managers.InventoryList;
   import core.managers.worldUnitManager.WorldUnitManager;
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class UnitsGrid extends GridScreen
   {
      
      protected var m_type:String = null;
      
      protected var m_subtype:String = null;
      
      protected var m_units:Array = new Array();
      
      protected var m_selections:Array = new Array();
      
      protected var m_maxSelections:int = 0;
      
      protected var m_selectionIndexes:Array = new Array();
      
      protected var m_levelLimit:int = 0;
      
      public function UnitsGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:String, param5:String, param6:Array, param7:int, param8:Array, param9:int = 0)
      {
         this.m_type = param4;
         this.m_subtype = param5;
         this.m_levelLimit = param9;
         this.m_maxSelections = param7;
         if(Boolean(param6) && param6.length > 0)
         {
            this.m_selections = param6;
         }
         if(Boolean(param8) && param8.length > 0)
         {
            this.m_selectionIndexes = param8;
         }
         super();
         this.init(param1,param2);
      }
      
      protected function init(param1:MovieClip, param2:SWFResource) : void
      {
         setDimensions(5,2);
         this.load(param1,param2);
      }
      
      override public function get numCards() : int
      {
         return this.m_units.length;
      }
      
      override protected function getMultFactor() : Number
      {
         return 1.05;
      }
      
      protected function unitSlotCard(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:UnitItem, param7:Boolean, param8:int, param9:Number) : GridSlot
      {
         return new UnitSlot(param1,param2,param3,param4,param5,param6,param7,param8,param9);
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         var _loc6_:UnitItem = this.m_units.shift();
         var _loc7_:Boolean = false;
         var _loc8_:int = 0;
         while(_loc8_ < this.m_selectionIndexes.length)
         {
            if(this.m_selectionIndexes[_loc8_] == param5)
            {
               _loc7_ = true;
            }
            _loc8_++;
         }
         return this.unitSlotCard(param1,param2,screen,param3,param4,_loc6_,_loc7_,param5,this.getMultFactor());
      }
      
      protected function resetAnchorPosition() : void
      {
         setAnchor(58,35);
      }
      
      override protected function load(param1:MovieClip, param2:SWFResource) : void
      {
         this.createItemList();
         super.load(param1,param2);
         this.resetAnchorPosition();
         this.fillOutHeader();
      }
      
      public function updateSelections(param1:Array, param2:Array) : void
      {
         this.m_selections = param1;
         this.m_selectionIndexes = param2;
         this.fillOutHeader();
      }
      
      public function updateSubtype(param1:String) : void
      {
         this.m_subtype = param1;
         this.m_selections = new Array();
         this.m_selectionIndexes = new Array();
         this.createItemList();
         this.updateCards();
         this.resetGridPosition();
      }
      
      public function updateLevelLimit(param1:int) : void
      {
         this.m_levelLimit = param1;
         this.m_selections = new Array();
         this.m_selectionIndexes = new Array();
         this.createItemList();
         this.updateCards();
         this.resetGridPosition();
      }
      
      protected function resetGridPosition() : void
      {
         m_clickPosition = 0;
         if(m_isVerticalGrid)
         {
            m_screen.anchor_mc.y = m_slotAnchorPosition;
         }
         else
         {
            m_screen.anchor_mc.x = m_slotAnchorPosition;
         }
         fixArrows(0);
      }
      
      public function get selections() : Array
      {
         return this.m_selections;
      }
      
      public function get selectionIndexes() : Array
      {
         return this.m_selectionIndexes;
      }
      
      protected function fillOutHeader() : void
      {
         var _loc1_:int = this.m_maxSelections - (this.m_selections ? this.m_selections.length : 0);
         screen.header_tf.text = ZGameUtils.ZlocT("Dialogs","PickUnitsHeader",{
            "num":_loc1_,
            "unit":ZGameUtils.ZlocTk("Dialogs","unit","",_loc1_)
         });
      }
      
      public function addSelection(param1:UnitItem) : Array
      {
         var _loc2_:int = 0;
         this.m_units = new Array();
         this.createItemList();
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         while(_loc5_ < this.m_units.length)
         {
            if(this.m_units[_loc5_].code == param1.code)
            {
               while(_loc5_ + 1 < this.m_units.length && this.m_units[_loc5_ + 1].code == param1.code)
               {
                  _loc5_++;
               }
               break;
            }
            _loc5_++;
         }
         var _loc6_:int = 0;
         while(_loc6_ < this.m_selectionIndexes.length)
         {
            if(this.m_selectionIndexes[_loc6_] >= _loc5_)
            {
               ++this.m_selectionIndexes[_loc6_];
            }
            _loc6_++;
         }
         this.m_selections.push(param1);
         this.m_selectionIndexes.push(_loc5_);
         return this.m_selections;
      }
      
      override public function updateCards() : void
      {
         super.updateCards();
         this.fillOutHeader();
      }
      
      protected function createItemList() : void
      {
         this.populateFromWorld();
         this.populateFromInventory();
      }
      
      protected function populateFromWorld() : void
      {
         var _loc4_:String = null;
         var _loc5_:UnitItem = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc1_:Dictionary = WorldUnitManager.instance.availableUnits;
         var _loc2_:Array = InventoryList.instance.items;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_];
            _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_,UnitItem) as UnitItem;
            if(_loc5_.type == this.m_type && _loc5_.subType == this.m_subtype)
            {
               _loc6_ = int(_loc1_[_loc4_]);
               _loc7_ = 0;
               while(_loc7_ < _loc6_)
               {
                  this.m_units.push(_loc5_);
                  _loc7_++;
               }
            }
            _loc3_++;
         }
      }
      
      protected function populateFromInventory() : void
      {
         var _loc3_:String = null;
         var _loc4_:UnitItem = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc1_:Array = InventoryList.instance.items;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = _loc1_[_loc2_];
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,UnitItem) as UnitItem;
            if(_loc4_.type == this.m_type && _loc4_.subType == this.m_subtype)
            {
               _loc5_ = ZGlobal.player.getNumberOfInventoryItems(_loc3_);
               _loc6_ = 0;
               while(_loc6_ < _loc5_)
               {
                  this.m_units.push(_loc4_);
                  _loc6_++;
               }
            }
            _loc2_++;
         }
      }
      
      override protected function onConfigureForItem(param1:WorldEvent) : void
      {
         var _loc4_:UnitSlot = null;
         var _loc2_:String = param1.eventData as String;
         var _loc3_:int = 0;
         for each(_loc4_ in m_cards)
         {
            if(_loc4_.getData().item.code == _loc2_)
            {
               break;
            }
            _loc3_++;
         }
         goToPage(int(_loc3_ / numCardsPerPage),false);
         enableLeftButtons(false);
         enableRightButtons(false);
      }
   }
}

