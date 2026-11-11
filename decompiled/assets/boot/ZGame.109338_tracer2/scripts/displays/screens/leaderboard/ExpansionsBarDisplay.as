package displays.screens.leaderboard
{
   import utils.ZGameUtils;
   
   public class ExpansionsBarDisplay extends BarDisplay
   {
      
      public function ExpansionsBarDisplay()
      {
         super();
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_ExpansionsScore");
      }
   }
}

