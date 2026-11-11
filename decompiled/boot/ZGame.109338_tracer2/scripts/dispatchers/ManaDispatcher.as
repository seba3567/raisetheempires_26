package dispatchers
{
   import flash.events.EventDispatcher;
   
   public class ManaDispatcher extends EventDispatcher
   {
      
      public static var instance:ManaDispatcher = new ManaDispatcher();
      
      public static const VALUE_UPDATED:String = "manavalueupdated";
      
      public static const AMOUNT_USED:String = "manaValueUsed";
      
      public function ManaDispatcher()
      {
         super();
      }
   }
}

