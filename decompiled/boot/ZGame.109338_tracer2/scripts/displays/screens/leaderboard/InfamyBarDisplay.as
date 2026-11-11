package displays.screens.leaderboard
{
   import utils.ZGameUtils;
   
   public class InfamyBarDisplay extends BarDisplay
   {
      
      public function InfamyBarDisplay()
      {
         super();
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_InfamyDashScore");
      }
   }
}

