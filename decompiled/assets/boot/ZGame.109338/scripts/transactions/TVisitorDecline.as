package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TVisitorDecline extends Transaction
   {
      
      private var m_neighborID:String;
      
      public function TVisitorDecline(param1:String)
      {
         super();
         this.m_neighborID = param1;
      }
      
      override public function perform() : void
      {
         signedCall("VisitorService.decline",this.m_neighborID);
      }
   }
}

