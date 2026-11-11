package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class HonorDashBoard extends Board
   {
      
      public function HonorDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "redHeart_mc";
      }
      
      override protected function get name() : String
      {
         return "honor";
      }
   }
}

