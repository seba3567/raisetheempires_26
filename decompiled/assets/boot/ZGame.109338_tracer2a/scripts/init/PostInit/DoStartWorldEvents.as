package init.PostInit
{
   import Engine.Init.InitializationAction;
   import core.managers.worldEventManager.WorldEventManager;
   import flash.events.Event;
   
   public class DoStartWorldEvents extends InitializationAction
   {
      
      public static const INIT_ID:String = "DoStartWorldEvents";
      
      protected var m_id:String;
      
      protected var m_results:Object = null;
      
      public function DoStartWorldEvents(param1:Object)
      {
         super(INIT_ID);
         this.m_results = param1;
      }
      
      override public function execute() : void
      {
         WorldEventManager.instance.init(this.m_results);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

