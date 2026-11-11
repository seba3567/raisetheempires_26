package transactions
{
   import Engine.Transactions.Transaction;
   import flash.external.ExternalInterface;
   
   public class TAddFriendPublish extends Transaction
   {
      
      protected var m_type:String;
      
      protected var m_data:Object;
      
      protected var m_targetId:String;
      
      public function TAddFriendPublish(param1:String, param2:Object, param3:String)
      {
         this.m_type = param1;
         this.m_data = param2;
         this.m_targetId = param3;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.addFriendPublish",this.m_type,this.m_data,this.m_targetId);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(param1.uid)
         {
            ExternalInterface.call("addFacebookFriend",param1.uid);
         }
      }
   }
}

