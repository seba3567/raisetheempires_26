package core.managers
{
   import Engine.Managers.ErrorManager;
   import Engine.Managers.StatsManager;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   
   public class ZPreloaderManager
   {
      
      private static const COUNTER_ERRORS:String = "errors";
      
      private static const COUNTER_ZPRELOADER:String = "zpreloader";
      
      private static const COUNTER_ZCACHE:String = "zcache";
      
      private static const INIT_STRING_DELIMITER:String = "|";
      
      private static var m_loader:Loader = null;
      
      private static var m_enabled:Boolean = false;
      
      private static var m_url:String = null;
      
      private static var m_initString:String = null;
      
      private static var m_loaded:Boolean = false;
      
      private static var m_zPreloader:* = null;
      
      private static var m_eventDispatcher:EventDispatcher = null;
      
      private static var m_zCacheNamespace:String = null;
      
      public function ZPreloaderManager()
      {
         super();
      }
      
      public static function init() : void
      {
         var _loc1_:Array = null;
         if(Boolean(!m_loaded) && Boolean(GlobalZCache.instance) && GlobalZCache.instance.allowed)
         {
            m_url = GlobalEngine.getFlashVar("zpreloader_url") as String;
            m_initString = GlobalEngine.getFlashVar("zpreloader_init") as String;
            if(m_url != null && m_url.length > 0)
            {
               _loc1_ = m_initString.split(INIT_STRING_DELIMITER);
               if(!_loc1_ || _loc1_.length < 3)
               {
                  return;
               }
               m_zCacheNamespace = _loc1_[2];
               m_enabled = true;
               if(Boolean(m_enabled && m_url && m_url.length > 0) && Boolean(m_initString) && m_initString.length > 0)
               {
                  load();
                  m_loaded = true;
               }
            }
         }
      }
      
      private static function load() : void
      {
         if(!m_loader)
         {
            m_loader = new Loader();
            m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoaderComplete);
            m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoaderIOError);
            try
            {
               m_loader.load(new URLRequest(m_url),new LoaderContext());
            }
            catch(e:Error)
            {
               StatsManager.count(COUNTER_ERRORS,COUNTER_ZCACHE,COUNTER_ZPRELOADER,m_zCacheNamespace,"load_error: " + e);
               ErrorManager.addError("ZPreloader load error: " + e);
               removeLoaderEventListeners();
            }
         }
      }
      
      private static function onLoaderComplete(param1:Event) : void
      {
         var event:Event = param1;
         removeLoaderEventListeners();
         if(m_loader.contentLoaderInfo.childAllowsParent)
         {
            try
            {
               m_zPreloader = m_loader.content as Object;
               m_zPreloader.init(m_initString);
               m_eventDispatcher = new EventDispatcher();
               m_zPreloader.zPreloaderEventDispatcher = m_eventDispatcher;
               m_eventDispatcher.addEventListener(Event.INIT,onZPreloaderInit);
               m_eventDispatcher.addEventListener(Event.COMPLETE,onZPreloaderComplete);
               StatsManager.count(COUNTER_ZCACHE,COUNTER_ZPRELOADER,m_zCacheNamespace,"status","enabled");
            }
            catch(e:Error)
            {
               StatsManager.count(COUNTER_ERRORS,COUNTER_ZCACHE,COUNTER_ZPRELOADER,m_zCacheNamespace,"init_error: " + e);
               ErrorManager.addError("ZPreloader init error: " + e);
            }
         }
         else
         {
            StatsManager.count(COUNTER_ERRORS,COUNTER_ZCACHE,COUNTER_ZPRELOADER,m_zCacheNamespace,"permission_error","childAllowsParent");
            ErrorManager.addError("ZPreloader childAllowsParent error");
         }
      }
      
      private static function onZPreloaderInit(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(m_zPreloader)
         {
            _loc2_ = Number(m_zPreloader.alreadyLoadedCount);
            _loc3_ = Number(m_zPreloader.totalAssets);
            if(_loc3_ > 0)
            {
               StatsManager.count(COUNTER_ZCACHE,COUNTER_ZPRELOADER,"progress",m_zCacheNamespace,"","",int(_loc2_ / _loc3_ * 100));
            }
         }
      }
      
      private static function onZPreloaderComplete(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         if(m_zPreloader)
         {
            _loc2_ = int(m_zPreloader.totalAssets);
            _loc3_ = Number(m_zPreloader.assetLengthMismatch);
            StatsManager.count(COUNTER_ZCACHE,COUNTER_ZPRELOADER,"completed",m_zCacheNamespace,"","",_loc2_);
            if(_loc3_ > 0)
            {
               StatsManager.count(COUNTER_ERRORS,COUNTER_ZCACHE,COUNTER_ZPRELOADER,"content_length",m_zCacheNamespace,"",_loc3_);
            }
         }
      }
      
      private static function onLoaderIOError(param1:IOErrorEvent) : void
      {
         removeLoaderEventListeners();
      }
      
      private static function removeLoaderEventListeners() : void
      {
         m_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoaderComplete);
         m_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onLoaderIOError);
      }
   }
}

