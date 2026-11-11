package displays.screens.leaderboard
{
   import utils.ZGameUtils;
   
   public class HonorBarDisplay extends BarDisplay
   {
      
      public function HonorBarDisplay()
      {
         super();
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_HonorDashScore");
      }
   }
}

