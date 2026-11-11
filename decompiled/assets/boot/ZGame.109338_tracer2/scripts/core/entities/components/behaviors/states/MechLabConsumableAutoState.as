package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.ExperimentsManager;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import dispatchers.UIDispatcher;
   import displays.screens.MechLabConsumableScreen;
   import events.CloseEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import zlabs.events.WorldEvent;
   
   public class MechLabConsumableAutoState extends AutoDialogState
   {
      
      public function MechLabConsumableAutoState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MECH_LAB_MASTER) >= ExperimentsManager.VARIANT_VALUE_MECH_LAB_ENABLED)
         {
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_TITAN_FIGHT_MASTER) >= ExperimentsManager.VARIANT_TITAN_FIGHT_ACTIVE)
            {
               clickNextState();
               (this.stateMachine.currentState as DialogState).onClick(null);
            }
            else
            {
               stateMachine.propertyBag.eventDispatcher.addEventListener(MechLabConsumableScreen.FINISHED,this.onFinished,false,0,true);
               stateMachine.propertyBag.eventDispatcher.addEventListener(CloseEvent.CLOSE,this.onCloseClick,false,0,true);
               MechLabConsumableScreen.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),owner);
            }
         }
      }
      
      protected function onFinished(param1:Event) : void
      {
         this.onCloseClick(null);
         clickNextState();
      }
      
      override protected function addListeners() : void
      {
         super.addListeners();
         UIDispatcher.instance.addEventListener(MessageOfTheDayManager.SHOW_MECHLAB_ACTIVATION_DIALOG,this.onShowDialog,false,0,true);
      }
      
      override protected function removeListeners() : void
      {
         super.removeListeners();
         UIDispatcher.instance.removeEventListener(MessageOfTheDayManager.SHOW_MECHLAB_ACTIVATION_DIALOG,this.onShowDialog);
      }
      
      override protected function onCloseClick(param1:CloseEvent) : void
      {
         stateMachine.propertyBag.eventDispatcher.removeEventListener(MechLabConsumableScreen.FINISHED,this.onFinished);
         stateMachine.propertyBag.eventDispatcher.removeEventListener(CloseEvent.CLOSE,this.onCloseClick);
      }
      
      private function onShowDialog(param1:WorldEvent) : void
      {
         this.showDialog();
      }
   }
}

