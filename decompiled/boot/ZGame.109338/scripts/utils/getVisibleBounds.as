package utils
{
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   
   public function getVisibleBounds(param1:DisplayObject) : Rectangle
   {
      var _loc2_:Matrix = new Matrix();
      _loc2_.tx = -param1.getBounds(null).x;
      _loc2_.ty = -param1.getBounds(null).y;
      var _loc3_:BitmapData = new BitmapData(param1.width,param1.height,true,0);
      _loc3_.draw(param1,_loc2_);
      var _loc4_:Rectangle = _loc3_.getColorBoundsRect(4294967295,0,false);
      _loc3_.dispose();
      return _loc4_;
   }
}

