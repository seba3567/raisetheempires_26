package zlabs.rendering.rendering2D.spritesheet
{
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.resource.ImageResource;
   
   public class SpriteSheetComponent extends SpriteContainerComponent
   {
      
      private var _image:ImageResource = null;
      
      private var _divider:ISpriteSheetDivider = null;
      
      private var _forcedBitmaps:Array = null;
      
      public function SpriteSheetComponent()
      {
         super();
      }
      
      override public function get isLoaded() : Boolean
      {
         return this.imageData != null || Boolean(this._forcedBitmaps);
      }
      
      public function get imageFilename() : String
      {
         return this._image == null ? null : this._image.filename;
      }
      
      public function set imageFilename(param1:String) : void
      {
         if(this._image)
         {
            Zlab.resourceManager.unload(this._image.filename,ImageResource);
            this.image = null;
         }
         Zlab.resourceManager.load(param1,ImageResource,this.onImageLoaded,this.onImageFailed);
      }
      
      public function get image() : ImageResource
      {
         return this._image;
      }
      
      public function set image(param1:ImageResource) : void
      {
         this._image = param1;
         deleteFrames();
      }
      
      public function get imageData() : BitmapData
      {
         if(!this._image)
         {
            return null;
         }
         return this._image.bitmapData;
      }
      
      public function get divider() : ISpriteSheetDivider
      {
         return this._divider;
      }
      
      public function set divider(param1:ISpriteSheetDivider) : void
      {
         this._divider = param1;
         this._divider.owningSheet = this;
         deleteFrames();
      }
      
      override protected function getSourceFrames() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:Rectangle = null;
         if(this._forcedBitmaps)
         {
            return this._forcedBitmaps;
         }
         if(!this.imageData)
         {
            return null;
         }
         if(!this._divider)
         {
            _loc1_ = new Array(1);
            _loc1_[0] = this.imageData;
         }
         else
         {
            _loc1_ = new Array(this._divider.frameCount);
            _loc2_ = 0;
            while(_loc2_ < this._divider.frameCount)
            {
               _loc3_ = this._divider.getFrameArea(_loc2_);
               _loc1_[_loc2_] = new BitmapData(_loc3_.width,_loc3_.height,true);
               _loc1_[_loc2_].copyPixels(this.imageData,_loc3_,new Point(0,0));
               _loc2_++;
            }
         }
         return _loc1_;
      }
      
      public function initializeFromBitmapDataArray(param1:Array) : void
      {
         this._forcedBitmaps = param1;
      }
      
      protected function onImageLoaded(param1:ImageResource) : void
      {
         this.image = param1;
      }
      
      protected function onImageFailed(param1:ImageResource) : void
      {
         Logger.error(this,"onImageFailed","Failed to load \'" + (param1 ? param1.filename : "(unknown)") + "\'");
      }
   }
}

