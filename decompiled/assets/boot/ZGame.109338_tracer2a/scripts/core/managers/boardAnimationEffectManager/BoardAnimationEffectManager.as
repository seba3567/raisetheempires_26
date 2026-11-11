package core.managers.boardAnimationEffectManager
{
   import as3isolib.geom.Pt;
   import core.managers.FXManager.FXManager;
   import core.managers.animationManager.FireAndForgetAnimation;
   import flash.display.Sprite;
   import flash.geom.Point;
   import zlabs.entity.IEntity;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   
   public class BoardAnimationEffectManager
   {
      
      public static var instance:BoardAnimationEffectManager = new BoardAnimationEffectManager();
      
      public function BoardAnimationEffectManager()
      {
         super();
      }
      
      public function playAnimation(param1:IEntity, param2:String, param3:String, param4:Pt, param5:Point) : void
      {
         var _loc7_:Sprite = null;
         var _loc6_:Object = new Object();
         var _loc8_:IsoSpriteRenderer = param1.lookupComponentByType(IsoSpriteRenderer) as IsoSpriteRenderer;
         _loc7_ = _loc8_.displayObject as Sprite;
         _loc6_.attachToObject = true;
         _loc6_.offset = param4;
         _loc6_.background = false;
         _loc6_.loopCount = 0;
         _loc6_.anchor = param5;
         _loc6_.anim = FXManager.instance.getFXAnim(param2);
         _loc6_.sound = FXManager.instance.getFXSound(param3);
         FireAndForgetAnimation.execute2D(_loc7_,_loc6_);
      }
      
      public function playAnimationAtSprite(param1:Sprite, param2:String, param3:String, param4:Pt, param5:Point) : void
      {
         var _loc6_:Object = new Object();
         _loc6_.attachToObject = true;
         _loc6_.offset = param4;
         _loc6_.background = false;
         _loc6_.loopCount = 0;
         _loc6_.anchor = param5;
         _loc6_.anim = FXManager.instance.getFXAnim(param2);
         _loc6_.sound = FXManager.instance.getFXSound(param3);
         FireAndForgetAnimation.execute2D(param1,_loc6_);
      }
   }
}

