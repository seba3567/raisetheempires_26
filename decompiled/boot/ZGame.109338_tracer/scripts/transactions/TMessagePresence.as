package transactions
{
   import Engine.Transactions.Transaction;
   import core.Zlingshot;
   
   public class TMessagePresence extends Transaction
   {
      
      private var m_hostUid:String;
      
      public function TMessagePresence(param1:String)
      {
         super();
         this.m_hostUid = param1;
      }
      
      override public function perform() : void
      {
         signedCall("ZlingshotService.presence",this.m_hostUid);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         Zlingshot.presenceTimer.reset();
         Zlingshot.presenceTimer.start();
      }
   }
}

