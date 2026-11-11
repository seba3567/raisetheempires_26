package init.PostInit
{
   import Engine.Init.InitializationAction;
   import core.ZGlobal;
   import core.managers.viralSurfacingManager.ViralSurfacingManager;
   import flash.events.Event;
   
   public class DoStartViralSurfacingManager extends InitializationAction
   {
      
      public static const INIT_ID:String = "DoStartViralSurfaceManager";
      
      protected var m_id:String;
      
      public function DoStartViralSurfacingManager()
      {
         super(INIT_ID);
         addDependency(DoStartMusic.INIT_ID);
      }
      
      override public function execute() : void
      {
         var _loc1_:XML = ZGlobal.gameSettings.getXML().viralSurfacing[0];
         ViralSurfacingManager.instance.initialize(_loc1_);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

