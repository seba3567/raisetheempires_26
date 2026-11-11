package core.worlds.strategicWorld
{
   import core.views.ViewManager;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import zlabs.Zlab;
   import zlabs.entity.EntityComponent;
   import zlabs.events.WorldEvent;
   
   public class StrategicRendererComponent extends EntityComponent
   {
      
      private var m_displayObject:Sprite = null;
      
      public function StrategicRendererComponent()
      {
         super();
      }
      
      public function get displayObject() : DisplayObject
      {
         return this.m_displayObject as DisplayObject;
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         this.m_displayObject = new Sprite();
         owner.eventDispatcher.addEventListener(ViewManager.ACTIVATE,this.onActivated);
         owner.eventDispatcher.addEventListener(ViewManager.DEACTIVATE,this.onDeactivated);
         owner.eventDispatcher.addEventListener(ViewManager.RELOAD,this.onReload);
         Zlab.mainStage.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen);
         this.reposition(false);
      }
      
      protected function onActivated(param1:Event) : void
      {
      }
      
      protected function onDeactivated(param1:WorldEvent) : void
      {
      }
      
      protected function onReload(param1:WorldEvent) : void
      {
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         owner.eventDispatcher.removeEventListener(ViewManager.ACTIVATE,this.onActivated);
         owner.eventDispatcher.removeEventListener(ViewManager.DEACTIVATE,this.onDeactivated);
         owner.eventDispatcher.removeEventListener(ViewManager.RELOAD,this.onReload);
         Zlab.mainStage.removeEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen);
      }
      
      private function onFullScreen(param1:FullScreenEvent) : void
      {
         this.reposition(param1.fullScreen);
      }
      
      private function reposition(param1:Boolean) : void
      {
      }
   }
}

