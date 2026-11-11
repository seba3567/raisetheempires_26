package Engine.Events
{
   import flash.events.Event;
   
   public class FreezeEvent extends Event
   {
      
      public static const FROZEN:String = "game_frozen";
      
      public static const THAWED:String = "game_thawed";
      
      public static const UPDATE:String = "game_frozen_update";
      
      public function FreezeEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

