package core.managers.autoActionsManager
{
   import core.ZGlobal;
   import core.managers.visitorManager.VisitorManager;
   import displays.popups.GenericPopup;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import zlabs.core.InputManager;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class AutoAction extends EventDispatcher
   {
      
      private var m_nextAction:AutoAction;
      
      protected var m_data:Object;
      
      private var m_nextActionTimeDelay:int = 0;
      
      private var m_timer:Timer;
      
      private var m_disableInput:Boolean = false;
      
      private var m_popupBlocker:GenericPopup;
      
      private const ACTION_LOCATION_HOME:String = "HOME";
      
      private var m_actionLocation:String = "HOME";
      
      public function AutoAction(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public function startAction() : void
      {
         AutoActionsManager.instance.activeAction = this;
         if(this.m_actionLocation == this.ACTION_LOCATION_HOME)
         {
            if(!ZGlobal.isVisiting())
            {
               this.doStartAction();
            }
            else
            {
               VisitorManager.instance.addEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded);
            }
         }
      }
      
      private function onWorldLoaded(param1:Event) : void
      {
         if(!ZGlobal.isVisiting())
         {
            VisitorManager.instance.removeEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded);
            this.doStartAction();
         }
      }
      
      private function doStartAction() : void
      {
         if(this.m_disableInput)
         {
            this.m_popupBlocker = new GenericPopup("Popup Blocker");
            this.m_popupBlocker.visible = false;
            this.m_popupBlocker.backgroundVisible = false;
            PopupManager.instance.addEventListener(PopupManager.SHOW_POPUP,this.popupShown,false,0,true);
            PopupManager.instance.push(this.m_popupBlocker);
         }
         else
         {
            this.performAction();
         }
      }
      
      private function popupShown(param1:WorldEvent) : void
      {
         if(param1.eventData == this.m_popupBlocker)
         {
            PopupManager.instance.containerCanvas.backgroundVisible = false;
            PopupManager.instance.removeEventListener(PopupManager.SHOW_POPUP,this.popupShown);
            this.performAction();
         }
      }
      
      protected function performAction() : void
      {
         this.doDisableInput();
      }
      
      protected function doDisableInput() : void
      {
         if(this.m_disableInput)
         {
            InputManager.disableInput();
            InputManager.disableButtonInput();
         }
      }
      
      protected function doReenableInput() : void
      {
         if(this.m_disableInput)
         {
            InputManager.enableInput();
            InputManager.enableButtonInput();
         }
      }
      
      protected function startEndAction() : void
      {
         if(this.m_nextAction)
         {
            if(this.m_nextActionTimeDelay <= 0)
            {
               this.endAction();
            }
            else
            {
               this.m_timer = new Timer(this.m_nextActionTimeDelay);
               this.m_timer.addEventListener(TimerEvent.TIMER,this.timeComplete,false,0,true);
               this.m_timer.start();
            }
         }
         else
         {
            this.doReenableInput();
         }
      }
      
      public function endAction() : void
      {
         if(this.m_popupBlocker)
         {
            PopupManager.instance.containerCanvas.backgroundVisible = true;
            this.m_popupBlocker.closeWindow();
            this.m_popupBlocker = null;
         }
         this.doReenableInput();
         if(this.m_nextAction)
         {
            this.m_nextAction.startAction();
         }
      }
      
      public function setNextAction(param1:AutoAction) : void
      {
         this.m_nextAction = param1;
      }
      
      public function set data(param1:Object) : void
      {
         this.m_data = param1;
      }
      
      public function get data() : Object
      {
         if(!this.m_data)
         {
            this.m_data = {};
         }
         return this.m_data;
      }
      
      private function timeComplete(param1:Event) : void
      {
         this.m_timer.removeEventListener(TimerEvent.TIMER,this.timeComplete);
         this.m_timer = null;
         this.endAction();
      }
      
      public function set nextActionTimeDelay(param1:int) : void
      {
         this.m_nextActionTimeDelay = param1;
      }
      
      public function set disableInput(param1:Boolean) : void
      {
         this.m_disableInput = param1;
      }
   }
}

