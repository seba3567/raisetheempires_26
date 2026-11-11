package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class ResourceDashBoard extends Board
   {
      
      public function ResourceDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         if(m_leaderboard.matchesMetric("coins"))
         {
            return "coin_mc";
         }
         if(m_leaderboard.matchesMetric("wood") && m_leaderboard.matchesMetric("oil"))
         {
            return "tycoon_mc";
         }
         return "ore_mc";
      }
      
      override protected function get name() : String
      {
         return "resource";
      }
   }
}

