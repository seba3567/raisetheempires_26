package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.managers.TreasureVaultManager;
   import displays.popups.TreasureVaultPopup;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import transactions.TInitUser;
   import zlabs.entity.PropertyReference;
   import zlabs.managers.WindowManager;
   
   public class TreasureVaultDialogState extends DialogState
   {
      
      private var overlayIconNameProperty:PropertyReference = new PropertyReference("@Overlay.iconName");
      
      private var m_actionIcon:String = null;
      
      private var m_timer:Timer = null;
      
      private var m_shouldShowOverlay:Boolean = false;
      
      public function TreasureVaultDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         super.performEnterActions();
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      override protected function removeListeners() : void
      {
         super.removeListeners();
         if(this.m_timer)
         {
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
            this.m_timer = null;
         }
      }
      
      override protected function showDialog() : void
      {
         if(ZGlobal.isHome() && TreasureVaultManager.isEnabled())
         {
            WindowManager.instance.push(new TreasureVaultPopup());
         }
      }
      
      override protected function shouldShowOverlay() : Object
      {
         return {
            "show":this.m_shouldShowOverlay,
            "data":m_data
         };
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         var _loc2_:Boolean = false;
         if(ZGlobal.isHome())
         {
            _loc2_ = TInitUser.initComplete && ZGlobal.isHome() && TreasureVaultManager.isSpinAvailable();
            if(_loc2_ != this.m_shouldShowOverlay)
            {
               this.m_shouldShowOverlay = _loc2_;
               updateOverlay();
            }
         }
      }
   }
}

