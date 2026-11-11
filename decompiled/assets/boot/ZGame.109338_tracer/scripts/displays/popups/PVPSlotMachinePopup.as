package displays.popups
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.PVPManager;
   import core.managers.WorldResourceManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.Tooltip;
   import core.ui.ZGameButton;
   import dispatchers.MessageDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import sound.SoundEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   import zlabs.sound.ISoundHandle;
   import zlabs.sound.SoundManager;
   
   public class PVPSlotMachinePopup extends GallantPopup
   {
      
      private static var SPIN_STATE_IDLE:uint = 0;
      
      private static var SPIN_STATE_SPINNING:uint = 1;
      
      private static var SPIN_STATE_SPINDOWN:uint = 2;
      
      private static var LOOPSOUND_URL:String = "assets/sound/ui/Sounds_UI_GPVP.swf";
      
      private static var LOOPSOUND_CLASSNAME:String = "GlobalPvp_SlotMachine_4.mp3";
      
      private static var REWARDFEATUREDSOUND_CLASSNAME:String = "GlobalPvp_SlotMachine_7.mp3";
      
      private static var REWARDNORMALSOUND_CLASSNAME:String = "GlobalPvp_SlotMachine_8.mp3";
      
      private static var SPINLOOP_VOLUME_TWEEN_SECS:Number = 4;
      
      private static var SPINLOOP_COUNT:int = 99999;
      
      private static var EXITBUTTON_REENABLE_DELAY_MS:int = 2000;
      
      private static var SPIN_CATEGORY:String = "slotMachineSpin";
      
      private static var REWARD_CATEGORY:String = "slotMachineReward";
      
      private static var REWARDMARQUEE_ANIM_OVER:String = "rewardMarqueeAnimOver";
      
      private var m_spinSoundClass:Class;
      
      private var m_rewardFeaturedClass:Class;
      
      private var m_rewardNormalClass:Class;
      
      private var m_mouseOverSpinButton:Boolean;
      
      private var m_buyButton:ZGameButton;
      
      private var m_spinButton:ZGameButton;
      
      private var m_shareButton:ZGameButton;
      
      private var m_spinResults:Object;
      
      private var m_spinTotalFrames:uint;
      
      private var m_iconLoaders:Array;
      
      private var m_fixedIconLoaders:Array = new Array();
      
      private var m_spinState:uint = SPIN_STATE_IDLE;
      
      private var m_tokenImageLoader:ImageLoader;
      
      private var m_grandPrizeLoader:ImageLoader;
      
      private var m_prizeRewardedLoader:ImageLoader;
      
      private var m_grandPrize:String;
      
      private var m_buySpinButtonOn:Boolean = false;
      
      private var m_sharePanelOpen:Boolean = false;
      
      private var m_awardClaimed:Boolean = false;
      
      private var m_feedItemName:String = null;
      
      public function PVPSlotMachinePopup()
      {
         var _loc1_:String = ZGlobal.getAssetURL(LOOPSOUND_URL);
         if(Zlab.resourceManager.validUrl(_loc1_))
         {
            Zlab.resourceManager.load(_loc1_,SWFResource,this.onSoundsLoaded);
         }
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_SlotMachine.swf"));
      }
      
      private function get mc() : MovieClip
      {
         return m_window.slotMachine_mc;
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.contentWidth = this.mc.background_mc.width;
         this.contentHeight = this.mc.background_mc.height;
         ZGameUtils.hideIfExists(this.mc.background_mc);
         centerWithinStage(Zlab.mainStage);
         this.mc.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         var _loc1_:uint = PVPManager.spinPurchaseKeyCost;
         TextFieldUtil.processTextField(this.mc.title_tf,ZGameUtils.ZlocT("Dialogs","GlobalPVPSlotMachineDialogSpinTitle"));
         TextFieldUtil.processTextField(this.mc.message_tf,ZGameUtils.ZlocT("Dialogs","GlobalPVPSlotMachineDialogSpinMessage",{"amount":_loc1_}));
         this.mc.win_mc.visible = false;
         this.initSpinButton();
         this.initBuySpinButton();
         this.initShareButton();
         this.updateTokenCounter();
         PVPManager.instance.addEventListener(PVPManager.SPIN_RESULTS,this.onSpinResult,false,0,true);
         SoundEvent.getSoundEvent("GPVPSlotMachineOpen").play();
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","GlobalPVPSlotMachineTokensTooltip");
         Tooltip.subscribe(this.mc.tokens_mc,_loc2_,{"offsetY":-25});
         this.doFadeIn();
         this.m_shareButton.disable_visual();
      }
      
      override protected function deinitDialog() : void
      {
         this.mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.exitButtonClicked);
         if(this.m_spinButton)
         {
            this.m_spinButton.dispose();
            this.m_spinButton = null;
         }
         if(this.m_buyButton)
         {
            this.m_buyButton.dispose();
            this.m_buyButton = null;
         }
         if(this.m_shareButton)
         {
            this.m_shareButton.dispose();
            this.m_shareButton = null;
         }
         if(this.m_grandPrizeLoader)
         {
            this.m_grandPrizeLoader.destroy();
            this.m_grandPrizeLoader = null;
         }
         if(this.m_prizeRewardedLoader)
         {
            this.m_prizeRewardedLoader.destroy();
            this.m_prizeRewardedLoader = null;
         }
         if(this.m_tokenImageLoader)
         {
            this.m_tokenImageLoader.destroy();
            this.m_tokenImageLoader = null;
         }
         PVPManager.instance.removeEventListener(PVPManager.SPIN_RESULTS,this.onSpinResult);
         Tooltip.unsubscribe(this.mc.tokens_mc);
         super.deinitDialog();
      }
      
      private function doFadeIn() : void
      {
         m_window.gotoAndStop(1);
         this.mc.gotoAndStop(1);
         m_window.gotoAndPlay(1);
         this.mc.slot1.gotoAndStop("_start");
      }
      
      private function shareFadeIn() : void
      {
         SoundEvent.getSoundEvent("GPVPSlotMachineSidePaneOpen").play();
         this.mc.gotoAndPlay("_share");
         this.m_shareButton.enable();
         this.m_sharePanelOpen = true;
      }
      
      private function shareFadeOut() : void
      {
         if(this.m_sharePanelOpen)
         {
            this.mc.gotoAndPlay("_shareHide");
            this.m_shareButton.disable_visual();
            this.m_sharePanelOpen = false;
            this.mc.slot1.gotoAndPlay("_reset");
         }
      }
      
      private function initButton(param1:MovieClip, param2:String = "", param3:Function = null) : ZGameButton
      {
         var _loc4_:ZGameButton = new ZGameButton(param1,param3,1.1,true);
         _loc4_.compactText(param2,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         _loc4_.show();
         _loc4_.enable();
         return _loc4_;
      }
      
      private function initBuySpinButton() : void
      {
         var _loc1_:uint = PVPManager.spinPurchaseCost;
         var _loc2_:Object = {"amount":_loc1_};
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","GlobalPVPBuySpinButton",_loc2_);
         this.m_buyButton = this.initButton(this.mc.spinBtns_mc.buy_bt,_loc3_,this.onBuyButtonClicked);
         this.mc.spinBtns_mc.buy_bt.notice_tf.visible = false;
         TextFieldUtil.processTextField(this.mc.spinBtns_mc.buy_bt.value_tf,_loc1_.toString());
      }
      
      private function initSpinButton() : void
      {
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","GlobalPVPSlotMachineDialogSpin");
         this.m_spinButton = this.initButton(this.mc.spinBtns_mc.spin_bt,_loc1_,this.spinButtonClicked);
      }
      
      private function initShareButton() : void
      {
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","Share");
         this.m_shareButton = this.initButton(this.mc.share_mc.buy_bt,_loc1_,this.shareButtonClicked);
      }
      
      private function setShareText(param1:String) : void
      {
         TextFieldUtil.processTextField(this.mc.share_mc.info_tf,param1);
      }
      
      private function updateTokenCounter() : void
      {
         var _loc1_:int = int(ZGlobal.player.inventory["GPTK"]);
         var _loc2_:String = "x" + _loc1_.toString();
         TextFieldUtil.processTextField(this.mc.spinBtns_mc.spin_bt.cost_tf,_loc2_);
         var _loc3_:int = int(PVPManager.spinPurchaseKeyCost);
         if(_loc3_ > _loc1_ && !this.m_buySpinButtonOn)
         {
            SoundEvent.getSoundEvent("GPVPSlotMachineButtonReset").play();
            this.mc.spinBtns_mc.gotoAndPlay("_switch");
            this.m_buySpinButtonOn = true;
         }
         else if(_loc3_ <= _loc1_)
         {
            this.mc.spinBtns_mc.gotoAndStop(1);
            this.m_buySpinButtonOn = false;
         }
      }
      
      override protected function close(param1:Event = null) : void
      {
         this.endSoundByCategory(SPIN_CATEGORY);
         this.endSoundByCategory(REWARD_CATEGORY);
         this.mc.marquee.removeEventListener(REWARDMARQUEE_ANIM_OVER,this.onRewardMarqueeAnimOver);
         if(this.m_awardClaimed)
         {
            PVPManager.instance.awardClaimed();
         }
         super.close(param1);
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         this.close();
      }
      
      private function onBuyButtonClicked(param1:MouseEvent) : void
      {
         this.startSpin(PVPManager.REWARD_SPIN_MODE_BUY);
      }
      
      private function spinButtonClicked(param1:MouseEvent) : void
      {
         this.startSpin(PVPManager.REWARD_SPIN_MODE_KEYS);
      }
      
      private function startSpin(param1:uint) : void
      {
         if(this.m_spinState == SPIN_STATE_IDLE)
         {
            this.shareFadeOut();
            this.m_spinResults = null;
            if(PVPManager.instance.slotMachineSpin(param1))
            {
               this.setSpinning(true);
               this.updateTokenCounter();
               this.mc.exit_bt.enabled = false;
               this.mc.exit_bt.mouseEnabled = false;
               this.mc.exit_bt.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            }
         }
      }
      
      private function shareButtonClicked(param1:MouseEvent) : void
      {
         ViralsManager.instance.sendFeed("g_pvp_spin_win",{"item":this.m_feedItemName});
         this.shareFadeOut();
      }
      
      private function onSpinResult(param1:WorldEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:GameItem = null;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         SoundEvent.getSoundEvent("GPVPSlotMachineSpinEnd").play();
         this.endSoundByCategory(SPIN_CATEGORY);
         if(this.m_prizeRewardedLoader)
         {
            this.m_prizeRewardedLoader.destroy();
            this.m_prizeRewardedLoader = null;
         }
         this.m_spinResults = param1.eventData;
         this.m_spinButton.enable();
         this.m_buyButton.enable();
         this.mc.exit_bt.enabled = true;
         this.mc.exit_bt.mouseEnabled = true;
         this.mc.exit_bt.filters = null;
         this.m_spinState = SPIN_STATE_IDLE;
         if(this.m_spinResults.loot)
         {
            _loc2_ = "";
            TextFieldUtil.processTextField(this.mc.slot1.icon.num_tf,"x1");
            if(this.m_spinResults.loot.handler == "addLootToInventory")
            {
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.ITEM_GIFT,this.m_spinResults.loot.payload));
               this.m_prizeRewardedLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_spinResults.loot.loot,"icon"),this.mc.slot1.icon.icon);
               _loc3_ = ZGlobal.gameSettings.getItemByCode(this.m_spinResults.loot.payload.code,GameItem) as GameItem;
               this.m_feedItemName = _loc3_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME);
               _loc2_ = ZGameUtils.ZlocT("Dialogs","GlobalPVPSlotMachineDialogShareItemMessage",{"item":this.m_feedItemName});
            }
            else if(this.m_spinResults.loot.handler == "awardResources")
            {
               _loc4_ = new Object();
               MessageDispatcher.instance.dispatchEvent(new WorldEvent(MessageDispatcher.RESOURCE_GIFT,this.m_spinResults.loot.payload));
               this.m_prizeRewardedLoader = ImageLoaderFactory.CreateImageLoader(WorldResourceManager.instance.getResourceImageURLByType(this.m_spinResults.loot.loot,WorldResourceManager.XTRA_LARGE_ICON),this.mc.slot1.icon.icon);
               if(this.m_spinResults.loot.payload.yield)
               {
                  _loc5_ = "x" + String(this.m_spinResults.loot.payload.yield);
                  TextFieldUtil.processTextField(this.mc.slot1.icon.num_tf,_loc5_);
               }
               this.m_feedItemName = WorldResourceManager.instance.getResourceFriendlyNameFromType(this.m_spinResults.loot.payload.name,GameItem.SENTENCE_FRIENDLYNAME,true);
               _loc2_ = ZGameUtils.ZlocT("Dialogs","GlobalPVPSlotMachineDialogShareResourceMessage",{
                  "item":this.m_feedItemName,
                  "amount":this.m_spinResults.loot.payload.yield
               });
            }
            TextFieldUtil.processTextField(this.mc.slot1.icon.item_tf,this.m_feedItemName.toLocaleUpperCase());
            this.setShareText(_loc2_);
         }
         this.m_awardClaimed = true;
         this.mc.slot1.gotoAndPlay("_reveal");
         if(this.m_spinResults.loot.loot == this.m_grandPrize)
         {
            this.playGrandPrizeWinAnimation();
         }
         else
         {
            this.playWinAnimation();
         }
         this.shareFadeIn();
      }
      
      private function playWinAnimation() : void
      {
         this.startSound(this.m_rewardNormalClass,REWARD_CATEGORY);
         this.mc.marquee.addEventListener(REWARDMARQUEE_ANIM_OVER,this.onRewardMarqueeAnimOver,false,0,true);
         this.mc.marquee.gotoAndPlay("_win2");
         this.mc.win_mc.visible = true;
         this.mc.win_mc.gotoAndPlay("_show");
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","GlobalPVPSlotMachineYouWon");
         TextFieldUtil.processTextField(this.mc.win_mc.text_mc1.generic_tf,_loc1_);
         TextFieldUtil.processTextField(this.mc.win_mc.text_mc2.generic_tf,_loc1_);
         TextFieldUtil.processTextField(this.mc.win_mc.text_mc3.generic_tf,_loc1_);
      }
      
      private function playGrandPrizeWinAnimation() : void
      {
         this.startSound(this.m_rewardFeaturedClass,REWARD_CATEGORY);
         this.mc.marquee.addEventListener(REWARDMARQUEE_ANIM_OVER,this.onRewardMarqueeAnimOver,false,0,true);
         this.mc.marquee.gotoAndPlay("_win1");
         this.mc.win_mc.visible = true;
         this.mc.win_mc.gotoAndPlay("_show");
      }
      
      private function onRewardMarqueeAnimOver(param1:Event) : void
      {
         this.mc.marquee.removeEventListener(REWARDMARQUEE_ANIM_OVER,this.onRewardMarqueeAnimOver);
         this.endSoundByCategory(REWARD_CATEGORY);
      }
      
      private function setStripsAnimating(param1:Boolean) : void
      {
         if(param1)
         {
            this.mc.slot1.gotoAndPlay("_start");
         }
      }
      
      private function startSpinSoundLoop() : void
      {
         this.startSound(this.m_spinSoundClass,SPIN_CATEGORY,SPINLOOP_VOLUME_TWEEN_SECS);
      }
      
      private function endSoundByCategory(param1:String) : void
      {
         var _loc2_:SoundManager = Zlab.soundManager as SoundManager;
         if(_loc2_)
         {
            _loc2_.stopCategorySounds(param1);
         }
      }
      
      private function onSoundsLoaded(param1:SWFResource) : void
      {
         this.m_spinSoundClass = param1.getAssetClass(LOOPSOUND_CLASSNAME);
         this.m_rewardFeaturedClass = param1.getAssetClass(REWARDFEATUREDSOUND_CLASSNAME);
         this.m_rewardNormalClass = param1.getAssetClass(REWARDNORMALSOUND_CLASSNAME);
      }
      
      private function setSpinning(param1:Boolean) : void
      {
         var _loc2_:String = null;
         if(param1)
         {
            this.m_spinState = SPIN_STATE_SPINNING;
            _loc2_ = this.m_awardClaimed ? "GPVPSlotMachineSpinReset" : "GPVPSlotMachineSpinStart";
            SoundEvent.getSoundEvent(_loc2_).play();
            this.startSpinSoundLoop();
         }
         this.setStripsAnimating(this.m_spinState > 0);
      }
      
      private function get soundMuted() : Boolean
      {
         var _loc1_:SoundManager = Zlab.soundManager as SoundManager;
         return !_loc1_ || _loc1_.getCategoryMuted(SoundManager.SFX_MIXER_CATEGORY);
      }
      
      private function startSound(param1:Class, param2:String, param3:Number = -1) : void
      {
         var _loc4_:SoundManager = null;
         var _loc5_:ISoundHandle = null;
         if(!this.soundMuted && Boolean(param1))
         {
            _loc4_ = Zlab.soundManager as SoundManager;
            _loc5_ = _loc4_.play(new param1(),null,param2,0,SPINLOOP_COUNT);
            if(param3 > 0)
            {
               _loc5_.volume = 0;
               TweenLite.to(_loc5_,param3,{"volume":1});
            }
         }
      }
   }
}

