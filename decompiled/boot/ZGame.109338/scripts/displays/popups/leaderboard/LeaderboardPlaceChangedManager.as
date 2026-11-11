package displays.popups.leaderboard
{
   import core.managers.leaderboardManager.Leaderboard;
   import core.managers.leaderboardManager.LeaderboardManager;
   import flash.events.Event;
   import zlabs.events.WorldEvent;
   
   public class LeaderboardPlaceChangedManager
   {
      
      public static var instance:LeaderboardPlaceChangedManager = new LeaderboardPlaceChangedManager();
      
      private var m_popup:LeaderboardUpdatedPopup;
      
      public function LeaderboardPlaceChangedManager()
      {
         super();
      }
      
      public function init() : void
      {
         LeaderboardManager.instance.addEventListener(LeaderboardManager.LEADERBOARD_PLACE_CHANGED,this.onPlayerPlaceChanged);
      }
      
      private function onPlayerPlaceChanged(param1:WorldEvent) : void
      {
         var _loc2_:int = int(param1.eventData.index);
         var _loc3_:Leaderboard = param1.eventData.leaderboard;
         var _loc4_:Boolean = Boolean(param1.eventData.passedPlayer);
         if(!LeaderboardUpdatedPopup.ACTIVE)
         {
            LeaderboardUpdatedPopup.ACTIVE = true;
            this.m_popup = new LeaderboardUpdatedPopup(_loc3_,_loc2_,_loc4_);
            this.m_popup.addEventListener(Event.CLOSE,this.onPopupClose,false,0,true);
         }
         else if(this.m_popup != null)
         {
            this.m_popup.attemptLastMinuteChange(_loc3_,_loc2_,_loc4_);
         }
      }
      
      private function onPopupClose(param1:Event) : void
      {
         this.m_popup.removeEventListener(Event.CLOSE,this.onPopupClose);
         this.m_popup = null;
      }
   }
}

