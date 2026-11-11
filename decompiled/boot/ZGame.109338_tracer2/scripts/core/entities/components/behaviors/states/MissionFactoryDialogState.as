package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import dispatchers.UIDispatcher;
   import displays.screens.MissionContractsScreen;
   import displays.screens.contractScreen.MissionContractSlot;
   import flash.events.EventDispatcher;
   import zlabs.events.WorldEvent;
   
   public class MissionFactoryDialogState extends DialogState
   {
      
      public function MissionFactoryDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = null;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_SPECOPS_PARTS) > ZGlobal.EXPERIMENT_MISSION_BUILDABLE_PARTS_V2)
         {
            stateMachine.propertyBag.eventDispatcher.addEventListener(MissionContractSlot.FINISH_MISSION,this.onMissionFinished,false,0,true);
            _loc1_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            MissionContractsScreen.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc1_.referenceSubtype,owner,false);
         }
      }
      
      protected function onMissionFinished(param1:WorldEvent) : void
      {
         stateMachine.storeReferenceData(param1.eventData.unitItem.name);
         clickNextState();
      }
      
      override protected function addListeners() : void
      {
         super.addListeners();
         UIDispatcher.instance.addEventListener(MissionContractsScreen.SHOW_MISSIONCONTRACTS_DIALOG,this.onShowMissionContractsFactory,false,0,true);
      }
      
      override protected function removeListeners() : void
      {
         super.removeListeners();
         UIDispatcher.instance.removeEventListener(MissionContractsScreen.SHOW_MISSIONCONTRACTS_DIALOG,this.onShowMissionContractsFactory);
      }
      
      private function onShowMissionContractsFactory(param1:WorldEvent) : void
      {
         this.showDialog();
      }
   }
}

