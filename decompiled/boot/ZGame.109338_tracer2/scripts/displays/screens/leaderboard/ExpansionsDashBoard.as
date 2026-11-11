package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class ExpansionsDashBoard extends Board
   {
      
      public function ExpansionsDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "expansion_mc";
      }
      
      override protected function get name() : String
      {
         return "expansions";
      }
   }
}

