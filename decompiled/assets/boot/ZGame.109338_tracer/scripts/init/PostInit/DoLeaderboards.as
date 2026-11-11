package init.PostInit
{
   import Engine.Init.InitializationAction;
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.leaderboardManager.LeaderboardManager;
   import flash.events.Event;
   import init.CompleteMonitor;
   
   public class DoLeaderboards extends InitializationAction
   {
      
      public static const INIT_ID:String = "DoLeaderboards";
      
      private var m_completeMonitor:CompleteMonitor = null;
      
      public function DoLeaderboards()
      {
         super(INIT_ID);
      }
      
      override public function execute() : void
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_LEADERBOARD_SUMMARY);
         if(_loc1_ == ExperimentsManager.EXPERIMENT_LEADERBOARD_SUMMARY_ENABLED_VARIANT)
         {
            dispatchEvent(new Event(Event.COMPLETE));
            return;
         }
         if(ZGlobal.player.getSeenFlag(LeaderboardManager.SEEN_FLAG_COMPLETED_ON_INIT) == 0)
         {
            this.m_completeMonitor = new CompleteMonitor(LeaderboardManager.LEADERBOARD_SUMMARY_CLOSED);
            this.m_completeMonitor.addEventListener(LeaderboardManager.LEADERBOARD_SUMMARY_CLOSED,this.onSummaryScreensClosed);
            if(LeaderboardManager.instance.showCompletedLeaderboards(this.m_completeMonitor))
            {
               ZGlobal.player.setSeenFlag(LeaderboardManager.SEEN_FLAG_COMPLETED_ON_INIT);
               return;
            }
         }
         this.onSummaryScreensClosed(null);
      }
      
      private function onSummaryScreensClosed(param1:Event) : void
      {
         if(this.m_completeMonitor)
         {
            this.m_completeMonitor.removeEventListener(LeaderboardManager.LEADERBOARD_SUMMARY_CLOSED,this.onSummaryScreensClosed);
            this.m_completeMonitor = null;
         }
         dispatchEvent(new Event(Event.COMPLETE));
      }
   }
}

