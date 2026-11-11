package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class VillainTokensBoard extends Board
   {
      
      public function VillainTokensBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "mastery_mc";
      }
      
      override protected function get name() : String
      {
         return Leaderboard.TYPE_VILLAIN_TOKENS;
      }
   }
}

