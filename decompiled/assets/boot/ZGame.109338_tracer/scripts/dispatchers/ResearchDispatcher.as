package dispatchers
{
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   
   public class ResearchDispatcher extends EventDispatcher
   {
      
      public static var instance:ResearchDispatcher = new ResearchDispatcher();
      
      public function ResearchDispatcher(param1:IEventDispatcher = null)
      {
         super(param1);
      }
   }
}

