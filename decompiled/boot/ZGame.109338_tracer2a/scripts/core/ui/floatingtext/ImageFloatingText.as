package core.ui.floatingtext
{
   import core.ui.FloatingText;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   
   public class ImageFloatingText extends FloatingText
   {
      
      private var m_imageLoader:ImageLoader = null;
      
      private var m_bitmap:Bitmap = null;
      
      private var m_scale:Number = 0.5;
      
      public function ImageFloatingText(param1:DisplayObjectContainer, param2:String)
      {
         super(param1);
         this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(param2,null,this.onImageLoaded);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(null != this.m_bitmap)
         {
            removeChild(this.m_bitmap);
            this.m_bitmap = null;
         }
         this.m_imageLoader.destroy();
         this.m_imageLoader = null;
      }
      
      override protected function get buffer() : int
      {
         return 32;
      }
      
      private function onImageLoaded(param1:String, param2:BitmapData) : void
      {
         this.m_bitmap = new Bitmap(param2);
         this.m_bitmap.smoothing = true;
         this.m_bitmap.scaleX = this.m_bitmap.scaleY = this.m_scale;
         this.m_bitmap.x = -this.m_bitmap.width;
         addChild(this.m_bitmap);
      }
   }
}

