package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import dispatchers.UIDispatcher;
   import zlabs.events.WorldEvent;
   
   public class MasteryFactoryDialogState extends DialogState
   {
      
      public function MasteryFactoryDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
      }
      
      protected function onPowerupFinished(param1:WorldEvent) : void
      {
         stateMachine.storeReferenceData(param1.eventData.unitItem.name);
         clickNextState();
      }
      
      override protected function addListeners() : void
      {
         super.addListeners();
         UIDispatcher.instance.addEventListener(MessageOfTheDayManager.SHOW_MASTERYFACTORY_DIALOG,this.onShowMasteryFactory,false,0,true);
      }
      
      override protected function removeListeners() : void
      {
         super.removeListeners();
         UIDispatcher.instance.removeEventListener(MessageOfTheDayManager.SHOW_MASTERYFACTORY_DIALOG,this.onShowMasteryFactory);
      }
      
      private function onShowMasteryFactory(param1:WorldEvent) : void
      {
         this.showDialog();
      }
   }
}

