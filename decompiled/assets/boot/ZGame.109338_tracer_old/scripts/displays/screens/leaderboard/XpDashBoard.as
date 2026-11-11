package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class XpDashBoard extends Board
   {
      
      public function XpDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "star_mc";
      }
      
      override protected function get name() : String
      {
         return "xp";
      }
   }
}

