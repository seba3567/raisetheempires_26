package transactions
{
   import core.ZGlobal;
   import displays.popups.WorldGamesRewardPopUp;
   import zlabs.entity.IEntity;
   import zlabs.managers.PopupManager;
   
   public class TExchangeWorldGamesRewards extends TWorldState
   {
      
      private var m_item:Object;
      
      public function TExchangeWorldGamesRewards(param1:IEntity, param2:Object)
      {
         this.m_item = param2;
         super(param1);
      }
      
      override public function perform() : void
      {
         signedWorldAction("ExchangeWorldGamesRewards",this.m_item);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:String = null;
         super.onComplete(param1);
         if(param1.item)
         {
            for(_loc2_ in param1.item)
            {
               ZGlobal.player.addToInventory(_loc2_,param1.item[_loc2_],true);
               PopupManager.instance.push(new WorldGamesRewardPopUp(_loc2_));
            }
         }
      }
   }
}

