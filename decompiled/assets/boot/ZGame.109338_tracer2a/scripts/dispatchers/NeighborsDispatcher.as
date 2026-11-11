package dispatchers
{
   import flash.events.EventDispatcher;
   
   public class NeighborsDispatcher extends EventDispatcher
   {
      
      public static var instance:NeighborsDispatcher = new NeighborsDispatcher();
      
      public function NeighborsDispatcher()
      {
         super();
      }
   }
}

