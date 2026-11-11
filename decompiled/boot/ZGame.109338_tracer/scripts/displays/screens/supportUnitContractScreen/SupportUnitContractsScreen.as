package displays.screens.supportUnitContractScreen
{
   import displays.screens.UnitContractsScreen;
   import zlabs.entity.IEntity;
   import zlabs.resource.SWFResource;
   
   public class SupportUnitContractsScreen extends UnitContractsScreen
   {
      
      public function SupportUnitContractsScreen(param1:IEntity, param2:String, param3:String)
      {
         super(param1,param2,param3);
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
      }
      
      override protected function createGrid() : void
      {
         m_grid = new SupportUnitContractGrid(m_window.grid_mc,m_resource,this,m_entity,m_type,m_subType);
      }
   }
}

