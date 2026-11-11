package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TPVPImmunityExtend extends Transaction
   {
      
      public function TPVPImmunityExtend()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.immunityExtend");
      }
   }
}

