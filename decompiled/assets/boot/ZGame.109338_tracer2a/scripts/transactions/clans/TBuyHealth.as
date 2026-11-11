package transactions.clans
{
   import Engine.Transactions.Transaction;
   import core.managers.AlliancesManager;
   import zlabs.events.WorldEvent;
   
   public class TBuyHealth extends Transaction
   {
      
      public function TBuyHealth()
      {
         super();
      }
      
      override public function perform() : void
      {
         signedCall("ClansService.buyHealth");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         AlliancesManager.instance.giveMaxHealth();
         AlliancesManager.instance.dispatchEvent(new WorldEvent(AlliancesManager.CLANS_ZLINGSHOT_MSG,"clan.healthUpdate"));
      }
   }
}

