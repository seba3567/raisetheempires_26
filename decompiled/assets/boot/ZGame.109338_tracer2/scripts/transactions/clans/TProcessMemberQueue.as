package transactions.clans
{
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   
   public class TProcessMemberQueue extends Transaction
   {
      
      private var m_messageQ:Array;
      
      public function TProcessMemberQueue()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.processMemberQueue");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:Transaction = null;
         if(param1["changeFlag"])
         {
            _loc2_ = new TGetClanInfo();
            TransactionManager.addTransaction(_loc2_,true);
         }
      }
   }
}

