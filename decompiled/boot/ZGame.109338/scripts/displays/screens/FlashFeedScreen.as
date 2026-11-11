package displays.screens
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.FlashFeedManager;
   import core.ui.ZGameButton;
   import displays.popups.AlarmCountdownClock;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class FlashFeedScreen extends GallantPopup
   {
      
      private static var m_instanceExists:Boolean = false;
      
      private var m_cards:Array;
      
      private var m_title:String;
      
      private var m_description:String;
      
      private var m_instructions:String;
      
      private var m_token_name:String;
      
      private var m_timeLeft:String;
      
      private var m_askForMoreButton:ZGameButton;
      
      private var m_tokens:int;
      
      private var m_items:Array;
      
      private var m_clock:AlarmCountdownClock;
      
      private var m_expireDateInSec:int;
      
      public var m_clockMc:MovieClip;
      
      public function FlashFeedScreen(param1:int, param2:Array, param3:Date)
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_FlashFeeds.swf"));
         this.m_tokens = param1;
         this.m_items = param2;
         this.m_expireDateInSec = Math.round(param3.getTime() / 1000);
         m_instanceExists = true;
         this.m_title = ZGameUtils.ZlocT("Dialogs","FlashFeed_Title");
         this.m_description = ZGameUtils.ZlocT("Dialogs","FlashFeed_Description");
         this.m_instructions = ZGameUtils.ZlocT("Dialogs","FlashFeed_Instructions");
         this.m_token_name = ZGameUtils.ZlocT("Dialogs","FlashFeed_TokenName");
         this.m_timeLeft = ZGameUtils.ZlocT("Dialogs","GlobalPVPStrangerBarTimeLeft");
      }
      
      private function get mc() : MovieClip
      {
         return m_window.flashfeeds_mc;
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         TextFieldUtil.compactTextField(this.mc.title_tf,this.m_title);
         TextFieldUtil.compactTextField(this.mc.description_tf,this.m_description);
         TextFieldUtil.compactTextField(this.mc.instructions_tf,this.m_instructions);
         TextFieldUtil.compactTextField(this.mc.tokensHeader_tf,this.m_token_name);
         TextFieldUtil.compactTextField(this.mc.time_tf,this.m_timeLeft);
         this.showTokenCount(this.m_tokens);
         this.m_clockMc = this.mc.clock_mc;
         this.m_clock = this.createCountdownClock();
         this.m_askForMoreButton = new ZGameButton(this.mc.buyAll_bt,this.onClickAskForMore,1.1,true);
         this.m_askForMoreButton.show();
         var _loc1_:Number = FlashFeedManager.getInstance().postToWallResetTime();
         if(_loc1_ > 0)
         {
            this.disableAskForTokensButton();
         }
         else
         {
            this.enableAskForTokensButton();
         }
         this.mc.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         this.createCards();
         this.updateCards();
         StatsManager.count("dialog","dialog_flashfeeds","view");
      }
      
      private function showTokenCount(param1:int) : void
      {
         var _loc2_:String = "x" + param1.toString();
         TextFieldUtil.compactTextField(this.mc.tokens_tf,_loc2_);
      }
      
      private function enableAskForTokensButton() : void
      {
         this.m_askForMoreButton.text = ZGameUtils.ZlocT("Dialogs","FlashFeed_AskMore_Button");
         this.m_askForMoreButton.enable();
      }
      
      private function disableAskForTokensButton() : void
      {
         this.m_askForMoreButton.disable_visual();
         this.onUpdateAskForTokensButton();
      }
      
      private function onUpdateAskForTokensButton() : void
      {
         var _loc2_:String = null;
         var _loc1_:Number = FlashFeedManager.getInstance().postToWallResetTime();
         if(_loc1_ > 0)
         {
            _loc2_ = this.getAskForButtonMessage();
            this.m_askForMoreButton.text = this.getAskForButtonMessage();
            Zlab.processManager.schedule(1000,this,this.onUpdateAskForTokensButton);
         }
         else
         {
            dispatchEvent(new Event(FlashFeedManager.ASK_FOR_TOKENS_TIMER_EXPIRED));
            this.enableAskForTokensButton();
         }
      }
      
      private function getAskForButtonMessage() : String
      {
         var _loc1_:Number = FlashFeedManager.getInstance().postToWallResetTime();
         return ZGameUtils.ZlocT("Dialogs","FlashFeed_AskForMore_Button_Disabled",{"time":ZGameTimeUtil.instance.getClockString(_loc1_)});
      }
      
      private function createCountdownClock() : AlarmCountdownClock
      {
         return new AlarmCountdownClock(this.m_clockMc,this.m_expireDateInSec);
      }
      
      private function createCards() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Object = null;
         var _loc3_:FlashFeedItemCard = null;
         this.m_cards = new Array();
         for(_loc1_ in this.m_items)
         {
            if(_loc1_ != null)
            {
               _loc2_ = this.m_items[_loc1_];
               _loc3_ = new FlashFeedItemCard(_loc2_,this.onItemSelected);
               _loc3_.sounds = ButtonSound.DEFAULT;
               this.m_cards.push(_loc3_);
            }
         }
      }
      
      private function updateCards() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         var _loc1_:int = 0;
         while(_loc1_ < this.m_cards.length)
         {
            _loc2_ = _loc1_ + 1;
            _loc3_ = true;
            if(this.m_items[_loc1_].tokens > this.m_tokens)
            {
               _loc3_ = false;
            }
            this.m_cards[_loc1_].setCard(this.mc.slots_mc["card_mc_" + _loc2_],_loc3_);
            _loc1_++;
         }
      }
      
      private function onClickAskForMore(param1:MouseEvent) : void
      {
         var _loc2_:int = ExperimentsManager.instance.getExperimentVariant(FlashFeedManager.EXPERIMENT_FLASHFEED_NEW);
         if(_loc2_ == FlashFeedManager.VARIANT_FLASH_FEED)
         {
            FlashFeedManager.getInstance().postFlashFeedToWall();
         }
         else if(_loc2_ == FlashFeedManager.VARIANT_FLASH_REQUEST)
         {
            close();
            FlashFeedManager.getInstance().sendFlashRequest();
         }
         this.disableAskForTokensButton();
         dispatchEvent(new Event(FlashFeedManager.ASK_FOR_TOKENS_TIMER_STARTED));
      }
      
      private function onItemSelected() : void
      {
         this.showTokenCount(ZGlobal.player.inventory[FlashFeedManager.getInstance().getItemCode()]);
         close();
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         StatsManager.count("dialog","dialog_flashfeeds","close");
         close();
      }
   }
}

