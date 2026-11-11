package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TViewZoom extends Transaction
   {
      
      private var m_data:Object = null;
      
      public function TViewZoom(param1:Number)
      {
         super();
         this.m_data = new Object();
         this.m_data.zoom = param1;
      }
      
      public function get zoom() : Number
      {
         return this.m_data.zoom;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.viewZoom",this.m_data);
      }
   }
}

