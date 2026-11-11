package transactions
{
   import core.managers.warehouseManager.WarehouseHoverManager;
   import entity.GameDataComponent;
   import events.MarketEvent;
   import zlabs.entity.IEntity;
   
   public class TWarehouseAdd extends TWorldState
   {
      
      private var m_params:Object;
      
      public function TWarehouseAdd(param1:IEntity, param2:IEntity, param3:String, param4:int)
      {
         super(param1);
         var _loc5_:GameDataComponent = GameDataComponent.getGameDataComponent(param2);
         this.m_params = new Object();
         this.m_params.item = param3;
         this.m_params.itemid = _loc5_.id;
         this.m_params.facid = WarehouseHoverManager.instance.sourceId;
         if(param4 > MarketEvent.SOURCE_NONE)
         {
            this.m_params.source = param4;
         }
      }
      
      override public function perform() : void
      {
         signedWorldAction("add",this.m_params);
      }
   }
}

