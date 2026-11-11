package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import displays.screens.partsGather.BuildingPartsGatherCyber;
   import entity.WarehouseComponent;
   import events.CloseEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   
   public class BuildingPartsCyberState extends BuildingPartsDialogState
   {
      
      public function BuildingPartsCyberState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function onFinished(param1:Event) : void
      {
         var _loc3_:WarehouseComponent = null;
         onCloseClick(null);
         var _loc2_:IEntity = ZGameUtils.getWareHouse("WHA1");
         if(_loc2_ != null)
         {
            _loc3_ = WarehouseComponent.getWarehouseComponent(_loc2_);
            _loc3_.upgradeBycyber();
         }
         clickNextState();
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:PartsBuildingItem = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(ZGlobal.isHome())
         {
            _loc1_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_.code,PartsBuildingItem) as PartsBuildingItem;
            if(Boolean(_loc2_) && Boolean(_loc2_.numParts > 0) && _loc2_.requiresAnyParts())
            {
               stateMachine.propertyBag.eventDispatcher.addEventListener(BuildingPartsGatherCyber.FINISHED,this.onFinished,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,onCloseClick,false,0,true);
               _loc3_ = data.@desc;
               _loc4_ = data.@desc2;
               if(_loc2_.xml.@buildingPartsDesc != undefined)
               {
                  _loc3_ = _loc2_.xml.@buildingPartsDesc;
               }
               if(_loc2_.xml.@buildingPartsDesc2 != undefined)
               {
                  _loc4_ = _loc2_.xml.@buildingPartsDesc2;
               }
               BuildingPartsGatherCyber.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc2_.code,_loc3_,owner,data.@tit,_loc4_);
               return;
            }
            this.onFinished(null);
         }
      }
   }
}

