package events
{
   import flash.events.Event;
   
   public class FriendBarEvent extends Event
   {
      
      public static const MOVE:String = "move";
      
      public static const MOVE_END:String = "stepEnd";
      
      public static const LOADED:String = "loaded";
      
      public var delta:int;
      
      public var length:int;
      
      public function FriendBarEvent(param1:String, param2:int = undefined, param3:int = undefined, param4:Boolean = false, param5:Boolean = false)
      {
         this.delta = param2;
         this.length = param3;
         super(param1,param4,param5);
      }
   }
}

