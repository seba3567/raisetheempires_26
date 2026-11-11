package core.permission
{
   public class PermissionTypes
   {
      
      public static const TYPE_FEED:String = "feed";
      
      public static const TYPE_TALKTALK:String = "talktalk";
      
      public static const TYPE_ACHIEVEMENTS:String = "achievements";
      
      public static const TYPE_APP_EMAILS:String = "app-emails";
      
      public static const TYPE_BIRTHDAY_ACCESS:String = "birthday-access";
      
      public static const TYPE_GDP:String = "gdp";
      
      private static var MAP:Object = {
         "talktalk":["read_stream"],
         "achievements":["publish_actions"],
         "app-emails":["email"],
         "publish_stream":["publish_stream"],
         "publish_actions":["publish_actions"],
         "birthday-access":["user_birthday"],
         "gdp":[]
      };
      
      private static const TITLE_MAP:Object = {
         "achievements":"Achievements require",
         "talktalk":"TalkTalk requires",
         "birthday-access":"Birthday Gift requires"
      };
      
      public function PermissionTypes()
      {
         super();
      }
      
      internal static function getPermissionsByType(param1:String) : Array
      {
         var _loc2_:Array = null;
         if(MAP.hasOwnProperty(param1))
         {
            _loc2_ = MAP[param1];
         }
         return _loc2_;
      }
      
      public static function getTitleByType(param1:String) : String
      {
         var _loc2_:String = "This feature requires";
         if(TITLE_MAP.hasOwnProperty(param1))
         {
            _loc2_ = TITLE_MAP[param1];
         }
         return _loc2_;
      }
      
      public static function setPermissionsForGDP(param1:String) : void
      {
         if(MAP.hasOwnProperty("gdp"))
         {
            MAP["gdp"] = param1.split(",");
         }
      }
   }
}

