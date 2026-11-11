package rendering.rendering2d.particles
{
   import as3isolib.geom.Pt;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.geom.Matrix;
   import zlabs.core.ObjectPool;
   import zlabs.utils.MathUtils;
   
   public class Particle
   {
      
      private var m_sprite:Sprite = null;
      
      private var m_bitmap:Bitmap = null;
      
      private var m_loader:ImageLoader = null;
      
      private var m_parent:DisplayObjectContainer = null;
      
      private var m_mtx:Matrix = new Matrix();
      
      private var m_position:Pt = null;
      
      private var m_endPosition:Pt = null;
      
      public function Particle(param1:String)
      {
         super();
         this.m_loader = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(param1),null,this.onImageLoaded);
      }
      
      public static function Create(param1:Pt, param2:DisplayObjectContainer) : Particle
      {
         var _loc3_:Particle = ObjectPool.instance.getObject(Particle,"assets/game/GeneralAssetGroup_UI.swf/twinkle_star.png");
         _loc3_.init(param1,param2);
         return _loc3_;
      }
      
      public function init(param1:Pt, param2:DisplayObjectContainer) : void
      {
         var _loc3_:Number = NaN;
         this.m_parent = param2;
         this.m_position = param1;
         if(this.m_sprite)
         {
            _loc3_ = this.m_bitmap.width * 2;
            this.m_endPosition = new Pt(this.m_position.x + MathUtils.randBetween(-_loc3_,_loc3_),this.m_position.y + MathUtils.randBetween(-_loc3_,_loc3_));
            this.m_parent.addChild(this.m_sprite);
            TweenLite.to(this,1.5,{
               "update":1,
               "onComplete":this.complete
            });
         }
      }
      
      private function onImageLoaded(param1:String, param2:BitmapData) : void
      {
         this.m_sprite = new Sprite();
         this.m_sprite.mouseEnabled = false;
         this.m_sprite.mouseChildren = false;
         this.m_bitmap = new Bitmap(param2);
         this.m_bitmap.x = this.m_bitmap.width * -0.5;
         this.m_bitmap.y = this.m_bitmap.height * -0.5;
         this.m_sprite.addChild(this.m_bitmap);
         this.init(this.m_position,this.m_parent);
      }
      
      public function get update() : Number
      {
         return 0;
      }
      
      public function set update(param1:Number) : void
      {
         var _loc2_:Pt = Pt.interpolate(this.m_position,this.m_endPosition,param1);
         this.m_mtx.identity();
         this.m_mtx.rotate(param1 * 8);
         this.m_mtx.scale(1 - param1,1 - param1);
         this.m_mtx.tx = _loc2_.x;
         this.m_mtx.ty = _loc2_.y;
         this.m_sprite.transform.matrix = this.m_mtx;
      }
      
      private function complete() : void
      {
         this.m_parent.removeChild(this.m_sprite);
         this.m_parent = null;
         if(this.m_loader)
         {
            this.m_loader.destroy();
            this.m_loader = null;
         }
         ObjectPool.instance.disposeObject(this,Particle);
      }
   }
}

