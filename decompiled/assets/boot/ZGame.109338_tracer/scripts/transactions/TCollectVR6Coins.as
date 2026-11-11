package transactions
{
   import core.ZGlobal;
   import core.managers.VolcanoReskin6Manager;
   import zlabs.entity.IEntity;
   
   public class TCollectVR6Coins extends TWorldState
   {
      
      public function TCollectVR6Coins(param1:IEntity)
      {
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("collectVR6Coins");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         if(param1.coins)
         {
            ZGlobal.player.coins += VolcanoReskin6Manager.TOKEN_REWARD_COIN_COUNT;
         }
      }
   }
}

