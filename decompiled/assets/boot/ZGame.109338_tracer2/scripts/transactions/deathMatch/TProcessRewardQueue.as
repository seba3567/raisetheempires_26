package transactions.deathMatch
{
   import Engine.Transactions.Transaction;
   import core.managers.deathMatchManager.DeathMatchManager;
   import zlabs.events.WorldEvent;
   
   public class TProcessRewardQueue extends Transaction
   {
      
      private var m_roomId:String;
      
      public function TProcessRewardQueue(param1:String)
      {
         this.m_roomId = param1;
         super();
      }
      
      override public function perform() : void
      {
         signedCall("DeathMatchService.processRewardQueue",this.m_roomId);
      }
      
      override protected function onComplete(param1:Object) : void
      {
         DeathMatchManager.instance.dispatchEvent(new WorldEvent(DeathMatchManager.REWARDS_GRANTED,param1));
      }
   }
}

