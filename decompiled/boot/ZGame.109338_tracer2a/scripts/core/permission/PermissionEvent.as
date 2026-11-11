package core.permission
{
   import flash.events.Event;
   
   public class PermissionEvent extends Event
   {
      
      public static const GRANTED:String = "granted";
      
      public static const DISMISSED:String = "dismissed";
      
      private var m_permType:String;
      
      public function PermissionEvent(param1:String, param2:String, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this.m_permType = param2;
      }
      
      public function get permType() : String
      {
         return this.m_permType;
      }
   }
}

