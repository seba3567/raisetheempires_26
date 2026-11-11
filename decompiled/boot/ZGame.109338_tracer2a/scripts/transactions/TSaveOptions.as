package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TSaveOptions extends Transaction
   {
      
      private var m_options:Object;
      
      public function TSaveOptions(param1:Object)
      {
         super();
         this.m_options = param1;
      }
      
      override public function perform() : void
      {
         if(this.m_options != null)
         {
            signedCall("UserService.saveOptions",this.m_options);
         }
      }
   }
}

