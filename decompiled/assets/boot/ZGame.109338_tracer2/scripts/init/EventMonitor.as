package init
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   
   public class EventMonitor extends EventDispatcher
   {
      
      protected var dispatcherCount:int;
      
      protected var numCompleted:int;
      
      public function EventMonitor()
      {
         super();
         this.dispatcherCount = 0;
         this.numCompleted = 0;
      }
      
      public function addDispatcher(param1:IEventDispatcher, param2:String) : void
      {
         ++this.dispatcherCount;
         param1.addEventListener(param2,this.onComplete);
      }
      
      public function removeDispatcher(param1:IEventDispatcher, param2:String) : void
      {
         --this.dispatcherCount;
         param1.removeEventListener(param2,this.onComplete);
      }
      
      protected function onComplete(param1:Event) : void
      {
         ++this.numCompleted;
         if(this.numCompleted == this.dispatcherCount)
         {
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      public function getDispatcherCount() : int
      {
         return this.dispatcherCount;
      }
   }
}

