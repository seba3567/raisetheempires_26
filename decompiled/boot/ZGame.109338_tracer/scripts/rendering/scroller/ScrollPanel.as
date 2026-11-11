package rendering.scroller
{
   import flash.display.Bitmap;
   import flash.display.IBitmapDrawable;
   import flash.geom.Rectangle;
   import zlabs.utils.bitmapDataUnlimited.BitmapDataUnlimited;
   
   public class ScrollPanel extends Bitmap
   {
      
      public var ID:String;
      
      private var bitmapController:BitmapDataUnlimited;
      
      public function ScrollPanel(param1:BitmapDataUnlimited)
      {
         this.bitmapController = param1;
         super(this.bitmapController.bitmapData,"auto",false);
      }
      
      public function draw(param1:IBitmapDrawable, param2:Rectangle) : void
      {
         var _loc3_:Rectangle = param2.clone();
         _loc3_.x = 0;
         _loc3_.y = 0;
         this.bitmapController.draw(param1,null,null,param2,false);
      }
      
      public function reset() : void
      {
         this.ID = "";
      }
      
      public function dispose() : void
      {
         bitmapData = null;
         this.bitmapController.dispose();
         this.bitmapController = null;
      }
   }
}

