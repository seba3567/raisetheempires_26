package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TPVPPillage extends Transaction
   {
      
      private var m_hostID:String;
      
      public function TPVPPillage(param1:String)
      {
         super();
         this.m_hostID = param1;
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.pillage",this.m_hostID);
      }
   }
}

