package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import entity.WarehouseComponent;
   import flash.events.Event;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   
   public class BuildingPartsAmityState extends BuildingPartsCyberState
   {
      
      public function BuildingPartsAmityState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function onFinished(param1:Event) : void
      {
         var _loc3_:WarehouseComponent = null;
         onCloseClick(null);
         var _loc2_:IEntity = ZGameUtils.getWareHouse("WHN1");
         if(_loc2_ != null)
         {
            _loc3_ = WarehouseComponent.getWarehouseComponent(_loc2_);
            _loc3_.upgradeBycyber();
         }
         clickNextState();
      }
   }
}

