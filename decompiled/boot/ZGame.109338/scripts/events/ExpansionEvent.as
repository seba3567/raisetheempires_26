package events
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import flash.events.Event;
   
   public class ExpansionEvent extends Event
   {
      
      public static const EXPANSION_TYPE_COIN:String = "expansiontypecoin";
      
      public static const EXPANSION_TYPE_CREW:String = "expansiontypecrew";
      
      public static const EXPANSION_TYPE_CASH:String = "expansiontypecash";
      
      public var item:String;
      
      private var itemClass:Class = GameItem;
      
      public var eventType:int;
      
      public var statsInfo:Object = null;
      
      public function ExpansionEvent(param1:String, param2:int, param3:String, param4:Object = null, param5:Class = null)
      {
         this.eventType = param2;
         this.item = param3;
         this.statsInfo = param4;
         if(param5 != null)
         {
            this.itemClass = param5;
         }
         super(param1,false,false);
      }
      
      public function get referenceItem() : GameItem
      {
         return ZGlobal.gameSettings.getItemByName(this.item,this.itemClass) as GameItem;
      }
   }
}

