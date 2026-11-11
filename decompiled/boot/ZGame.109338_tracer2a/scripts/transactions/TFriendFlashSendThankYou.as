package transactions
{
   import Engine.Classes.SNAPISocialNetwork;
   import Engine.Transactions.Transaction;
   
   public class TFriendFlashSendThankYou extends Transaction
   {
      
      private var m_zid:String;
      
      private var m_msg:String;
      
      public function TFriendFlashSendThankYou(param1:String, param2:String)
      {
         this.m_zid = param1;
         this.m_msg = param2;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.EPGiftThankYou",this.m_zid,this.m_msg);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:SNAPISocialNetwork = GlobalEngine.socialNetwork as SNAPISocialNetwork;
         if(Boolean(_loc2_) && Boolean(param1.feedData))
         {
            _loc2_.snapiStreamPublish(param1.feedData);
         }
      }
   }
}

