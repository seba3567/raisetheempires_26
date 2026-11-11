package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TOpenDialog extends Transaction
   {
      
      private var m_data:Object = null;
      
      public function TOpenDialog(param1:String)
      {
         super();
         this.m_data = new Object();
         this.m_data.dialog = param1;
      }
      
      public function get dialog() : String
      {
         return this.m_data.dialog;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.openDialog",this.m_data);
      }
   }
}

