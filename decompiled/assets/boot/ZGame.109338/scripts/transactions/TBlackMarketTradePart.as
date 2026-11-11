package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TBlackMarketTradePart extends Transaction
   {
      
      private var m_partCode:String;
      
      private var m_itemCode:String;
      
      public function TBlackMarketTradePart(param1:String, param2:String)
      {
         super();
         this.m_partCode = param2;
         this.m_itemCode = param1;
      }
      
      override public function perform() : void
      {
         super.perform();
         signedCall("BlackMarketHelperService.tradeForPart",this.m_itemCode,this.m_partCode);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
      }
   }
}

