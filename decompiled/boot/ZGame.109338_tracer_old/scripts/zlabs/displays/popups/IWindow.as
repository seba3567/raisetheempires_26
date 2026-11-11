package zlabs.displays.popups
{
   import flash.display.Stage;
   import flash.events.EventDispatcher;
   import zlabs.managers.WindowManager;
   
   public interface IWindow
   {
      
      function onShow() : void;
      
      function onHide() : void;
      
      function set enabled(param1:Boolean) : void;
      
      function get enabled() : Boolean;
      
      function centerWithinStage(param1:Stage) : void;
      
      function setManager(param1:WindowManager) : void;
      
      function setManagerToNotifyOnLoad(param1:WindowManager) : void;
      
      function get eventDispatcher() : EventDispatcher;
   }
}

