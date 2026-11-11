package zlabs.utils.bitmapDataUnlimited
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.IBitmapDrawable;
   import flash.display.Loader;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import zlabs.utils.bitmapDataUnlimited.events.BitmapDataUnlimitedEvent;
   
   [Event(name="ERROR",type="com.formatlos.events.BitmapDataUnlimitedEvent")]
   [Event(name="COMPLETE",type="com.formatlos.events.BitmapDataUnlimitedEvent")]
   public class BitmapDataUnlimited extends EventDispatcher
   {
      
      private static const DRAW_LIMIT:uint = 4000;
      
      private var _loader:Loader;
      
      private var _gif:Gif;
      
      private var _fillColor:uint;
      
      private var _transparent:Boolean;
      
      private var _bitmapData:BitmapData;
      
      public function BitmapDataUnlimited()
      {
         super();
      }
      
      public function dispose() : void
      {
         this._bitmapData.dispose();
         this._bitmapData = null;
         this._gif.dispose();
         this._gif = null;
         this._loader = null;
      }
      
      public function get bitmapData() : BitmapData
      {
         return this._bitmapData;
      }
      
      public function create(param1:int, param2:int, param3:Boolean = true, param4:uint = 16777215) : void
      {
         var width_:int = param1;
         var height_:int = param2;
         var transparent_:Boolean = param3;
         var fillColor_:uint = param4;
         try
         {
            this._bitmapData = new BitmapData(width_,height_,transparent_,fillColor_);
            dispatchEvent(new BitmapDataUnlimitedEvent(BitmapDataUnlimitedEvent.COMPLETE));
         }
         catch(error:ArgumentError)
         {
            if(width_ <= 0 || height_ <= 0)
            {
               throw error;
            }
            _transparent = transparent_;
            _fillColor = fillColor_;
            _gif = new Gif(width_,height_,transparent_,fillColor_);
            _loader = new Loader();
            _loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoaderComplete);
            _loader.loadBytes(_gif.bytes);
         }
         this._fillColor;
      }
      
      public function draw(param1:IBitmapDrawable, param2:ColorTransform = null, param3:String = null, param4:Rectangle = null, param5:Boolean = false) : void
      {
         var _loc6_:Rectangle = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Matrix = null;
         var _loc14_:BitmapData = null;
         var _loc15_:Rectangle = null;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         if(param1 is BitmapData)
         {
            _loc6_ = (param1 as BitmapData).rect.clone();
         }
         else if(param1 is DisplayObject)
         {
            _loc6_ = (param1 as DisplayObject).getBounds(param1 as DisplayObject);
         }
         if(_loc6_)
         {
            _loc7_ = param4 ? int(param4.x) : 0;
            _loc8_ = param4 ? int(param4.y) : 0;
            _loc9_ = _loc7_ + (param4 ? param4.width : this._bitmapData.width);
            _loc10_ = _loc8_ + (param4 ? param4.height : this._bitmapData.height);
            _loc11_ = Math.min(_loc6_.right,_loc9_);
            _loc12_ = Math.min(_loc6_.bottom,_loc10_);
            _loc15_ = new Rectangle();
            _loc16_ = 0;
            _loc17_ = 0;
            while(_loc7_ < _loc11_)
            {
               while(_loc8_ < _loc12_)
               {
                  _loc13_ = new Matrix();
                  _loc13_.tx = -_loc7_;
                  _loc13_.ty = -_loc8_;
                  _loc15_.width = _loc11_ - _loc7_ >= DRAW_LIMIT ? DRAW_LIMIT : _loc11_ - _loc7_;
                  _loc15_.height = _loc12_ - _loc8_ >= DRAW_LIMIT ? DRAW_LIMIT : _loc12_ - _loc8_;
                  if(!_loc14_)
                  {
                     _loc14_ = this._bitmapData.clone();
                  }
                  _loc14_.fillRect(_loc14_.rect,!this._transparent ? 2972807 : 0);
                  _loc14_.draw(param1,_loc13_,param2,param3,_loc15_,param5);
                  this._bitmapData.copyPixels(_loc14_,_loc15_,new Point(_loc16_,_loc17_),null,null,true);
                  _loc17_ += _loc15_.height;
                  _loc8_ += DRAW_LIMIT;
               }
               _loc16_ += _loc15_.width;
               _loc7_ += DRAW_LIMIT;
               _loc8_ = param4 ? int(param4.y) : 0;
               _loc17_ = 0;
            }
            if(_loc14_)
            {
               _loc14_.dispose();
               _loc14_ = null;
            }
         }
      }
      
      public function clear() : void
      {
         this._bitmapData.fillRect(this._bitmapData.rect,!this._transparent ? 2972807 : 0);
      }
      
      private function onLoaderComplete(param1:Event) : void
      {
         var event:Event = param1;
         var ok:Boolean = true;
         try
         {
            this._bitmapData = Bitmap(this._loader.content).bitmapData.clone();
            if(!this._transparent)
            {
               this._bitmapData.fillRect(this._bitmapData.rect,this._fillColor);
            }
         }
         catch(error:ArgumentError)
         {
            ok = false;
            dispatchEvent(new BitmapDataUnlimitedEvent(BitmapDataUnlimitedEvent.ERROR));
         }
         this._loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoaderComplete);
         this._loader.unload();
         this._loader = null;
         this._gif.dispose();
         this._gif = null;
         if(ok)
         {
            dispatchEvent(new BitmapDataUnlimitedEvent(BitmapDataUnlimitedEvent.COMPLETE));
         }
      }
   }
}

