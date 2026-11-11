package init
{
   import Engine.Init.InitializationAction;
   import core.ZGlobal;
   import core.tilemap.TilesetManager;
   import flash.events.Event;
   
   public class TerrainInit extends InitializationAction
   {
      
      public static const INIT_ID:String = "TerrainInit";
      
      public function TerrainInit()
      {
         super(INIT_ID);
         addDependency(GameSettingsInit.INIT_ID);
      }
      
      override public function execute() : void
      {
         TilesetManager.instance.addEventListener(Event.COMPLETE,this.onTilesetManagerLoadComplete,false,0,true);
         TilesetManager.instance.initFromXML(ZGlobal.gameSettings.getXML());
      }
      
      private function onTilesetManagerLoadComplete(param1:Event) : void
      {
         TilesetManager.instance.removeEventListener(Event.COMPLETE,this.onTilesetManagerLoadComplete);
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

