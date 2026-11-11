package core.ui.UIDirector
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class UIDirectorScript extends EventDispatcher
   {
      
      public function UIDirectorScript()
      {
         super();
      }
      
      public function begin() : void
      {
      }
      
      protected function exitScript() : void
      {
         dispatchEvent(new Event(UIDirector.EVENT_SCRIPT_END));
      }
   }
}

