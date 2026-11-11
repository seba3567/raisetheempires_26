package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   import flash.display.MovieClip;
   
   public class Campaign2Board extends Board
   {
      
      public function Campaign2Board(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "molten_mc";
      }
      
      override protected function get name() : String
      {
         return "camp2";
      }
      
      override protected function showTrophies(param1:MovieClip, param2:Object) : void
      {
      }
   }
}

