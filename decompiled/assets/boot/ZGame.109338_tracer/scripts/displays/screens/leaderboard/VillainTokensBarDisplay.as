package displays.screens.leaderboard
{
   import utils.ZGameUtils;
   
   public class VillainTokensBarDisplay extends BarDisplay
   {
      
      public function VillainTokensBarDisplay()
      {
         super();
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_CampaignMasteryScore");
      }
   }
}

