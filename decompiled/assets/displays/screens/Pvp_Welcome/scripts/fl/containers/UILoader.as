package fl.containers
{
   import fl.core.InvalidationType;
   import fl.core.UIComponent;
   import fl.events.ComponentEvent;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol4")]
   public class UILoader extends UIComponent
   {
      
      private static var defaultStyles:Object = {};
      
      protected var contentInited:Boolean = false;
      
      protected var _maintainAspectRatio:Boolean = true;
      
      protected var loader:Loader;
      
      protected var _autoLoad:Boolean = true;
      
      protected var contentClip:Sprite;
      
      protected var _scaleContent:Boolean = true;
      
      protected var _source:Object;
      
      public function UILoader()
      {
         super();
      }
      
      public static function getStyleDefinition() : Object
      {
         return defaultStyles;
      }
      
      protected function _unload(param1:Boolean = false) : void
      {
         var throwError:Boolean = false;
         throwError = param1;
         if(this.loader != null)
         {
            this.clearLoadEvents();
            this.contentClip.removeChild(this.loader);
            try
            {
               this.loader.close();
            }
            catch(e:Error)
            {
            }
            try
            {
               this.loader.unload();
            }
            catch(e:*)
            {
               if(throwError)
               {
                  throw e;
               }
            }
            this.loader = null;
            return;
         }
         this.contentInited = false;
         if(this.contentClip.numChildren)
         {
            this.contentClip.removeChildAt(0);
         }
      }
      
      protected function handleComplete(param1:Event) : void
      {
         this.clearLoadEvents();
         this.passEvent(param1);
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         if(!this._scaleContent && _width > 0)
         {
            return;
         }
         super.setSize(param1,param2);
      }
      
      override protected function draw() : void
      {
         if(isInvalid(InvalidationType.SIZE))
         {
            this.drawLayout();
         }
         super.draw();
      }
      
      protected function handleError(param1:Event) : void
      {
         this.passEvent(param1);
         this.clearLoadEvents();
         this.loader.contentLoaderInfo.removeEventListener(Event.INIT,this.handleInit);
      }
      
      protected function initLoader() : void
      {
         this.loader = new Loader();
         this.contentClip.addChild(this.loader);
      }
      
      protected function clearLoadEvents() : void
      {
         this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.handleError);
         this.loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleError);
         this.loader.contentLoaderInfo.removeEventListener(Event.OPEN,this.passEvent);
         this.loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.passEvent);
         this.loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS,this.passEvent);
         this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.handleComplete);
      }
      
      protected function drawLayout() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:LoaderInfo = null;
         if(!this.contentInited)
         {
            return;
         }
         var _loc4_:Boolean = false;
         if(this.loader)
         {
            _loc3_ = this.loader.contentLoaderInfo;
            _loc1_ = _loc3_.width;
            _loc2_ = _loc3_.height;
         }
         else
         {
            _loc1_ = this.contentClip.width;
            _loc2_ = this.contentClip.height;
         }
         var _loc5_:Number = _width;
         var _loc6_:Number = _height;
         if(!this._scaleContent)
         {
            _width = this.contentClip.width;
            _height = this.contentClip.height;
         }
         else
         {
            this.sizeContent(this.contentClip,_loc1_,_loc2_,_width,_height);
         }
         if(_loc5_ != _width || _loc6_ != _height)
         {
            dispatchEvent(new ComponentEvent(ComponentEvent.RESIZE,true));
         }
      }
      
      public function get scaleContent() : Boolean
      {
         return this._scaleContent;
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         this.contentClip = new Sprite();
         addChild(this.contentClip);
      }
      
      public function get maintainAspectRatio() : Boolean
      {
         return this._maintainAspectRatio;
      }
      
      protected function passEvent(param1:Event) : void
      {
         dispatchEvent(param1);
      }
      
      public function get bytesTotal() : uint
      {
         return this.loader == null || this.loader.contentLoaderInfo == null ? uint(0) : uint(this.loader.contentLoaderInfo.bytesTotal);
      }
      
      protected function sizeContent(param1:DisplayObject, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = param4;
         var _loc9_:Number = param5;
         if(this._maintainAspectRatio)
         {
            _loc6_ = param4 / param5;
            _loc7_ = param2 / param3;
            if(_loc6_ < _loc7_)
            {
               _loc9_ = _loc8_ / _loc7_;
            }
            else
            {
               _loc8_ = _loc9_ * _loc7_;
            }
         }
         param1.width = _loc8_;
         param1.height = _loc9_;
         param1.x = param4 / 2 - _loc8_ / 2;
         param1.y = param5 / 2 - _loc9_ / 2;
      }
      
      public function get source() : Object
      {
         return this._source;
      }
      
      public function set scaleContent(param1:Boolean) : void
      {
         if(this._scaleContent == param1)
         {
            return;
         }
         this._scaleContent = param1;
         invalidate(InvalidationType.SIZE);
      }
      
      public function get bytesLoaded() : uint
      {
         return this.loader == null || this.loader.contentLoaderInfo == null ? uint(0) : uint(this.loader.contentLoaderInfo.bytesLoaded);
      }
      
      public function loadBytes(param1:ByteArray, param2:LoaderContext = null) : void
      {
         var bytes:ByteArray = param1;
         var context:LoaderContext = param2;
         this._unload();
         this.initLoader();
         try
         {
            this.loader.loadBytes(bytes,context);
            return;
         }
         catch(error:*)
         {
            throw error;
         }
      }
      
      protected function handleInit(param1:Event) : void
      {
         this.loader.contentLoaderInfo.removeEventListener(Event.INIT,this.handleInit);
         this.contentInited = true;
         this.passEvent(param1);
         invalidate(InvalidationType.SIZE);
      }
      
      public function set autoLoad(param1:Boolean) : void
      {
         this._autoLoad = param1;
         if(this._autoLoad && this.loader == null && this._source != null && this._source != "")
         {
            this.load();
         }
      }
      
      public function load(param1:URLRequest = null, param2:LoaderContext = null) : void
      {
         this._unload();
         if((param1 == null || param1.url == null) && (this._source == null || this._source == ""))
         {
            return;
         }
         var _loc3_:DisplayObject = getDisplayObjectInstance(this.source);
         if(_loc3_ != null)
         {
            this.contentClip.addChild(_loc3_);
            this.contentInited = true;
            invalidate(InvalidationType.SIZE);
            return;
         }
         param1 = param1;
         if(param1 == null)
         {
            param1 = new URLRequest(this._source.toString());
         }
         if(param2 == null)
         {
            param2 = new LoaderContext(false,ApplicationDomain.currentDomain);
         }
         this.initLoader();
         this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.handleError,false,0,true);
         this.loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleError,false,0,true);
         this.loader.contentLoaderInfo.addEventListener(Event.OPEN,this.passEvent,false,0,true);
         this.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.passEvent,false,0,true);
         this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.handleComplete,false,0,true);
         this.loader.contentLoaderInfo.addEventListener(Event.INIT,this.handleInit,false,0,true);
         this.loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.passEvent,false,0,true);
         this.loader.load(param1,param2);
      }
      
      public function get percentLoaded() : Number
      {
         return this.bytesTotal <= 0 ? Number(0) : Number(this.bytesLoaded / this.bytesTotal * 100);
      }
      
      public function set maintainAspectRatio(param1:Boolean) : void
      {
         this._maintainAspectRatio = param1;
         invalidate(InvalidationType.SIZE);
      }
      
      public function get autoLoad() : Boolean
      {
         return this._autoLoad;
      }
      
      public function set source(param1:Object) : void
      {
         if(param1 == "")
         {
            return;
         }
         this._source = param1;
         this._unload();
         if(this._autoLoad && this._source != null)
         {
            this.load();
         }
      }
      
      public function close() : void
      {
         try
         {
            this.loader.close();
            return;
         }
         catch(error:*)
         {
            throw error;
         }
      }
      
      public function get content() : DisplayObject
      {
         if(this.loader != null)
         {
            return this.loader.content;
         }
         if(this.contentClip.numChildren)
         {
            return this.contentClip.getChildAt(0);
         }
         return null;
      }
      
      public function unload() : void
      {
         this._source = null;
         this._unload(true);
      }
   }
}

