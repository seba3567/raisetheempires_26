package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class DamageDashBoard extends Board
   {
      
      public function DamageDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "damage_mc";
      }
      
      override protected function get name() : String
      {
         return "damage";
      }
   }
}

