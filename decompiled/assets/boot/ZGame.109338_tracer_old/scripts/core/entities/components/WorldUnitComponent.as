package core.entities.components
{
   import core.gameobjects.GameItem;
   import core.managers.worldUnitManager.WorldUnitManager;
   import entity.EntityInit;
   import zlabs.entity.EntityComponent;
   
   public class WorldUnitComponent extends EntityComponent
   {
      
      private var m_code:String = null;
      
      private var m_type:uint = 0;
      
      public function WorldUnitComponent(param1:EntityInit)
      {
         super();
         this.m_code = (param1.m_item as GameItem).code;
         if(null != param1.m_object && null != param1.m_object.data && null != param1.m_object.data.unit)
         {
            this.m_type = param1.m_object.data.unit;
         }
      }
      
      public function set type(param1:uint) : void
      {
         this.m_type = param1;
      }
      
      public function get type() : uint
      {
         return this.m_type;
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         WorldUnitManager.instance.registerUnit(this.m_code,this);
         if(this.m_type != WorldUnitManager.UNIT_AVAILABLE)
         {
            WorldUnitManager.instance.holdUnitByComponent(this,this.m_code,this.m_type);
         }
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         WorldUnitManager.instance.unRegisterUnit(this.m_code,this);
      }
   }
}

