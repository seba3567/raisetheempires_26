package displays.screens.leaderboard
{
   import utils.ZGameUtils;
   
   public class ResearchUpgradesBarDisplay extends BarDisplay
   {
      
      public function ResearchUpgradesBarDisplay()
      {
         super();
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_ResearchUpgradesScore");
      }
   }
}

