package core.managers
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import entity.GameDataComponent;
   import flash.utils.Dictionary;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   
   public class MechLabDailyRewardManager
   {
      
      private static var m_instance:MechLabDailyRewardManager = new MechLabDailyRewardManager();
      
      private var m_sequentialLogins:int = 0;
      
      private var m_rewards:Object;
      
      private var m_hasCollected:Boolean = false;
      
      private const PART_CODE:String = "B289";
      
      private const MAX_DAY:int = 16;
      
      private const MAX_TIERS:int = 5;
      
      public function MechLabDailyRewardManager()
      {
         super();
         this.m_rewards = new Object();
         this.m_rewards.tier0 = {
            "day":0,
            "reward":0
         };
         this.m_rewards.tier1 = {
            "day":1,
            "reward":1
         };
         this.m_rewards.tier2 = {
            "day":3,
            "reward":3
         };
         this.m_rewards.tier3 = {
            "day":7,
            "reward":6
         };
         this.m_rewards.tier4 = {
            "day":15,
            "reward":12
         };
      }
      
      public static function get instance() : MechLabDailyRewardManager
      {
         return m_instance;
      }
      
      public function onInitUser(param1:int) : void
      {
         var _loc2_:int = 0;
         this.sequentialLogins = param1;
         if(ZGlobal.newDayThisSession && !this.hasUnactivatedMechLab())
         {
            _loc2_ = this.getDailyReward();
            ZGlobal.player.removeInventoryItem(this.PART_CODE,_loc2_);
         }
         else
         {
            this.hasCollected = true;
         }
      }
      
      public function onCollect() : void
      {
         var _loc1_:int = 0;
         if(!this.hasCollected)
         {
            _loc1_ = this.getDailyReward();
            ZGlobal.player.addToInventory(this.PART_CODE,_loc1_);
            this.hasCollected = true;
         }
      }
      
      private function getDailyReward() : int
      {
         var _loc1_:int = 1;
         var _loc2_:int = this.getDayTier();
         var _loc3_:int = this.getTierDay(_loc2_);
         if(_loc3_ == this.sequentialLogins % this.MAX_DAY)
         {
            _loc1_ += this.getTierReward(this.getDayTier());
         }
         return _loc1_;
      }
      
      public function get hasCollected() : Boolean
      {
         return this.m_hasCollected;
      }
      
      public function set hasCollected(param1:Boolean) : void
      {
         this.m_hasCollected = param1;
      }
      
      public function set sequentialLogins(param1:int) : void
      {
         this.m_sequentialLogins = param1;
      }
      
      public function get sequentialLogins() : int
      {
         return this.m_sequentialLogins;
      }
      
      public function getDayTier() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         _loc1_ = 0;
         _loc2_ = this.m_sequentialLogins % this.MAX_DAY;
         _loc3_ = 0;
         while(_loc3_ < this.MAX_TIERS)
         {
            _loc4_ = this.m_rewards["tier" + _loc3_];
            if(_loc2_ < _loc4_.day)
            {
               break;
            }
            _loc1_ = _loc3_;
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function getTierReward(param1:int) : int
      {
         return this.m_rewards["tier" + param1].reward;
      }
      
      public function getTierDay(param1:int, param2:Boolean = false) : int
      {
         var _loc3_:int = 0;
         _loc3_ = int(this.m_rewards["tier" + param1].day);
         if(param2)
         {
            _loc3_ += this.getTierZeroDayOffset();
         }
         return _loc3_;
      }
      
      public function getTierZeroDayOffset() : int
      {
         return Math.floor(this.m_sequentialLogins / this.MAX_DAY) * this.MAX_DAY;
      }
      
      private function hasUnactivatedMechLab() : Boolean
      {
         var _loc2_:IEntity = null;
         var _loc3_:GameDataComponent = null;
         var _loc4_:PropertyReference = null;
         var _loc5_:BehaviorStateMachine = null;
         var _loc1_:Dictionary = WorldObjectManager.instance.getObjectsBySubType("building","military");
         for each(_loc2_ in _loc1_)
         {
            _loc3_ = GameDataComponent.getGameDataComponent(_loc2_);
            if(Boolean(_loc3_) && _loc3_.gameData.code == "TL01")
            {
               _loc4_ = new PropertyReference("@StateMachine.stateMachine");
               _loc5_ = _loc2_.getProperty(_loc4_) as BehaviorStateMachine;
               if((Boolean(_loc5_)) && Boolean(_loc5_.isCurrentStateBuilt()) && !_loc5_.isCurrentStateActivated())
               {
                  return true;
               }
            }
         }
         return false;
      }
   }
}

