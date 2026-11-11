package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.entities.components.states.IState;
   import core.managers.ExperimentsManager;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import dispatchers.UIDispatcher;
   import displays.screens.MechLabProductionScreen;
   import displays.screens.mechBattleSetup.MechBattleSetup;
   import events.CloseEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import zlabs.events.WorldEvent;
   
   public class MechLabProductionAutoState extends AutoDialogState
   {
      
      public function MechLabProductionAutoState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_TITAN_FIGHT_MASTER) >= ExperimentsManager.VARIANT_TITAN_FIGHT_ACTIVE)
         {
            window = MechLabProductionScreen.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),owner);
         }
      }
      
      override public function load(param1:IMachine, param2:IState) : void
      {
         super.load(param1,param2);
         if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
         {
            MechBattleSetup.ENABLED = true;
         }
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         if(ZGlobal.visitMode == ZGlobal.MODE_HOME)
         {
            MechBattleSetup.ENABLED = true;
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
         super.onCloseClick(param1);
      }
      
      private function onShowDialog(param1:WorldEvent) : void
      {
         this.showDialog();
      }
   }
}

