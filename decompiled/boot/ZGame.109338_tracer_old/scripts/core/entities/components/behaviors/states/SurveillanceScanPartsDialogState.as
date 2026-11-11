package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.managers.UnitDropManager;
   import dispatchers.UIDispatcher;
   import displays.screens.partsGather.BuildingPartsGather;
   import displays.screens.partsGather.SurveillanceScanPartsGather;
   import events.CloseEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class SurveillanceScanPartsDialogState extends DialogState
   {
      
      public static const DISPLAY:String = "SurveillanceScanPartsDialogDisplay";
      
      public function SurveillanceScanPartsDialogState(param1:BehaviorStateInit)
      {
         super(param1);
         UIDispatcher.instance.addEventListener(SurveillanceScanPartsDialogState.DISPLAY,this.onDisplay,false,0,true);
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:PartsBuildingItem = null;
         if(ZGlobal.isHome())
         {
            _loc1_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_.code,PartsBuildingItem) as PartsBuildingItem;
            if(Boolean(_loc2_) && Boolean(_loc2_.numParts > 0) && _loc2_.requiresAnyParts())
            {
               stateMachine.propertyBag.eventDispatcher.addEventListener(BuildingPartsGather.FINISHED,this.onFinished,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,this.onCloseClick,false,0,true);
               SurveillanceScanPartsGather.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc2_.code,data.@desc,owner);
               return;
            }
            this.onFinished(null);
         }
      }
      
      private function onDisplay(param1:Event) : void
      {
         UIDispatcher.instance.removeEventListener(SurveillanceScanPartsDialogState.DISPLAY,this.onDisplay);
         this.showDialog();
      }
      
      protected function onFinished(param1:Event) : void
      {
         this.onCloseClick(null);
         if(UnitDropManager.instance.numUnrevealedUnits > 0)
         {
            clickNextState();
         }
      }
      
      override protected function onCloseClick(param1:CloseEvent) : void
      {
         stateMachine.propertyBag.eventDispatcher.removeEventListener(BuildingPartsGather.FINISHED,this.onFinished);
         stateMachine.propertyBag.eventDispatcher.removeEventListener(CloseEvent.CLOSE,this.onCloseClick);
         UIDispatcher.instance.addEventListener(SurveillanceScanPartsDialogState.DISPLAY,this.onDisplay);
      }
   }
}

