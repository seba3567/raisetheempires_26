package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.FlashFeedManager;
   
   public class TFlashFeedRedeemItem extends Transaction
   {
      
      private var m_itemCode:String;
      
      public function TFlashFeedRedeemItem(param1:String)
      {
         super();
         this.m_itemCode = param1;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.flashFeedRedeemItem",this.m_itemCode);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(param1.result_str == "redeemed")
         {
            FlashFeedManager.getInstance().rewardAddedToInventory(param1.itemCode);
         }
         else if(param1.result_str == "timer expired")
         {
            FlashFeedManager.getInstance().showTokensExpiredMessage();
         }
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
         super.onFault(param1,param2);
      }
   }
}

