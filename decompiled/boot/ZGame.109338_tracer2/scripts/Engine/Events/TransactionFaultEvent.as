package Engine.Events
{
   import Engine.Transactions.Transaction;
   
   public class TransactionFaultEvent extends TransactionEvent
   {
      
      public static const FAULT:String = "fault";
      
      public static const RETRY:String = "retry";
      
      public var errorType:int;
      
      public var errorData:Object;
      
      public function TransactionFaultEvent(param1:String, param2:Transaction, param3:int, param4:Object)
      {
         this.transaction = param2;
         this.errorType = param3;
         this.errorData = param4;
         super(param1);
      }
   }
}

