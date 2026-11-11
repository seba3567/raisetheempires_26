package zlabs.resource
{
   import Engine.Classes.SNAPISocialNetwork;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import zlabs.Zlab;
   import zlabs.ZlabUtil;
   import zlabs.debug.Logger;
   import zlabs.resource.provider.EmbeddedResourceProvider;
   import zlabs.resource.provider.FallbackResourceProvider;
   import zlabs.resource.provider.IResourceProvider;
   import zlabs.serialization.TypeUtility;
   
   public class ResourceManager
   {
      
      public var onlyLoadEmbeddedResources:Boolean = false;
      
      public var onEmbeddedFail:Function;
      
      private var _resources:Dictionary = new Dictionary();
      
      private var resourceProviders:Array = new Array();
      
      public function ResourceManager()
      {
         super();
      }
      
      public function validUrl(param1:String) : Boolean
      {
         if(param1 == null || param1 == "" || param1 == "unknown")
         {
            return false;
         }
         return true;
      }
      
      public function load(param1:String, param2:Class, param3:Function = null, param4:Function = null, param5:Function = null, param6:Boolean = false, param7:Boolean = false) : Resource
      {
         var resourceIdentifier:String;
         var resource:Resource = null;
         var fileExtension:String = null;
         var rp:int = 0;
         var tmpR:Resource = null;
         var filename:String = param1;
         var resourceType:Class = param2;
         var onLoaded:Function = param3;
         var onFailed:Function = param4;
         var onProgress:Function = param5;
         var forceReload:Boolean = param6;
         var lowPriority:Boolean = param7;
         if(Boolean(GlobalEngine.socialNetwork) && Boolean(filename.indexOf("graph.facebook.com") > 0) && filename.indexOf("/picture") > 0)
         {
            filename = (GlobalEngine.socialNetwork as SNAPISocialNetwork).formatFacebookProfilePicUrl(filename);
         }
         if(!this.validUrl(filename))
         {
            Logger.error(this,"load","Cannot load a " + resourceType + " with empty filename.");
            return null;
         }
         resourceIdentifier = filename.toLowerCase() + resourceType;
         resource = this._resources[resourceIdentifier];
         if(Boolean(resource && resource.isLowPriority) && Boolean(!resource.isLoaded) && !lowPriority)
         {
            Zlab.bulkLoader.changeItemPriority(resourceIdentifier,1);
            resource.isLowPriority = false;
         }
         if(Boolean(resource) && forceReload)
         {
            this._resources[resourceIdentifier] = null;
            delete this._resources[resourceIdentifier];
            resource.destroy();
            resource = null;
         }
         if(!resource)
         {
            if(this.onlyLoadEmbeddedResources && !EmbeddedResourceProvider.instance.isResourceKnown(filename,resourceType))
            {
               tmpR = new Resource();
               tmpR.filename = filename;
               tmpR.fail("not embedded in the SWF with type " + resourceType + ".");
               this.fail(tmpR,onFailed,"\'" + filename + "\' was not loaded because it was not embedded in the SWF with type " + resourceType + ".");
               if(this.onEmbeddedFail != null)
               {
                  this.onEmbeddedFail(filename);
               }
               return null;
            }
            fileExtension = ZlabUtil.getFileExtension(filename).toLocaleLowerCase();
            if(resourceType == SoundResource && (fileExtension == "mp3" || fileExtension == "wav"))
            {
               resourceType = MP3Resource;
            }
            rp = 0;
            while(rp < this.resourceProviders.length)
            {
               if((this.resourceProviders[rp] as IResourceProvider).isResourceKnown(filename,resourceType))
               {
                  resource = (this.resourceProviders[rp] as IResourceProvider).getResource(filename,resourceType,onProgress,forceReload);
               }
               rp++;
            }
            if(!resource)
            {
               resource = FallbackResourceProvider.instance.getResource(filename,resourceType,onProgress,forceReload,lowPriority);
            }
            if(!resource.filename)
            {
               resource.filename = filename;
            }
            this._resources[resourceIdentifier] = resource;
         }
         else if(!(resource is resourceType))
         {
            this.fail(resource,onFailed,"The resource " + filename + " is already loaded, but is of type " + TypeUtility.getObjectClassName(resource) + " rather than the specified " + resourceType + ".");
            return null;
         }
         if(resource.didFail)
         {
            this.fail(resource,onFailed,"The resource " + filename + " has previously failed to load");
         }
         else if(resource.isLoaded)
         {
            if(onLoaded != null)
            {
               Zlab.callLater(onLoaded,[resource]);
            }
         }
         else
         {
            if(onLoaded != null)
            {
               resource.addEventListener(ResourceEvent.LOADED_EVENT,function(param1:Event):void
               {
                  onLoaded(resource);
               });
            }
            if(onFailed != null)
            {
               resource.addEventListener(ResourceEvent.FAILED_EVENT,function(param1:Event):void
               {
                  onFailed(resource);
               });
            }
         }
         resource.incrementReferenceCount();
         return resource;
      }
      
      public function onResourceLoaded(param1:ResourceEvent) : void
      {
      }
      
      public function resourceTypeRequest(param1:String, param2:String = "") : Class
      {
         var _loc3_:Class = ImageResource;
         if(param1.indexOf(".swf") >= 0)
         {
            _loc3_ = SWFResource;
         }
         else if(param1.indexOf(".mp3") >= 0)
         {
            _loc3_ = MP3Resource;
         }
         return _loc3_;
      }
      
      public function unload(param1:String, param2:Class) : void
      {
      }
      
      public function registerEmbeddedResource(param1:String, param2:Class, param3:*) : void
      {
         var resource:Resource = null;
         var filename:String = param1;
         var resourceType:Class = param2;
         var data:* = param3;
         var resourceIdentifier:String = filename.toLowerCase() + resourceType;
         if(this._resources[resourceIdentifier])
         {
            Logger.warn(this,"registerEmbeddedResource","A resource from file " + filename + " has already been embedded.");
            return;
         }
         try
         {
            resource = new resourceType();
            resource.filename = filename;
            resource.initialize(data);
            resource.incrementReferenceCount();
            this._resources[resourceIdentifier] = resource;
         }
         catch(e:Error)
         {
            Logger.error(this,"registerEmbeddedResources","Could not instantiate resource " + filename + " due to error:\n" + e.toString());
            return;
         }
      }
      
      public function registerResourceProvider(param1:IResourceProvider) : void
      {
         if(this.resourceProviders.indexOf(param1) != -1)
         {
            Logger.warn(ResourceManager,"registerResourceProvider","Tried to register ResourceProvider \'" + param1 + "\' twice. Ignoring...");
            return;
         }
         this.resourceProviders.push(param1);
      }
      
      public function isLoaded(param1:String, param2:Class) : Boolean
      {
         var _loc3_:String = param1.toLowerCase() + param2;
         if(!this._resources[_loc3_])
         {
            return false;
         }
         var _loc4_:Resource = this._resources[_loc3_];
         return _loc4_.isLoaded;
      }
      
      private function fail(param1:Resource, param2:Function, param3:String) : void
      {
         if(!param1)
         {
            throw new Error("Tried to fail null resource.");
         }
         Logger.error(this,"load",param3);
         if(param2 != null)
         {
            Zlab.callLater(param2,[param1]);
         }
      }
   }
}

