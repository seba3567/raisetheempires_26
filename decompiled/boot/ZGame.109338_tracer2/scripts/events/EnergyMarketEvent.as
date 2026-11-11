package events
{
   import core.gameobjects.GameItem;
   
   public class EnergyMarketEvent extends MarketEvent
   {
      
      private var m_refillItem:GameItem = null;
      
      public function EnergyMarketEvent(param1:String, param2:int, param3:String, param4:int, param5:Object, param6:GameItem = null, param7:Class = null)
      {
         super(param1,param2,param3,param4,param5,param7);
         this.m_refillItem = param6;
      }
      
      public function get isRefill() : Boolean
      {
         return this.m_refillItem != null;
      }
      
      override public function get referenceItem() : GameItem
      {
         return this.m_refillItem != null ? this.m_refillItem : super.referenceItem;
      }
   }
}

