package transactions
{
   import Engine.Transactions.Transaction;
   import zlabs.debug.Logger;
   
   public class TPVPGlobalOptInOut extends Transaction
   {
      
      private var m_optIn:Boolean;
      
      public function TPVPGlobalOptInOut(param1:Boolean)
      {
         super();
         this.m_optIn = param1;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.globalPVPOptInOut",this.m_optIn);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(!param1.res)
         {
            Logger.print(this," failed");
         }
      }
   }
}

