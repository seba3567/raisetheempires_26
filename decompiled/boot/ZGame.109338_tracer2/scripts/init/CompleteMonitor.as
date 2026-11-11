package init
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   
   public class CompleteMonitor extends EventDispatcher
   {
      
      protected var dispatcherCount:int;
      
      protected var numCompleted:int;
      
      private var eventName:String = "complete";
      
      public function CompleteMonitor(param1:String = "complete")
      {
         super();
         this.dispatcherCount = this.numCompleted = 0;
         this.eventName = param1;
      }
      
      public function addDispatcher(param1:IEventDispatcher) : void
      {
         this.dispatcherCount += 1;
         param1.addEventListener(this.eventName,this.onComplete);
      }
      
      protected function onComplete(param1:Event) : void
      {
         this.numCompleted += 1;
         if(this.numCompleted == this.dispatcherCount)
         {
            dispatchEvent(new Event(this.eventName));
         }
      }
      
      public function getDispatcherCount() : int
      {
         return this.dispatcherCount;
      }
   }
}

