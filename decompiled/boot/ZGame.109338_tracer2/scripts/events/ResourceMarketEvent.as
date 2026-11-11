package events
{
   import zlabs.events.WorldEvent;
   
   public class ResourceMarketEvent extends WorldEvent
   {
      
      public static const ADD:String = "ResourceMarketAdd";
      
      public static const REMOVE:String = "ResourceMarketRemove";
      
      public static const BUY:String = "ResourceMarketBuy";
      
      public static const ITEM:String = "ResourceMarketItem";
      
      public var targetObject:Object;
      
      public var marketId:int;
      
      public function ResourceMarketEvent(param1:String, param2:Object = null, param3:Object = null, param4:int = 0)
      {
         super(param1,param2);
         this.targetObject = param3;
         this.marketId = param4;
      }
   }
}

