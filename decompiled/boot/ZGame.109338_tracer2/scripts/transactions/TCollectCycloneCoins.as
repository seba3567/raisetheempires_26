package transactions
{
   import core.ZGlobal;
   import core.managers.CyclonePowerManager;
   import zlabs.entity.IEntity;
   
   public class TCollectCycloneCoins extends TWorldState
   {
      
      public function TCollectCycloneCoins(param1:IEntity)
      {
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("collectCycloneCoins");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         if(param1.coins)
         {
            ZGlobal.player.coins += CyclonePowerManager.TOKEN_REWARD_COIN_COUNT;
         }
      }
   }
}

