package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TString extends Transaction
   {
      
      private var m_string:String;
      
      public function TString(param1:String)
      {
         super();
         this.m_string = param1;
      }
      
      public function get string() : String
      {
         return this.m_string;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.genericString",this.m_string);
      }
   }
}

