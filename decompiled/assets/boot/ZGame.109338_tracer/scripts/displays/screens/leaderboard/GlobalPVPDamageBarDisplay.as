package displays.screens.leaderboard
{
   import flash.display.MovieClip;
   import utils.ZGameUtils;
   
   public class GlobalPVPDamageBarDisplay extends BarDisplay
   {
      
      public function GlobalPVPDamageBarDisplay()
      {
         super();
      }
      
      override public function requireText(param1:int) : String
      {
         return ZGameUtils.ZlocT("Leaderboards","Leaderboards_GPVPDamageDashScore");
      }
      
      override public function getTrophies(param1:Board, param2:MovieClip) : Array
      {
         return param1.globeTrophies(param2);
      }
   }
}

