package zlabs.resource.provider
{
   import br.com.stimuli.loading.BulkLoader;
   import br.com.stimuli.loading.BulkProgressEvent;
   import br.com.stimuli.loading.loadingtypes.LoadingItem;
   import flash.display.Bitmap;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import zlabs.Zlab;
   import zlabs.resource.MP3Resource;
   import zlabs.resource.Resource;
   
   public class BulkLoaderResourceProvider extends ResourceProviderBase
   {
      
      protected var loader:BulkLoader = null;
      
      private var _phase:int = 1;
      
      private var bulkResources:Array = new Array();
      
      private var onLoaded:Function = null;
      
      private var onProgress:Function = null;
      
      private var onProvideResources:Function = null;
      
      public function BulkLoaderResourceProvider(param1:String, param2:int = 12, param3:Boolean = true)
      {
         super(param3);
         Zlab.bulkLoader = this.loader = new BulkLoader(param1,param2);
      }
      
      public function get phase() : int
      {
         return this._phase;
      }
      
      override public function getResource(param1:String, param2:Class, param3:Function, param4:Boolean = false, param5:Boolean = false) : Resource
      {
         var _loc7_:Resource = null;
         var _loc6_:String = param1.toLowerCase() + param2;
         if(resources[_loc6_] != null && !param4)
         {
            return resources[_loc6_];
         }
         if(this.loader.get(_loc6_) != null)
         {
            this.loader.remove(_loc6_);
         }
         this.loader.add(param1,{
            "id":_loc6_,
            "type":(param2 == MP3Resource ? "sound" : "binary"),
            "priority":(param5 ? 0 : 1)
         });
         if(!this.loader.isRunning)
         {
            this.loader.start();
         }
         this.loader.get(_loc6_).addEventListener(Event.COMPLETE,this.resourceLoaded);
         this.loader.get(_loc6_).addEventListener(BulkLoader.ERROR,this.resourceError);
         if(null != param3)
         {
            this.onProgress = param3;
            this.loader.get(_loc6_).addEventListener(BulkProgressEvent.PROGRESS,this.resourceProgress);
         }
         if(resources[_loc6_] == null)
         {
            _loc7_ = new param2();
            _loc7_.filename = param1;
            _loc7_.isLowPriority = param5;
            resources[_loc6_] = _loc7_;
         }
         else
         {
            _loc7_ = resources[_loc6_];
         }
         return _loc7_;
      }
      
      public function load(param1:Function = null, param2:Function = null, param3:Function = null) : void
      {
         this.onLoaded = param1;
         this.onProgress = param2;
         this.onProvideResources = param3;
         this._phase = 1;
         if(!this.loader.hasEventListener(BulkProgressEvent.COMPLETE))
         {
            this.loader.addEventListener(BulkProgressEvent.COMPLETE,this.resourcesLoaded);
         }
         if(!this.loader.hasEventListener(BulkProgressEvent.PROGRESS))
         {
            this.loader.addEventListener(BulkProgressEvent.PROGRESS,this.resourcesProgress);
         }
         this.loadResources();
      }
      
      private function resourceProgress(param1:BulkProgressEvent) : void
      {
         if(null != this.onProgress)
         {
            this.onProgress(param1.percentLoaded);
         }
      }
      
      protected function resourceLoaded(param1:Event) : void
      {
         var content:* = undefined;
         var event:Event = param1;
         if(resources[(event.currentTarget as LoadingItem).id] != null)
         {
            content = this.loader.getContent((event.currentTarget as LoadingItem).id,true);
            if((event.currentTarget as LoadingItem).url.url.lastIndexOf(".phpgz") > 0)
            {
               try
               {
                  (content as ByteArray).uncompress();
               }
               catch(e:Error)
               {
               }
            }
            (resources[(event.currentTarget as LoadingItem).id] as Resource).initialize(content);
            content = null;
         }
      }
      
      private function resourceError(param1:ErrorEvent) : void
      {
         if(resources[(param1.currentTarget as LoadingItem).id] != null)
         {
            (resources[(param1.currentTarget as LoadingItem).id] as Resource).fail(param1.text);
         }
      }
      
      protected function provideResources() : Array
      {
         return new Array();
      }
      
      private function resourcesLoaded(param1:BulkProgressEvent) : void
      {
         this.saveResources();
         if(this.onLoaded != null)
         {
            this.onLoaded(this.phase);
         }
         ++this._phase;
         this.loadResources();
      }
      
      private function resourcesProgress(param1:BulkProgressEvent) : void
      {
         if(this.onProgress != null)
         {
            this.onProgress(this.phase,Math.round(param1.percentLoaded * 100));
         }
      }
      
      private function loadResources() : void
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         if(this.onProvideResources != null)
         {
            this.bulkResources = this.onProvideResources(this.phase);
         }
         else
         {
            this.bulkResources = this.provideResources();
         }
         if(Boolean(this.bulkResources) && this.bulkResources.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < this.bulkResources.length)
            {
               _loc2_ = this.bulkResources[_loc1_].url.toLowerCase() + this.bulkResources[_loc1_].type;
               if(this.bulkResources[_loc1_].url != "" && this.bulkResources[_loc1_].url != null && Boolean(this.bulkResources[_loc1_].type))
               {
                  this.loader.add(this.bulkResources[_loc1_].url,{"id":_loc2_});
               }
               _loc1_++;
            }
            if(!this.loader.isRunning)
            {
               this.loader.start();
            }
         }
      }
      
      private function saveResources() : void
      {
         var _loc2_:String = null;
         var _loc3_:Resource = null;
         var _loc4_:* = undefined;
         var _loc1_:int = 0;
         while(_loc1_ < this.bulkResources.length)
         {
            if(this.bulkResources[_loc1_].url != "" && this.bulkResources[_loc1_].url != null && this.bulkResources[_loc1_].type != null)
            {
               _loc2_ = this.bulkResources[_loc1_].url.toLowerCase() + this.bulkResources[_loc1_].type;
               if(this.loader.getContent(_loc2_) != null)
               {
                  _loc3_ = new this.bulkResources[_loc1_].type();
                  _loc4_ = this.loader.getContent(_loc2_,true);
                  _loc3_.filename = this.bulkResources[_loc1_].url;
                  if(_loc4_ is Bitmap)
                  {
                     _loc3_.initialize((_loc4_ as Bitmap).bitmapData);
                     _loc4_ = null;
                  }
                  else
                  {
                     _loc3_.initialize(_loc4_);
                  }
                  resources[_loc2_] = _loc3_;
               }
            }
            _loc1_++;
         }
      }
   }
}

