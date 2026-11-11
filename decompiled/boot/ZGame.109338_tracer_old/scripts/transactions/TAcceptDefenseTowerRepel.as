package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TAcceptDefenseTowerRepel extends Transaction
   {
      
      private var m_invaderID:String;
      
      public function TAcceptDefenseTowerRepel(param1:String)
      {
         super();
         this.m_invaderID = param1;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.acceptDefenseTowerRepel",this.m_invaderID);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
         super.onFault(param1,param2);
      }
   }
}

