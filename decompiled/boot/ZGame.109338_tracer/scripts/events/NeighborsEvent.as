package events
{
   import flash.events.Event;
   
   public class NeighborsEvent extends Event
   {
      
      public static const SETUP_COMPLETE:String = "SETUP";
      
      public static const NEIGHBORS_LOADED:String = "NEIGHBORS";
      
      public static const FRIENDS_LOADED:String = "FRIENDS";
      
      public static const NEW_NEIGHBOR_ADDED:String = "newneighbouradded";
      
      public static const TEND_CHECK_TIMEOUT:String = "neighbortendtimeout";
      
      private var m_friends:Array = null;
      
      private var m_varient:int = 0;
      
      public function NeighborsEvent(param1:String, param2:Array, param3:int = 0)
      {
         super(param1);
         this.m_friends = param2;
         this.m_varient = param3;
      }
      
      public function get friends() : Array
      {
         return this.m_friends;
      }
      
      public function get varient() : int
      {
         return this.m_varient;
      }
   }
}

