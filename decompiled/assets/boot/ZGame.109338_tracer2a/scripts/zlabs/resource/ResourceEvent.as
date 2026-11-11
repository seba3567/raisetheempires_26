package zlabs.resource
{
   import flash.events.Event;
   
   public class ResourceEvent extends Event
   {
      
      public static const LOADED_EVENT:String = "LOADED_EVENT";
      
      public static const FAILED_EVENT:String = "FAILED_EVENT";
      
      public var resourceObject:Resource = null;
      
      public function ResourceEvent(param1:String, param2:Resource, param3:Boolean = false, param4:Boolean = false)
      {
         this.resourceObject = param2;
         super(param1,param3,param4);
      }
   }
}

