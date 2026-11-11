package core.managers.animationManager
{
   import core.entities.components.DestroyOnCompleteComponent;
   import core.managers.DebugManager;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import rendering.rendering2d.AnimationCanvasComponent;
   import rendering.rendering2d.AnimationComponent;
   import rendering.rendering2d.MovieComponent;
   import rendering.rendering2d.TemporaryRenderComponent;
   import rendering.renderingIso.QuadSpatialComponent;
   import sound.SoundEvent;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   
   public class FireAndForgetAnimation
   {
      
      public function FireAndForgetAnimation()
      {
         super();
      }
      
      public static function execute(param1:IEntity, param2:Object) : void
      {
         var _loc8_:QuadSpatialComponent = null;
         var _loc9_:Vector3D = null;
         var _loc10_:TemporaryRenderComponent = null;
         var _loc11_:QuadSpatialComponent = null;
         var _loc3_:IEntity = Zlab.allocateEntity();
         var _loc4_:AnimationCanvasComponent = null;
         var _loc5_:DestroyOnCompleteComponent = null;
         var _loc6_:IsoSpriteRenderer = null;
         if(param2.attachToObject)
         {
            _loc6_ = IsoSpriteRenderer(param1.lookupComponentByType(IsoSpriteRenderer));
            _loc4_ = new AnimationCanvasComponent(_loc6_.displayObject as Sprite);
            _loc5_ = new DestroyOnCompleteComponent();
            _loc3_.addComponent(_loc5_,"destroyOnComplete");
         }
         else
         {
            _loc8_ = QuadSpatialComponent(param1.lookupComponentByType(QuadSpatialComponent));
            _loc9_ = _loc8_.position;
            if(null != param2.offset)
            {
               _loc9_.x += param2.offset.x;
               _loc9_.y += param2.offset.y;
               _loc9_.z += param2.offset.z;
            }
            _loc10_ = new TemporaryRenderComponent(_loc9_);
            _loc3_.addComponent(_loc10_,"TemporaryRenderComponent");
            _loc4_ = new AnimationCanvasComponent(_loc10_.sprite);
            _loc5_ = _loc10_;
            _loc11_ = new QuadSpatialComponent(_loc8_.quadAreaManager,0.5,true);
            _loc11_.isoSprite = _loc10_.isoSprite;
            _loc11_.position = _loc9_;
            _loc3_.addComponent(_loc11_,"Spatial");
         }
         if(null != param2.background && param2.background == true)
         {
            _loc4_.backGround = true;
         }
         _loc3_.addComponent(_loc4_,"AnimationCanvas");
         var _loc7_:AnimationComponent = new AnimationComponent(_loc6_);
         if(null != param2.loopCount && param2.loopCount != 0)
         {
            _loc7_.loopCount = param2.loopCount;
         }
         else
         {
            _loc7_.mode = AnimationComponent.NONE;
         }
         _loc7_.anchor = param2.anchor;
         _loc7_.anim = param2.anim;
         _loc7_.eventDispatcher = _loc5_.eventDispatcher;
         _loc3_.addComponent(_loc7_,"AnimationComponent");
         _loc4_.animations.push(_loc7_);
         _loc3_.initialize();
         if(Boolean(param2.sound) && param2.sound.length > 0)
         {
            SoundEvent.getSoundEvent(param2.sound).play();
         }
      }
      
      public static function execute2D(param1:Sprite, param2:Object) : void
      {
         var _loc4_:IEntity = null;
         var _loc5_:AnimationCanvasComponent = null;
         var _loc6_:DestroyOnCompleteComponent = null;
         var _loc7_:AnimationComponent = null;
         var _loc8_:Point = null;
         var _loc3_:Animation = AnimationManager.instance.getAnimation(param2.anim);
         if(null != _loc3_)
         {
            _loc4_ = Zlab.allocateEntity();
            _loc5_ = null;
            _loc6_ = null;
            _loc5_ = new AnimationCanvasComponent(param1);
            _loc5_.twoD = true;
            _loc6_ = new DestroyOnCompleteComponent();
            _loc4_.addComponent(_loc6_,"destroyOnComplete");
            if(null != param2.background && param2.background == true)
            {
               _loc5_.backGround = true;
            }
            _loc4_.addComponent(_loc5_,"AnimationCanvas");
            _loc7_ = null;
            if(_loc3_.movie)
            {
               _loc7_ = new MovieComponent(null);
               if(DebugManager.instance.poolfx)
               {
                  _loc7_.usePool = true;
               }
               (_loc7_ as MovieComponent).color = param2.color;
            }
            else
            {
               _loc7_ = new AnimationComponent(null);
            }
            if(null != param2.loopCount && param2.loopCount != 0)
            {
               _loc7_.loopCount = param2.loopCount;
            }
            else
            {
               _loc7_.mode = AnimationComponent.NONE;
            }
            if(null != param2.drift)
            {
               _loc7_.drift = param2.drift;
            }
            _loc8_ = param2.anchor;
            if(null != param2.offset)
            {
               _loc8_.x += param2.offset.x;
               _loc8_.y += param2.offset.y;
            }
            _loc7_.anchor = _loc8_;
            _loc7_.anim = param2.anim;
            _loc7_.eventDispatcher = _loc6_.eventDispatcher;
            _loc4_.addComponent(_loc7_,"AnimationComponent");
            _loc5_.animations.push(_loc7_);
            _loc4_.initialize();
            if(Boolean(param2.sound) && param2.sound.length > 0)
            {
               SoundEvent.getSoundEvent(param2.sound).play();
            }
            _loc5_ = null;
            _loc6_ = null;
            _loc7_ = null;
            _loc3_ = null;
            _loc4_ = null;
         }
         else
         {
            Logger.error(null,"execute2D","no animation found with name " + param2.anim);
         }
      }
   }
}

