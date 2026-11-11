package transactions
{
   import core.ZGlobal;
   import core.managers.TimedBuildableManager;
   import zlabs.entity.IEntity;
   
   public class TCollectTimedBuildableCoins extends TWorldState
   {
      
      private var m_params:Object;
      
      public function TCollectTimedBuildableCoins(param1:IEntity, param2:String)
      {
         super(param1);
         this.m_params = new Object();
         this.m_params.reskinID = param2;
      }
      
      override public function perform() : void
      {
         signedWorldAction("collectTimedBuildableCoins",this.m_params);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         if(param1.coins)
         {
            ZGlobal.player.coins += TimedBuildableManager.TOKEN_REWARD_COIN_COUNT;
         }
      }
   }
}

