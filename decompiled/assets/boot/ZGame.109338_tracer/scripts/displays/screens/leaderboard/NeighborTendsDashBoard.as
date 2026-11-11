package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class NeighborTendsDashBoard extends Board
   {
      
      public function NeighborTendsDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "hoe_mc";
      }
      
      override protected function get name() : String
      {
         return Leaderboard.TYPE_NEIGHBOR_TENDS;
      }
   }
}

