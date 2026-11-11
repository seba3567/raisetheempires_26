package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.DecorationTargetComponent;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IState;
   import core.gameobjects.GameItem;
   import displays.screens.researchScreens.ResearchUnitSelectionScreen;
   import displays.screens.researchScreens.ResearchUpgradeScreen;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   
   public class ResearchDialogState extends DialogState
   {
      
      public function ResearchDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         stateMachine.propertyBag.eventDispatcher.addEventListener(ResearchUpgradeScreen.UPGRADE_SELECTED,this.onUpgradeSelected,false,0,true);
         var _loc1_:GameItem = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
         ResearchUnitSelectionScreen.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc1_.referenceSubtype,owner,null,false);
      }
      
      protected function onUpgradeSelected(param1:WorldEvent) : void
      {
         var _loc2_:Dictionary = null;
         stateMachine.propertyBag.eventDispatcher.removeEventListener(ResearchUpgradeScreen.UPGRADE_SELECTED,this.onUpgradeSelected);
         m_stateMachine.storeReferenceData(param1.eventData.referenceItem.name,param1.eventData.researchItem.name);
         var _loc3_:DecorationTargetComponent = owner.lookupComponentByType(DecorationTargetComponent) as DecorationTargetComponent;
         if(_loc3_)
         {
            _loc2_ = _loc3_.getDiscount();
         }
         ZGlobal.player.buyItem(param1.eventData.referenceItem,param1.eventData.referenceItem.cash != 0,1,null,false,_loc2_);
         clickNextState();
         Zlab.processManager.schedule(500,this,this.showSpeedupScreen);
      }
      
      private function showSpeedupScreen() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         var _loc1_:IState = stateMachine.currentState;
         if(Boolean(_loc1_) && _loc1_ is AutoDialogState)
         {
            AutoDialogState(_loc1_).showSpeedupScreen();
         }
      }
      
      override protected function getSetStateReferenceItemName() : String
      {
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByName(stateMachine.referenceItemName,GameItem) as GameItem;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByName(stateMachine.researchItemName,GameItem) as GameItem;
         return _loc1_.code + ":" + _loc2_.code;
      }
   }
}

