package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TSelect extends Transaction
   {
      
      private var m_data:Object = null;
      
      public function TSelect(param1:String)
      {
         super();
         this.m_data = new Object();
         this.m_data.itemCode = param1;
      }
      
      public function get itemCode() : String
      {
         return this.m_data.itemCode;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.select",this.m_data);
      }
   }
}

