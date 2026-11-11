package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TAcceptedTOS extends Transaction
   {
      
      private var m_status:Boolean;
      
      public function TAcceptedTOS(param1:Boolean)
      {
         super();
         this.m_status = param1;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.acceptedTOS",this.m_status);
      }
   }
}

