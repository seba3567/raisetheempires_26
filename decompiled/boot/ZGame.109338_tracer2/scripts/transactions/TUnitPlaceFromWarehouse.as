package transactions
{
   import core.managers.WorldObjectManager;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class TUnitPlaceFromWarehouse extends TWorldState
   {
      
      private var m_params:Object = new Object();
      
      private var m_code:String = null;
      
      public function TUnitPlaceFromWarehouse(param1:IEntity, param2:int)
      {
         this.m_params.warehouseIdNum = param2;
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("placeFromWarehouse",this.m_params);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_PLACED,this.m_code));
      }
   }
}

