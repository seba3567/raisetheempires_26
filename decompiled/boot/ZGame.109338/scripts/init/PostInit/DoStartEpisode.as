package init.PostInit
{
   import Engine.Init.InitializationAction;
   import displays.popups.EpisodePopup;
   import flash.events.Event;
   import zlabs.managers.PopupManager;
   
   public class DoStartEpisode extends InitializationAction
   {
      
      public static const INIT_ID:String = "DoStartEpisode";
      
      public function DoStartEpisode()
      {
         super(INIT_ID);
         addDependency(DoPlayCinematics.INIT_ID);
      }
      
      override public function execute() : void
      {
         PopupManager.instance.push(new EpisodePopup("Episode01",null,true));
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

