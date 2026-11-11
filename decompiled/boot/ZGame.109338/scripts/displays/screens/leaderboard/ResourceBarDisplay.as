package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   import utils.ZGameUtils;
   
   public class ResourceBarDisplay extends BarDisplay
   {
      
      private var m_scoreLabel:String = null;
      
      public function ResourceBarDisplay(param1:Leaderboard)
      {
         super();
         if(param1.matchesMetric("coins"))
         {
            this.m_scoreLabel = ZGameUtils.ZlocT("Leaderboards","Leaderboards_CoinDashScore");
         }
         else if(param1.matchesMetric("wood") && param1.matchesMetric("oil"))
         {
            this.m_scoreLabel = ZGameUtils.ZlocT("Leaderboards","Leaderboards_OilWoodDashScore");
         }
         else
         {
            this.m_scoreLabel = ZGameUtils.ZlocT("Leaderboards","Leaderboards_OreDashScore");
         }
      }
      
      override public function requireText(param1:int) : String
      {
         return this.m_scoreLabel;
      }
   }
}

