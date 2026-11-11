package zlabs.displays.popups
{
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import zlabs.Zlab;
   import zlabs.displays.zflex.ZContainer;
   import zlabs.managers.WindowManager;
   
   public class PopUpBase extends ZContainer implements IWindow
   {
      
      public static const POPUP_PRIORITY_LOW:int = 5;
      
      public static const POPUP_PRIORITY_NORMAL:int = 4;
      
      public static const POPUP_PRIORITY_MEDIUM:int = 3;
      
      public static const POPUP_PRIORITY_HIGH:int = 2;
      
      public static const POPUP_PRIORITY_CRITICAL:int = 1;
      
      public var priority:int = 4;
      
      protected var m_window:MovieClip;
      
      protected var m_animation:PopupAniConfig;
      
      protected var m_manager:WindowManager;
      
      protected var m_managerToNotifyOnLoad:WindowManager;
      
      protected var m_origOffsetX:Number = 0;
      
      protected var m_origOffsetY:Number = 0;
      
      public function PopUpBase()
      {
         super();
      }
      
      protected function initDialog() : void
      {
         this.centerWithinStage(Zlab.mainStage);
      }
      
      protected function deinitDialog() : void
      {
      }
      
      public function get window() : MovieClip
      {
         return this.m_window;
      }
      
      public function setManager(param1:WindowManager) : void
      {
         this.m_manager = param1;
      }
      
      public function setManagerToNotifyOnLoad(param1:WindowManager) : void
      {
         this.m_managerToNotifyOnLoad = param1;
      }
      
      public function get eventDispatcher() : EventDispatcher
      {
         return this;
      }
      
      protected function close(param1:Event = null) : void
      {
         this.m_managerToNotifyOnLoad = null;
         if(this.m_manager.displayedWindow == this)
         {
            this.m_manager.pop();
         }
      }
      
      public function get canClickBehindSelf() : Boolean
      {
         return false;
      }
      
      public function get animation() : PopupAniConfig
      {
         return this.m_animation;
      }
      
      public function set animation(param1:PopupAniConfig) : void
      {
         this.m_animation = param1;
      }
      
      override public function destroy() : void
      {
         this.m_window = null;
      }
      
      public function centerWithinStage(param1:Stage) : void
      {
         centerX = param1.stageWidth / 2 + this.m_origOffsetX;
         centerY = param1.stageHeight / 2 + this.m_origOffsetY;
      }
      
      public function onShow() : void
      {
      }
      
      public function onHide() : void
      {
      }
   }
}

