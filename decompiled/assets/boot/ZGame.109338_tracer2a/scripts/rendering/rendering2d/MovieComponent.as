package rendering.rendering2d
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.DestroyOnCompleteComponent;
   import core.managers.animationManager.Animation;
   import core.managers.animationManager.AnimationManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import sound.SoundEvent;
   import zlabs.Zlab;
   import zlabs.core.ObjectPool;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   import zlabs.resource.SWFResource;
   
   public class MovieComponent extends AnimationComponent
   {
      
      private static var movieComponent:MovieComponent = null;
      
      private static var animationCanvas:AnimationCanvasComponent = null;
      
      private static var destroyOnCompleteComponent:DestroyOnCompleteComponent = null;
      
      private var m_animation:Animation = null;
      
      private var m_swfPath:String = null;
      
      private var m_imageName:String = null;
      
      private var m_animName:String = null;
      
      private var m_movie:MovieClip = null;
      
      private var m_movieController:MovieController = null;
      
      private var m_poolClass:Class = null;
      
      private var m_color:Array = null;
      
      private var m_usePool:Boolean = false;
      
      private var m_loopCount:int = -1;
      
      private var m_mode:int = LOOP;
      
      public function MovieComponent(param1:IsoSpriteRenderer)
      {
         super(param1);
      }
      
      public static function executeMovieClip(param1:Sprite, param2:Object) : MovieComponent
      {
         var _loc4_:IEntity = null;
         var _loc5_:Point = null;
         var _loc3_:Animation = AnimationManager.instance.getAnimation(param2.anim);
         if(null != _loc3_)
         {
            _loc4_ = Zlab.allocateEntity();
            animationCanvas = new AnimationCanvasComponent(param1);
            animationCanvas.twoD = true;
            destroyOnCompleteComponent = new DestroyOnCompleteComponent();
            _loc4_.addComponent(destroyOnCompleteComponent,"destroyOnComplete");
            if(null != param2.background && param2.background == true)
            {
               animationCanvas.backGround = true;
            }
            _loc4_.addComponent(animationCanvas,"AnimationCanvas");
            if(_loc3_.movie)
            {
               movieComponent = new MovieComponent(null);
               (movieComponent as MovieComponent).color = param2.color;
            }
            if(null != param2.loopCount && param2.loopCount != 0)
            {
               movieComponent.loopCount = param2.loopCount;
            }
            else
            {
               movieComponent.mode = AnimationComponent.NONE;
            }
            _loc5_ = param2.anchor;
            if(null != param2.offset)
            {
               _loc5_.x += param2.offset.x;
               _loc5_.y += param2.offset.y;
            }
            movieComponent.anchor = _loc5_;
            movieComponent.anim = param2.anim;
            movieComponent.eventDispatcher = destroyOnCompleteComponent.eventDispatcher;
            _loc4_.addComponent(movieComponent,"AnimationComponent");
            animationCanvas.animations.push(movieComponent);
            _loc4_.initialize();
            if(Boolean(param2.sound) && param2.sound.length > 0)
            {
               SoundEvent.getSoundEvent(param2.sound).play();
            }
         }
         else
         {
            Logger.error(null,"executeMovieClip","no animation found with name " + param2.anim);
         }
         return movieComponent;
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         if(this.m_movie)
         {
            if(null != this.m_movie.parent)
            {
               this.m_movie.parent.removeChild(this.m_movie);
            }
            if(this.m_poolClass)
            {
               ObjectPool.instance.disposeObject(this.m_movie,this.m_poolClass);
               this.m_poolClass = null;
            }
            this.m_movie = null;
         }
         if(this.m_movieController)
         {
            this.m_movieController.dispose();
            this.m_movieController = null;
         }
         this.m_color = null;
         this.m_swfPath = null;
         this.m_imageName = null;
      }
      
      override public function set usePool(param1:Boolean) : void
      {
         this.m_usePool = param1;
      }
      
      public function set color(param1:Array) : void
      {
         this.m_color = param1;
      }
      
      override public function set anim(param1:String) : void
      {
         var _loc2_:Animation = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         if(param1)
         {
            this.m_animation = AnimationManager.instance.getAnimation(param1);
            this.m_animName = param1;
            _loc2_ = AnimationManager.instance.getAnimation(this.m_animName);
            _loc3_ = _loc2_.url;
            _loc4_ = _loc3_.indexOf(".swf");
            this.m_swfPath = _loc3_.substr(0,_loc4_ + 4);
            this.m_imageName = _loc3_.substr(_loc4_ + 5);
            this.m_mode = this.m_animation.looping ? LOOP : NONE;
            this.m_loopCount = this.m_animation.loopCount;
            Zlab.resourceManager.load(ZGlobal.getAssetURL(this.m_swfPath),SWFResource,this.onSWFLoadComplete,this.onSWFLoadFailed);
            _loc2_ = null;
            _loc3_ = null;
         }
      }
      
      override public function update(param1:Number, param2:Pt) : DisplayObject
      {
         if(null != this.m_movie)
         {
            this.m_movie.x = m_position.x;
            this.m_movie.y = m_position.y;
            if(this.m_movieController)
            {
               this.m_movieController.waitForUpdate = false;
               if(this.m_movieController.complete)
               {
                  dispatchComplete();
               }
            }
         }
         return this.m_movie;
      }
      
      private function onSWFLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:Class = param1.getAssetClass(this.m_imageName);
         if(_loc2_)
         {
            this.initFromClass(_loc2_);
         }
         else
         {
            Logger.error(this,"onSWFLoadFailed","unable to load class " + this.m_imageName);
         }
      }
      
      protected function initFromClass(param1:Class) : void
      {
         var _loc2_:Animation = null;
         if(this.m_usePool)
         {
            this.m_poolClass = param1;
            this.m_movie = ObjectPool.instance.getObject(this.m_poolClass) as MovieClip;
         }
         else
         {
            this.m_movie = new param1() as MovieClip;
         }
         if(this.m_color)
         {
            this.m_movie.transform.colorTransform = new ColorTransform(this.m_color[0],this.m_color[1],this.m_color[2]);
         }
         this.m_movie.mouseEnabled = false;
         this.m_movie.mouseChildren = false;
         if(this.useController)
         {
            this.m_movieController = new MovieController(this.m_movie);
            if(this.m_loopCount > 0)
            {
               this.m_movieController.mode = MovieController.LOOP;
            }
            else
            {
               this.m_movieController.mode = MovieController.ONCE;
            }
            this.m_movieController.waitForUpdate = true;
            _loc2_ = AnimationManager.instance.getAnimation(this.m_animName);
            this.m_movieController.sounds = _loc2_.sounds;
         }
         m_position = m_anchor.clone();
         initDrift();
      }
      
      protected function get useController() : Boolean
      {
         return true;
      }
      
      private function onSWFLoadFailed(param1:SWFResource) : void
      {
         Logger.error(this,"onSWFLoadFailed","unable to load swf " + param1.filename);
      }
   }
}

