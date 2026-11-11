package transactions
{
   public class TPurchaseContractUnlock extends TZGameTransaction
   {
      
      private var m_itemCode:String = null;
      
      private var m_stats:Object;
      
      public function TPurchaseContractUnlock(param1:String, param2:Object = null)
      {
         super();
         this.m_itemCode = param1;
         this.m_stats = param2;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.purchaseContractUnlock",modifiedData(this.data));
      }
      
      override protected function onComplete(param1:Object) : void
      {
      }
      
      protected function get data() : Object
      {
         var _loc1_:Object = this.m_stats ? this.m_stats : {};
         return {
            "itemCode":this.m_itemCode,
            "stats":_loc1_
         };
      }
   }
}

