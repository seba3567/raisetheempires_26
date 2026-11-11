package core.gamemode.orders
{
   import as3isolib.geom.Pt;
   import events.UnitEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import init.EventMonitor;
   import zlabs.entity.IEntity;
   
   public class Order extends EventDispatcher
   {
      
      protected var m_eventMonitor:EventMonitor = null;
      
      private var m_priority:int = 0;
      
      public function Order(param1:int)
      {
         super();
         this.m_priority = param1;
      }
      
      public function execute(param1:IEntity) : void
      {
         this.m_eventMonitor = new EventMonitor();
         this.m_eventMonitor.addEventListener(Event.COMPLETE,this.onActionComplete);
         this.m_eventMonitor.addDispatcher(param1.eventDispatcher,UnitEvent.ACTION_COMPLETE);
      }
      
      public function dispose(param1:IEntity) : void
      {
         if(this.m_eventMonitor)
         {
            this.m_eventMonitor.removeDispatcher(param1.eventDispatcher,UnitEvent.ACTION_COMPLETE);
            this.m_eventMonitor = null;
         }
      }
      
      public function get priority() : int
      {
         return this.m_priority;
      }
      
      public function get destination() : Pt
      {
         return null;
      }
      
      public function get target() : IEntity
      {
         return null;
      }
      
      protected function onActionComplete(param1:Event) : void
      {
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

