package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class WhiteKnightRepelsDashBoard extends Board
   {
      
      public function WhiteKnightRepelsDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "skull_mc";
      }
      
      override protected function get name() : String
      {
         return Leaderboard.TYPE_WHITE_KNIGHT_REPELS;
      }
   }
}

