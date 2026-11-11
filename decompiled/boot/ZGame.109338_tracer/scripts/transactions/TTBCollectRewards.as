package transactions
{
   import core.entities.components.behaviors.states.TBPlayAgainDialogState;
   import flash.events.IEventDispatcher;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class TTBCollectRewards extends TWorldState
   {
      
      private var m_eventDispatcher:IEventDispatcher;
      
      public function TTBCollectRewards(param1:IEntity, param2:IEventDispatcher)
      {
         super(param1);
         this.m_eventDispatcher = param2;
      }
      
      override public function perform() : void
      {
         signedWorldAction("TBCollectReward");
      }
      
      override protected function onComplete(param1:Object) : void
      {
         super.onComplete(param1);
         if(this.m_eventDispatcher)
         {
            this.m_eventDispatcher.dispatchEvent(new WorldEvent(TBPlayAgainDialogState.COLLECT_REWARD,param1));
            this.m_eventDispatcher = null;
         }
      }
   }
}

