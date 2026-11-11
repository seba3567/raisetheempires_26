package zlabs.events
{
   import flash.events.Event;
   
   public class WorldEvent extends Event
   {
      
      public var eventData:Object = null;
      
      public function WorldEvent(param1:String, param2:Object = null)
      {
         this.eventData = param2;
         super(param1);
      }
      
      override public function clone() : Event
      {
         return new WorldEvent(type,this.eventData);
      }
   }
}

