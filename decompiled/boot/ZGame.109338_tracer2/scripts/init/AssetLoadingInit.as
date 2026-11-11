package init
{
   import Engine.Init.InitializationAction;
   import flash.events.Event;
   import resources.EmbeddedFonts;
   
   public class AssetLoadingInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "AssetLoadingInit";
      
      public function AssetLoadingInit()
      {
         super(INIT_ID);
      }
      
      override public function execute() : void
      {
         EmbeddedFonts.initialize();
         this.onAssetsLoaded();
      }
      
      protected function onAssetsLoaded(param1:Event = null) : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

