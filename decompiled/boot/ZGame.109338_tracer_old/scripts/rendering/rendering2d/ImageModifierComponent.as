package rendering.rendering2d
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.SoundEvent;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   
   public class ImageModifierComponent extends EntityComponent
   {
      
      public static const ACTIVATE:String = "activatemodifier";
      
      public static const DEACTIVATE:String = "deactivatemodifier";
      
      public var containerReference:PropertyReference = null;
      
      private var m_name:String = null;
      
      private var m_imageUpdated:Boolean = false;
      
      private var m_active:Boolean = false;
      
      public function ImageModifierComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         owner.eventDispatcher.addEventListener(IsoSpriteRenderer.IMAGE_UPDATED,this.onImageUpdated,false,0,true);
         owner.eventDispatcher.addEventListener(IsoSpatialComponent.STOP,this.onImageUpdated,false,0,true);
         owner.eventDispatcher.addEventListener(ACTIVATE,this.onActivate,false,0,true);
         owner.eventDispatcher.addEventListener(DEACTIVATE,this.onDeactivate,false,0,true);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         this.onDeactivate(null);
         owner.eventDispatcher.removeEventListener(IsoSpriteRenderer.IMAGE_UPDATED,this.onImageUpdated);
         owner.eventDispatcher.removeEventListener(IsoSpatialComponent.STOP,this.onImageUpdated);
         owner.eventDispatcher.removeEventListener(ACTIVATE,this.onActivate);
         owner.eventDispatcher.removeEventListener(DEACTIVATE,this.onDeactivate);
         var _loc1_:DisplayObject = this.container;
         TweenMax.killTweensOf(_loc1_);
      }
      
      private function get container() : DisplayObject
      {
         return owner.getProperty(this.containerReference) as DisplayObject;
      }
      
      private function onActivate(param1:WorldEvent) : void
      {
         this.m_active = true;
         this.m_name = String(param1.eventData);
         owner.eventDispatcher.addEventListener(MouseEvent.MOUSE_UP,this.onMouseClick,false,0,true);
      }
      
      private function onDeactivate(param1:Event) : void
      {
         this.m_active = false;
         owner.eventDispatcher.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseClick);
      }
      
      private function onImageUpdated(param1:Event) : void
      {
         this.m_imageUpdated = true;
      }
      
      private function onMouseClick(param1:MouseEvent) : void
      {
         var _loc2_:DisplayObject = null;
         var _loc3_:Number = NaN;
         var _loc4_:SoundEvent = null;
         if(this.m_active && this.m_imageUpdated)
         {
            _loc2_ = this.container;
            _loc2_.scaleX = 1;
            _loc2_.scaleY = 1;
            _loc3_ = 1.2;
            TweenMax.to(_loc2_,0.2,{
               "scaleX":_loc3_,
               "scaleY":_loc3_,
               "yoyo":true,
               "repeat":1,
               "ease":Back.easeIn
            });
            _loc4_ = SoundEvent.getSoundEvent(this.m_name);
            if(_loc4_)
            {
               _loc4_.play();
            }
         }
      }
   }
}

