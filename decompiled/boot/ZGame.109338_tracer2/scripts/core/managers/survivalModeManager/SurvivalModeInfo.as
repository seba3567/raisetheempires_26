package core.managers.survivalModeManager
{
   public class SurvivalModeInfo
   {
      
      private var m_curSet:String = null;
      
      private var m_curWave:int = -1;
      
      private var m_curLoop:int = 0;
      
      private var m_curPlayerFleet:String = null;
      
      private var m_curEnemyFleet:String = null;
      
      private var m_lastPlayedTime:Number = 0;
      
      private var m_rewardRefreshCount:Number = 0;
      
      private var m_rewards:Object;
      
      private var m_rewardsChanged:Boolean;
      
      public function SurvivalModeInfo(param1:Object)
      {
         super();
         if(param1 != null)
         {
            this.m_curSet = param1.curSet;
            this.m_curWave = param1.curWave;
            this.m_curLoop = param1.curLoop;
            this.m_curPlayerFleet = param1.curPlayerFleet;
            this.m_curEnemyFleet = param1.curEnemyFleet;
            this.m_lastPlayedTime = param1.lastPlayedTime;
            this.m_rewardRefreshCount = param1.rewardRefreshCount;
            this.m_rewards = param1.rewards;
            this.m_rewardsChanged = param1.rewardChanged;
         }
      }
      
      public function reset() : void
      {
         this.m_curSet = null;
         this.m_curWave = -1;
         this.m_curLoop = 0;
         this.m_curPlayerFleet = null;
         this.m_curEnemyFleet = null;
      }
      
      public function get rewards() : Object
      {
         return this.m_rewards;
      }
      
      public function get rewardChanged() : Boolean
      {
         return this.m_rewardsChanged;
      }
      
      public function get curSet() : String
      {
         return this.m_curSet;
      }
      
      public function get curWave() : int
      {
         return this.m_curWave;
      }
      
      public function get rewardRefreshCount() : Number
      {
         return this.m_rewardRefreshCount;
      }
      
      public function get curLoop() : int
      {
         return this.m_curLoop;
      }
      
      public function get curPlayerFleet() : String
      {
         return this.m_curPlayerFleet;
      }
      
      public function get curEnemyFleet() : String
      {
         return this.m_curEnemyFleet;
      }
      
      public function get isInBattle() : Boolean
      {
         return this.m_curPlayerFleet != null && this.m_curPlayerFleet != "" && this.m_curEnemyFleet != null && this.m_curEnemyFleet != "";
      }
   }
}

