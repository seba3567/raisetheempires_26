package transactions.deathMatch
{
   import Engine.Transactions.Transaction;
   import core.managers.deathMatchManager.DeathMatchManager;
   import flash.events.Event;
   import zlabs.managers.PopupManager;
   
   public class TFetchDeathMatchOpponents extends Transaction
   {
      
      private var m_roomId:String;
      
      public function TFetchDeathMatchOpponents(param1:String)
      {
         this.m_roomId = param1;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("DeathMatchService.fetchOpponents",this.m_roomId);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         if(param1.hasOwnProperty("opponents"))
         {
            DeathMatchManager.instance.updateLocalOpponentCache(this.m_roomId,param1);
            DeathMatchManager.instance.dispatchEvent(new Event(DeathMatchManager.OPPONENT_LIST_UPDATED));
         }
      }
      
      override protected function onFault(param1:int, param2:String) : void
      {
         if(DeathMatchManager.instance.loadingScreen != null)
         {
            while(PopupManager.instance.displayedWindow != DeathMatchManager.instance.loadingScreen)
            {
               PopupManager.instance.pop();
            }
            PopupManager.instance.pop();
            DeathMatchManager.instance.loadingScreen = null;
         }
      }
   }
}

