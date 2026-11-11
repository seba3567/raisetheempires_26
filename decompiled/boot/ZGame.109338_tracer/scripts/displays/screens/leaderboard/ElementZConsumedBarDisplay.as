package displays.screens.leaderboard
{
   import utils.ZGameUtils;
   
   public class ElementZConsumedBarDisplay extends BarDisplay
   {
      
      public function ElementZConsumedBarDisplay()
      {
         super();
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_ElementZConsumedScore");
      }
   }
}

