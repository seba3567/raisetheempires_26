package transactions
{
   import Engine.Transactions.Transaction;
   import core.Zlingshot;
   
   public class TMessageFetch extends Transaction
   {
      
      private var m_lastStamp:Number = 0;
      
      private var m_inQueue:Boolean = false;
      
      public function TMessageFetch(param1:Number = 0)
      {
         super();
         this.m_lastStamp = param1;
      }
      
      override public function perform() : void
      {
         signedCall("ZlingshotService.fetch",this.m_lastStamp);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         this.m_inQueue = false;
         if(Boolean(param1) && param1.timestamp > 0)
         {
            if(Zlingshot.firstStamp <= 0)
            {
               Zlingshot.firstStamp = param1.timestamp;
            }
            if(param1.messages)
            {
               Zlingshot.instance.messages = param1.messages;
            }
         }
         Zlingshot.fetchTimer.reset();
         Zlingshot.fetchTimer.start();
      }
      
      override public function postAddTransaction() : void
      {
         this.m_inQueue = true;
      }
      
      public function get inQueue() : Boolean
      {
         return this.m_inQueue;
      }
   }
}

