package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.gameobjects.UpgradeItem;
   import dispatchers.UIDispatcher;
   import displays.screens.SpeedupScreen;
   import displays.screens.researchScreens.MegaResearchUnitSelectionScreen;
   import events.CloseEvent;
   import flash.events.EventDispatcher;
   import zlabs.events.WorldEvent;
   
   public class MegaResearchAutoDialogState extends AutoDialogState
   {
      
      public function MegaResearchAutoDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         m_alwaysDispatchProgress = true;
         UIDispatcher.instance.addEventListener(MegaResearchUnitSelectionScreen.SHOW_SPEEDUP_SCREEN,this.onShowSpeedupScreen,false,0,true);
         super.performEnterActions();
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         m_alwaysDispatchProgress = false;
         super.performExitActions(param1);
      }
      
      override public function showSpeedupScreen() : void
      {
         super.showDialog();
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:UnitItem = null;
         if(!m_window)
         {
            stateMachine.propertyBag.eventDispatcher.addEventListener(MegaResearchUnitSelectionScreen.EXIT,onExit,false,0,true);
            _loc1_ = stateMachine.propertyBag.getProperty(dataProperty,null) as GameItem;
            _loc2_ = ZGlobal.gameSettings.getItemByName(stateMachine.researchItemName,UnitItem) as UnitItem;
            m_window = MegaResearchUnitSelectionScreen.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),_loc1_.referenceSubtype,owner,_loc2_,false);
         }
      }
      
      override protected function onCloseClick(param1:CloseEvent) : void
      {
         if(Boolean(m_window) && m_window is SpeedupScreen)
         {
            super.onCloseClick(param1);
         }
         else
         {
            stateMachine.propertyBag.eventDispatcher.removeEventListener(MegaResearchUnitSelectionScreen.EXIT,onExit);
            m_window = null;
         }
      }
      
      override protected function removeListeners() : void
      {
         UIDispatcher.instance.removeEventListener(MegaResearchUnitSelectionScreen.SHOW_SPEEDUP_SCREEN,this.onShowSpeedupScreen);
         super.removeListeners();
      }
      
      private function onShowSpeedupScreen(param1:WorldEvent) : void
      {
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByName(stateMachine.researchItemName,GameItem) as GameItem;
         var _loc3_:GameItem = ZGlobal.gameSettings.getItemByName(stateMachine.referenceItemName,GameItem) as GameItem;
         if(Boolean(_loc2_) && Boolean(_loc2_.code == UnitItem(param1.eventData.unitItem).code) && (Boolean(_loc3_) && Boolean(_loc3_.code == UpgradeItem(param1.eventData.upgradeItem).code)))
         {
            this.onCloseClick(null);
            super.showDialog();
         }
      }
   }
}

