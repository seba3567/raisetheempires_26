package events
{
   import zlabs.events.WorldEvent;
   
   public class UnitEvent extends WorldEvent
   {
      
      public static const TERRAIN_AS_TARGET:String = "terrainastarget";
      
      public static const TERRAIN_AS_TARGET_CLIENT_ONLY:String = "terrainastargetclientonly";
      
      public static const ACTION_STARTED:String = "actionstarted";
      
      public static const ACTION_COMPLETE:String = "actioncomplete";
      
      public static const ACTION_FAILED:String = "actionfailed";
      
      public static const ACTION_ENDED:String = "actionended";
      
      public function UnitEvent(param1:String, param2:Object = null)
      {
         super(param1,param2);
      }
   }
}

