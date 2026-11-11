package displays.screens.contractScreen
{
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import zlabs.entity.IEntity;
   import zlabs.resource.SWFResource;
   
   public class MasteryUnitContractGrid extends UnitContractGrid
   {
      
      public function MasteryUnitContractGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:IEntity, param5:String, param6:String)
      {
         super(param1,param2,param3,param4,param5,param6);
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         return new MasteryUnitContractSlot(param1,param2,screen,m_listener,param3,param4,m_entity,m_items[param5],getMultFactor());
      }
   }
}

