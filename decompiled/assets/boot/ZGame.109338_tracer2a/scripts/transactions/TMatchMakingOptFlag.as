package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TMatchMakingOptFlag extends Transaction
   {
      
      protected var m_flag:Boolean;
      
      public function TMatchMakingOptFlag(param1:Boolean)
      {
         this.m_flag = param1;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("UserService.matchMakingOptFlag",this.m_flag);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
      }
   }
}

