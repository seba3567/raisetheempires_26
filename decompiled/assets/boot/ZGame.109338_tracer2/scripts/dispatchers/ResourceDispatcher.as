package dispatchers
{
   import flash.events.EventDispatcher;
   
   public class ResourceDispatcher extends EventDispatcher
   {
      
      public static var instance:ResourceDispatcher = new ResourceDispatcher();
      
      public function ResourceDispatcher()
      {
         super();
      }
   }
}

