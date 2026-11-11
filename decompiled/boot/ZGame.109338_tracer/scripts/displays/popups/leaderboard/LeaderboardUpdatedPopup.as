package displays.popups.leaderboard
{
   import com.greensock.TweenLite;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.managers.leaderboardManager.Leaderboard;
   import core.managers.leaderboardManager.LeaderboardManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import core.ui.ZGameButton;
   import displays.screens.leaderboard.Board;
   import displays.screens.leaderboard.PopupBoard;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.ZGameUtils;
   import zlabs.ZGameBase;
   import zlabs.Zlab;
   import zlabs.core.InputManager;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class LeaderboardUpdatedPopup extends Sprite
   {
      
      public static var ACTIVE:Boolean = false;
      
      private static var ACCEPT_LAST_MINUTE_CHANGE:Boolean = true;
      
      private var WIDTH:int = 393;
      
      private var HEIGHT:int = 237;
      
      private var m_shareButton:ZGameButton = null;
      
      private var m_skipButton:ZGameButton = null;
      
      private var m_window:MovieClip = null;
      
      private var m_board:Board = null;
      
      private var m_leaderboard:Leaderboard = null;
      
      private var m_animName:String = null;
      
      private var m_uidPassed:String = null;
      
      private var m_index:int = 0;
      
      private var m_shareClicked:Boolean = false;
      
      private var m_mouseOver:Boolean = false;
      
      private var m_passedPlayer:Boolean = false;
      
      private var m_resourceLoaded:Boolean = false;
      
      public function LeaderboardUpdatedPopup(param1:Leaderboard, param2:int, param3:Boolean = false)
      {
         super();
         this.m_leaderboard = param1;
         this.m_index = param2;
         this.m_passedPlayer = param3;
         this.m_board = new PopupBoard(this.m_leaderboard);
         ACTIVE = true;
         Zlab.resourceManager.load(ZGlobal.getAssetURL("assets/displays/screens/PU_Leaderboard2.swf"),SWFResource,this.onLoadComplete,this.onLoadFail);
      }
      
      public function attemptLastMinuteChange(param1:Leaderboard, param2:int, param3:Boolean = false) : void
      {
         if(ACTIVE && ACCEPT_LAST_MINUTE_CHANGE && this.m_leaderboard == param1)
         {
            this.m_index = param2;
            this.m_passedPlayer = param3;
            if(this.m_resourceLoaded)
            {
               this.screen.passingAnim_mc.gotoAndStop(1);
               this.populateBars();
            }
         }
      }
      
      protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_resourceLoaded = true;
         this.m_window = param1.clip;
         this.m_window.standings_mc.visible = false;
         this.m_window.upgrade_mc.visible = false;
         this.m_window.complete_mc.visible = false;
         this.m_window.popup_mc.visible = true;
         addChild(this.m_window);
         scaleX = scaleY = 0.75;
         this.WIDTH *= scaleX;
         this.HEIGHT *= scaleY;
         var _loc2_:Number = LeaderboardManager.instance.uiOffset;
         y = -this.HEIGHT;
         x = _loc2_ >= 0 ? _loc2_ + 10 : (Zlab.mainStage.stageWidth - this.WIDTH) / 2;
         ZGameBase.layerPopUp.addChild(this);
         this.screen.passingAnim_mc.gotoAndStop(1);
         addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         this.populateBars();
         var _loc3_:Number = ZGlobal.gameSettings.getSeconds("leaderboardUpdateSlideTime",0.75);
         TweenLite.to(this,_loc3_,{
            "y":0,
            "onComplete":this.firstDelay
         });
      }
      
      protected function onLoadFail(param1:SWFResource) : void
      {
         this.dispose();
      }
      
      private function firstDelay() : void
      {
         ACCEPT_LAST_MINUTE_CHANGE = false;
         var _loc1_:Number = ZGlobal.gameSettings.getSeconds("leaderboardUpdatePreAnimDelay",0.75);
         Zlab.processManager.schedule(_loc1_ * 1000,this,this.pause);
      }
      
      private function pause() : void
      {
         var _loc1_:Number = ZGlobal.gameSettings.getSeconds("leaderboardUpdateShowTime",3);
         Zlab.processManager.schedule(_loc1_ * 1000,this,this.pauseEnd);
         this.screen.passingAnim_mc.gotoAndPlay(this.m_animName);
      }
      
      private function pauseEnd() : void
      {
         TweenLite.killTweensOf(this);
         var _loc1_:Number = ZGlobal.gameSettings.getSeconds("leaderboardUpdateSlideTime",0.75);
         TweenLite.to(this,_loc1_,{
            "y":-this.HEIGHT,
            "onComplete":this.dispose
         });
      }
      
      protected function get screen() : MovieClip
      {
         return this.m_window.popup_mc;
      }
      
      private function dispose() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         TweenLite.killTweensOf(this);
         removeEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         this.onMouseOut(null);
         if(this.m_window)
         {
            removeChild(this.m_window);
            this.m_window = null;
            ZGameBase.layerPopUp.removeChild(this);
         }
         if(this.m_shareButton)
         {
            this.m_shareButton.dispose();
            this.m_shareButton = null;
         }
         if(this.m_skipButton)
         {
            this.m_skipButton.dispose();
            this.m_skipButton = null;
         }
         ACTIVE = false;
         ACCEPT_LAST_MINUTE_CHANGE = true;
         dispatchEvent(new Event(Event.CLOSE));
      }
      
      private function get bars() : Array
      {
         return [this.screen.passingAnim_mc.bar1_mc,this.screen.passingAnim_mc.bar2_mc,this.screen.passingAnim_mc.bar3_mc];
      }
      
      private function populateBars() : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:Array = null;
         var _loc7_:int = 0;
         var _loc1_:Array = null;
         if(this.m_index == 0)
         {
            _loc1_ = [this.screen.passingAnim_mc.bar1_mc,this.screen.passingAnim_mc.bar3_mc,this.screen.passingAnim_mc.bar2_mc];
         }
         else
         {
            _loc1_ = this.bars;
         }
         this.m_board.beginPopulation(_loc1_);
         var _loc2_:int = int(_loc1_.length);
         for each(_loc3_ in _loc1_)
         {
            _loc3_.visible = false;
         }
         _loc4_ = new Array();
         if(this.m_index == 0)
         {
            _loc4_.push(this.m_index + 1);
            _loc4_.push(this.m_index);
            _loc4_.push(this.m_index + 2);
            this.m_animName = "pass1";
         }
         else
         {
            _loc4_.push(this.m_index - 1);
            _loc4_.push(this.m_index + 1);
            _loc4_.push(this.m_index);
            this.m_animName = "pass2";
         }
         this.m_shareButton = new ZGameButton(this.screen.green_btn,this.onShareButtonClicked);
         this.m_shareButton.text = ZGameUtils.ZlocT("Dialogs","Share");
         this.m_shareButton.hide();
         if(this.m_passedPlayer)
         {
            this.m_uidPassed = this.m_board.leaderboard.getNextPlayerId(this.m_index,1);
            this.m_shareButton.show();
         }
         this.m_skipButton = new ZGameButton(this.screen.orange_btn,this.onSkipButtonClicked);
         this.m_skipButton.text = ZGameUtils.ZlocT("Main","Skip");
         var _loc5_:int = this.m_index + 2;
         if(_loc4_.length < _loc1_.length && _loc5_ < this.m_board.numValues)
         {
            _loc4_.push(_loc5_);
         }
         this.screen.passingAnim_mc.gotoAndStop(this.m_animName);
         var _loc6_:int = 0;
         while(_loc6_ < _loc2_)
         {
            _loc1_[_loc6_].visible = true;
            _loc7_ = this.m_board.populateBar(_loc1_[_loc6_],_loc4_[_loc6_]);
            if(_loc7_ == Board.ERROR)
            {
               break;
            }
            _loc6_++;
         }
      }
      
      private function onShareButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:Player = null;
         if(Boolean(this.m_uidPassed) && !this.m_shareClicked)
         {
            _loc2_ = ZGlobal.player.findFriendById(this.m_uidPassed);
            if(Boolean(_loc2_) && _loc2_.uid != ZGlobal.player.uid)
            {
               this.m_shareClicked = true;
               ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
                  "counter":"dialog",
                  "kingdom":"lb_floating_dialog_passing",
                  "phylum":"share"
               }));
               ViralsManager.instance.sendFeed("LB_Passing",{
                  "user":ZGlobal.player.firstName,
                  "victim":_loc2_.firstName,
                  "title":this.m_board.title
               });
            }
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(!this.m_mouseOver)
         {
            InputManager.disableButtonInput();
            this.m_mouseOver = true;
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(this.m_mouseOver)
         {
            InputManager.enableButtonInput();
            this.m_mouseOver = false;
         }
      }
      
      private function onSkipButtonClicked(param1:MouseEvent) : void
      {
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
            "counter":"dialog",
            "kingdom":"lb_floating_dialog_passing",
            "phylum":"skip"
         }));
         this.pauseEnd();
      }
   }
}

