package zlabs.resource.provider
{
   import Engine.Managers.StatsManager;
   import br.com.stimuli.loading.loadingtypes.LoadingItem;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import zlabs.ZConfig;
   import zlabs.resource.Resource;
   import zlabs.resource.SWFResource;
   import zlabs.resource.XMLResource;
   
   public class ZCacheResourceProvider extends BulkLoaderResourceProvider
   {
      
      public function ZCacheResourceProvider(param1:String, param2:int = 12, param3:Boolean = true)
      {
         super(param1,param2,param3);
      }
      
      override public function getResource(param1:String, param2:Class, param3:Function, param4:Boolean = false, param5:Boolean = false) : Resource
      {
         var key:String = null;
         var data:* = undefined;
         var resource:Resource = null;
         var uri:String = param1;
         var type:Class = param2;
         var progress:Function = param3;
         var forceReload:Boolean = param4;
         var lowPriority:Boolean = param5;
         var resourceIdentifier:String = uri.toLowerCase() + type;
         if(resources[resourceIdentifier] != null && !forceReload)
         {
            return resources[resourceIdentifier];
         }
         try
         {
            key = uri.substring(ZConfig.ASSET_BASE_PATH.length);
            if(!forceReload && this.useCache(uri,type) && GlobalZCache.instance.containsKey(key))
            {
               data = GlobalZCache.instance.get(key);
               if(data != null)
               {
                  trace("ZLA ZCache hit: " + key + ", type=" + type);
                  resource = new type();
                  resource.filename = key;
                  resource.initialize(data);
                  resources[resourceIdentifier] = resource;
                  return resource;
               }
            }
         }
         catch(e:Error)
         {
            StatsManager.count("errors","zcache","ZCacheResourceProvider","getResource");
         }
         return super.getResource(uri,type,progress,forceReload,lowPriority);
      }
      
      override protected function resourceLoaded(param1:Event) : void
      {
         var content:* = undefined;
         var uri:String = null;
         var key:String = null;
         var event:Event = param1;
         try
         {
            if(resources[(event.currentTarget as LoadingItem).id] != null)
            {
               content = (event.currentTarget as LoadingItem).content;
               uri = (event.currentTarget as LoadingItem).url.url;
               key = uri.substring(ZConfig.ASSET_BASE_PATH.length);
               if(this.useCache(uri) && (!GlobalZCache.instance.containsKey(key) || GlobalZCache.instance.get(key) == null))
               {
                  if(uri.lastIndexOf(".phpgz") > 0)
                  {
                     (content as ByteArray).uncompress();
                  }
                  trace("ZLA ZCache put: " + key);
                  GlobalZCache.instance.put(key,content,(content as ByteArray).length);
               }
               content = null;
            }
         }
         catch(e:Error)
         {
            StatsManager.count("errors","zcache","ZCacheResourceProvider","resourceLoaded");
         }
         super.resourceLoaded(event);
      }
      
      private function useCache(param1:String, param2:Class = null) : Boolean
      {
         if(param2 != null && param2 != SWFResource && param2 != XMLResource)
         {
            return false;
         }
         if(Boolean(GlobalZCache.instance && GlobalZCache.instance.allowed && param1 != null) && Boolean(param1 is String) && param1.indexOf(ZConfig.ASSET_BASE_PATH) == 0)
         {
            return param1.toLowerCase().lastIndexOf(".swf") == param1.length - 4 || param1.toLowerCase().lastIndexOf(".png") == param1.length - 4;
         }
         return false;
      }
   }
}

