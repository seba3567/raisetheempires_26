package zlabs.core
{
   import flash.events.Event;
   
   public class LevelEvent extends Event
   {
      
      public static const READY_EVENT:String = "ready";
      
      public static const LEVEL_LOADED_EVENT:String = "levelLoaded";
      
      public static const LEVEL_UNLOADED_EVENT:String = "levelUnloaded";
      
      public var level:int = -1;
      
      public function LevelEvent(param1:String, param2:int, param3:Boolean = false, param4:Boolean = false)
      {
         this.level = param2;
         super(param1,param3,param4);
      }
   }
}

