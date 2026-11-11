package zlabs.resource
{
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.Security;
   import flash.system.SecurityDomain;
   import flash.utils.ByteArray;
   import zlabs.debug.Logger;
   
   [Event(name="FAILED_EVENT",type="zlab.resource.ResourceEvent")]
   [Event(name="LOADED_EVENT",type="zlab.resource.ResourceEvent")]
   public class Resource extends EventDispatcher
   {
      
      private var m_context:LoaderContext;
      
      protected var _callback:Function;
      
      protected var _filename:String = null;
      
      private var _isLoaded:Boolean = false;
      
      private var _didFail:Boolean = false;
      
      private var _urlLoader:URLLoader;
      
      private var _loader:Loader;
      
      private var _referenceCount:int = 0;
      
      private var _isLowPriority:Boolean = false;
      
      public function Resource()
      {
         super();
      }
      
      public function get filename() : String
      {
         return this._filename;
      }
      
      public function set filename(param1:String) : void
      {
         if(this._filename != null)
         {
            Logger.warn(this,"set filename","Can\'t change the filename of a resource once it has been set.");
            return;
         }
         this._filename = param1;
      }
      
      public function get isLoaded() : Boolean
      {
         return this._isLoaded;
      }
      
      public function get didFail() : Boolean
      {
         return this._didFail;
      }
      
      public function get referenceCount() : int
      {
         return this._referenceCount;
      }
      
      protected function get resourceLoader() : Loader
      {
         return this._loader;
      }
      
      public function load(param1:String) : void
      {
         var loader:URLLoader;
         var request:URLRequest;
         var filename:String = param1;
         this._filename = filename;
         try
         {
            Security.allowDomain("*","zynga.com");
         }
         catch(error:SecurityError)
         {
         }
         this.m_context = new LoaderContext();
         if(Security.sandboxType == Security.REMOTE)
         {
            this.m_context.securityDomain = SecurityDomain.currentDomain;
         }
         this.m_context.applicationDomain = ApplicationDomain.currentDomain;
         this.m_context.checkPolicyFile = true;
         loader = new URLLoader();
         loader.dataFormat = URLLoaderDataFormat.BINARY;
         loader.addEventListener(Event.COMPLETE,this.onDownloadComplete,false,0,true);
         loader.addEventListener(IOErrorEvent.IO_ERROR,this.onDownloadError,false,0,true);
         loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onDownloadSecurityError,false,0,true);
         request = new URLRequest();
         request.url = filename;
         loader.load(request);
         this._urlLoader = loader;
      }
      
      public function initialize(param1:*) : void
      {
         if(!(param1 is ByteArray))
         {
            throw new Error("Default Resource can only process ByteArrays!");
         }
         var _loc2_:Loader = new Loader();
         _loc2_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadComplete);
         _loc2_.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onDownloadError);
         _loc2_.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onDownloadSecurityError);
         _loc2_.loadBytes(param1);
         this._loader = _loc2_;
      }
      
      public function incrementReferenceCount() : void
      {
         ++this._referenceCount;
      }
      
      public function decrementReferenceCount() : void
      {
         --this._referenceCount;
      }
      
      public function fail(param1:String) : void
      {
         this.onFailed(param1);
      }
      
      protected function onContentReady(param1:*) : Boolean
      {
         return false;
      }
      
      protected function onLoadComplete(param1:Event = null) : void
      {
         var event:Event = param1;
         try
         {
            if(this.onContentReady(event ? event.target.content : null))
            {
               this._isLoaded = true;
               this._urlLoader = null;
               this._loader = null;
               dispatchEvent(new ResourceEvent(ResourceEvent.LOADED_EVENT,this));
               return;
            }
            this.onFailed("Got false from onContentReady - the data wasn\'t accepted.");
            return;
         }
         catch(e:Error)
         {
            Logger.error(this,"Load","Failed to load! " + e.toString());
         }
         this.onFailed("The resource type does not match the loaded content.");
      }
      
      private function onDownloadComplete(param1:Event) : void
      {
         var _loc2_:ByteArray = (param1.target as URLLoader).data as ByteArray;
         this.initialize(_loc2_);
      }
      
      private function onDownloadError(param1:IOErrorEvent) : void
      {
         this.onFailed(param1.text);
      }
      
      private function onDownloadSecurityError(param1:SecurityErrorEvent) : void
      {
         this.onFailed(param1.text);
      }
      
      protected function onFailed(param1:String) : void
      {
         this._isLoaded = true;
         this._didFail = true;
         Logger.error(this,"Load","Resource " + this._filename + " failed to load with error: " + param1);
         dispatchEvent(new ResourceEvent(ResourceEvent.FAILED_EVENT,this));
         this._urlLoader = null;
         this._loader = null;
      }
      
      public function set callback(param1:Function) : void
      {
         this._callback = param1;
      }
      
      public function get callback() : Function
      {
         return this._callback;
      }
      
      public function get isLowPriority() : Boolean
      {
         return this._isLowPriority;
      }
      
      public function set isLowPriority(param1:Boolean) : void
      {
         this._isLowPriority = param1;
      }
      
      public function clearCallback() : void
      {
         this._callback = null;
      }
      
      public function destroy() : void
      {
         this._callback = null;
         this.m_context = null;
         this._urlLoader = null;
         this._loader = null;
      }
   }
}

