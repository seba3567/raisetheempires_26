package displays.screens.contractScreen
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import displays.screens.gridScreen.GridScreen;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import zlabs.resource.SWFResource;
   
   public class EspionageHQContractGrid extends GridScreen
   {
      
      private static const NUM_CARD_COLUMNS:int = 4;
      
      private static const NUM_CARD_ROWS:int = 1;
      
      protected var m_type:String = null;
      
      protected var m_subtype:String = null;
      
      protected var m_spies:Array = new Array();
      
      public function EspionageHQContractGrid(param1:MovieClip, param2:SWFResource, param3:String, param4:String)
      {
         this.m_type = param3;
         this.m_subtype = param4;
         super();
         this.init(param1,param2);
      }
      
      protected function init(param1:MovieClip, param2:SWFResource) : void
      {
         setDimensions(NUM_CARD_COLUMNS,NUM_CARD_ROWS);
         this.load(param1,param2);
         goToPage(0,false);
      }
      
      override protected function load(param1:MovieClip, param2:SWFResource) : void
      {
         this.createItemList();
         super.load(param1,param2);
         setAnchor(18,210);
      }
      
      protected function createItemList() : void
      {
         var _loc2_:XML = null;
         var _loc1_:XMLList = ZGlobal.gameSettings.getItemsByType(this.m_type,this.m_subtype);
         for each(_loc2_ in _loc1_)
         {
            this.m_spies.push(new GameItem(_loc2_));
         }
      }
      
      override public function get numCards() : int
      {
         return this.m_spies.length;
      }
      
      override protected function getMultFactor() : Number
      {
         return 1;
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         return new EspionageHQContractSlot(param1,param2,screen,this.m_spies[param5],this.getMultFactor(),param3,param4);
      }
      
      override protected function createSpecialCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int) : GridSlot
      {
         return new EspionageHQComingSoonSlot(param1,param2,param3,param4);
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return this.m_spies.length < NUM_CARD_COLUMNS;
      }
   }
}

