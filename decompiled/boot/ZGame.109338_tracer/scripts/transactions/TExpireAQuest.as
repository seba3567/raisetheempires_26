package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TExpireAQuest extends Transaction
   {
      
      private var m_questName:String = "";
      
      public function TExpireAQuest(param1:String)
      {
         super();
         this.m_questName = param1;
      }
      
      override public function perform() : void
      {
         signedCall("WorldService.expireAQuest",this.m_questName);
      }
      
      override protected function onAmfComplete(param1:Object) : void
      {
         super.onAmfComplete(param1);
         if(param1)
         {
            if(param1.errorType == NO_ERROR)
            {
            }
         }
      }
   }
}

