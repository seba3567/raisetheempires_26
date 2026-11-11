package core.entities.components
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import zlabs.entity.EntityComponent;
   
   public class DestroyOnCompleteComponent extends EntityComponent
   {
      
      private var m_eventDispatcher:EventDispatcher = null;
      
      public function DestroyOnCompleteComponent()
      {
         super();
         this.m_eventDispatcher = new EventDispatcher();
         this.m_eventDispatcher.addEventListener(Event.COMPLETE,this.onComplete);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         this.m_eventDispatcher.removeEventListener(Event.COMPLETE,this.onComplete);
         this.m_eventDispatcher = null;
      }
      
      public function get eventDispatcher() : EventDispatcher
      {
         return this.m_eventDispatcher;
      }
      
      private function onComplete(param1:Event) : void
      {
         owner.destroy();
      }
   }
}

