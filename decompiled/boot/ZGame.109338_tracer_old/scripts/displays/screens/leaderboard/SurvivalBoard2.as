package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   import flash.display.MovieClip;
   
   public class SurvivalBoard2 extends Board
   {
      
      public function SurvivalBoard2(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "survival_mc";
      }
      
      override protected function get name() : String
      {
         return "survival";
      }
      
      override protected function showTrophies(param1:MovieClip, param2:Object) : void
      {
      }
   }
}

