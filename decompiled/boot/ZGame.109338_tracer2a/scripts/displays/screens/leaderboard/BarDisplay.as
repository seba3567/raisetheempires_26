package displays.screens.leaderboard
{
   import flash.display.MovieClip;
   import utils.ZGameUtils;
   
   public class BarDisplay
   {
      
      public function BarDisplay()
      {
         super();
      }
      
      public function getScore(param1:int) : String
      {
         return param1.toString();
      }
      
      public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_TotalScore");
      }
      
      public function getTrophies(param1:Board, param2:MovieClip) : Array
      {
         return param1.trophies(param2);
      }
   }
}

