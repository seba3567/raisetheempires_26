package displays.screens.leaderboard
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.leaderboardManager.Leaderboard;
   import core.managers.leaderboardManager.LeaderboardManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import dispatchers.NeighborsDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import events.FriendBarSlotEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.ZConfig;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class LeaderboardScreen extends ZGamePopUp
   {
      
      private const BARS_PER_PAGE:uint = 6;
      
      private var m_boards:Array = null;
      
      private var m_tabControllers:Array = null;
      
      private var m_currentBoard:Board = null;
      
      private var m_scrollIndex:int = 0;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_imageLoaders:Array = [];
      
      private var m_openToBoardId:String = null;
      
      private var m_autoSurvivalVariant:Number = ExperimentsManager.instance.getExperimentVariant("empires_survival_autorefresh");
      
      public function LeaderboardScreen(param1:String = null)
      {
         super(ZGlobal.getAssetURL("assets/displays/screens/Leaderboard2.swf"));
         this.m_openToBoardId = param1;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.contentWidth = 718;
         this.contentHeight = 598 - 26;
         this.initDialog();
         LeaderboardManager.instance.addEventListener(Event.COMPLETE,this.onInitcomplete);
         LeaderboardManager.instance.init();
         addChild(m_window);
         this.page.timer_tf.visible = false;
         this.page.previous_mc.visible = false;
         this.page.pagination_tf.visible = false;
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         TextFieldUtil.processTextField(this.screen.title_tf,ZGameUtils.ZlocT("Leaderboards","Leaderboards_Title"));
         TextFieldUtil.processTextField(this.page.heading_tf,ZGameUtils.ZlocT("Leaderboards","Leaderboards_Title"));
         TextFieldUtil.processTextField(this.page.subHeading_tf,ZGameUtils.ZlocT("Leaderboards","Leaderboards_Loading"));
         LeaderboardManager.instance.addEventListener(LeaderboardManager.LEADERBOARD_REWARD_COLLECTED,this.onRewardCollected);
         NeighborsDispatcher.instance.addEventListener(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,this.onMenuClicked,false,100);
         this.initButtons();
         this.initTabs();
         this.updateTitleTrophies();
         this.page.scroll_mc.visible = false;
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.disposeBoards();
         this.disposeTabs();
         this.deinitButtons();
         this.hideCurrentBoard();
         LeaderboardManager.instance.removeEventListener(Event.COMPLETE,this.onInitcomplete);
         LeaderboardManager.instance.removeEventListener(LeaderboardManager.LEADERBOARD_REWARD_COLLECTED,this.onRewardCollected);
         NeighborsDispatcher.instance.removeEventListener(FriendBarSlotEvent.FRIEND_BAR_SLOT_CLICK,this.onMenuClicked);
         for each(_loc1_ in this.m_imageLoaders)
         {
            _loc1_.destroy();
            _loc1_ = null;
         }
         this.m_imageLoaders = [];
         super.deinitDialog();
      }
      
      private function get screen() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      private function get page() : MovieClip
      {
         return m_window.screen_mc.page_mc;
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         LeaderboardManager.instance.updateInteresting();
         close();
      }
      
      private function updateScrollButtons() : void
      {
         ZGameUtils.setButtonEnabled(this.page.up_mc,this.onSingleUp,this.m_scrollIndex > 0);
         ZGameUtils.setButtonEnabled(this.page.pageUp_mc,this.onPageUp,this.m_scrollIndex > 0);
         ZGameUtils.setButtonEnabled(this.page.down_mc,this.onSingleDown,this.m_scrollIndex + this.BARS_PER_PAGE < this.m_currentBoard.numValues);
         ZGameUtils.setButtonEnabled(this.page.pageDown_mc,this.onPageDown,this.m_scrollIndex + this.BARS_PER_PAGE < this.m_currentBoard.numValues);
      }
      
      private function onSingleUp(param1:MouseEvent) : void
      {
         if(this.m_scrollIndex > 0)
         {
            this.page.gotoAndPlay("1down");
            --this.m_scrollIndex;
            this.populateAnimatingBars(this.BARS_PER_PAGE - 1,this.BARS_PER_PAGE + 1);
            this.updateScrollButtons();
         }
      }
      
      private function onPageUp(param1:MouseEvent) : void
      {
         var _loc2_:int = Math.min(this.BARS_PER_PAGE,this.m_scrollIndex);
         if(_loc2_ > 0)
         {
            this.page.gotoAndPlay(_loc2_ == this.BARS_PER_PAGE ? "pageDown" : _loc2_.toString() + "down");
            this.m_scrollIndex -= _loc2_;
            this.populateAnimatingBars(this.BARS_PER_PAGE - _loc2_,this.BARS_PER_PAGE + _loc2_);
            this.updateScrollButtons();
         }
      }
      
      private function onSingleDown(param1:MouseEvent) : void
      {
         if(this.m_scrollIndex + this.BARS_PER_PAGE < this.m_currentBoard.numValues)
         {
            this.page.gotoAndPlay("1up");
            this.populateAnimatingBars(0,this.BARS_PER_PAGE + 1);
            ++this.m_scrollIndex;
            this.updateScrollButtons();
         }
      }
      
      private function onPageDown(param1:MouseEvent) : void
      {
         var _loc2_:int = Math.min(this.BARS_PER_PAGE,this.m_currentBoard.numValues - (this.m_scrollIndex + this.BARS_PER_PAGE));
         if(_loc2_ > 0)
         {
            this.page.gotoAndPlay(_loc2_ == this.BARS_PER_PAGE ? "pageUp" : _loc2_.toString() + "up");
            this.populateAnimatingBars(0,this.BARS_PER_PAGE + _loc2_);
            this.m_scrollIndex += _loc2_;
            this.updateScrollButtons();
         }
      }
      
      private function onTabClicked(param1:int) : void
      {
         this.switchTo(param1);
      }
      
      private function getBoardFromId(param1:String) : Board
      {
         var _loc3_:Board = null;
         var _loc2_:Board = null;
         for each(_loc3_ in this.m_boards)
         {
            if(_loc3_.id == param1)
            {
               _loc2_ = _loc3_;
               break;
            }
         }
         return _loc2_;
      }
      
      private function getInitialIndex(param1:Board) : int
      {
         var _loc2_:uint = 0;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         if(param1 != null && ZGlobal.player != null && ZGlobal.player.uid != null)
         {
            _loc2_ = param1.getPlayerIndex(ZGlobal.player.uid);
            if(_loc2_ > 2)
            {
               _loc3_ = int(_loc2_ / this.BARS_PER_PAGE);
               _loc3_ *= this.BARS_PER_PAGE;
               _loc3_ += _loc2_ % this.BARS_PER_PAGE;
               _loc3_ -= this.BARS_PER_PAGE / 2;
               _loc3_ = Math.min(_loc3_,param1.numValues - this.BARS_PER_PAGE);
               return int(Math.max(_loc3_,0));
            }
            return 0;
         }
         _loc4_ = "LeaderboardScreen.getInitialIndex -- one of these is null. ";
         _loc4_ = _loc4_ + ("Board is null check: " + (param1 == null));
         _loc4_ = _loc4_ + (", ZGlobalPlayer is null check: " + (ZGlobal.player == null));
         if(ZGlobal.player != null)
         {
            _loc4_ += ", ZGlobal.player.uid is null check: " + (ZGlobal.player.uid == null);
         }
         throw Error(_loc4_);
      }
      
      private function switchTo(param1:int) : void
      {
         if(this.m_boards)
         {
            this.hideCurrentBoard();
            this.m_currentBoard = this.m_boards[param1];
            this.m_scrollIndex = this.getInitialIndex(this.m_currentBoard);
            this.setInfo();
            if(this.m_currentBoard)
            {
               this.page.gotoAndStop(1);
               this.populateAnimatingBars(0,this.BARS_PER_PAGE);
               this.updateScrollButtons();
            }
         }
      }
      
      private function hideCurrentBoard() : void
      {
         if(this.m_currentBoard)
         {
            this.m_currentBoard.hide(this.allBars);
            this.m_currentBoard = null;
         }
      }
      
      private function setInfo() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         TextFieldUtil.processTextField(this.page.heading_tf,this.m_currentBoard.title);
         TextFieldUtil.processTextField(this.page.subHeading_tf,this.m_currentBoard.description);
         if(this.m_currentBoard.isTimed)
         {
            this.page.timer_tf.visible = true;
            this.onTimerCallback();
         }
         else
         {
            this.page.timer_tf.visible = false;
         }
      }
      
      private function onTimerCallback() : void
      {
         var _loc1_:String = this.m_currentBoard.remainingTime;
         if(_loc1_)
         {
            TextFieldUtil.processTextField(this.page.timer_tf,_loc1_);
            Zlab.processManager.schedule(1000,this,this.onTimerCallback);
         }
         else
         {
            close();
            m_manager.push(new LeaderboardScreen());
         }
      }
      
      private function get allBars() : Array
      {
         return [this.page.scroll_mc.barA1_mc,this.page.scroll_mc.bar2_mc,this.page.scroll_mc.bar3_mc,this.page.scroll_mc.bar4_mc,this.page.scroll_mc.bar5_mc,this.page.scroll_mc.bar6_mc,this.page.scroll_mc.barB1_mc,this.page.scroll_mc.barB2_mc,this.page.scroll_mc.barB3_mc,this.page.scroll_mc.barB4_mc,this.page.scroll_mc.barB5_mc,this.page.scroll_mc.barB6_mc];
      }
      
      private function populateAnimatingBars(param1:int, param2:int) : void
      {
         var _loc6_:int = 0;
         var _loc3_:Array = this.allBars;
         this.m_currentBoard.beginPopulation(_loc3_);
         var _loc4_:int = this.m_scrollIndex;
         var _loc5_:int = param1;
         while(_loc5_ < param1 + param2)
         {
            _loc6_ = this.m_currentBoard.populateBar(_loc3_[_loc5_],_loc4_);
            if(_loc6_ == Board.ERROR)
            {
               break;
            }
            _loc5_++;
            _loc4_++;
         }
         while(_loc5_ < this.BARS_PER_PAGE)
         {
            _loc3_[_loc5_].visible = false;
            _loc5_++;
         }
      }
      
      private function initTabs() : void
      {
         var _loc2_:MovieClip = null;
         var _loc1_:Array = this.tabs;
         this.m_tabControllers = new Array();
         for each(_loc2_ in _loc1_)
         {
            _loc2_.visible = false;
            _loc2_.mouseChildren = false;
            this.m_buttonSounds.addButton(_loc2_,ButtonSound.DEFAULT);
         }
      }
      
      private function initButtons() : void
      {
         this.page.up_mc.addEventListener(MouseEvent.CLICK,this.onSingleUp,false,0,true);
         this.page.down_mc.addEventListener(MouseEvent.CLICK,this.onSingleDown,false,0,true);
         this.page.pageUp_mc.addEventListener(MouseEvent.CLICK,this.onPageUp,false,0,true);
         this.page.pageDown_mc.addEventListener(MouseEvent.CLICK,this.onPageDown,false,0,true);
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit,false,0,true);
         this.m_buttonSounds.addButton(this.page.up_mc,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.page.down_mc,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.page.pageUp_mc,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.page.pageDown_mc,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.screen.exit_bt,ButtonSound.DEFAULT);
      }
      
      private function disposeBoards() : void
      {
         var _loc2_:Board = null;
         var _loc1_:Array = this.allBars;
         for each(_loc2_ in this.m_boards)
         {
            _loc2_.dispose(_loc1_);
         }
         this.m_boards = null;
      }
      
      private function disposeTabs() : void
      {
         var _loc1_:TabController = null;
         for each(_loc1_ in this.m_tabControllers)
         {
            _loc1_.dispose();
         }
         this.m_tabControllers = null;
      }
      
      private function deinitButtons() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         this.page.up_mc.removeEventListener(MouseEvent.CLICK,this.onSingleUp);
         this.page.down_mc.removeEventListener(MouseEvent.CLICK,this.onSingleDown);
         this.page.pageUp_mc.removeEventListener(MouseEvent.CLICK,this.onPageUp);
         this.page.pageDown_mc.removeEventListener(MouseEvent.CLICK,this.onPageDown);
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
      }
      
      private function get tabs() : Array
      {
         return [this.screen.tab1_mc,this.screen.tab2_mc,this.screen.tab3_mc,this.screen.tab4_mc,this.screen.tab5_mc,this.screen.tab6_mc,this.screen.tab7_mc,this.screen.tab8_mc,this.screen.tab9_mc];
      }
      
      private function initTab(param1:MovieClip, param2:int, param3:Board) : void
      {
         var _loc5_:String = null;
         var _loc7_:ImageLoader = null;
         var _loc8_:Number = NaN;
         param1.visible = true;
         var _loc4_:Array = ["ore_mc","damage_mc","campaign_mc","raven_mc","molten_mc","wood_mc","coin_mc","blueprint_mc","oil_mc","blackHeart_mc","redHeart_mc","tombstone_mc","star_mc","target_mc","glance_mc","expansion_mc","blitzDamage_mc","wrench_mc","hoe_mc","element_mc","skull_mc","powerup_mc","survivalMode_mc","mastery_mc","tycoon_mc","spender_mc","dominance_mc","survival_mc"];
         for each(_loc5_ in _loc4_)
         {
            param1[_loc5_].visible = false;
            ZGameUtils.hideIfExists(param1.tab_icon_container);
         }
         if(Boolean(param1.tab_icon_container) && Boolean(param3.tabIcon))
         {
            ZGameUtils.showIfExists(param1.tab_icon_container);
            _loc7_ = ImageLoaderFactory.CreateImageLoader(ZConfig.ASSET_BASE_PATH + param3.tabIcon,param1.tab_icon_container.icon_mc);
            _loc7_.smooth = true;
            this.m_imageLoaders.push(_loc7_);
         }
         else if(Boolean(param3.icon) && Boolean(param1[param3.icon]))
         {
            param1[param3.icon].visible = true;
            if(this.m_autoSurvivalVariant > 2 && (param3.icon == "survivalMode_mc" || param3.icon == "survival_mc"))
            {
               _loc8_ = SurvivalModeManager.instance.hudIconNumber + 2;
               param1[param3.icon].gotoAndStop(_loc8_);
            }
         }
         var _loc6_:TabController = new TabController(param1,param2,param3.title,this.onTabClicked,this.m_tabControllers,param3.leaderboard.type);
         param1.badge_mc.visible = false;
      }
      
      private function onRewardCollected(param1:Event) : void
      {
         this.updateTabSunbursts();
      }
      
      private function onMenuClicked(param1:FriendBarSlotEvent) : void
      {
         close();
      }
      
      private function updateTabSunbursts() : void
      {
         var _loc3_:Board = null;
         var _loc4_:MovieClip = null;
         var _loc1_:uint = 0;
         var _loc2_:Array = this.tabs;
         for each(_loc3_ in this.m_boards)
         {
            _loc4_ = _loc2_[_loc1_];
            if(_loc3_.rewardToCollect)
            {
               _loc4_.starburst_mc.visible = true;
               _loc4_.starburst_mc.gotoAndPlay(1);
            }
            else
            {
               _loc4_.starburst_mc.visible = false;
               _loc4_.starburst_mc.gotoAndStop(1);
            }
            _loc1_++;
         }
      }
      
      private function onInitcomplete(param1:Event) : void
      {
         var _loc6_:String = null;
         var _loc7_:Leaderboard = null;
         var _loc8_:Board = null;
         LeaderboardManager.instance.removeEventListener(Event.COMPLETE,this.onInitcomplete);
         this.m_boards = new Array();
         LeaderboardManager.instance.showCompletedLeaderboards();
         var _loc2_:Array = this.tabs;
         var _loc3_:uint = 0;
         var _loc4_:Array = LeaderboardManager.instance.getOrderedIDs();
         var _loc5_:Dictionary = LeaderboardManager.instance.leaderboards;
         for each(_loc6_ in _loc4_)
         {
            _loc7_ = _loc5_[_loc6_];
            if(_loc7_.isVisible(false))
            {
               _loc8_ = Board.createBoard(_loc7_,true);
               this.m_boards.push(_loc8_);
               this.initTab(_loc2_[_loc3_],_loc3_,_loc8_);
               _loc3_++;
            }
         }
         while(_loc3_ < _loc2_.length)
         {
            _loc2_[_loc3_].visible = false;
            _loc3_++;
         }
         this.updateTabSunbursts();
         this.page.scroll_mc.visible = true;
         if(this.m_openToBoardId)
         {
            (this.m_tabControllers[Math.max(0,this.m_boards.indexOf(this.getBoardFromId(this.m_openToBoardId)))] as TabController).selectTab();
            this.m_openToBoardId = null;
         }
         else
         {
            this.switchTo(0);
         }
      }
      
      private function updateTitleTrophies() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(Boolean(this.screen.trophy0) && Boolean(this.screen.trophy1))
         {
            _loc1_ = this.screen.title_tf.textWidth * 0.5;
            _loc2_ = this.screen.x + contentWidth * 0.5;
            this.screen.trophy0.x = _loc2_ - _loc1_ - this.screen.trophy0.width * 0.25;
            this.screen.trophy1.x = _loc2_ + _loc1_ + this.screen.trophy1.width * 0.25;
         }
      }
   }
}

