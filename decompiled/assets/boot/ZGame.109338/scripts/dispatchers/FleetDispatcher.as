package dispatchers
{
   import flash.events.EventDispatcher;
   
   public class FleetDispatcher extends EventDispatcher
   {
      
      public static var instance:FleetDispatcher = new FleetDispatcher();
      
      public function FleetDispatcher()
      {
         super();
      }
   }
}

