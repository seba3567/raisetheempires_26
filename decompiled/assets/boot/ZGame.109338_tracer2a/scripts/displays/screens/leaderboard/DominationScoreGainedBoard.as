package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class DominationScoreGainedBoard extends Board
   {
      
      public function DominationScoreGainedBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "dominance_mc";
      }
      
      override protected function get name() : String
      {
         return "camp";
      }
   }
}

