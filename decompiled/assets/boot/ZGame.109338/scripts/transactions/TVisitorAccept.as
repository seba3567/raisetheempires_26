package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TVisitorAccept extends Transaction
   {
      
      private var m_neighborID:String;
      
      public function TVisitorAccept(param1:String)
      {
         super();
         this.m_neighborID = param1;
      }
      
      override public function perform() : void
      {
         signedCall("VisitorService.accept",this.m_neighborID);
      }
   }
}

