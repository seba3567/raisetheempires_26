package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class GlancingBlowsDashBoard extends Board
   {
      
      public function GlancingBlowsDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "glance_mc";
      }
      
      override protected function get name() : String
      {
         return "glancingBlows";
      }
   }
}

