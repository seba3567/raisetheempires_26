package displays.screens
{
   import dispatchers.ResourceDispatcher;
   import displays.screens.contractScreen.ContractsScreen;
   import displays.screens.contractScreen.ElementZContractGrid;
   import events.ResourceUpdatedEvent;
   import zlabs.entity.IEntity;
   import zlabs.resource.SWFResource;
   
   public class ElementZColliderContractScreen extends ContractsScreen
   {
      
      public function ElementZColliderContractScreen(param1:IEntity, param2:String, param3:String)
      {
         super(param1,param2,param3,this.assetUrl);
      }
      
      private function get assetUrl() : String
      {
         return "assets/displays/screens/PU_ZColliderContract.swf";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         ResourceDispatcher.instance.addEventListener(ResourceUpdatedEvent.ENERGY,onResourcesUpdated,false,0,true);
         m_grid = new ElementZContractGrid(m_window.grid_mc,m_resource,this,m_entity,m_type,m_subType);
      }
   }
}

