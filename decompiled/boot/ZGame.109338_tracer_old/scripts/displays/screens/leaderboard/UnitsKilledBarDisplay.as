package displays.screens.leaderboard
{
   import utils.ZGameUtils;
   
   public class UnitsKilledBarDisplay extends BarDisplay
   {
      
      public function UnitsKilledBarDisplay()
      {
         super();
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_UnitsKilledScore");
      }
   }
}

