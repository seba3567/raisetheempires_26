package events
{
   public class ExperienceUpdatedEvent extends UpdateEvent
   {
      
      public static const GOOD_XP:String = "GOOD_EXPERIENCE_UPDATED";
      
      public static const BAD_XP:String = "BAD_EXPERIENCE_UPDATED";
      
      public static const GOOD_LEVEL:String = "GOOD_LEVEL_UPDATED";
      
      public static const BAD_LEVEL:String = "BAD_LEVEL_UPDATED";
      
      public static const EXPERIENCE:String = "EXPERIENCE_UPDATED";
      
      public static const LEVEL:String = "LEVEL_UPDATED";
      
      public function ExperienceUpdatedEvent(param1:String, param2:int, param3:int)
      {
         super(param1,param2,param3);
      }
   }
}

