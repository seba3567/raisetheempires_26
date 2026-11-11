package displays.screens.leaderboard
{
   import utils.ZGameUtils;
   
   public class SurvivalDamageDashBarDisplay extends BarDisplay
   {
      
      public function SurvivalDamageDashBarDisplay()
      {
         super();
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_SurvivalDamageDashScore");
      }
   }
}

