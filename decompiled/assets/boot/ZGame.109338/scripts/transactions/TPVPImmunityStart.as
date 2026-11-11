package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TPVPImmunityStart extends Transaction
   {
      
      public function TPVPImmunityStart()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.immunityStart");
      }
   }
}

