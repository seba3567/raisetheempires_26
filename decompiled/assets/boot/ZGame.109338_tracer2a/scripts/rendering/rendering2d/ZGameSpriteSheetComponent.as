package rendering.rendering2d
{
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.BitmapData;
   import zlabs.rendering.rendering2D.spritesheet.SpriteSheetComponent;
   
   public class ZGameSpriteSheetComponent extends SpriteSheetComponent
   {
      
      private var m_bitmapData:BitmapData = null;
      
      private var m_bitmapDataLoaded:Boolean = false;
      
      private var m_imageLoader:ImageLoader = null;
      
      public function ZGameSpriteSheetComponent()
      {
         super();
      }
      
      override public function set imageFilename(param1:String) : void
      {
         if(this.imageData)
         {
            image = null;
            this.m_imageLoader.destroy();
            this.m_imageLoader = null;
         }
         this.m_bitmapDataLoaded = false;
         this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(param1,null,this.onBitmapDataLoaded);
         this.m_imageLoader.useCache = false;
      }
      
      override public function getFrame(param1:int, param2:Number = 0) : BitmapData
      {
         var _loc3_:BitmapData = null;
         if(this.m_bitmapDataLoaded)
         {
            _loc3_ = getRawFrame(param1);
            if(_loc3_ != null)
            {
               this.m_bitmapData = null;
            }
         }
         return _loc3_;
      }
      
      override public function get imageData() : BitmapData
      {
         return this.m_bitmapData;
      }
      
      private function onBitmapDataLoaded(param1:String, param2:BitmapData) : void
      {
         this.m_bitmapData = param2;
         this.m_bitmapDataLoaded = true;
      }
   }
}

