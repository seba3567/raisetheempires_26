package transactions
{
   import displays.screens.Market;
   import displays.screens.MarketGuest;
   import zlabs.entity.IEntity;
   
   public class TMarketBuy extends TWorldState
   {
      
      public static const STATUS_MSG_PRICE_CHANGED:int = 34;
      
      public static const STATUS_MSG_INVALID_UNITS:int = 35;
      
      public static const CANT_REMOVE:int = 36;
      
      public static const CANT_OFFER:int = 37;
      
      public static const MARKET_DOES_NOT_EXIST:int = 38;
      
      public static const STATUS_MSG_SUCCESS:String = "success";
      
      private var m_params:Object;
      
      private var m_dialog:Market;
      
      private var m_type:String;
      
      public function TMarketBuy(param1:Market, param2:IEntity, param3:String, param4:String, param5:int, param6:Number, param7:String)
      {
         super(param2);
         this.m_dialog = param1;
         this.m_type = param3;
         this.m_params = new Object();
         this.m_params.item = param4;
         this.m_params.units = param5;
         this.m_params.price = param6;
         this.m_params.hostId = String(param7);
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function get units() : int
      {
         return this.m_params.units;
      }
      
      public function get item() : String
      {
         return this.m_params.item;
      }
      
      override public function perform() : void
      {
         signedWorldAction("buy",this.m_params);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(this.m_dialog)
         {
            if(param1[0].toString() == "success")
            {
               MarketGuest(this.m_dialog).onBuySuccess();
            }
            else
            {
               _loc2_ = int(param1[0]);
               MarketGuest(this.m_dialog).onBuyFail(_loc2_);
            }
         }
      }
   }
}

