package Engine.Events
{
   import Engine.Transactions.Transaction;
   import flash.events.Event;
   
   public class TransactionEvent extends Event
   {
      
      public static const COMPLETED:String = "completed";
      
      public static const QUEUE_LIMIT_EXCEEDED:String = "exceeded_max_queued";
      
      public static const QUEUE_LIMIT_NORMAL:String = "queue_normal";
      
      public static const VERSION_MISMATCH:String = "version_mismatch";
      
      public static const ADDED:String = "added";
      
      public static const RETRY_SUCCESS:String = "retry_success";
      
      public static const BATCH_SEND:String = "batch_send";
      
      public static const INACTIVE:String = "inactive";
      
      public static const OUT_OF_SYNC:String = "out_of_sync";
      
      public var transaction:Transaction;
      
      public function TransactionEvent(param1:String, param2:Transaction = null)
      {
         this.transaction = param2;
         super(param1);
      }
   }
}

