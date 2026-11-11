package displays.screens.blackMarket
{
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import zlabs.resource.SWFResource;
   
   public class BlackMarketGrid extends GridScreen
   {
      
      protected var m_items:Array = null;
      
      protected var m_listener:EventDispatcher = null;
      
      public function BlackMarketGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:Array, param5:Boolean = false)
      {
         super();
         this.m_items = param4;
         this.m_listener = param3;
         m_isVerticalGrid = param5;
         this.initGridSize();
         load(param1,param2);
      }
      
      protected function initGridSize() : void
      {
         setDimensions(0,2);
      }
      
      protected function createItemList() : void
      {
      }
      
      override public function get numCards() : int
      {
         return this.m_items.length;
      }
      
      override protected function createCards(param1:SWFResource) : void
      {
         var _loc2_:BlackMarketTradeSlot = null;
         super.createCards(param1);
         for each(_loc2_ in m_cards)
         {
            _loc2_.rollOverTarget.removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
            _loc2_.rollOverTarget.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
            _loc2_.disable();
         }
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         return new BlackMarketTradeSlot(param1,param2,screen,param3,param4,this.m_items[param5],this.m_listener);
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return false;
      }
      
      override public function updateCards() : void
      {
         var _loc2_:BlackMarketTradeSlot = null;
         var _loc1_:uint = cards.length;
         var _loc3_:uint = 0;
         while(_loc3_ < _loc1_)
         {
            _loc2_ = cards[_loc3_];
            _loc2_.update();
            _loc3_++;
         }
         _loc2_ = null;
      }
   }
}

