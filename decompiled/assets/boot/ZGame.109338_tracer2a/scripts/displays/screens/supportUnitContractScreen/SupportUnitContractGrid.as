package displays.screens.supportUnitContractScreen
{
   import core.entities.components.DecorationTargetComponent;
   import displays.screens.contractScreen.UnitContractGrid;
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import zlabs.entity.IEntity;
   import zlabs.resource.SWFResource;
   
   public class SupportUnitContractGrid extends UnitContractGrid
   {
      
      private var m_discountInfo:Dictionary;
      
      public function SupportUnitContractGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:IEntity, param5:String, param6:String)
      {
         this.m_discountInfo = DecorationTargetComponent.getDiscountForObject(param4);
         super(param1,param2,param3,param4,param5,param6);
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         return new SupportUnitContractSlot(param1,param2,screen,m_listener,param3,param4,m_entity,m_items[param5],getMultFactor(),this.m_discountInfo);
      }
   }
}

