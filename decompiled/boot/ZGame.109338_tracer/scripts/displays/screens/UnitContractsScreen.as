package displays.screens
{
   import core.managers.tutorialManager.TutorialManager;
   import displays.screens.contractScreen.ContractsScreen;
   import displays.screens.contractScreen.UnitContractGrid;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class UnitContractsScreen extends ContractsScreen
   {
      
      public function UnitContractsScreen(param1:IEntity, param2:String, param3:String)
      {
         super(param1,param2,param3,"assets/displays/screens/PU_UnitsContract.swf");
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.hideManaUI();
         this.createGrid();
         if(TutorialManager.instance.active)
         {
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.CONTRACT_SCREEN_LOADED));
         }
      }
      
      private function hideManaUI() : void
      {
         m_window.elementZ_mc.visible = false;
         m_window.elementZ_mc.glowAnim_mc.gotoAndStop(1);
      }
      
      protected function createGrid() : void
      {
         m_grid = new UnitContractGrid(m_window.grid_mc,m_resource,this,m_entity,m_type,m_subType);
      }
   }
}

