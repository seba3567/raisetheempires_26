package displays.screens.leUnitFactoryScreens
{
   import core.ZGlobal;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.PartsLEUnitItem;
   import dispatchers.UIDispatcher;
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import displays.screens.researchScreens.ResearchUnitsGrid;
   import flash.display.MovieClip;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class LEUnitsGrid extends GridScreen
   {
      
      protected static var m_pageNum:int = 0;
      
      protected var m_type:String = null;
      
      protected var m_subtype:String = null;
      
      protected var m_units:Array = new Array();
      
      protected var m_useSavedPageNum:Boolean = false;
      
      protected var m_highestTier:int;
      
      public function LEUnitsGrid(param1:MovieClip, param2:SWFResource, param3:String, param4:String, param5:Boolean = true)
      {
         this.m_type = param3;
         this.m_subtype = param4;
         this.m_useSavedPageNum = param5;
         super();
         this.init(param1,param2);
      }
      
      public static function setPageNum(param1:int) : void
      {
         m_pageNum = param1;
      }
      
      private function passesTierCheck(param1:ConsumableItem) : Boolean
      {
         return true;
      }
      
      protected function init(param1:MovieClip, param2:SWFResource) : void
      {
         setDimensions(4,1);
         this.load(param1,param2);
         if(this.m_useSavedPageNum)
         {
            goToPage(m_pageNum,false);
         }
         else
         {
            goToPage(0,false);
         }
         UIDispatcher.instance.addEventListener(ResearchUnitsGrid.EVENT_UPDATE_RESEARCH_SLOTS,this.onUpdateSlots,false,0,true);
      }
      
      private function onUpdateSlots(param1:WorldEvent) : void
      {
         updateCards();
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
         var _loc6_:Boolean = false;
         return new LEUnitSlot(param1,param2,screen,param3,param4,this.m_units[param5],this.getMultFactor(),_loc6_);
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return false;
      }
      
      override protected function load(param1:MovieClip, param2:SWFResource) : void
      {
         this.createItemList();
         super.load(param1,param2);
         setAnchor(23,155);
         this.fillOutHeader();
         m_screen.arrowRt_bt.visible = false;
         m_screen.arrowLt_bt.visible = false;
         m_screen.instructions_tf.visible = false;
      }
      
      protected function fillOutHeader() : void
      {
         screen.header_tf.text = "units";
      }
      
      protected function createItemList() : void
      {
         var _loc1_:PartsLEUnitItem = null;
         this.m_units = [];
         var _loc2_:int = 0;
         while(_loc2_ < 4)
         {
            _loc1_ = ZGlobal.gameSettings.getItemByCode("LUF" + (_loc2_ + 1),PartsLEUnitItem) as PartsLEUnitItem;
            this.m_units.push(_loc1_);
            _loc2_++;
         }
      }
      
      override public function dispose() : void
      {
         UIDispatcher.instance.removeEventListener(ResearchUnitsGrid.EVENT_UPDATE_RESEARCH_SLOTS,this.onUpdateSlots);
         super.dispose();
      }
   }
}

