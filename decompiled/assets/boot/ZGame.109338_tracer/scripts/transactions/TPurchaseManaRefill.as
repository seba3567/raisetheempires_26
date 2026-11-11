package transactions
{
   public class TPurchaseManaRefill extends TZGameTransaction
   {
      
      private var m_data:Object = null;
      
      public function TPurchaseManaRefill(param1:Object = null)
      {
         super();
         this.m_data = {"stats":param1};
      }
      
      override public function perform() : void
      {
         signedCall("UserService.purchaseManaRefill",modifiedData(this.m_data));
      }
   }
}

