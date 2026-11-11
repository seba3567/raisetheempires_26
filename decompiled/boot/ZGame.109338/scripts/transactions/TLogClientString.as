package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TLogClientString extends Transaction
   {
      
      private var m_string:String;
      
      public function TLogClientString(param1:String)
      {
         super();
         this.m_string = param1;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.lcs",this.m_string);
      }
   }
}

