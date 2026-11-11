package zlabs.core
{
   import flash.events.Event;
   
   public class TemplateEvent extends Event
   {
      
      public static const GROUP_LOADED:String = "groupLoaded";
      
      public var name:String;
      
      public function TemplateEvent(param1:String, param2:String, param3:Boolean = false, param4:Boolean = false)
      {
         this.name = param2;
         super(param1,param3,param4);
      }
   }
}

