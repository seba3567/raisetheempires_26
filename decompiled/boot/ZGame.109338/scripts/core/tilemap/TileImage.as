package core.tilemap
{
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.UIControllerComponent;
   import core.managers.BuildManager;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.geom.Point;
   import utils.BitArray;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.utils.MathUtils;
   
   public class TileImage
   {
      
      private var m_bitmap:Bitmap = null;
      
      private var m_tileAnimation:TileAnimation = null;
      
      private var m_currentFrame:int = 0;
      
      private var m_mapSize:int = 0;
      
      private var m_position:Point = null;
      
      public function TileImage(param1:String, param2:String, param3:int, param4:Point, param5:Sprite)
      {
         super();
         this.m_bitmap = new Bitmap();
         param5.addChild(this.m_bitmap);
         this.m_mapSize = param3;
         this.m_position = param4;
         TilesetManager.instance.loadTileAnimation(param1,param2,this.onTileAnimationLoaded);
      }
      
      public function updateExpansion(param1:BitArray, param2:Boolean) : void
      {
         var _loc3_:int = int(MathUtils.gridToExpansionIndex(this.m_position.x,this.m_position.y,this.m_mapSize));
         if(param1.isBitSet(_loc3_) == param2)
         {
            this.enable = param2;
         }
      }
      
      public function set enable(param1:Boolean) : void
      {
         if(param1)
         {
            this.m_bitmap.transform.colorTransform = ZGameUtils.ClearTransform;
            this.enableObjects = true;
         }
         else
         {
            this.m_bitmap.transform.colorTransform = ZGameUtils.ExpansionTransform;
            this.enableObjects = false;
         }
      }
      
      private function set enableObjects(param1:Boolean) : void
      {
         var _loc9_:int = 0;
         var _loc10_:IEntity = null;
         var _loc2_:String = param1 ? UIControllerComponent.SPRITE_EFFECT_ENABLED_OFF : UIControllerComponent.SPRITE_EFFECT_ENABLED_ON;
         var _loc3_:Array = null;
         var _loc4_:Point = new Point();
         var _loc5_:uint = 4;
         var _loc6_:uint = this.m_position.x * _loc5_;
         var _loc7_:uint = this.m_position.y * _loc5_;
         var _loc8_:int = 0;
         while(_loc8_ < _loc5_)
         {
            _loc9_ = 0;
            while(_loc9_ < _loc5_)
            {
               _loc4_.y = (_loc7_ + _loc8_) * ZGlobal.cellSize;
               _loc4_.x = (_loc6_ + _loc9_) * ZGlobal.cellSize;
               _loc3_ = BuildManager.instance.getObjectsAt(_loc4_,true);
               for each(_loc10_ in _loc3_)
               {
                  _loc10_.eventDispatcher.dispatchEvent(new WorldEvent(UIControllerComponent.EVENT_SPRITE_EFFECT,_loc2_));
               }
               _loc9_++;
            }
            _loc8_++;
         }
      }
      
      private function onTileAnimationLoaded(param1:TileAnimation) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Pt = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Pt = null;
         if(null != this.m_bitmap)
         {
            this.m_tileAnimation = param1;
            this.m_bitmap.bitmapData = this.m_tileAnimation.getFrame(0);
            _loc2_ = this.m_mapSize / (this.m_bitmap.height / ZGlobal.cellSize);
            _loc3_ = new Pt(_loc2_ - 1 - this.m_position.y - _loc2_,this.m_position.x);
            _loc4_ = this.m_bitmap.width;
            _loc5_ = this.m_bitmap.height;
            _loc3_.x *= _loc4_;
            _loc3_.y *= _loc5_;
            _loc6_ = IsoMath.screenToIso(_loc3_);
            this.m_bitmap.x = _loc6_.x;
            this.m_bitmap.y = _loc6_.y * 0.5 - ZGlobal.cellSize * 2;
         }
      }
      
      public function get bitmap() : Bitmap
      {
         return this.m_bitmap;
      }
      
      public function get isAnimating() : Boolean
      {
         return this.m_tileAnimation.frames > 0;
      }
      
      public function dispose() : void
      {
         if(this.m_bitmap != null)
         {
            this.m_bitmap.parent.removeChild(this.m_bitmap);
            this.m_bitmap.bitmapData = null;
            this.m_bitmap = null;
         }
         this.m_tileAnimation = null;
      }
   }
}

