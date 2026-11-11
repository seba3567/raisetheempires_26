package displays.screens.leaderboard
{
   import utils.ZGameUtils;
   
   public class DamageBarDisplay extends BarDisplay
   {
      
      public function DamageBarDisplay()
      {
         super();
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_DamageDashScore");
      }
   }
}

