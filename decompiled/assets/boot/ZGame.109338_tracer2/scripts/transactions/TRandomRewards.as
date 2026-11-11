package transactions
{
   import core.entities.components.behaviors.states.RandomRewardsState;
   import flash.events.IEventDispatcher;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class TRandomRewards extends TWorldState
   {
      
      private var m_eventDispatcher:IEventDispatcher = null;
      
      public function TRandomRewards(param1:IEntity, param2:IEventDispatcher)
      {
         super(param1);
         this.m_eventDispatcher = param2;
      }
      
      override public function perform() : void
      {
         signedWorldAction("randomRewards",{});
      }
      
      override protected function onComplete(param1:Object) : void
      {
         this.m_eventDispatcher.dispatchEvent(new WorldEvent(RandomRewardsState.REWARD_COMPLETE,param1.data));
         this.m_eventDispatcher = null;
      }
   }
}

