package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TSurvivalModeToaster extends Transaction
   {
      
      private var m_time:Number = 0;
      
      public function TSurvivalModeToaster(param1:Number)
      {
         super();
         this.m_time = param1;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.setSurvivalModeToaster",this.m_time);
      }
      
      override protected function onComplete(param1:Object) : void
      {
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
      }
   }
}

