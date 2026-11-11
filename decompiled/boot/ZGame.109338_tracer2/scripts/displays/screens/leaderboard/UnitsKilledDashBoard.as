package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class UnitsKilledDashBoard extends Board
   {
      
      public function UnitsKilledDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "tombstone_mc";
      }
      
      override protected function get name() : String
      {
         return "unitsKilled";
      }
   }
}

