package events
{
   import flash.events.Event;
   
   public class GameModeEvent extends Event
   {
      
      public static const ADD_MODE:String = "addGame";
      
      public function GameModeEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

