package displays.screens.leaderboard
{
   import utils.ZGameUtils;
   
   public class SurvivalBarDisplay extends BarDisplay
   {
      
      public function SurvivalBarDisplay()
      {
         super();
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_SurvivalHighestComplete");
      }
   }
}

