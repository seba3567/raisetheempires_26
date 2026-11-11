package Cache.Classes
{
   import Cache.Interfaces.IZCache;
   import flash.net.registerClassAlias;
   import flash.utils.ByteArray;
   
   public final class ZCacheClient implements IZCache
   {
      
      registerClassAlias("flash.utils.ByteArray",ByteArray);
      
      private var m_zCache:Object;
      
      public function ZCacheClient(param1:Object)
      {
         super();
         this.m_zCache = param1;
      }
      
      public function get initError() : Error
      {
         return this.m_zCache.initError;
      }
      
      public function get lastFlushError() : Error
      {
         return this.m_zCache.lastFlushError;
      }
      
      public function get inactivityFlushTimeout() : int
      {
         return this.m_zCache.inactivityFlushTimeout;
      }
      
      public function set inactivityFlushTimeout(param1:int) : void
      {
         this.m_zCache.inactivityFlushTimeout = param1;
      }
      
      public function get namespace() : String
      {
         return this.m_zCache.namespace;
      }
      
      public function init(param1:String) : Boolean
      {
         return this.m_zCache.init(param1);
      }
      
      public function flush() : Boolean
      {
         return this.m_zCache.flush();
      }
      
      public function get allowed() : Boolean
      {
         return this.m_zCache.allowed;
      }
      
      public function promptForStorage(param1:Function, param2:Function) : void
      {
         this.m_zCache.promptForStorage(param1,param2);
      }
      
      public function put(param1:String, param2:*, param3:uint) : Boolean
      {
         return this.m_zCache.put(param1,param2,param3);
      }
      
      public function get(param1:String) : *
      {
         return this.m_zCache.get(param1);
      }
      
      public function containsKey(param1:String) : Boolean
      {
         return this.m_zCache.containsKey(param1);
      }
      
      public function clear() : Boolean
      {
         return this.m_zCache.clear();
      }
      
      public function remove(param1:String) : *
      {
         return this.m_zCache.remove(param1);
      }
      
      public function get stats() : Object
      {
         return this.m_zCache.stats;
      }
   }
}

