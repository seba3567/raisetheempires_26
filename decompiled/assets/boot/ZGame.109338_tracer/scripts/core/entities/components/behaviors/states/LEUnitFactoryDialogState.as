package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.managers.LEUnitFactoryManager;
   import displays.screens.leUnitFactoryScreens.LEUnitSelectionScreen;
   import flash.events.EventDispatcher;
   import zlabs.events.WorldEvent;
   
   public class LEUnitFactoryDialogState extends DialogState
   {
      
      private static var m_activeState:LEUnitFactoryDialogState;
      
      public function LEUnitFactoryDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         if(m_activeState != null)
         {
            m_activeState.removePlacementListeners();
         }
         m_activeState = this;
         LEUnitFactoryManager.instance.eventDispatcher.addEventListener(LEUnitSelectionScreen.FINISH_LE_UNIT,this.onLEUnitFinished,false,0,true);
         LEUnitFactoryManager.instance.eventDispatcher.addEventListener(LEUnitFactoryManager.START_PLACEMENT,this.onLEUnitStartPlacement,false,0,true);
         var _loc1_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
         LEUnitSelectionScreen.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc1_.referenceSubtype,owner,false);
      }
      
      private function onLEUnitStartPlacement(param1:WorldEvent) : void
      {
      }
      
      protected function onLEUnitFinished(param1:WorldEvent) : void
      {
         stateMachine.storeReferenceData(param1.eventData.unitItem.code);
         clickNextState();
      }
      
      override protected function addListeners() : void
      {
         super.addListeners();
      }
      
      override protected function removeListeners() : void
      {
         super.removeListeners();
         this.removePlacementListeners();
      }
      
      private function removePlacementListeners() : void
      {
         LEUnitFactoryManager.instance.eventDispatcher.removeEventListener(LEUnitSelectionScreen.FINISH_LE_UNIT,this.onLEUnitFinished);
         LEUnitFactoryManager.instance.eventDispatcher.removeEventListener(LEUnitFactoryManager.START_PLACEMENT,this.onLEUnitStartPlacement);
      }
      
      private function onShowPowerUpFactory(param1:WorldEvent) : void
      {
         this.showDialog();
      }
   }
}

