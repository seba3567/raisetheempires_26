package zlabs.resource
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import zlabs.Zlab;
   
   public class ImageResource extends Resource
   {
      
      protected var _bitmapData:BitmapData = null;
      
      public function ImageResource()
      {
         super();
      }
      
      public function get image() : Bitmap
      {
         if(this._bitmapData != null)
         {
            return new Bitmap(this._bitmapData);
         }
         return null;
      }
      
      public function get bitmapData() : BitmapData
      {
         return this._bitmapData;
      }
      
      public function get byteArray() : ByteArray
      {
         return this._bitmapData.getPixels(this._bitmapData.rect);
      }
      
      override public function initialize(param1:*) : void
      {
         var _loc2_:DisplayObject = null;
         var _loc3_:DisplayObject = null;
         var _loc4_:Rectangle = null;
         var _loc5_:Matrix = null;
         var _loc6_:BitmapData = null;
         if(param1 is Bitmap)
         {
            this.onContentReady(param1.bitmapData);
            onLoadComplete();
            return;
         }
         if(param1 is BitmapData)
         {
            this.onContentReady(param1 as BitmapData);
            onLoadComplete();
            return;
         }
         if(param1 is DisplayObject)
         {
            _loc2_ = param1 as DisplayObject;
            if(_loc2_.parent)
            {
               _loc3_ = _loc2_.parent;
            }
            else
            {
               _loc3_ = Zlab.mainStage;
            }
            _loc4_ = _loc2_.getBounds(_loc3_);
            _loc5_ = new Matrix();
            _loc5_.translate(_loc4_.x * -1,_loc4_.y * -1);
            _loc6_ = new BitmapData(_loc4_.width,_loc4_.height,true,0);
            _loc6_.draw(_loc2_,_loc5_);
            this.onContentReady(_loc6_);
            onLoadComplete();
            return;
         }
         super.initialize(param1);
      }
      
      override protected function onContentReady(param1:*) : Boolean
      {
         if(param1 is BitmapData)
         {
            this._bitmapData = param1 as BitmapData;
         }
         else if(param1 is Bitmap)
         {
            this._bitmapData = (param1 as Bitmap).bitmapData;
            param1 = null;
         }
         return this._bitmapData != null;
      }
   }
}

