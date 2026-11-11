package init.PostInit
{
   import Engine.Init.InitializationAction;
   import core.ui.UIManager;
   import flash.events.Event;
   
   public class DoStartMusic extends InitializationAction
   {
      
      public static const INIT_ID:String = "DoStartMusic";
      
      public function DoStartMusic()
      {
         super(INIT_ID);
         addDependency(DoStartQuests.INIT_ID);
      }
      
      override public function execute() : void
      {
         UIManager.instance.dispatchEvent(new Event(UIManager.UI_START_MUSIC));
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

