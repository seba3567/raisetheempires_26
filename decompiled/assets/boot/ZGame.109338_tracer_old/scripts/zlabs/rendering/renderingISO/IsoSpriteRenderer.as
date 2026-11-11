package zlabs.rendering.renderingISO
{
   import as3isolib.display.IsoSprite;
   import as3isolib.geom.Pt;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import zlabs.core.ObjectType;
   import zlabs.entity.PropertyReference;
   import zlabs.rendering.rendering2D.spritesheet.SpriteContainerComponent;
   
   public class IsoSpriteRenderer extends BitmapFillComponent
   {
      
      public static const IMAGE_UPDATED:String = "imageupdated";
      
      public var isoComponent:SpriteContainerComponent;
      
      public var spriteIndex:int = 0;
      
      public var directionReference:PropertyReference;
      
      public var offsetReference:PropertyReference;
      
      public var isometricVolumeReference:PropertyReference;
      
      public var isoSpritePropRef:PropertyReference;
      
      private var offset:Pt = null;
      
      private var volume:Pt = null;
      
      private var m_imageOffset:Pt = new Pt(0,0);
      
      private var canvas:Graphics;
      
      private var matrix:Matrix = new Matrix();
      
      public function IsoSpriteRenderer()
      {
         super();
      }
      
      protected function getCurrentFrame() : BitmapData
      {
         if(!this.isoComponent || !this.isoComponent.isLoaded)
         {
            return null;
         }
         if(this.directionReference)
         {
            return this.isoComponent.getFrame(this.spriteIndex,owner.getProperty(this.directionReference) as Number);
         }
         return this.isoComponent.getFrame(this.spriteIndex);
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         this.bitmapDataUpdated();
         owner.eventDispatcher.addEventListener(IMAGE_UPDATED,this.onImageUpdated,false,0,true);
         owner.eventDispatcher.addEventListener(IsoSpriteComponent.FORCE_UPDATE_DISPLAY,this.onForceUpdateDisplay,false,0,true);
         var _loc1_:IsoSprite = owner.getProperty(this.isoSpritePropRef) as IsoSprite;
         this.canvas = _loc1_.container.graphics;
         registerForUpdates = false;
      }
      
      public function get imageOffset() : Pt
      {
         return this.m_imageOffset;
      }
      
      public function get displayObject() : DisplayObject
      {
         var _loc1_:IsoSprite = owner.getProperty(this.isoSpritePropRef) as IsoSprite;
         return _loc1_.container;
      }
      
      private function onImageUpdated(param1:Event = null) : void
      {
         var _loc2_:BitmapData = this.getCurrentFrame();
         if(!_loc2_)
         {
            return;
         }
         if(null != param1)
         {
            this.bitmapDataUpdated();
         }
         this.updateDisplayObjectTransform(_loc2_);
         this.canvas.clear();
         this.canvas.beginBitmapFill(_loc2_,this.matrix,false,false);
         this.canvas.drawRect(this.matrix.tx,this.matrix.ty,_loc2_.width,_loc2_.height);
         this.canvas.endFill();
      }
      
      private function onForceUpdateDisplay(param1:Event) : void
      {
         this.onImageUpdated();
      }
      
      public function pickingAlphaThreshold(param1:Number) : void
      {
      }
      
      override public function onFrame(param1:Number) : void
      {
      }
      
      private function bitmapDataUpdated() : void
      {
         this.offset = owner.getProperty(this.offsetReference);
         this.volume = owner.getProperty(this.isometricVolumeReference);
      }
      
      public function updateDisplayObjectTransform(param1:BitmapData) : void
      {
         this.m_imageOffset.x = -(param1.width / 2);
         this.m_imageOffset.y = -param1.height + this.volume.y;
         if(this.offset)
         {
            this.m_imageOffset.x += this.offset.x;
            this.m_imageOffset.y += this.offset.y;
         }
         this.matrix.tx = this.m_imageOffset.x;
         this.matrix.ty = this.m_imageOffset.y;
      }
      
      public function pointOccupied(param1:Point, param2:ObjectType) : Boolean
      {
         return false;
      }
      
      override protected function onRemove() : void
      {
         this.isoComponent = null;
         owner.eventDispatcher.removeEventListener(IMAGE_UPDATED,this.onImageUpdated);
         owner.eventDispatcher.removeEventListener(IsoSpriteComponent.FORCE_UPDATE_DISPLAY,this.onForceUpdateDisplay);
         super.onRemove();
      }
   }
}

