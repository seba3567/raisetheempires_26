package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.managers.mayhemManager.MayhemClock;
   import displays.screens.partsGather.AMSBuildingPartsGather;
   import displays.screens.partsGather.BuildingPartsGather;
   import events.CloseEvent;
   import flash.events.EventDispatcher;
   import utils.ZGameTimeUtil;
   
   public class AMSBuildingPartsDialogState extends BuildingPartsDialogState
   {
      
      public function AMSBuildingPartsDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:PartsBuildingItem = null;
         if(ZGlobal.isHome())
         {
            MayhemClock.instance.show();
            _loc1_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_.code,PartsBuildingItem) as PartsBuildingItem;
            if(Boolean(_loc2_) && Boolean(_loc2_.numParts > 0) && _loc2_.requiresAnyParts())
            {
               stateMachine.propertyBag.eventDispatcher.addEventListener(BuildingPartsGather.FINISHED,onFinished,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,onCloseClick,false,0,true);
               AMSBuildingPartsGather.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc2_.code,data.@desc,owner);
               return;
            }
            onFinished(null);
         }
      }
      
      private function get duration() : Number
      {
         var _loc1_:ZGameTimeUtil = new ZGameTimeUtil();
         return _loc1_.parseTimeAsSeconds(data.@buildDuration,0);
      }
   }
}

