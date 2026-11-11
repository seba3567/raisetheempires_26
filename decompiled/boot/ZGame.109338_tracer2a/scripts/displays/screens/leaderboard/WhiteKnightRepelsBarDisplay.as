package displays.screens.leaderboard
{
   import utils.ZGameUtils;
   
   public class WhiteKnightRepelsBarDisplay extends BarDisplay
   {
      
      public function WhiteKnightRepelsBarDisplay()
      {
         super();
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_WhiteKnightRepelsScore");
      }
   }
}

