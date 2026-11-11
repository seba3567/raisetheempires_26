package transactions
{
   import Engine.Transactions.Transaction;
   import core.ui.menuitem.RecentPlayersUIItem;
   import dispatchers.NeighborsDispatcher;
   import zlabs.events.WorldEvent;
   
   public class TRecentPlayers extends Transaction
   {
      
      private var m_callback:Function = null;
      
      public function TRecentPlayers(param1:Function)
      {
         super();
         this.m_callback = param1;
      }
      
      override public function perform() : void
      {
         super.perform();
         signedCall("DataServicesService.getRecentPlayers");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         var _loc2_:WorldEvent = null;
         super.onComplete(param1);
         if(this.m_callback != null)
         {
            this.m_callback(param1);
         }
         else
         {
            _loc2_ = new WorldEvent(RecentPlayersUIItem.RECENT_PLAYERS_RECEIVED,param1 as Array);
            NeighborsDispatcher.instance.dispatchEvent(_loc2_);
         }
      }
   }
}

