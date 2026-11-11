package displays.screens.leaderboard
{
   import utils.ZGameUtils;
   
   public class XpBarDisplay extends BarDisplay
   {
      
      public function XpBarDisplay()
      {
         super();
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_XPDashScore");
      }
   }
}

