package zlabs.core
{
   internal final class ScheduleObject implements IPrioritizable
   {
      
      public var dueTime:Number = 0;
      
      public var thisObject:Object = null;
      
      public var callback:Function = null;
      
      public var arguments:Array = null;
      
      public function ScheduleObject()
      {
         super();
      }
      
      public function get priority() : int
      {
         return -this.dueTime;
      }
      
      public function set priority(param1:int) : void
      {
         throw new Error("Unimplemented.");
      }
   }
}

