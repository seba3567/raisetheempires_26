package displays.screens
{
   import core.managers.tutorialManager.TutorialManager;
   import displays.screens.contractScreen.ContractsScreen;
   import displays.screens.contractScreen.ResourceContractGrid;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class ResourceContractsScreen extends ContractsScreen
   {
      
      public function ResourceContractsScreen(param1:IEntity, param2:String, param3:String)
      {
         super(param1,param2,param3,"assets/displays/screens/PU_ResourceContract.swf");
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         m_grid = new ResourceContractGrid(m_window.grid_mc,m_resource,this,m_entity,m_type,m_subType);
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.CONTRACT_SCREEN_LOADED));
         }
      }
   }
}

