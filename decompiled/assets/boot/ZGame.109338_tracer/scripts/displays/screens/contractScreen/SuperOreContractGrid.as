package displays.screens.contractScreen
{
   import displays.screens.gridScreen.GridSlot;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import zlabs.entity.IEntity;
   import zlabs.resource.SWFResource;
   
   public class SuperOreContractGrid extends ResourceContractGrid
   {
      
      private var m_multiplier:int;
      
      public function SuperOreContractGrid(param1:MovieClip, param2:SWFResource, param3:EventDispatcher, param4:IEntity, param5:String, param6:String, param7:String = null, param8:int = 1)
      {
         this.m_multiplier = param8;
         super(param1,param2,param3,param4,param5,param6,param7);
      }
      
      override protected function createCard(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:int = 0) : GridSlot
      {
         return new SuperOreContractSlot(param1,param2,screen,m_listener,param3,param4,m_entity,m_items[param5],getMultFactor(),m_resourceType,this.m_multiplier);
      }
   }
}

