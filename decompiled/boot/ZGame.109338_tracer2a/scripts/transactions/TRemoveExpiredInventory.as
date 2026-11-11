package transactions
{
   public class TRemoveExpiredInventory extends TZGameTransaction
   {
      
      private var m_itemCode:String = null;
      
      public function TRemoveExpiredInventory(param1:String)
      {
         super();
         this.m_itemCode = param1;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.removeExpiredInventory",modifiedData({"code":this.m_itemCode}));
      }
   }
}

