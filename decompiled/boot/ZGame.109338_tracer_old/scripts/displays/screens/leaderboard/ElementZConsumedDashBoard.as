package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   
   public class ElementZConsumedDashBoard extends Board
   {
      
      public function ElementZConsumedDashBoard(param1:Leaderboard, param2:Boolean)
      {
         super(param1,param2);
      }
      
      override public function get icon() : String
      {
         return "element_mc";
      }
      
      override protected function get name() : String
      {
         return Leaderboard.TYPE_ELEMENT_Z_CONSUMED;
      }
   }
}

