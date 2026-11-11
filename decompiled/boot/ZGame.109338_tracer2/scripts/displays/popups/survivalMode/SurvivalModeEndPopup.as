package displays.popups.survivalMode
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.RewardHelper;
   import core.gameobjects.UnitItem;
   import core.managers.WorldResourceManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   
   public class SurvivalModeEndPopup extends GallantPopup
   {
      
      public static const SURVIVALMODE_END_GAMEOVER:int = 0;
      
      public static const SURVIVALMODE_END_CONTINUE:int = 1;
      
      private static const CONTINUE_TIMER:int = 30;
      
      private var m_closeCallback:Function = null;
      
      private var m_shareButton:ZGameButton = null;
      
      private var m_continueButton:ZGameButton = null;
      
      private var m_counter:int = 0;
      
      private var m_timer:Timer;
      
      private var m_loaders:Array = null;
      
      private var m_round:int = 0;
      
      public function SurvivalModeEndPopup(param1:Function)
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_SurvivalModeEnd.swf"));
         this.m_closeCallback = param1;
      }
      
      private function get mc() : MovieClip
      {
         return m_window.end_mc;
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.m_loaders = new Array();
         this.m_counter = CONTINUE_TIMER;
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onCountdownUpdated);
         this.m_timer.start();
         this.contentWidth = this.mc.background_mc.width;
         this.contentHeight = this.mc.background_mc.height;
         ZGameUtils.hideIfExists(this.mc.background_mc);
         centerWithinStage(Zlab.mainStage);
         this.mc.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         this.m_round = SurvivalModeManager.instance.getCurrentRound();
         TextFieldUtil.processTextField(this.mc.title_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeEndTitle",{"wave":this.m_round}));
         TextFieldUtil.processTextField(this.mc.continue_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeEndContinue"));
         TextFieldUtil.processTextField(this.mc.countdown_mc.seconds_mc.countdown_tf,this.m_counter.toString());
         this.populateNextBonusWaveRewards();
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","Share");
         this.m_shareButton = new ZGameButton(this.mc.share_mc,this.onShareClicked,1.1,true);
         this.m_shareButton.compactText(_loc1_,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         this.m_shareButton.show();
         this.m_shareButton.enable();
         var _loc2_:int = SurvivalModeManager.continuePurchaseCost;
         _loc1_ = ZGameUtils.ZlocT("Dialogs","SurvivalModeEndContinueButton",{"amount":_loc2_});
         this.m_continueButton = new ZGameButton(this.mc.buy_mc,this.onContinueClicked,1.1,true);
         this.m_continueButton.compactText(_loc1_,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         this.m_continueButton.show();
         this.m_continueButton.enable();
         if(null != this.m_closeCallback)
         {
            addEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback,false,0,true);
         }
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         this.mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.exitButtonClicked);
         if(this.m_shareButton)
         {
            this.m_shareButton.dispose();
            this.m_shareButton = null;
         }
         if(this.m_continueButton)
         {
            this.m_continueButton.dispose();
            this.m_continueButton = null;
         }
         if(null != this.m_closeCallback)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
            this.m_closeCallback = null;
         }
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = null;
         this.stopCountdownTimer();
         super.deinitDialog();
      }
      
      private function stopCountdownTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.stop();
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.onCountdownUpdated);
         }
      }
      
      private function onCountdownUpdated(param1:Event = null) : void
      {
         --this.m_counter;
         TextFieldUtil.processTextField(this.mc.countdown_mc.seconds_mc.countdown_tf,this.m_counter.toString());
         if(this.m_counter == 0)
         {
            this.stopCountdownTimer();
            this.m_continueButton.disable_visual();
            TextFieldUtil.processTextField(this.mc.continue_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeEndGameOver"));
         }
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,SURVIVALMODE_END_GAMEOVER));
         close();
      }
      
      private function onShareClicked(param1:MouseEvent) : void
      {
         ViralsManager.instance.sendFeedWithLotsOfFriction("survival_mode_victory",{"wave":this.m_round},null);
         this.m_shareButton.disable_visual();
      }
      
      private function populateNextBonusWaveRewards() : void
      {
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:XML = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:RewardHelper = null;
         var _loc12_:UnitItem = null;
         var _loc13_:ImageLoader = null;
         var _loc1_:Object = SurvivalModeManager.instance.getNextBonusWaveRewards();
         var _loc2_:int = int(_loc1_.round);
         var _loc3_:XML = _loc1_.xml;
         TextFieldUtil.processTextField(this.mc.reward_tf,ZGameUtils.ZlocT("Dialogs","SurvivalModeEndNextWaveTitle",{"nextWave":_loc2_}));
         TextFieldUtil.processTextField(this.mc.body_tf,SurvivalModeManager.instance.isInBattle ? " " : ZGameUtils.ZlocT("Dialogs","SurvivalModeEndNewWaveBody",{"nextWave":_loc2_}));
         if(Boolean(_loc3_) && Boolean(_loc3_.reward))
         {
            _loc4_ = [this.mc.reward1_mc.questName_tf,this.mc.reward2_mc.questName_tf,this.mc.reward3_mc.questName_tf];
            _loc5_ = [this.mc.reward1_mc.icon,this.mc.reward2_mc.icon,this.mc.reward3_mc.icon];
            _loc6_ = new Object();
            _loc6_.rewardText = new Array();
            _loc6_.rewardIcons = new Array();
            _loc6_.rewardPairs = new Array();
            _loc7_ = 1;
            for each(_loc8_ in _loc3_.reward)
            {
               this.mc["reward" + _loc7_ + "_mc"].strength_mc.visible = false;
               _loc11_ = new RewardHelper(_loc8_);
               _loc11_.buildUI(_loc6_,WorldResourceManager.LARGE_ICON);
               _loc12_ = ZGlobal.gameSettings.getItemByCode(_loc8_.@item.toString(),UnitItem) as UnitItem;
               if(_loc12_)
               {
                  if(_loc12_.subType == GameItem.SUBTYPE_UNIT_ARMY || _loc12_.subType == GameItem.SUBTYPE_UNIT_AIR || _loc12_.subType == GameItem.SUBTYPE_UNIT_NAVY)
                  {
                     TextFieldUtil.compactTextField(this.mc["reward" + _loc7_ + "_mc"].strength_mc.strength_tf,String(_loc12_.getStrength(null)));
                     this.mc["reward" + _loc7_ + "_mc"].strength_mc.visible = true;
                  }
               }
               _loc7_++;
            }
            _loc9_ = Math.min(_loc5_.length,_loc6_.rewardText.length);
            _loc10_ = 0;
            while(_loc10_ < _loc9_)
            {
               _loc13_ = ImageLoaderFactory.CreateImageLoader(_loc6_.rewardIcons[_loc10_],_loc5_[_loc10_]);
               _loc13_.smooth = true;
               this.m_loaders.push(_loc13_);
               TextFieldUtil.compactTextField(_loc4_[_loc10_],ZGameUtils.ZlocT("Dialogs","WinRewardResult",{"reward":_loc6_.rewardText[_loc10_]}));
               _loc10_++;
            }
         }
      }
      
      private function onContinueClicked(param1:MouseEvent) : void
      {
         var _loc2_:int = SurvivalModeManager.continuePurchaseCost;
         if(!ZGlobal.player.canBuyCash(_loc2_))
         {
            return;
         }
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,SURVIVALMODE_END_CONTINUE));
         close();
      }
   }
}

