package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class InfamyDashBoard extends Board
   {
      
      public function InfamyDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "blackHeart_mc";
      }
      
      override protected function get name() : String
      {
         return "infamy";
      }
   }
}

