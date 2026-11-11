package dispatchers
{
   import flash.events.EventDispatcher;
   
   public class EnergyDispatcher extends EventDispatcher
   {
      
      public static var instance:EnergyDispatcher = new EnergyDispatcher();
      
      public function EnergyDispatcher()
      {
         super();
      }
   }
}

