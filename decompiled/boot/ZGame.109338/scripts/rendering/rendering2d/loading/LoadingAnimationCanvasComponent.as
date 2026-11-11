package rendering.rendering2d.loading
{
   import entity.EntityInit;
   import flash.display.Sprite;
   import rendering.rendering2d.AnimationCanvasComponent;
   import rendering.rendering2d.AnimationComponent;
   
   public class LoadingAnimationCanvasComponent extends AnimationCanvasComponent
   {
      
      public function LoadingAnimationCanvasComponent(param1:Sprite)
      {
         super(param1);
      }
      
      override public function removeAnimation(param1:AnimationComponent) : void
      {
         super.removeAnimation(param1);
         if(animations.length == 0)
         {
            owner.removeComponent(this);
         }
      }
      
      override protected function setupAssetLoadTracker(param1:EntityInit) : void
      {
      }
   }
}

