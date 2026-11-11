package displays.screens.leaderboard
{
   import utils.ZGameUtils;
   
   public class NeighborTendsBarDisplay extends BarDisplay
   {
      
      public function NeighborTendsBarDisplay()
      {
         super();
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_NeighborTendsScore");
      }
   }
}

