package transactions
{
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import core.managers.mayhemManager.MayhemManager;
   
   public class TStopMayhemEvent extends Transaction
   {
      
      private var m_params:Object;
      
      public function TStopMayhemEvent(param1:String, param2:Boolean = false)
      {
         super();
         this.m_params = new Object();
         this.m_params.eventKey = param1;
         this.m_params.averted = param2;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.stopMayhemEvent",this.m_params.eventKey,this.m_params.averted);
      }
      
      override protected function onAmfComplete(param1:Object) : void
      {
         super.onAmfComplete(param1);
         if(param1)
         {
            if(param1.errorType == NO_ERROR)
            {
               TransactionManager.addTransaction(new TExpireAQuest(MayhemManager.AMS_QUEST));
            }
         }
      }
   }
}

