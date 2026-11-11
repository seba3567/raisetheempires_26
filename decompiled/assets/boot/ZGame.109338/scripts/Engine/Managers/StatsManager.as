package Engine.Managers
{
   import by.blooddy.crypto.MD5;
   import by.blooddy.crypto.serialization.JSON;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.utils.Timer;
   
   public class StatsManager
   {
      
      public static const ONE_LINE_FEED:int = 1;
      
      public static const SHORT_FEED:int = 2;
      
      public static const APP_TO_USER_NOTIF:int = 3;
      
      public static const USER_TO_USER_NOTIF:int = 4;
      
      public static const STATUS:int = 5;
      
      public static const APP_EMAIL:int = 6;
      
      public static const REQUEST:int = 7;
      
      public static const FEED:int = 8;
      
      private static const REPORT_DELAY:int = 10000;
      
      private static const IDLE_TIMER_ENABLED:Boolean = true;
      
      private static const HEARTBEAT_STATS_ENABLED:Boolean = false;
      
      public static var m_stats:Array = new Array();
      
      public static var m_timer:Timer = null;
      
      protected static var m_idle:Boolean = false;
      
      private static var m_enabled:Boolean = true;
      
      private static var m_attempts:Number = 0;
      
      public function StatsManager()
      {
         super();
      }
      
      protected static function addStatDataToBatch(param1:String, ... rest) : void
      {
         if(m_timer == null)
         {
            m_timer = new Timer(REPORT_DELAY);
            m_timer.addEventListener(TimerEvent.TIMER,onTimer,false,0,true);
            m_timer.start();
         }
         m_stats.push({
            "statfunction":param1,
            "data":rest
         });
      }
      
      public static function count(param1:String, param2:String = "", param3:String = "", param4:String = "", param5:String = "", param6:String = "", param7:int = 1) : void
      {
         GlobalEngine.msg("StatsManager.count",param1,param2,param3,param4,param5,param6,param7);
         addStatDataToBatch("count",param1,param2,param3,param4,param5,param6,param7);
      }
      
      public static function economy(param1:int, param2:String, param3:String = "", param4:String = "", param5:String = "", param6:String = "", param7:String = "", param8:int = 1) : void
      {
         addStatDataToBatch("economy",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public static function trackMessage(param1:int, param2:String, param3:int, param4:String = "", param5:String = "", param6:String = "", param7:Boolean = true) : void
      {
         addStatDataToBatch("trackMessage",param1,param2,param3,param4,param5,param6,param7);
      }
      
      public static function countSample(param1:int, param2:String, param3:String = "", param4:String = "", param5:String = "", param6:String = "", param7:String = "", param8:int = 1) : void
      {
         addStatDataToBatch("countSample",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public static function perf(param1:String = "", param2:String = "", param3:String = "", param4:String = "", param5:String = "", param6:String = "", param7:String = "") : void
      {
         addStatDataToBatch("perf",param1,param2,param3,param4,param5,param6,param7);
      }
      
      public static function social(param1:String, param2:String, param3:String = "", param4:String = "", param5:String = "", param6:String = "", param7:int = 0, param8:String = "") : void
      {
         GlobalEngine.msg("StatsManager.social",param1,param2,param3,param4,param5,param6,param7,param8);
         addStatDataToBatch("social",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public static function startExperiment(param1:String, param2:String, param3:int) : int
      {
         var _loc4_:int = 0;
         var _loc5_:int = 7;
         var _loc6_:String = MD5.hash(param2 + param1);
         var _loc7_:int = parseInt("0x" + _loc6_.substr(-_loc5_));
         _loc4_ = _loc7_ % (param3 + 1);
         addStatDataToBatch("setUserExperimentVariant",param1,param2,_loc4_);
         return _loc4_;
      }
      
      public static function experimentGoal(param1:String, param2:String, param3:int = 0) : void
      {
         addStatDataToBatch("experimentGoal",param1,param2,param3);
      }
      
      public static function notIdle() : void
      {
         m_idle = false;
      }
      
      private static function sendStatsRetry(param1:Event) : void
      {
         if(++m_attempts <= 3)
         {
            sendStats();
         }
         else
         {
            sendStatsComplete(param1);
         }
      }
      
      private static function sendStatsComplete(param1:Event) : void
      {
         m_stats = [];
         m_attempts = 0;
      }
      
      public static function sendStats(param1:Boolean = false) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:URLRequest = null;
         var _loc5_:URLLoader = null;
         if(Boolean(m_stats.length) && m_enabled == true)
         {
            _loc2_ = new Object();
            _loc2_.signedParams = TransactionManager.additionalSignedParams != null && TransactionManager.additionalSignedParams.hasOwnProperty("zySig") ? TransactionManager.additionalSignedParams : GlobalEngine.zyParams;
            _loc2_.stats = m_stats;
            _loc3_ = by.blooddy.crypto.serialization.JSON.encode(_loc2_);
            _loc4_ = new URLRequest(Config.RECORD_STATS_PATH);
            _loc4_.method = URLRequestMethod.POST;
            _loc4_.contentType = "application/json";
            _loc4_.data = _loc3_;
            _loc5_ = new URLLoader();
            _loc5_.dataFormat = URLLoaderDataFormat.BINARY;
            _loc5_.addEventListener(IOErrorEvent.IO_ERROR,sendStatsRetry);
            _loc5_.addEventListener(Event.COMPLETE,sendStatsComplete);
            _loc5_.load(_loc4_);
         }
      }
      
      private static function onTimer(param1:TimerEvent) : void
      {
         if(HEARTBEAT_STATS_ENABLED)
         {
            if(m_idle && IDLE_TIMER_ENABLED)
            {
               count("timer","idle");
            }
            else
            {
               count("timer","active");
            }
         }
         sendStats();
      }
      
      public static function milestone(param1:String, param2:Number = 0) : void
      {
         addStatDataToBatch("milestone",param1,param2);
      }
      
      public static function disable() : void
      {
         m_enabled = false;
      }
      
      public static function enable() : void
      {
         m_enabled = true;
      }
   }
}

