package transactions
{
   import core.ZGlobal;
   import core.managers.DeepSeaDrillManager;
   import zlabs.entity.IEntity;
   
   public class TCollectDeepSeaDrillCoins extends TWorldState
   {
      
      public function TCollectDeepSeaDrillCoins(param1:IEntity)
      {
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("collectDeepSeaDrillCoins");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         if(param1.coins)
         {
            ZGlobal.player.coins += DeepSeaDrillManager.TOKEN_REWARD_COIN_COUNT;
         }
      }
   }
}

