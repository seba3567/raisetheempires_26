package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TCompleteSocialRepel extends Transaction
   {
      
      private var m_invaderID:String;
      
      public function TCompleteSocialRepel(param1:String)
      {
         super();
         this.m_invaderID = param1;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.completeSocialRepel",this.m_invaderID);
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

