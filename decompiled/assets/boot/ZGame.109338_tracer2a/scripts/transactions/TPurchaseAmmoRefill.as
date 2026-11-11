package transactions
{
   public class TPurchaseAmmoRefill extends TZGameTransaction
   {
      
      private var m_data:Object = null;
      
      public function TPurchaseAmmoRefill(param1:Object = null)
      {
         super();
         this.m_data = {"stats":param1};
      }
      
      override public function perform() : void
      {
         signedCall("UserService.purchaseAmmoRefill",modifiedData(this.m_data));
      }
   }
}

