package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class PowerUpAddictDashBoard extends Board
   {
      
      public function PowerUpAddictDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "powerup_mc";
      }
      
      override protected function get name() : String
      {
         return Leaderboard.TYPE_POWER_UP_ADDICT;
      }
   }
}

