package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.BountyCenterPick;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.managers.BountyCenterManager;
   import dispatchers.UIDispatcher;
   import displays.popups.BountyCenterPopup;
   import displays.popups.buyEnergy.BuyEnergyPopup;
   import flash.events.Event;
   import transactions.TInitUser;
   import zlabs.managers.PopupManager;
   
   public class BountyCenterDialogState extends DialogState
   {
      
      protected var m_activatedPickMenu:BountyCenterPick = null;
      
      public function BountyCenterDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         if(ZGlobal.isHome())
         {
            BountyCenterManager.instance.addEventListener(BountyCenterManager.EVENT_STATE_CHANGE,BountyCenterManager.instance.refreshPicks);
            UIDispatcher.instance.addEventListener(TInitUser.EVENT_COMPLETE,this.onBountyCenterStateChange,false,0,true);
            BountyCenterManager.instance.refreshPicks();
         }
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         super.performExitActions(param1);
         if(ZGlobal.isHome())
         {
            BountyCenterManager.instance.removeEventListener(BountyCenterManager.EVENT_STATE_CHANGE,BountyCenterManager.instance.refreshPicks);
            BountyCenterManager.instance.removeActivatedPick();
         }
      }
      
      protected function onBountyCenterStateChange(param1:Event = null) : void
      {
      }
      
      override protected function showDialog() : void
      {
         var _loc1_:BountyCenterPopup = null;
         if(ZGlobal.isHome())
         {
            _loc1_ = new BountyCenterPopup(this.onPopupClosed);
            PopupManager.instance.push(_loc1_);
         }
      }
      
      protected function onPopupClosed(param1:Event) : void
      {
         switch(param1.type)
         {
            case BountyCenterPopup.ACCEPTED_ACTIVATE:
               if(BountyCenterManager.instance.hasSufficientEnergy() == false)
               {
                  BuyEnergyPopup.enableWatchToEarn();
                  BuyEnergyPopup.show();
               }
               else
               {
                  BountyCenterManager.instance.deductEnergy();
                  BountyCenterManager.instance.activate(false);
               }
               break;
            case BountyCenterPopup.ACCEPTED_SKIP_COOLING:
               if(BountyCenterManager.instance.hasSufficientCash() && BountyCenterManager.instance.hasSufficientEnergy())
               {
                  BountyCenterManager.instance.deductCash();
                  BountyCenterManager.instance.deductEnergy();
                  BountyCenterManager.instance.activate(true);
               }
         }
      }
   }
}

