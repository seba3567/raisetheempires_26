package rendering.rendering2d
{
   import as3isolib.geom.Pt;
   import com.greensock.TweenLite;
   import com.greensock.easing.Linear;
   import core.ZGlobal;
   import core.managers.animationManager.Animation;
   import core.managers.animationManager.AnimationManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.entity.EntityComponent;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   import zlabs.utils.MathUtils;
   
   public class AnimationComponent extends EntityComponent
   {
      
      public static const NONE:int = 1 << 0;
      
      public static const LOOP:int = 1 << 1;
      
      private static const MIN_FRAMES:int = 1;
      
      protected var m_anchor:Point = null;
      
      protected var m_position:Point = null;
      
      private var m_animation:Animation = null;
      
      private var m_bitmap:Bitmap = null;
      
      private var m_eventDispatcher:EventDispatcher = null;
      
      private var m_currentFrame:int = 0;
      
      private var m_mode:int = LOOP;
      
      private var m_loopCount:int = -1;
      
      private var m_animTimeout:Number = 0;
      
      private var m_animTime:Number = 0;
      
      private var m_parentIsoSpriteRenderer:IsoSpriteRenderer = null;
      
      private var m_drift:Point = null;
      
      private var m_lastOffset:Pt = null;
      
      private var m_useLastOffset:Boolean = false;
      
      private var m_paused:Boolean = false;
      
      private var m_smooth:Boolean = false;
      
      private var m_frameUpdates:int = 0;
      
      public function AnimationComponent(param1:IsoSpriteRenderer)
      {
         super();
         this.m_bitmap = new Bitmap();
         this.m_lastOffset = new Pt();
         this.m_parentIsoSpriteRenderer = param1;
      }
      
      public function set mode(param1:int) : void
      {
         this.m_mode = param1;
      }
      
      public function set loopCount(param1:int) : void
      {
         this.m_loopCount = param1;
      }
      
      public function set eventDispatcher(param1:EventDispatcher) : void
      {
         this.m_eventDispatcher = param1;
      }
      
      public function set paused(param1:Boolean) : void
      {
         this.m_paused = param1;
      }
      
      public function set smooth(param1:Boolean) : void
      {
         this.m_smooth = param1;
      }
      
      public function mouseHitTest(param1:Point) : Boolean
      {
         var _loc2_:Point = null;
         if(null != this.m_bitmap && null != this.m_bitmap.bitmapData && null != this.m_animation)
         {
            if(this.m_animation.selectable)
            {
               _loc2_ = new Point(param1.x,param1.y);
               _loc2_.x -= this.m_anchor.x;
               _loc2_.y -= this.m_anchor.y;
               _loc2_.x += this.m_animation.rootPoint.x;
               _loc2_.y += this.m_animation.rootPoint.y;
               return this.m_bitmap.bitmapData.hitTest(new Point(0,0),1,_loc2_);
            }
         }
         return false;
      }
      
      public function stop() : void
      {
         if(Boolean(this.m_bitmap) && Boolean(this.m_bitmap.parent))
         {
            this.m_bitmap.parent.removeChild(this.m_bitmap);
         }
         TweenLite.killTweensOf(this.m_position);
         this.m_animation = null;
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         this.stop();
         this.m_bitmap = null;
         this.m_eventDispatcher = null;
         this.m_parentIsoSpriteRenderer = null;
         this.m_anchor = null;
         this.m_position = null;
      }
      
      public function set anchor(param1:Point) : void
      {
         this.m_anchor = param1;
      }
      
      public function set drift(param1:Point) : void
      {
         this.m_drift = param1;
      }
      
      public function get position() : Point
      {
         return this.m_position;
      }
      
      public function set usePool(param1:Boolean) : void
      {
      }
      
      public function set anim(param1:String) : void
      {
         if(param1)
         {
            this.m_animation = AnimationManager.instance.getAnimation(param1);
            if(!this.m_animation)
            {
               Logger.error(this,"anim","unable to find animation called: " + param1);
            }
            else
            {
               this.m_animTime = this.m_animation.frameTime;
               this.m_animTimeout = 0;
               this.m_position = this.m_anchor.clone();
               this.m_position.x -= this.m_animation.rootPoint.x;
               this.m_position.y -= this.m_animation.rootPoint.y;
               this.m_mode = this.m_animation.looping ? LOOP : NONE;
               this.m_loopCount = this.m_animation.loopCount;
               this.m_useLastOffset = this.m_animation.useLastOffset;
               if(this.m_animation.randomStart && Boolean(this.m_mode & LOOP))
               {
                  if(this.m_loopCount < 0)
                  {
                     this.m_currentFrame = MathUtils.randBetween(0,this.m_animation.numFrames - 1);
                  }
               }
               else
               {
                  this.m_currentFrame = 0;
               }
               this.update(0,null);
               this.initDrift();
            }
         }
         else
         {
            this.stop();
         }
      }
      
      protected function initDrift() : void
      {
         if(this.m_drift)
         {
            TweenLite.to(this.m_position,10,{
               "x":this.m_drift.x.toString(),
               "y":this.m_drift.y.toString(),
               "ease":Linear.easeOut
            });
         }
      }
      
      public function update(param1:Number, param2:Pt) : DisplayObject
      {
         if(this.m_animation)
         {
            if(!this.m_paused || null == this.m_bitmap.bitmapData)
            {
               this.m_animTimeout -= param1;
            }
            if(ZGlobal.lowQualityMode && this.m_frameUpdates > MIN_FRAMES && this.m_animation.pausable)
            {
               return this.m_bitmap;
            }
            if(this.m_animTimeout <= 0)
            {
               this.m_animTimeout = this.m_animTime;
               if(this.m_mode & LOOP)
               {
                  ++this.m_currentFrame;
                  this.m_currentFrame %= this.m_animation.numFrames;
                  if(this.m_loopCount > 0 && this.m_currentFrame == 0)
                  {
                     --this.m_loopCount;
                     if(this.m_loopCount <= 1)
                     {
                        this.m_loopCount = -1;
                        this.m_mode &= ~LOOP;
                     }
                  }
                  this.updateBitmap(param2);
               }
               else if(this.m_currentFrame < this.m_animation.numFrames - 1)
               {
                  ++this.m_currentFrame;
                  this.updateBitmap(param2);
                  if(Boolean(this.m_eventDispatcher) && this.m_currentFrame >= this.m_animation.numFrames - 1)
                  {
                     this.dispatchComplete();
                  }
               }
            }
            return this.m_bitmap;
         }
         return null;
      }
      
      public function dispatchComplete() : void
      {
         if(this.m_eventDispatcher)
         {
            this.m_eventDispatcher.dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      private function updateBitmap(param1:Pt) : void
      {
         var _loc2_:BitmapData = this.m_animation.getData(this.m_currentFrame);
         if(_loc2_)
         {
            this.m_bitmap.bitmapData = _loc2_;
            if(this.m_frameUpdates <= MIN_FRAMES)
            {
               ++this.m_frameUpdates;
            }
            this.m_bitmap.x = this.m_position.x;
            this.m_bitmap.y = this.m_position.y;
            if(this.m_parentIsoSpriteRenderer)
            {
               if(!this.m_useLastOffset)
               {
                  this.m_lastOffset.x = this.m_parentIsoSpriteRenderer.imageOffset.x;
                  this.m_lastOffset.y = this.m_parentIsoSpriteRenderer.imageOffset.y;
               }
               this.m_bitmap.x += this.m_lastOffset.x;
               this.m_bitmap.y += this.m_lastOffset.y;
               this.m_useLastOffset = false;
            }
            if(null != param1)
            {
               this.m_bitmap.x += param1.x;
               this.m_bitmap.y += param1.y;
            }
            if(this.m_smooth)
            {
               ZGameUtils.smoothImage(this.m_bitmap);
            }
         }
      }
   }
}

