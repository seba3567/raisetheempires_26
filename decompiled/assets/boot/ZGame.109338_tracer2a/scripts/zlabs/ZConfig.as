package zlabs
{
   public class ZConfig
   {
      
      public static var SN_APP_URL:String = "";
      
      public static var BASE_PATH:String = "127.0.0.1";
      
      public static var SERVICES_GATEWAY_PATH:String = BASE_PATH + "flashservices/gateway.php";
      
      public static var GAME_SETTINGS_PATH:String = "";
      
      public static var ASSET_POLICY_FILE:String = "";
      
      private static var m_counter:int = 0;
      
      public static var ASSET_BASE_PATH:String = Config.ASSET_PATHS[0];
      
      public function ZConfig()
      {
         super();
      }
   }
}

