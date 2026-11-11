package com.zynga.ads.w2e
{
   import com.zynga.ads.zac_internal;
   import flash.external.ExternalInterface;
   
   use namespace zac_internal;
   
   public class WatchToEarn
   {
      
      private static var _instance:Service;
      
      zac_internal static const VERSION:String = "#{VERSION}";
      
      public function WatchToEarn(param1:SingletonEnforcer)
      {
         super();
         throw new Error("WatchToEarn is a factory and cannot be instantiated.");
      }
      
      public static function create(param1:*, param2:String, param3:* = null) : IService
      {
         _instance = new Service(param1);
         ExternalInterface.call("zynga.ads.WatchToEarn.service.initializeFlash",ExternalInterface.objectID,param1,param2,param3);
         ExternalInterface.addCallback("zynga_ads_w2e_dispatchEvent",_instance.dispatchExternalEvent);
         ExternalInterface.addCallback("zynga_ads_version",zac_internal::getVersion);
         return _instance;
      }
      
      public static function get(param1:String = null) : IService
      {
         if(!_instance)
         {
            throw new Error("Watch to Earn is not initialized yet.");
         }
         return _instance;
      }
      
      zac_internal static function getVersion() : String
      {
         return zac_internal::VERSION;
      }
   }
}

class SingletonEnforcer
{
   
   public function SingletonEnforcer()
   {
      super();
   }
}
