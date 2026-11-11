package events
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import flash.events.Event;
   
   public class MarketEvent extends Event
   {
      
      public static const SOURCE_NONE:int = 0;
      
      public static const SOURCE_STORE:int = 1;
      
      public static const SOURCE_INVENTORY:int = 2;
      
      public static const SOURCE_BUILDING:int = 3;
      
      public static const BUILDING:int = 3;
      
      public static const EXPAND_ISLAND:int = 6;
      
      public static const EQUIPMENT:int = 12;
      
      public static const CONTRACT:int = 13;
      
      public static const BUILDABLE:int = 14;
      
      public static const ROADS:int = 15;
      
      public static const CONSUMABLE:int = 16;
      
      public static const RESOURCE:int = 17;
      
      public static const MARKET_BUY:String = "marketbuy";
      
      public static const MARKET_BUY_WITH_MASTERY_TOKENS:String = "marketbuywithmasterytokens";
      
      public static const MARKET_GIFT:String = "marketgift";
      
      public static const MARKET_PRESENT:String = "marketpresent";
      
      public static const MARKET_USE:String = "marketuse";
      
      public static const MARKET_UNLOCK:String = "marketunlock";
      
      public static const MARKET_UNLOCK_CONTRACT:String = "marketunlockcontract";
      
      public static const MARKET_EXPANSION_CASH_UNLOCK:String = "marketexpansioncashunlock";
      
      public static const MARKET_EXPANSION_CREW_UNLOCK:String = "marketexpansioncrewunlock";
      
      public static const BOOSTER:int = 19;
      
      public var item:String;
      
      private var itemClass:Class = GameItem;
      
      public var eventType:int;
      
      public var statsInfo:Object = null;
      
      public var source:int = 0;
      
      public function MarketEvent(param1:String, param2:int, param3:String, param4:int, param5:Object = null, param6:Class = null)
      {
         this.eventType = param2;
         this.item = param3;
         this.source = param4;
         this.statsInfo = param5;
         if(param6 != null)
         {
            this.itemClass = param6;
         }
         super(param1,false,false);
      }
      
      public function get referenceItem() : GameItem
      {
         return ZGlobal.gameSettings.getItemByName(this.item,this.itemClass) as GameItem;
      }
   }
}

