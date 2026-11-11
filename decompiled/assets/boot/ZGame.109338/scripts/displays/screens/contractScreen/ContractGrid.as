package displays.screens.contractScreen
{
   import dispatchers.UIDispatcher;
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class ContractGrid extends GridScreen
   {
      
      public static const EVENT_UPDATE_SLOTS:String = "updateContractGridSlots";
      
      protected var m_listener:EventDispatcher = null;
      
      protected var m_entity:IEntity = null;
      
      protected var m_type:String = null;
      
      protected var m_subtype:String = null;
      
      protected var m_items:Array = null;
      
      public function ContractGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:IEntity, param5:String, param6:String)
      {
         super();
         this.m_listener = param3;
         this.m_entity = param4;
         this.m_type = param5;
         this.m_subtype = param6;
         this.createItemList();
         this.initGridSize();
         load(param1,param2);
         setAnchor(screen.origin_mc.x,screen.origin_mc.y);
         UIDispatcher.instance.addEventListener(EVENT_UPDATE_SLOTS,this.onUpdateSlots,false,0,true);
      }
      
      override public function dispose() : void
      {
         this.m_listener = null;
         this.m_entity = null;
         this.m_items = null;
         UIDispatcher.instance.removeEventListener(EVENT_UPDATE_SLOTS,this.onUpdateSlots);
         super.dispose();
      }
      
      override public function get numCards() : int
      {
         return this.m_items.length;
      }
      
      override protected function getMultFactor() : Number
      {
         return 1;
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         return null;
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return false;
      }
      
      protected function initGridSize() : void
      {
      }
      
      protected function createItemList() : void
      {
      }
      
      private function onUpdateSlots(param1:WorldEvent) : void
      {
         updateCards();
      }
      
      public function updateCardsForMastery() : void
      {
      }
   }
}

