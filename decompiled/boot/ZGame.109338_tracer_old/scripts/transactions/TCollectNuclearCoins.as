package transactions
{
   import core.ZGlobal;
   import core.managers.NuclearPowerManager;
   import zlabs.entity.IEntity;
   
   public class TCollectNuclearCoins extends TWorldState
   {
      
      public function TCollectNuclearCoins(param1:IEntity)
      {
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("collectNuclearCoins");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         if(param1.coins)
         {
            ZGlobal.player.coins += NuclearPowerManager.TOKEN_REWARD_COIN_COUNT;
         }
      }
   }
}

