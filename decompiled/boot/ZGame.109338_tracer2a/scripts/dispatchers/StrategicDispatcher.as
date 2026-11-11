package dispatchers
{
   import flash.events.EventDispatcher;
   
   public class StrategicDispatcher extends EventDispatcher
   {
      
      public static var instance:StrategicDispatcher = new StrategicDispatcher();
      
      public static const LEFT:String = "goleft";
      
      public static const RIGHT:String = "goright";
      
      public static const SHIFT_LEFT:String = "shiftleft";
      
      public static const SHIFT_RIGHT:String = "shiftright";
      
      public static const SELECTED:String = "selected";
      
      public static const TOGGLE:String = "toggle";
      
      public static const LOAD_MAP:String = "loadmap";
      
      public static const CREATE_ISLAND:String = "createisland";
      
      public static const DEPLOY:String = "deploy";
      
      public static const BATTLE_COMPLETE:String = "battlecomplete";
      
      public static const ENTERED:String = "entered";
      
      public static const EXITED:String = "exited";
      
      public static const QUEST_LOCKING_UPDATED:String = "questlockingupdated";
      
      public static const CONTINUE_PROGRESS:String = "continueprogress";
      
      public static const START_PROGRESS:String = "startprogress";
      
      public static const REMATCH:String = "sdrematch";
      
      public static const CANCEL:String = "sdcancel";
      
      public static const SWF_LOADED:String = "swfloaded";
      
      public static const CAMPAIGN_LOADED:String = "campaignloaded";
      
      public static const ISLAND_CLICKED:String = "islandclicked";
      
      public static const ISLAND_EXIT:String = "islandexit";
      
      public static const ISLAND_FORCE_EXIT:String = "islandforceexit";
      
      public static const ISLAND_SELECTED:String = "islandselected";
      
      public static const ISLAND_ACTIVE_FOCUS:String = "islandactivefocus";
      
      public static const ISLAND_SCOPE_ENTER:String = "islandscopeenter";
      
      public static const ISLAND_SCOPE_LEAVE:String = "islandscopeleave";
      
      public static const ISLAND_REGISTER:String = "islandregister";
      
      public static const ISLAND_UNREGISTER:String = "islandunregister";
      
      public static const CAMPAIGN_BATTLE_WON:String = "campaignbattlewon";
      
      public static const SURVIVAL_BATTLE_WON:String = "survivalbattlewon";
      
      public static const DISPLAYING_LEADERBOARD_SCREEN:String = "campaigndisplayingLBScreen";
      
      public static const EXPANSION_PURCHASED:String = "expansionPurchased";
      
      public static const PICK_FOCUS:String = "islandpickfocus";
      
      public static const ALLY_TEND:String = "allyTend";
      
      public static const VILLAIN_TOKEN_AWARDED:String = "villainTokenAwarded";
      
      public function StrategicDispatcher()
      {
         super();
      }
   }
}

