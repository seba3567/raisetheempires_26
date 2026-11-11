package displays.popups.leaderboard
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.managers.leaderboardManager.Leaderboard;
   import core.managers.leaderboardManager.LeaderboardManager;
   import displays.screens.leaderboard.Board;
   import displays.screens.leaderboard.SummaryBoard;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TCollectLeaderBoard;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class LeaderboardCompletePopup extends LeaderboardPopup
   {
      
      private var m_board:Board = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function LeaderboardCompletePopup(param1:Leaderboard)
      {
         super();
         this.m_board = new SummaryBoard(param1,false);
      }
      
      override public function get statsData() : Object
      {
         return {
            "counter":"dialog",
            "kingdom":"lb_placement_complete"
         };
      }
      
      override protected function get screen() : MovieClip
      {
         return m_window.complete_mc;
      }
      
      override protected function initializeScreen() : void
      {
         this.contentWidth = this.screen.width;
         this.contentHeight = this.screen.height;
         super.initializeScreen();
         this.screen.return_mc.visible = false;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,onExit,false,0,true);
         this.m_buttonSounds.addButton(this.screen.exit_bt,ButtonSound.DEFAULT);
         TextFieldUtil.processTextField(this.screen.heading_tf,this.m_board.summary);
         var _loc1_:String = ZGameUtils.ZlocT("Leaderboards","Leaderboards_CompleteMessage",{
            "rank":this.m_board.rank,
            "amount":this.m_board.activePlayers
         });
         TextFieldUtil.processTextField(this.screen.subHeading_tf,_loc1_);
         this.m_board.parentScreen = this.screen;
         updateTitleTrophies();
         this.populateBars();
      }
      
      override protected function deinitDialog() : void
      {
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,onExit);
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         super.deinitDialog();
      }
      
      override protected function close(param1:Event = null) : void
      {
         if(this.m_board.allRewardsCollected(this.m_board.getReward(this.m_board.leaderboard.entry(ZGlobal.player.uid))))
         {
            LeaderboardManager.instance.dispatchEvent(new WorldEvent(LeaderboardManager.LEADERBOARD_COMPLETE,this.m_board.id));
            TransactionManager.addTransaction(new TCollectLeaderBoard(this.m_board.id,0,0,true,false));
         }
         dispatchEvent(new Event(LeaderboardManager.LEADERBOARD_SUMMARY_CLOSED));
         super.close(param1);
      }
      
      private function get bars() : Array
      {
         return [this.screen.bar1_mc,this.screen.bar2_mc,this.screen.bar3_mc,this.screen.bar4_mc];
      }
      
      private function populateBars() : void
      {
         var _loc5_:int = 0;
         var _loc1_:Array = this.bars;
         this.m_board.beginPopulation(_loc1_);
         var _loc2_:int = int(_loc1_.length);
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc5_ = this.m_board.populateBar(_loc1_[_loc4_],_loc3_);
            if(_loc5_ == Board.ERROR)
            {
               break;
            }
            if(_loc5_ != Board.SKIP_ENTRY)
            {
               _loc4_++;
            }
            _loc3_++;
         }
      }
   }
}

