package rendering.rendering2d
{
   import Engine.Helpers.Vector2;
   import as3isolib.geom.Pt;
   import core.gameobjects.ItemImage;
   import displays.ImageLoaderFactory;
   import flash.display.BitmapData;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import zlabs.entity.PropertyReference;
   import zlabs.rendering.rendering2D.spritesheet.SpriteContainerComponent;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   
   public class GameArtComponent extends SpriteContainerComponent
   {
      
      public var imageReference:PropertyReference = null;
      
      protected var m_gridSize:Point = new Point();
      
      protected var m_offset:Pt = new Pt(0,0);
      
      protected var m_skew:Pt = new Pt(0,0);
      
      protected var m_requestedImage:String = null;
      
      protected var m_currentImage:String = null;
      
      private var _image:BitmapData = null;
      
      private var m_canvas:BitmapData = null;
      
      private var m_layers:Array = null;
      
      public function GameArtComponent()
      {
         super();
      }
      
      override protected function onRemove() : void
      {
         this._image = null;
         this.m_canvas = null;
         this.m_layers = null;
         super.onRemove();
      }
      
      override public function get isLoaded() : Boolean
      {
         return this._image != null;
      }
      
      override public function getFrame(param1:int, param2:Number = 0) : BitmapData
      {
         return this.m_canvas;
      }
      
      public function set gridSize(param1:Point) : void
      {
         this.m_gridSize.x = param1.x;
         this.m_gridSize.y = param1.y;
      }
      
      public function set imageFilename(param1:String) : void
      {
         if(this._image)
         {
            if(this.m_currentImage == param1)
            {
               return;
            }
         }
         this.m_requestedImage = param1;
         ImageLoaderFactory.CreateImageLoader(param1,null,this.onImageLoaded);
      }
      
      public function set imageOffset(param1:Pt) : void
      {
         this.m_offset = param1;
      }
      
      public function set imageSkew(param1:Pt) : void
      {
         this.m_skew = param1;
      }
      
      public function get dimensions() : Vector2
      {
         return new Vector2(this._image.width,this._image.height);
      }
      
      public function get bitmapData() : BitmapData
      {
         return this.m_canvas;
      }
      
      public function set bitmapData(param1:BitmapData) : void
      {
         this._image = param1;
         owner.eventDispatcher.dispatchEvent(new Event(IsoSpriteRenderer.IMAGE_UPDATED));
      }
      
      public function set itemImage(param1:ItemImage) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         if(!param1)
         {
            this.unloadImage(true);
            return;
         }
         this.imageOffset = param1.offset;
         this.imageSkew = param1.skew;
         this.imageFilename = param1.url;
         if(param1.additionalImages)
         {
            this.m_layers = new Array();
            for each(_loc2_ in param1.additionalImages)
            {
               this.m_layers.push({
                  "url":_loc2_.url,
                  "offset":_loc2_.offset,
                  "skew":_loc2_.skew
               });
            }
            for each(_loc3_ in this.m_layers)
            {
               ImageLoaderFactory.CreateImageLoader(_loc3_.url,null,this.onAdditionalImageLoaded);
            }
         }
      }
      
      public function get imageOffset() : Pt
      {
         return this.m_offset;
      }
      
      public function get imageSkew() : Pt
      {
         return this.m_skew;
      }
      
      public function updateDisplayObjectTransform() : void
      {
      }
      
      private function unloadImage(param1:Boolean) : void
      {
         this._image = null;
         this.m_canvas = null;
         if(param1)
         {
            owner.eventDispatcher.dispatchEvent(new Event(IsoSpriteRenderer.IMAGE_UPDATED));
         }
      }
      
      private function onAdditionalImageLoaded(param1:String, param2:BitmapData) : void
      {
         var _loc3_:Object = null;
         for each(_loc3_ in this.m_layers)
         {
            if(_loc3_.url == param1)
            {
               _loc3_.bitmapData = param2;
               this.buildImage();
               break;
            }
         }
      }
      
      protected function onImageLoaded(param1:String, param2:BitmapData) : void
      {
         if(isRegistered)
         {
            if(param1 == this.m_requestedImage)
            {
               this.unloadImage(false);
               this._image = param2;
               this.m_currentImage = param1;
               this.m_requestedImage = null;
               this.buildImage();
            }
         }
      }
      
      private function buildImage() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:Boolean = false;
         var _loc3_:Object = null;
         var _loc4_:Pt = null;
         var _loc5_:Matrix = null;
         if(this._image)
         {
            _loc1_ = false;
            if(this.m_canvas == null)
            {
               if(this.m_layers)
               {
                  this.m_canvas = new BitmapData(this._image.width,this._image.height,true,0);
                  this.m_canvas.draw(this._image);
               }
               else
               {
                  this.m_canvas = this._image;
               }
               _loc1_ = true;
            }
            if(null != this.m_layers)
            {
               this.m_currentImage = null;
               _loc2_ = true;
               for each(_loc3_ in this.m_layers)
               {
                  if(_loc3_.url != null)
                  {
                     if(_loc3_.bitmapData == null)
                     {
                        _loc2_ = false;
                        break;
                     }
                     _loc4_ = new Pt(0,this._image.height - _loc3_.bitmapData.height);
                     if(null != _loc3_.offset)
                     {
                        _loc4_.x += _loc3_.offset.x;
                        _loc4_.y += _loc3_.offset.y;
                     }
                     _loc5_ = new Matrix();
                     _loc5_.translate(_loc4_.x,_loc4_.y);
                     if(null != _loc3_.skew)
                     {
                        _loc5_.c = _loc3_.skew.x;
                        _loc5_.b = _loc3_.skew.y;
                     }
                     this.m_canvas.draw(_loc3_.bitmapData,_loc5_);
                     _loc1_ = true;
                     _loc3_.bitmapData = null;
                     _loc3_.url = null;
                  }
               }
               if(_loc2_)
               {
                  this.m_layers = null;
               }
            }
         }
         if(_loc1_)
         {
            owner.eventDispatcher.dispatchEvent(new Event(IsoSpriteRenderer.IMAGE_UPDATED));
         }
      }
   }
}

