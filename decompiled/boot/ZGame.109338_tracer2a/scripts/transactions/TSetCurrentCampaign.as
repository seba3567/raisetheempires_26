package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TSetCurrentCampaign extends Transaction
   {
      
      private var m_campaign:String = null;
      
      public function TSetCurrentCampaign(param1:String)
      {
         super();
         this.m_campaign = param1;
      }
      
      override public function perform() : void
      {
         signedCall("UserService.setCurrentCampaign",this.m_campaign);
      }
      
      override protected function onComplete(param1:Object) : void
      {
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
      }
   }
}

