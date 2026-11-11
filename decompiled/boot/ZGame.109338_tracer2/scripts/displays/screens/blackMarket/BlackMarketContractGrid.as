package displays.screens.blackMarket
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.WorldObjectManager;
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import zlabs.resource.SWFResource;
   
   public class BlackMarketContractGrid extends GridScreen
   {
      
      protected var m_items:Array = null;
      
      protected var m_listener:EventDispatcher;
      
      public function BlackMarketContractGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:Array)
      {
         this.m_items = param4;
         super();
         this.initGridSize();
         this.m_listener = param3;
         load(param1,param2);
      }
      
      protected function initGridSize() : void
      {
         setDimensions(2,2);
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         var _loc6_:Boolean = false;
         var _loc7_:GameItem = ZGlobal.gameSettings.getItemByCode(this.m_items[param5].code,GameItem) as GameItem;
         var _loc8_:Dictionary = WorldObjectManager.instance.getObjectsBySubType(_loc7_.type,_loc7_.subType);
         return new BlackMarketUnitContactSlot(param1,param2,screen,this.m_listener,param3,param4,this.m_items[param5]);
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
         var _loc2_:BlackMarketUnitContactSlot = null;
         super.createCards(param1);
         for each(_loc2_ in m_cards)
         {
            _loc2_.rollOverTarget.removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
            _loc2_.rollOverTarget.removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
            _loc2_.disable();
         }
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return false;
      }
      
      override protected function onRightClick(param1:MouseEvent) : void
      {
         super.onRightClick(param1);
         StatsManager.count(BlackMarketContractScreen.BLACKMARKET_COUNTER,"navigateright/left");
      }
      
      override protected function onLeftClick(param1:MouseEvent) : void
      {
         super.onLeftClick(param1);
         StatsManager.count(BlackMarketContractScreen.BLACKMARKET_COUNTER,"navigateright/left");
      }
   }
}

