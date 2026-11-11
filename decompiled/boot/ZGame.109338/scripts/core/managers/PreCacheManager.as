package core.managers
{
   import Engine.Events.TransactionEvent;
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   
   public class PreCacheManager
   {
      
      private var m_loader:Loader = null;
      
      public function PreCacheManager()
      {
         super();
         TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,this.onTransactionComplete);
      }
      
      public function onTransactionComplete(param1:TransactionEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:LoaderContext = null;
         if(param1.transaction.rawResult.metadata.precache_url)
         {
            _loc2_ = param1.transaction.rawResult.metadata.precache_url;
            if(_loc2_ != null && _loc2_.length > 0 && this.m_loader == null)
            {
               this.m_loader = new Loader();
               this.m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onSWFLoaded);
               this.m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onSWFLoadError);
               _loc3_ = new LoaderContext();
               this.m_loader.load(new URLRequest(_loc2_),_loc3_);
               TransactionManager.getInstance().removeEventListener(TransactionEvent.COMPLETED,this.onTransactionComplete);
            }
         }
      }
      
      private function onSWFLoaded(param1:Event) : void
      {
         this.m_loader = null;
         StatsManager.count("precache");
      }
      
      private function onSWFLoadError(param1:Event) : void
      {
         this.m_loader = null;
         StatsManager.count("precache_error");
      }
   }
}

