package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.managers.EspionageHQManager;
   import dispatchers.UIDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.genericPopup.GenericPopup1B;
   import displays.screens.EspionageHQScreen;
   import displays.screens.contractScreen.EspionageHQContractSlot;
   import entity.GameDataComponent;
   import flash.events.EventDispatcher;
   import transactions.TEspionageFinish;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class EspionageHQDialogState extends DialogState
   {
      
      public function EspionageHQDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         var _loc1_:GameDataComponent = null;
         super.performEnterActions();
         if(!ZGlobal.isVisiting())
         {
            if(EspionageHQManager.instance.isInited == false)
            {
               _loc1_ = owner.lookupComponentByType(GameDataComponent) as GameDataComponent;
               if(_loc1_)
               {
                  EspionageHQManager.instance.init(_loc1_);
               }
            }
            stateMachine.propertyBag.eventDispatcher.addEventListener(EspionageHQContractSlot.FINISH_SPY,this.onSpyEquipFinished,false,0,true);
            UIDispatcher.instance.addEventListener(EspionageHQContractSlot.DEPLOY_SPY,this.onSpyDeployed,false,0,true);
         }
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         super.performExitActions(param1);
         if(!ZGlobal.isVisiting())
         {
            stateMachine.propertyBag.eventDispatcher.removeEventListener(EspionageHQContractSlot.FINISH_SPY,this.onSpyEquipFinished);
            UIDispatcher.instance.removeEventListener(EspionageHQContractSlot.DEPLOY_SPY,this.onSpyDeployed);
         }
      }
      
      override protected function showDialog() : void
      {
         if(ZGlobal.isHome())
         {
            EspionageHQScreen.display(EventDispatcher(stateMachine.propertyBag.eventDispatcher),owner);
         }
      }
      
      public function showEspionageHQScreen() : void
      {
         this.showDialog();
      }
      
      protected function onSpyDeployed(param1:WorldEvent) : void
      {
         var _loc2_:GenericPopup1B = null;
         if(param1.eventData.spyItem)
         {
            EspionageHQManager.instance.spyDeploy = param1.eventData.spyItem.code;
            _loc2_ = new GenericPopup1B(ZGameUtils.ZlocT("Dialogs","Espionage_HQ_Visit_Neighbor"),null,GenericPopup.OK,this.highlightArrow);
            PopupManager.instance.push(_loc2_);
         }
      }
      
      private function highlightArrow(param1:GenericPopupEvent) : void
      {
         EspionageHQManager.showhighlight();
      }
      
      protected function onSpyEquipFinished(param1:WorldEvent) : void
      {
         if(param1.eventData.spyItem)
         {
            EspionageHQManager.instance.spyEquip = param1.eventData.spyItem.code;
            this.finishSpy(param1.eventData.spyItem.code);
         }
      }
      
      private function finishSpy(param1:String) : void
      {
         var _loc2_:TEspionageFinish = new TEspionageFinish(owner,param1);
         TransactionManager.addTransaction(_loc2_);
      }
   }
}

