package displays.screens.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   import flash.display.MovieClip;
   
   public class PopupBoard extends Board
   {
      
      public function PopupBoard(param1:Leaderboard)
      {
         super(param1,false);
      }
      
      override protected function hideAllTrophies(param1:MovieClip) : void
      {
      }
      
      override protected function showTrophies(param1:MovieClip, param2:Object) : void
      {
      }
      
      override protected function rewardCollected(param1:MovieClip) : void
      {
      }
   }
}

