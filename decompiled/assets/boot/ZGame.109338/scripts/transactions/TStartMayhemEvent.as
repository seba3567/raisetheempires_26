package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TStartMayhemEvent extends Transaction
   {
      
      protected var m_params:Object;
      
      public function TStartMayhemEvent(param1:String, param2:String)
      {
         super();
         this.m_params = new Object();
         this.m_params.eventKey = param1;
         this.m_params.endTime = param2;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.startMayhemEvent",this.m_params.eventKey,this.m_params.endTime);
      }
   }
}

