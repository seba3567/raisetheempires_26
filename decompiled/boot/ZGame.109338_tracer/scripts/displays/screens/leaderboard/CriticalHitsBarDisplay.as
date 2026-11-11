package displays.screens.leaderboard
{
   import utils.ZGameUtils;
   
   public class CriticalHitsBarDisplay extends BarDisplay
   {
      
      public function CriticalHitsBarDisplay()
      {
         super();
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_CriticalHitsScore");
      }
   }
}

