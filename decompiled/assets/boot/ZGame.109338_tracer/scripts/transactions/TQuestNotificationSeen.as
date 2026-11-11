package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TQuestNotificationSeen extends Transaction
   {
      
      private var m_quests:Array = null;
      
      public function TQuestNotificationSeen(param1:Array)
      {
         this.m_quests = param1;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.doSeenQuestNotification",this.m_quests);
      }
   }
}

