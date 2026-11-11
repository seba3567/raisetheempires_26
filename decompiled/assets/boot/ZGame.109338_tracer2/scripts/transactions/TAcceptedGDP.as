package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TAcceptedGDP extends Transaction
   {
      
      private var m_status:Boolean;
      
      public function TAcceptedGDP(param1:Boolean)
      {
         super();
         this.m_status = param1;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.acceptedGDP",this.m_status);
      }
   }
}

