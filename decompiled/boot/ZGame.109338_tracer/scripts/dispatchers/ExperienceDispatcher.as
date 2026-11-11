package dispatchers
{
   import flash.events.EventDispatcher;
   
   public class ExperienceDispatcher extends EventDispatcher
   {
      
      public static var instance:ExperienceDispatcher = new ExperienceDispatcher();
      
      public function ExperienceDispatcher()
      {
         super();
      }
   }
}

