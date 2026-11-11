package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class GlobalPVPDamageDashBoard extends Board
   {
      
      public function GlobalPVPDamageDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "blitzDamage_mc";
      }
      
      override protected function get name() : String
      {
         return "damage";
      }
   }
}

