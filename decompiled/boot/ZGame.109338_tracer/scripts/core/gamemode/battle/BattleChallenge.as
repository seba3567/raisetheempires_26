package core.gamemode.battle
{
   import core.gameobjects.Fleet;
   import core.managers.ChallengeModeManager;
   
   public class BattleChallenge extends BattleHost
   {
      
      private var m_restoreToStrategicMap:Boolean;
      
      private var m_globalPVP:Boolean = ChallengeModeManager.instance.currentChallengeHasStatus(ChallengeModeManager.CHALLENGE_FLAG_GLOBAL_PVP);
      
      public function BattleChallenge(param1:Fleet, param2:Fleet, param3:Boolean = false)
      {
         this.m_restoreToStrategicMap = param3;
         super(param1,param2);
      }
      
      override public function endBattleWithRetreat() : void
      {
         super.endBattleWithRetreat();
         ChallengeModeManager.instance.completeChallengeBattle(Battle.BATTLE_RESULT_RETREAT,m_enemyFleetName);
      }
      
      override protected function battleOver(param1:int) : void
      {
         super.battleOver(param1);
         ChallengeModeManager.instance.completeChallengeBattle(m_battleResult,m_enemyFleetName);
      }
      
      override public function rematch() : void
      {
      }
      
      override public function get isChallenge() : Boolean
      {
         return true;
      }
      
      override public function get isGlobalPVP() : Boolean
      {
         return this.m_globalPVP;
      }
      
      override public function get returnToPreviousView() : Boolean
      {
         var _loc1_:Boolean = m_battleResult == Battle.BATTLE_RESULT_WON && this.m_restoreToStrategicMap;
         return !_loc1_;
      }
   }
}

