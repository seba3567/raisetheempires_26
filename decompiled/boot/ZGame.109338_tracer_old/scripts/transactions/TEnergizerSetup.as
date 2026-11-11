package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TEnergizerSetup extends Transaction
   {
      
      protected var m_type:uint;
      
      public function TEnergizerSetup(param1:uint = 0)
      {
         this.m_type = param1;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.energizerSetup",this.m_type);
      }
   }
}

