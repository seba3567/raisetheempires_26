package core.views
{
   import core.gamemode.GameModeManager;
   import events.IsoViewEvent;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.rendering2D.DisplayObjectRenderer;
   import zlabs.rendering.rendering2D.ISpatialManager2D;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class ViewComponent extends EntityComponent
   {
      
      private var m_spatialManager:ISpatialManager2D;
      
      public var rendererPropertyReference:PropertyReference = null;
      
      private var render:DisplayObjectRenderer;
      
      public var layer:Number = 0;
      
      public function ViewComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         GameModeManager.instance.addEventListener(IsoViewEvent.ISOVIEW_PAN,this.onUpdateView,false,0,true);
         owner.eventDispatcher.addEventListener(ViewManager.ACTIVATE,this.onActivate,false,0,true);
         owner.eventDispatcher.addEventListener(ViewManager.DEACTIVATE,this.onDeactivate,false,0,true);
         this.render = new DisplayObjectRenderer();
         this.render.layerIndex = this.layer;
         super.onAdd();
      }
      
      private function onUpdateView(param1:Event) : void
      {
         owner.eventDispatcher.dispatchEvent(new Event(IsoViewComponent.UPDATE_VIEW));
      }
      
      public function onActivate(param1:Event) : void
      {
         this.render.displayObject = this.renderer;
      }
      
      public function onDeactivate(param1:WorldEvent) : void
      {
         this.render.displayObject = null;
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         GameModeManager.instance.removeEventListener(IsoViewEvent.ISOVIEW_PAN,this.onUpdateView);
         owner.eventDispatcher.removeEventListener(ViewManager.ACTIVATE,this.onActivate);
         owner.eventDispatcher.removeEventListener(ViewManager.DEACTIVATE,this.onDeactivate);
      }
      
      public function get spatialManager() : ISpatialManager2D
      {
         return this.m_spatialManager;
      }
      
      public function get renderer() : DisplayObject
      {
         var _loc1_:Object = owner.getProperty(this.rendererPropertyReference);
         return _loc1_ as DisplayObject;
      }
   }
}

