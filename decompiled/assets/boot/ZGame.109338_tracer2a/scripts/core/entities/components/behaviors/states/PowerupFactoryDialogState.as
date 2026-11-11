package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import dispatchers.UIDispatcher;
   import displays.screens.powerupFactoryScreens.PowerupSelectionScreen;
   import flash.events.EventDispatcher;
   import zlabs.events.WorldEvent;
   
   public class PowerupFactoryDialogState extends DialogState
   {
      
      public function PowerupFactoryDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         stateMachine.propertyBag.eventDispatcher.addEventListener(PowerupSelectionScreen.FINISH_POWERUP,this.onPowerupFinished,false,0,true);
         var _loc1_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
         PowerupSelectionScreen.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc1_.referenceSubtype,owner,false);
      }
      
      protected function onPowerupFinished(param1:WorldEvent) : void
      {
         stateMachine.storeReferenceData(param1.eventData.unitItem.name);
         clickNextState();
      }
      
      override protected function addListeners() : void
      {
         super.addListeners();
         UIDispatcher.instance.addEventListener(MessageOfTheDayManager.SHOW_POWERUPFACTORY_DIALOG,this.onShowPowerUpFactory,false,0,true);
      }
      
      override protected function removeListeners() : void
      {
         super.removeListeners();
         UIDispatcher.instance.removeEventListener(MessageOfTheDayManager.SHOW_POWERUPFACTORY_DIALOG,this.onShowPowerUpFactory);
      }
      
      private function onShowPowerUpFactory(param1:WorldEvent) : void
      {
         this.showDialog();
      }
   }
}

