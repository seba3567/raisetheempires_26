package transactions
{
   import core.ZGlobal;
   import core.managers.MeteoriteMiningManager;
   import zlabs.entity.IEntity;
   
   public class TCollectMeteoriteCoins extends TWorldState
   {
      
      public function TCollectMeteoriteCoins(param1:IEntity)
      {
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("collectMeteoriteCoins");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         if(param1.coins)
         {
            ZGlobal.player.coins += MeteoriteMiningManager.TOKEN_REWARD_COIN_COUNT;
         }
      }
   }
}

