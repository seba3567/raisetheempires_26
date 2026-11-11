package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.ExperimentsManager;
   import dispatchers.UIDispatcher;
   import displays.screens.partsGather.MechLabPartsGather;
   import entity.GameDataComponent;
   import events.CloseEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import zlabs.events.WorldEvent;
   
   public class MechLabPartsDialogState extends DialogState
   {
      
      public function MechLabPartsDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MECH_LAB_MASTER) >= ExperimentsManager.VARIANT_VALUE_MECH_LAB_ENABLED)
         {
            stateMachine.propertyBag.eventDispatcher.addEventListener(MechLabPartsGather.FINISHED,this.onFinished,false,0,true);
            stateMachine.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,this.onCloseClick,false,0,true);
            MechLabPartsGather.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),owner);
         }
      }
      
      protected function onFinished(param1:Event) : void
      {
         this.storeCurrentLevel();
         this.onCloseClick(null);
         clickNextState();
      }
      
      private function storeCurrentLevel() : void
      {
         var _loc1_:GameDataComponent = GameDataComponent.getGameDataComponent(owner);
         if(!_loc1_.userData.data)
         {
            _loc1_.userData.data = new Object();
         }
         _loc1_.userData.data.playerLevel = ZGlobal.player.level;
      }
      
      override protected function addListeners() : void
      {
         super.addListeners();
         UIDispatcher.instance.addEventListener(MechLabPartsGather.SHOW_MECHLAB_PARTS_GATHER,this.onShowDialog,false,0,true);
      }
      
      override protected function removeListeners() : void
      {
         super.removeListeners();
         UIDispatcher.instance.removeEventListener(MechLabPartsGather.SHOW_MECHLAB_PARTS_GATHER,this.onShowDialog);
      }
      
      override protected function onCloseClick(param1:CloseEvent) : void
      {
         stateMachine.propertyBag.eventDispatcher.removeEventListener(MechLabPartsGather.FINISHED,this.onFinished);
         stateMachine.propertyBag.eventDispatcher.removeEventListener(CloseEvent.CLOSE,this.onCloseClick);
      }
      
      private function onShowDialog(param1:WorldEvent) : void
      {
         this.showDialog();
      }
   }
}

