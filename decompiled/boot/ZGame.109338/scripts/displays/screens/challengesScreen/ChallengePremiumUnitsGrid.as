package displays.screens.challengesScreen
{
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import displays.screens.gridScreen.GridSlot;
   import displays.screens.pickUnitsScreen.PremiumUnitSlotV2;
   import displays.screens.pickUnitsScreen.PremiumUnitsGrid;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import zlabs.resource.SWFResource;
   
   public class ChallengePremiumUnitsGrid extends PremiumUnitsGrid
   {
      
      private var m_prioritiseSupportUnits:Boolean = false;
      
      public function ChallengePremiumUnitsGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:String, param5:int, param6:Boolean, param7:int = 0)
      {
         this.m_prioritiseSupportUnits = param6;
         super(param1,param2,param3,"Buildable",param4,null,param5,param7);
      }
      
      override protected function init(param1:MovieClip, param2:SWFResource) : void
      {
         setDimensions(5,2);
         load(param1,param2);
      }
      
      override protected function resetAnchorPosition() : void
      {
         setAnchor(screen.origin_mc.x,screen.origin_mc.y);
      }
      
      override protected function getMultFactor() : Number
      {
         return 1;
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         var _loc6_:UnitItem = m_units.shift();
         return new PremiumUnitSlotV2(param1,param2,screen,param3,param4,_loc6_,this.getMultFactor(),this.m_prioritiseSupportUnits);
      }
      
      override protected function hasSpecialCard() : Boolean
      {
         return false;
      }
      
      override protected function fillOutHeader() : void
      {
      }
      
      override protected function sortItems(param1:GameItem, param2:GameItem) : int
      {
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         if(Boolean(this.m_prioritiseSupportUnits) && Boolean(param1 as UnitItem) && Boolean(param2 as UnitItem))
         {
            _loc3_ = (param1 as UnitItem).secondaryAbility ? true : false;
            _loc4_ = (param2 as UnitItem).secondaryAbility ? true : false;
            if(_loc3_ != _loc4_)
            {
               if(_loc3_)
               {
                  return -1;
               }
               return 1;
            }
         }
         return super.sortItems(param1,param2);
      }
   }
}

