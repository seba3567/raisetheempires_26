package dispatchers
{
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   
   public class UIDispatcher extends EventDispatcher
   {
      
      public static var instance:UIDispatcher = new UIDispatcher();
      
      public static const PLAYER_NAME_LOADED:String = "playernameloaded";
      
      public static const PLAYER_LEVEL_LOADED:String = "playerlevelloaded";
      
      public static const TITAN_NAME_LOADED:String = "titannameloaded";
      
      public static const OPTIONS_LOADED:String = "optionsloaded";
      
      public static const UI_WIDTH_OFFSET:String = "uiwidthoffset";
      
      public static const UI_HEIGHT_OFFSET:String = "uiheightoffset";
      
      public static const UI_PAUSE_QUEST_ICONS:String = "pausequesticons";
      
      public static const UI_PLAYER_ISLAND_MODE_ACTIVE:String = "playerislandmodeactive";
      
      public static const UI_REMOVE_UI_ITEM:String = "removeuiitem";
      
      public static const UI_FIGHTMETER_RELOADED:String = "fightmeterreloaded";
      
      public static const UI_BATTLEWINLOSE:String = "battlewinlose";
      
      public function UIDispatcher(param1:IEventDispatcher = null)
      {
         super(param1);
      }
   }
}

