package fl.containers
{
   import fl.core.InvalidationType;
   import fl.core.UIComponent;
   import fl.display.ProLoader;
   import fl.display.ProLoaderInfo;
   import fl.events.ComponentEvent;
   import flash.display.DisplayObject;
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
   
   [Embed(source="/_assets/assets.swf", symbol="symbol22")]
   public class UILoader extends UIComponent
   {
      
      private static var defaultStyles:Object = {};
      
      protected var _scaleContent:Boolean = true;
      
      protected var _autoLoad:Boolean = true;
      
      protected var contentInited:Boolean = false;
      
      protected var _source:Object;
      
      protected var loader:ProLoader;
      
      protected var _maintainAspectRatio:Boolean = true;
      
      protected var contentClip:Sprite;
      
      public function UILoader()
      {
         super();
      }
      
      public static function getStyleDefinition() : Object
      {
         return defaultStyles;
      }
      
      override public function setSize(param1:Number, param2:Number) : void
      {
         if(!this._scaleContent && _width > 0)
         {
            return;
         }
         super.setSize(param1,param2);
      }
      
      public function get autoLoad() : Boolean
      {
         return this._autoLoad;
      }
      
      public function set autoLoad(param1:Boolean) : void
      {
         this._autoLoad = param1;
         if(this._autoLoad && this.loader == null && this._source != null && this._source != "")
         {
            this.load();
         }
      }
      
      public function get scaleContent() : Boolean
      {
         return this._scaleContent;
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
      
      public function get maintainAspectRatio() : Boolean
      {
         return this._maintainAspectRatio;
      }
      
      public function set maintainAspectRatio(param1:Boolean) : void
      {
         this._maintainAspectRatio = param1;
         invalidate(InvalidationType.SIZE);
      }
      
      public function get bytesLoaded() : uint
      {
         return this.loader == null || this.loader.contentLoaderInfo == null ? 0 : this.loader.contentLoaderInfo.bytesLoaded;
      }
      
      public function get bytesTotal() : uint
      {
         return this.loader == null || this.loader.contentLoaderInfo == null ? 0 : this.loader.contentLoaderInfo.bytesTotal;
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
      
      public function get source() : Object
      {
         return this._source;
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
      
      public function get percentLoaded() : Number
      {
         return this.bytesTotal <= 0 ? 0 : this.bytesLoaded / this.bytesTotal * 100;
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
         this.loader.load(param1,param2);
      }
      
      public function unload() : void
      {
         this._source = null;
         this._unload(true);
      }
      
      public function close() : void
      {
         try
         {
            this.loader.close();
         }
         catch(error:*)
         {
            throw error;
         }
      }
      
      protected function _unload(param1:Boolean = false) : void
      {
         var throwError:Boolean = param1;
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
      
      protected function initLoader() : void
      {
         this.loader = new ProLoader();
         this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.handleError,false,0,true);
         this.loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleError,false,0,true);
         this.loader.contentLoaderInfo.addEventListener(Event.OPEN,this.passEvent,false,0,true);
         this.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.passEvent,false,0,true);
         this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.handleComplete,false,0,true);
         this.loader.contentLoaderInfo.addEventListener(Event.INIT,this.handleInit,false,0,true);
         this.loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS,this.passEvent,false,0,true);
         this.contentClip.addChild(this.loader);
      }
      
      protected function handleComplete(param1:Event) : void
      {
         this.clearLoadEvents();
         this.passEvent(param1);
      }
      
      protected function passEvent(param1:Event) : void
      {
         dispatchEvent(param1);
      }
      
      protected function handleError(param1:Event) : void
      {
         this.passEvent(param1);
         this.clearLoadEvents();
         this.loader.contentLoaderInfo.removeEventListener(Event.INIT,this.handleInit);
      }
      
      protected function handleInit(param1:Event) : void
      {
         this.loader.contentLoaderInfo.removeEventListener(Event.INIT,this.handleInit);
         this.contentInited = true;
         this.passEvent(param1);
         invalidate(InvalidationType.SIZE);
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
      
      override protected function draw() : void
      {
         if(isInvalid(InvalidationType.SIZE))
         {
            this.drawLayout();
         }
         super.draw();
      }
      
      protected function drawLayout() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc6_:ProLoaderInfo = null;
         if(!this.contentInited)
         {
            return;
         }
         var _loc1_:Boolean = false;
         if(this.loader)
         {
            _loc6_ = this.loader.contentLoaderInfo;
            _loc2_ = _loc6_.width;
            _loc3_ = _loc6_.height;
         }
         else
         {
            _loc2_ = this.contentClip.width;
            _loc3_ = this.contentClip.height;
         }
         var _loc4_:Number = _width;
         var _loc5_:Number = _height;
         if(!this._scaleContent)
         {
            _width = this.contentClip.width;
            _height = this.contentClip.height;
         }
         else
         {
            this.sizeContent(this.contentClip,_loc2_,_loc3_,_width,_height);
         }
         if(_loc4_ != _width || _loc5_ != _height)
         {
            dispatchEvent(new ComponentEvent(ComponentEvent.RESIZE,true));
         }
      }
      
      protected function sizeContent(param1:DisplayObject, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc6_:Number = param4;
         var _loc7_:Number = param5;
         if(this._maintainAspectRatio)
         {
            _loc8_ = param4 / param5;
            _loc9_ = param2 / param3;
            if(_loc8_ < _loc9_)
            {
               _loc7_ = _loc6_ / _loc9_;
            }
            else
            {
               _loc6_ = _loc7_ * _loc9_;
            }
         }
         param1.width = _loc6_;
         param1.height = _loc7_;
         param1.x = param4 / 2 - _loc6_ / 2;
         param1.y = param5 / 2 - _loc7_ / 2;
      }
      
      override protected function configUI() : void
      {
         super.configUI();
         this.contentClip = new Sprite();
         addChild(this.contentClip);
      }
   }
}

