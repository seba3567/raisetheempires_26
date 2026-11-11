package transactions
{
   public class TPurchaseUnlock extends TZGameTransaction
   {
      
      private var m_itemCode:String = null;
      
      public function TPurchaseUnlock(param1:String)
      {
         super();
         this.m_itemCode = param1;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.purchaseUnlock",modifiedData(this.data));
      }
      
      override protected function onComplete(param1:Object) : void
      {
      }
      
      protected function get data() : Object
      {
         return {"itemCode":this.m_itemCode};
      }
   }
}

