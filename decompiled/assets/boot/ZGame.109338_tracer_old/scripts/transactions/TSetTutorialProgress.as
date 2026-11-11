package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TSetTutorialProgress extends Transaction
   {
      
      private var m_progress:String = null;
      
      public function TSetTutorialProgress(param1:String)
      {
         super();
         this.m_progress = param1;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.tutorialProgress",this.m_progress);
      }
      
      override protected function onComplete(param1:Object) : void
      {
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
      }
   }
}

