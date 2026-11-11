package transactions
{
   import Engine.Transactions.Transaction;
   
   public class TPVPGlobalSlotMachineSpinBuy extends Transaction
   {
      
      public function TPVPGlobalSlotMachineSpinBuy()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("PVPService.slotMachineSpinBuy");
      }
   }
}

