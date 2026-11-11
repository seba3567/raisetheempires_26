package rendering.rendering2d
{
   import as3isolib.geom.Pt;
   import core.managers.animationManager.AnimationManager;
   import core.managers.assetLoadTracker.AssetLoadTracker;
   import entity.EntityInit;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import zlabs.components.AnimatedComponent;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   
   public class AnimationCanvasComponent extends AnimatedComponent
   {
      
      private var m_animations:Array = new Array();
      
      private var m_parent:Sprite = null;
      
      private var m_activeCount:int = 1;
      
      private var m_frames:int = 0;
      
      private var m_assetTracker:AssetLoadTracker = null;
      
      private var m_backGround:Boolean = false;
      
      private var m_2D:Boolean = false;
      
      public function AnimationCanvasComponent(param1:Sprite, param2:EntityInit = null)
      {
         super();
         this.m_parent = param1;
         this.enableAnimationManager = true;
         this.setupAssetLoadTracker(param2);
      }
      
      public function get animations() : Array
      {
         return this.m_animations;
      }
      
      public function set backGround(param1:Boolean) : void
      {
         this.m_backGround = param1;
      }
      
      public function set twoD(param1:Boolean) : void
      {
         this.m_2D = param1;
      }
      
      public function removeAnimation(param1:AnimationComponent) : void
      {
         var _loc2_:int = this.m_animations.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.m_animations.splice(_loc2_,1);
         }
      }
      
      protected function setupAssetLoadTracker(param1:EntityInit) : void
      {
         if(Boolean(param1) && Boolean(param1.m_assetLoadTracker))
         {
            this.m_assetTracker = param1.m_assetLoadTracker;
            this.m_assetTracker.addEventListener(Event.COMPLETE,this.onAssetLoadComplete);
            this.m_frames = 0;
         }
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         owner.eventDispatcher.addEventListener(IsoSpatialComponent.ACTIVE_DISPLAY,this.onShow,false,0,true);
         owner.eventDispatcher.addEventListener(IsoSpatialComponent.INACTIVE_NON_DISPLAY,this.onHide,false,0,true);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         this.enableAnimationManager = false;
         owner.eventDispatcher.removeEventListener(IsoSpatialComponent.ACTIVE_DISPLAY,this.onShow);
         owner.eventDispatcher.removeEventListener(IsoSpatialComponent.INACTIVE_NON_DISPLAY,this.onHide);
         this.disposeAssetTracker();
         this.m_parent = null;
         this.m_animations = null;
      }
      
      public function set enableAnimationManager(param1:Boolean) : void
      {
         if(param1)
         {
            AnimationManager.instance.addEventListener(AnimationManager.ACTIVATE,this.onActivateAnimation,false,0,true);
         }
         else
         {
            AnimationManager.instance.removeEventListener(AnimationManager.ACTIVATE,this.onActivateAnimation);
         }
      }
      
      public function set forceAnimation(param1:Boolean) : void
      {
         if(param1)
         {
            this.enableAnimationManager = false;
            registerForUpdates = true;
         }
      }
      
      private function onActivateAnimation(param1:WorldEvent) : void
      {
         this.updateActiveCount(param1.eventData ? 1 : -1);
      }
      
      public function set animationData(param1:Array) : void
      {
         var _loc3_:Object = null;
         var _loc2_:* = 0;
         for each(_loc3_ in param1)
         {
            this.m_animations[_loc2_].anchor = _loc3_.anchor;
            this.m_animations[_loc2_].anim = _loc3_.name;
            _loc2_++;
         }
         while(_loc2_ < this.m_animations.length)
         {
            this.m_animations[_loc2_++].anim = null;
         }
      }
      
      override public function onFrame(param1:Number) : void
      {
         var _loc2_:AnimationComponent = null;
         var _loc3_:Pt = null;
         var _loc4_:DisplayObject = null;
         if(Boolean(this.m_assetTracker) && ++this.m_frames >= 2)
         {
            return;
         }
         for each(_loc2_ in this.m_animations)
         {
            _loc3_ = null;
            if(!this.m_2D && this.m_backGround)
            {
               _loc3_ = new Pt(this.m_parent.x,this.m_parent.y);
            }
            _loc4_ = _loc2_.update(param1,_loc3_);
            if(_loc4_)
            {
               if(this.m_2D)
               {
                  if(_loc4_.parent != this.m_parent)
                  {
                     if(this.m_backGround)
                     {
                        this.m_parent.addChildAt(_loc4_,0);
                     }
                     else
                     {
                        this.m_parent.addChild(_loc4_);
                     }
                  }
               }
               else if(this.m_backGround)
               {
                  if(_loc4_.parent != this.m_parent.parent)
                  {
                     this.m_parent.parent.addChildAt(_loc4_,0);
                  }
                  else
                  {
                     this.m_parent.parent.setChildIndex(_loc4_,0);
                  }
               }
               else if(_loc4_.parent != this.m_parent)
               {
                  this.m_parent.addChildAt(_loc4_,0);
               }
            }
         }
      }
      
      private function onShow(param1:Event) : void
      {
         this.updateActiveCount(1);
      }
      
      private function onHide(param1:Event) : void
      {
         this.updateActiveCount(-1);
      }
      
      private function updateActiveCount(param1:int) : void
      {
         var _loc2_:int = this.m_activeCount;
         this.m_activeCount += param1;
         if(_loc2_ > 0 && this.m_activeCount <= 0)
         {
            registerForUpdates = false;
         }
         else if(_loc2_ <= 0 && this.m_activeCount > 0)
         {
            registerForUpdates = true;
         }
      }
      
      private function onAssetLoadComplete(param1:Event) : void
      {
         this.disposeAssetTracker();
      }
      
      private function disposeAssetTracker() : void
      {
         if(this.m_assetTracker)
         {
            this.m_assetTracker.removeEventListener(Event.COMPLETE,this.onAssetLoadComplete);
            this.m_assetTracker = null;
         }
      }
   }
}

