package displays.screens.pickConsumableScreen
{
   import core.ZGlobal;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.GameItem;
   import core.managers.InventoryList;
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class ConsumablesGrid extends GridScreen
   {
      
      protected var m_type:String = "consumable";
      
      protected var m_subtype:String = null;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var m_consumables:Array = new Array();
      
      protected var m_selections:Array = new Array();
      
      protected var m_maxSelections:int = 0;
      
      protected var m_selectionIndexes:Array = new Array();
      
      public function ConsumablesGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:Array, param5:int, param6:Array)
      {
         this.m_eventDispatcher = param3;
         this.m_maxSelections = param5;
         if(Boolean(param4) && param4.length > 0)
         {
            this.m_selections = param4;
         }
         if(Boolean(param6) && param6.length > 0)
         {
            this.m_selectionIndexes = param6;
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
         return this.m_consumables.length;
      }
      
      override protected function getMultFactor() : Number
      {
         return 1.05;
      }
      
      override protected function close() : void
      {
         screen.removeEventListener(ConsumableSlot.CLICKED,this.onCardClicked);
         super.close();
      }
      
      protected function consumableSlotCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:ConsumableItem, param6:Boolean, param7:int, param8:Number) : GridSlot
      {
         return new ConsumableSlot(param1,param2,screen,param3,param4,param5,param6,param7,param8);
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         var _loc6_:ConsumableItem = this.m_consumables.shift();
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
         return this.consumableSlotCard(param1,param2,param3,param4,_loc6_,_loc7_,param5,this.getMultFactor());
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return false;
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
         screen.addEventListener(ConsumableSlot.CLICKED,this.onCardClicked);
         this.addHeader();
      }
      
      public function updateSelections(param1:Array, param2:Array) : void
      {
         this.m_selections = param1;
         this.m_selectionIndexes = param2;
         this.fillOutHeader();
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
      
      protected function addHeader() : void
      {
         screen.header_tf.text = ZGameUtils.ZlocT("Dialogs","PickConsumableHeader");
      }
      
      protected function onCardClicked(param1:WorldEvent) : void
      {
         if(this.m_maxSelections == 1)
         {
            this.close();
            this.m_eventDispatcher.dispatchEvent(new WorldEvent(param1.type,param1.eventData));
         }
      }
      
      public function addSelection(param1:ConsumableItem) : Array
      {
         return this.m_selections;
      }
      
      protected function createItemList() : void
      {
         var _loc3_:String = null;
         var _loc4_:ConsumableItem = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc1_:Array = InventoryList.instance.items;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = _loc1_[_loc2_];
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,ConsumableItem) as ConsumableItem;
            if(_loc4_.type == this.m_type && _loc4_.subType == GameItem.TYPE_CONSUMABLE)
            {
               _loc5_ = ZGlobal.player.getNumberOfInventoryItems(_loc3_);
               _loc6_ = 0;
               while(_loc6_ < _loc5_)
               {
                  this.m_consumables.push(_loc4_);
                  _loc6_++;
               }
            }
            _loc2_++;
         }
      }
   }
}

