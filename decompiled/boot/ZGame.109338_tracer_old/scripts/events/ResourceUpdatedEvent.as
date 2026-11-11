package events
{
   public class ResourceUpdatedEvent extends UpdateEvent
   {
      
      public static const FOOD:String = "food";
      
      public static const COINS:String = "coins";
      
      public static const OIL:String = "oil";
      
      public static const WOOD:String = "wood";
      
      public static const CASH:String = "cash";
      
      public static const WORKERS:String = "workers";
      
      public static const ENERGY:String = "energy";
      
      private var m_oldAmount:int = 0;
      
      private var m_newAmount:int = 0;
      
      public function ResourceUpdatedEvent(param1:String, param2:int = 0, param3:int = 0)
      {
         super(param1,param2,param3);
      }
   }
}

