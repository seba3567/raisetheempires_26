package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class CriticalHitsDashBoard extends Board
   {
      
      public function CriticalHitsDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "target_mc";
      }
      
      override protected function get name() : String
      {
         return "criticalHits";
      }
   }
}

