package core.entities.components.behaviors.states
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.utils.YieldHelper;
   import core.gameobjects.GameItem;
   import core.managers.rewardPickupManager.RewardPickupManager;
   import transactions.TRandomRewards;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class RandomRewardsState extends SimpleAutoState
   {
      
      public static const REWARD_COMPLETE:String = "rewardcomplete";
      
      private var m_rewardData:Object = null;
      
      private var m_completed:Boolean = false;
      
      public function RandomRewardsState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function performEnterActions() : void
      {
         stateMachine.propertyBag.eventDispatcher.addEventListener(REWARD_COMPLETE,this.onComplete);
         TransactionManager.addTransaction(new TRandomRewards(stateMachine.propertyBag as IEntity,stateMachine.propertyBag.eventDispatcher));
         super.performEnterActions();
      }
      
      override protected function removeListeners() : void
      {
         stateMachine.propertyBag.eventDispatcher.addEventListener(REWARD_COMPLETE,this.onComplete);
         super.removeListeners();
      }
      
      private function onComplete(param1:WorldEvent) : void
      {
         this.m_rewardData = param1.eventData;
         this.tryCreateRewards();
      }
      
      override protected function onProgressComplete() : void
      {
         this.m_completed = true;
         this.tryCreateRewards();
      }
      
      private function tryCreateRewards() : void
      {
         var _loc1_:GameItem = null;
         var _loc2_:XML = null;
         var _loc3_:YieldHelper = null;
         if(Boolean(this.m_rewardData) && this.m_completed)
         {
            RewardPickupManager.instance.startLootCreationScope(true);
            if(this.m_rewardData.type == "item")
            {
               _loc1_ = ZGlobal.gameSettings.getItemByCode(this.m_rewardData.item,GameItem) as GameItem;
               RewardPickupManager.instance.addItemReward(stateMachine.propertyBag as IEntity,_loc1_);
            }
            else if(this.m_rewardData.type == "cash")
            {
               RewardPickupManager.instance.addCashReward(stateMachine.propertyBag as IEntity,this.m_rewardData.count);
            }
            else
            {
               _loc2_ = new XML("<state " + this.m_rewardData.type + "=\"" + this.m_rewardData.count + "\"/>");
               _loc3_ = new YieldHelper();
               _loc3_.initFromData(_loc2_);
               _loc3_.execute(stateMachine,_loc2_);
            }
            RewardPickupManager.instance.startLootCreationScope(false);
            super.onProgressComplete();
         }
      }
   }
}

