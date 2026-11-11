package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class SurvivalDamageDashBoard extends Board
   {
      
      public function SurvivalDamageDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "survival_mc";
      }
      
      override protected function get name() : String
      {
         return "damage";
      }
   }
}

