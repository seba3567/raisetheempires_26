package rendering.rendering2d.loading
{
   import flash.events.Event;
   import rendering.rendering2d.AnimationCanvasComponent;
   import rendering.rendering2d.MovieComponent;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   
   public class LoadingMovieComponent extends MovieComponent
   {
      
      private var m_parent:AnimationCanvasComponent = null;
      
      public function LoadingMovieComponent(param1:IsoSpriteRenderer, param2:AnimationCanvasComponent)
      {
         super(param1);
         this.m_parent = param2;
      }
      
      override public function set anim(param1:String) : void
      {
      }
      
      public function set animClass(param1:Class) : void
      {
         initFromClass(param1);
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         owner.eventDispatcher.addEventListener(IsoSpriteRenderer.IMAGE_UPDATED,this.onImageUpdated);
      }
      
      override protected function get useController() : Boolean
      {
         return false;
      }
      
      private function onImageUpdated(param1:Event) : void
      {
         owner.eventDispatcher.removeEventListener(IsoSpriteRenderer.IMAGE_UPDATED,this.onImageUpdated);
         this.m_parent.removeAnimation(this);
         owner.removeComponent(this);
      }
   }
}

