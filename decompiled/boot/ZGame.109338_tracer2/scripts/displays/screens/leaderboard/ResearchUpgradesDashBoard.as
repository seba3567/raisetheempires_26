package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class ResearchUpgradesDashBoard extends Board
   {
      
      public function ResearchUpgradesDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "wrench_mc";
      }
      
      override protected function get name() : String
      {
         return Leaderboard.TYPE_RESEARCH_UPGRADES;
      }
   }
}

