package transactions
{
   import Engine.Transactions.Transaction;
   import core.managers.FriendManager;
   
   public class TFriendQuery extends Transaction
   {
      
      public function TFriendQuery()
      {
         super();
      }
      
      override public function perform() : void
      {
         super.perform();
         signedCall("DataServicesService.getFriendsInfo");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         FriendManager.instance.onFriendQueryComplete(param1);
      }
   }
}

