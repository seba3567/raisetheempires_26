package events
{
   import flash.events.Event;
   
   public class CloseEvent extends Event
   {
      
      public static const CLOSE:String = "close";
      
      public function CloseEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

