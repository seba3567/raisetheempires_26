package displays.popups
{
   import ZLocalization.LocaleFormatter;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.ExperimentsManager;
   import core.managers.TierSurfacingManager;
   import core.managers.TreasureVaultManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.screens.requests.RequestAskPartsDialog;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import sound.SoundEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import utils.getVisibleBounds;
   import zlabs.Zlab;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   import zlabs.sound.ISoundHandle;
   import zlabs.sound.SoundManager;
   
   public class TreasureVaultPopup extends GallantPopup
   {
      
      private static var SPIN_STATE_IDLE:uint = 0;
      
      private static var SPIN_STATE_SPINNING:uint = 1;
      
      private static var SPIN_STATE_REWARD:uint = 2;
      
      private static var LOOPSOUND_URL:String = "assets/sound/ui/Sounds_UI_GPVP.swf";
      
      private static var LOOPSOUND_CLASSNAME:String = "GlobalPvp_SlotMachine_4.mp3";
      
      private static var REWARDFEATUREDSOUND_CLASSNAME:String = "GlobalPvp_SlotMachine_7.mp3";
      
      private static var REWARDNORMALSOUND_CLASSNAME:String = "GlobalPvp_SlotMachine_8.mp3";
      
      private static var SPINLOOP_VOLUME_TWEEN_SECS:Number = 4;
      
      private static var SPINLOOP_COUNT:int = 99999;
      
      private static var SPIN_CATEGORY:String = "slotMachineSpin";
      
      private static var REWARD_CATEGORY:String = "slotMachineReward";
      
      private var m_spinSoundClass:Class;
      
      private var m_rewardFeaturedClass:Class;
      
      private var m_rewardNormalClass:Class;
      
      private var m_askButton:ZGameButton;
      
      private var m_buyButton:ZGameButton;
      
      private var m_spinButton:ZGameButton;
      
      private var m_spinResults:Object;
      
      private var m_iconLoaders:Array;
      
      private var m_spinState:uint = SPIN_STATE_IDLE;
      
      private var m_tierSelected:uint = 1;
      
      private var m_highestTierAvailable:uint = 0;
      
      private var m_timer:Timer;
      
      public function TreasureVaultPopup()
      {
         var _loc1_:String = ZGlobal.getAssetURL(LOOPSOUND_URL);
         if(Zlab.resourceManager.validUrl(_loc1_))
         {
            Zlab.resourceManager.load(_loc1_,SWFResource,this.onSoundsLoaded);
         }
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_TreasureVault_Browser.swf"));
      }
      
      private function get mc() : MovieClip
      {
         return m_window.vaultBrowser_mc;
      }
      
      private function getTierMc(param1:int) : MovieClip
      {
         switch(param1)
         {
            case 1:
               return this.mc.bronze_mc;
            case 2:
               return this.mc.silver_mc;
            case 3:
               return this.mc.gold_mc;
            case 4:
               return this.mc.platinum_mc;
            default:
               return null;
         }
      }
      
      private function getTierGraphicMc(param1:MovieClip, param2:int) : MovieClip
      {
         switch(param2)
         {
            case 1:
               return param1.bronzeVault_mc;
            case 2:
               return param1.silverVault_mc;
            case 3:
               return param1.goldVault_mc;
            case 4:
               return param1.plantinumVault_mc;
            default:
               return null;
         }
      }
      
      private function getTierName(param1:int) : String
      {
         var _loc2_:String = "TreasureVaultTier";
         switch(param1)
         {
            case 1:
               return _loc2_ + "Bronze";
            case 2:
               return _loc2_ + "Silver";
            case 3:
               return _loc2_ + "Gold";
            case 4:
               return _loc2_ + "Platinum";
            default:
               return null;
         }
      }
      
      private function getTierHeaderMc(param1:int) : MovieClip
      {
         switch(param1)
         {
            case 1:
               return this.mc.bar_mc.bronzeHeader_mc;
            case 2:
               return this.mc.bar_mc.silverHeader_mc;
            case 3:
               return this.mc.bar_mc.goldHeader_mc;
            case 4:
               return this.mc.bar_mc.platinumHeader_mc;
            default:
               return null;
         }
      }
      
      private function onTierClicked(param1:MouseEvent) : void
      {
         if(Boolean(param1.currentTarget) && Boolean(param1.currentTarget.tierData))
         {
            this.selectTier(param1.currentTarget.tierData.tierNum);
         }
      }
      
      private function onTierOver(param1:MouseEvent) : void
      {
         this.highlightTier(param1.currentTarget.tierData.tierNum);
      }
      
      private function onTierOut(param1:MouseEvent) : void
      {
         this.unHighlightTier(param1.currentTarget.tierData.tierNum);
      }
      
      private function initTier(param1:int) : void
      {
         var _loc2_:MovieClip = this.getTierMc(param1);
         _loc2_.highlight_mc.visible = false;
         _loc2_.mouseOver_mc.visible = false;
         TextFieldUtil.processTextField(_loc2_.vault_tf,ZGameUtils.ZlocT("Dialogs",this.getTierName(param1)));
         TextFieldUtil.processTextField(_loc2_.unlock_tf,ZGameUtils.ZlocT("Dialogs","TreasureVaultOpenForKeys"));
         TextFieldUtil.processTextField(_loc2_.keys_tf,TreasureVaultManager.getSpinKeyCost(param1).toString());
         var _loc3_:int = int(TreasureVaultManager.TIER_MIN);
         while(_loc3_ <= TreasureVaultManager.TIER_MAX)
         {
            this.getTierGraphicMc(_loc2_,_loc3_).visible = param1 == _loc3_;
            _loc3_++;
         }
         _loc2_.addEventListener(MouseEvent.CLICK,this.onTierClicked,false,0,true);
         _loc2_.addEventListener(MouseEvent.MOUSE_OVER,this.onTierOver,false,0,true);
         _loc2_.addEventListener(MouseEvent.MOUSE_OUT,this.onTierOut,false,0,true);
         _loc2_.tierData = {"tierNum":param1};
      }
      
      private function deinitTier(param1:int) : void
      {
         var _loc2_:MovieClip = this.getTierMc(param1);
         _loc2_.removeEventListener(MouseEvent.CLICK,this.onTierClicked);
         _loc2_.removeEventListener(MouseEvent.MOUSE_OVER,this.onTierOver);
         _loc2_.removeEventListener(MouseEvent.MOUSE_OUT,this.onTierOut);
      }
      
      private function initTiers() : void
      {
         var _loc1_:int = int(TreasureVaultManager.TIER_MIN);
         while(_loc1_ <= TreasureVaultManager.TIER_MAX)
         {
            this.initTier(_loc1_);
            _loc1_++;
         }
      }
      
      private function deinitTiers() : void
      {
         var _loc1_:int = int(TreasureVaultManager.TIER_MIN);
         while(_loc1_ <= TreasureVaultManager.TIER_MAX)
         {
            this.deinitTier(_loc1_);
            _loc1_++;
         }
      }
      
      private function onAskButtonClicked(param1:MouseEvent) : void
      {
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(TreasureVaultManager.VAULT_KEY_ITEM,GameItem) as GameItem;
         var _loc3_:String = _loc2_.name;
         var _loc4_:String = "treasurevault_key";
         var _loc5_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_REQUEST2_MASTER);
         var _loc6_:Array = new Array();
         var _loc7_:Object = _loc2_.getSentenceNameLocalizationObject("plural",true);
         _loc6_["request_body"] = ZGameUtils.ZlocT("Requests","PartRequest_treasurevaultkey",{"gift":_loc7_});
         PopupManager.instance.push(new RequestAskPartsDialog(_loc3_,_loc3_,_loc6_));
      }
      
      private function updateButtons(param1:int) : void
      {
         var _loc8_:String = null;
         var _loc2_:XML = TreasureVaultManager.getTierCostData(param1);
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:int = ZGlobal.player.cash;
         var _loc4_:int = int(_loc2_.@cash);
         this.m_buyButton.compactText(ZGameUtils.ZlocT("Dialogs","TreasureVaultOpenForCashCount",{"count":_loc4_}),{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         if(this.m_spinState == SPIN_STATE_IDLE)
         {
            this.m_buyButton.enable();
         }
         else
         {
            this.m_buyButton.disable_visual();
         }
         var _loc5_:Boolean = TreasureVaultManager.isSpinAvailable();
         var _loc6_:int = int(ZGlobal.player.inventory[TreasureVaultManager.VAULT_KEY_ITEM]);
         var _loc7_:int = int(_loc2_.@keys);
         if(_loc5_)
         {
            this.m_spinButton.compactText(ZGameUtils.ZlocT("Dialogs","TreasureVaultOpenForKeysCount",{"count":_loc7_}),{
               "maxLines":1,
               "minScale":0.5,
               "onFail":"return"
            });
         }
         else
         {
            _loc8_ = LocaleFormatter.formatDuration(TreasureVaultManager.spinNextAvailable());
            this.m_spinButton.compactText(ZGameUtils.ZlocT("Dialogs","TreasureVaultAvailableIn",{"duration":_loc8_}),{
               "maxLines":1,
               "minScale":0.5,
               "onFail":"return"
            });
         }
         if(_loc5_ && _loc6_ >= _loc7_ && this.m_spinState == SPIN_STATE_IDLE && param1 == this.m_highestTierAvailable)
         {
            this.m_spinButton.enable();
         }
         else
         {
            this.m_spinButton.disable_visual();
         }
      }
      
      private function selectTier(param1:int) : void
      {
         var _loc5_:Object = null;
         var _loc6_:MovieClip = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:ImageLoader = null;
         var _loc10_:uint = 0;
         var _loc11_:Boolean = false;
         var _loc12_:GameItem = null;
         var _loc13_:UnitItem = null;
         var _loc14_:UnitClass = null;
         var _loc2_:int = int(TreasureVaultManager.TIER_MIN);
         while(_loc2_ <= TreasureVaultManager.TIER_MAX)
         {
            this.getTierHeaderMc(_loc2_).visible = _loc2_ == param1;
            this.getTierMc(_loc2_).highlight_mc.visible = _loc2_ == param1;
            _loc2_++;
         }
         TextFieldUtil.processTextField(this.mc.bar_mc.vault_tf,ZGameUtils.ZlocT("Dialogs",this.getTierName(param1)));
         this.m_iconLoaders = new Array();
         var _loc3_:Object = TreasureVaultManager.getHighlightData(param1);
         var _loc4_:int = 0;
         for each(_loc5_ in _loc3_.lootItem)
         {
            if(_loc4_ >= 8)
            {
               break;
            }
            _loc6_ = this.mc["item" + (_loc4_ + 1) + "_mc"];
            _loc7_ = null;
            _loc8_ = null;
            _loc6_.class_icon.visible = false;
            _loc6_.strength_mc.visible = false;
            if(_loc6_.tierRating_mc)
            {
               _loc6_.tierRating_mc.visible = false;
            }
            if(_loc5_.handler == "addLootToInventory")
            {
               _loc12_ = ZGlobal.gameSettings.getItemByName(_loc5_.itemName,GameItem) as GameItem;
               _loc7_ = ZGlobal.gameSettings.getImageByName(_loc5_.itemName,"icon");
               _loc8_ = _loc12_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
               if(_loc12_.isUnit())
               {
                  _loc13_ = ZGlobal.gameSettings.getItemByCode(_loc12_.code,UnitItem) as UnitItem;
                  _loc6_.class_icon.visible = true;
                  _loc6_.strength_mc.visible = true;
                  _loc14_ = UnitClassManager.instance.unitClassForUnit(_loc13_);
                  if(_loc14_)
                  {
                     this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc14_.getSmIconURL()),_loc6_.class_icon));
                  }
                  TextFieldUtil.processTextField(_loc6_.strength_mc.value_tf,String(_loc13_.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(_loc12_.code))));
                  if(Boolean(_loc6_.tierRating_mc) && TierSurfacingManager.instance.tierSurfacingEnabled)
                  {
                     TextFieldUtil.compactTextField(_loc6_.tierRating_mc.tier_tf,String(_loc13_.tier));
                     _loc6_.tierRating_mc.visible = true;
                  }
               }
            }
            else if(_loc5_.handler == "awardResources")
            {
               _loc7_ = WorldResourceManager.instance.getResourceImageURLByType(_loc5_.loot,WorldResourceManager.XTRA_LARGE_ICON);
               _loc8_ = WorldResourceManager.instance.getResourceFriendlyNameFromType(_loc5_.loot,GameItem.MENU_FRIENDLYNAME);
            }
            _loc6_.icon.unload();
            _loc9_ = ImageLoaderFactory.CreateImageLoader(_loc7_,_loc6_.icon);
            this.m_iconLoaders.push(_loc9_);
            _loc10_ = uint(ExperimentsManager.instance.getExperimentVariant("empire_vault_limited"));
            _loc11_ = _loc10_ == 3;
            _loc6_.limited_tf.visible = false;
            if(_loc11_ && _loc5_.limited != undefined && _loc5_.remaining != undefined)
            {
               if(_loc6_.limited_mc.treasureVaultPosAdjusted == undefined)
               {
                  _loc6_.limited_mc.y -= 5;
                  _loc6_.limited_mc.itemLeft_tf.y -= 2.5;
                  _loc6_.limited_mc.treasureVaultPosAdjusted = true;
               }
               _loc6_.limited_mc.visible = true;
               TextFieldUtil.compactTextField(_loc6_.limited_mc.itemLeft_tf,ZGameUtils.ZlocT("Dialogs","TreasureVaultLimitedRemaining",{
                  "remaining":_loc5_.remaining,
                  "total":_loc5_.limited
               }));
            }
            else
            {
               _loc6_.limited_mc.visible = false;
            }
            TextFieldUtil.compactTextField(_loc6_.item_tf,_loc8_,{
               "minScale":0.7,
               "maxLines":2,
               "fontSize":14
            });
            if(_loc5_.amount > 1)
            {
               _loc6_.quantity_tf.visible = true;
               TextFieldUtil.processTextField(_loc6_.quantity_tf,"x" + _loc5_.amount.toString());
            }
            else
            {
               _loc6_.quantity_tf.visible = false;
            }
            _loc4_++;
         }
         this.m_tierSelected = param1;
         this.updateButtons(this.m_tierSelected);
      }
      
      private function highlightTier(param1:int) : void
      {
         var _loc2_:int = int(TreasureVaultManager.TIER_MIN);
         while(_loc2_ <= TreasureVaultManager.TIER_MAX)
         {
            this.getTierMc(_loc2_).mouseOver_mc.visible = _loc2_ == param1;
            _loc2_++;
         }
      }
      
      private function unHighlightTier(param1:int) : void
      {
         var _loc2_:int = int(TreasureVaultManager.TIER_MIN);
         while(_loc2_ <= TreasureVaultManager.TIER_MAX)
         {
            this.getTierMc(_loc2_).mouseOver_mc.visible = false;
            _loc2_++;
         }
      }
      
      private function initButtons() : void
      {
         this.m_askButton = this.initButton(this.mc.ask_mc,ZGameUtils.ZlocT("Dialogs","TreasureVaultAskForKeys"),this.onAskButtonClicked);
         this.m_buyButton = this.initButton(this.mc.bar_mc.buy_mc,"",this.onBuyButtonClicked);
         this.m_buyButton.disable_visual();
         this.m_spinButton = this.initButton(this.mc.unlock_mc,"",this.onKeysButtonClicked);
         this.m_spinButton.disable_visual();
      }
      
      private function initHeader() : void
      {
         var _loc1_:int = int(TreasureVaultManager.TIER_MIN);
         while(_loc1_ <= TreasureVaultManager.TIER_MAX)
         {
            this.getTierHeaderMc(_loc1_).visible = false;
            _loc1_++;
         }
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         m_origOffsetX = -16;
         m_origOffsetY = -45.8;
         this.mc.exit_bt.visible = false;
         var _loc1_:Rectangle = getVisibleBounds(this.mc);
         this.mc.exit_bt.visible = true;
         contentWidth = _loc1_.width;
         contentHeight = _loc1_.height;
         centerWithinStage(Zlab.mainStage);
         this.mc.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         var _loc2_:uint = TreasureVaultManager.getSpinKeyCost(this.m_tierSelected);
         TextFieldUtil.processTextField(this.mc.title_tf,ZGameUtils.ZlocT("Dialogs","TreasureVaultTitle"));
         TextFieldUtil.compactTextField(this.mc.discription_tf,ZGameUtils.ZlocT("Dialogs","TreasureVaultDescription"));
         TextFieldUtil.processTextField(this.mc.info_tf,ZGameUtils.ZlocT("Dialogs","TreasureVaultContains"));
         TextFieldUtil.compactTextField(this.mc.tips_tf,ZGameUtils.ZlocT("Dialogs","TreasureVaultHint"));
         this.initTiers();
         this.initButtons();
         this.initHeader();
         TreasureVaultManager.instance.addEventListener(TreasureVaultManager.SPIN_RESULTS,this.onSpinResult,false,0,true);
         SoundEvent.getSoundEvent("GPVPSlotMachineOpen").play();
         this.updateTokenCounter();
         if(this.m_highestTierAvailable != TreasureVaultManager.TIER_NONE)
         {
            this.selectTier(this.m_highestTierAvailable);
         }
         else
         {
            this.selectTier(TreasureVaultManager.TIER_MAX);
         }
         this.m_timer = new Timer(1000);
         this.m_timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.m_timer.start();
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         this.updateButtons(this.m_tierSelected);
      }
      
      override protected function deinitDialog() : void
      {
         this.mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.exitButtonClicked);
         this.m_timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         if(this.m_askButton)
         {
            this.m_askButton.dispose();
            this.m_askButton = null;
         }
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
         this.deinitTiers();
         TreasureVaultManager.instance.removeEventListener(TreasureVaultManager.SPIN_RESULTS,this.onSpinResult);
         super.deinitDialog();
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
      
      private function updateTokenCounter() : void
      {
         var _loc3_:XML = null;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:MovieClip = null;
         var _loc7_:MovieClip = null;
         var _loc1_:int = int(ZGlobal.player.inventory[TreasureVaultManager.VAULT_KEY_ITEM]);
         TextFieldUtil.processTextField(this.mc.keys_tf,_loc1_.toString());
         this.m_highestTierAvailable = TreasureVaultManager.TIER_NONE;
         var _loc2_:int = int(TreasureVaultManager.TIER_MIN);
         while(_loc2_ <= TreasureVaultManager.TIER_MAX)
         {
            _loc3_ = TreasureVaultManager.getTierCostData(_loc2_);
            _loc4_ = int(_loc3_.@keys);
            _loc5_ = _loc1_ >= _loc4_;
            _loc6_ = this.getTierMc(_loc2_);
            _loc6_.available_mc.visible = false;
            _loc6_.keys_tf.textColor = _loc5_ ? 3355443 : 13369344;
            this.m_highestTierAvailable = _loc5_ ? uint(_loc2_) : this.m_highestTierAvailable;
            _loc2_++;
         }
         this.mc.meter_mc.gotoAndStop(this.m_highestTierAvailable * 2);
         if(this.m_highestTierAvailable != TreasureVaultManager.TIER_NONE)
         {
            _loc7_ = this.getTierMc(this.m_highestTierAvailable);
            _loc7_.available_mc.visible = true;
         }
      }
      
      override protected function close(param1:Event = null) : void
      {
         this.endSoundByCategory(SPIN_CATEGORY);
         this.endSoundByCategory(REWARD_CATEGORY);
         super.close(param1);
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         this.close();
      }
      
      private function onBuyPopupClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.startSpin(TreasureVaultManager.REWARD_SPIN_MODE_BUY);
         }
      }
      
      private function onBuyButtonClicked(param1:MouseEvent) : void
      {
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc2_:XML = TreasureVaultManager.getTierCostData(this.m_tierSelected);
         if(!_loc2_ || _loc2_.@cash == undefined)
         {
            return;
         }
         var _loc3_:int = int(_loc2_.@cash);
         var _loc4_:Boolean = ZGlobal.player.canBuyCash(_loc3_,true);
         if(_loc4_)
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc3_))
            {
               _loc5_ = ZGameUtils.CashTokenReplacements(_loc3_);
               _loc6_ = ZGameUtils.ZlocT("Dialogs","QuestTaskBuyConfirmMsg",_loc5_);
               PopupManager.instance.push(GenericPopup2B.NewYesNo(_loc6_,ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle"),this.onBuyPopupClosed));
            }
            else
            {
               this.startSpin(TreasureVaultManager.REWARD_SPIN_MODE_BUY);
            }
         }
      }
      
      private function onKeysButtonClicked(param1:MouseEvent) : void
      {
         this.startSpin(TreasureVaultManager.REWARD_SPIN_MODE_KEYS);
      }
      
      private function startSpin(param1:uint) : void
      {
         var _loc2_:TreasureVaultRewardPopup = null;
         if(this.m_spinState == SPIN_STATE_IDLE)
         {
            if(TreasureVaultManager.instance.slotMachineSpin(param1,this.m_tierSelected))
            {
               _loc2_ = new TreasureVaultRewardPopup();
               _loc2_.addEventListener(CLOSED,this.onRewardClose);
               WindowManager.instance.push(_loc2_);
               this.m_spinResults = null;
               this.m_spinState = SPIN_STATE_SPINNING;
               SoundEvent.getSoundEvent("GPVPSlotMachineSpinStart").play();
               this.startSpinSoundLoop();
               this.updateTokenCounter();
               this.updateButtons(this.m_tierSelected);
               this.mc.exit_bt.enabled = false;
               this.mc.exit_bt.mouseEnabled = false;
               this.mc.exit_bt.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            }
         }
      }
      
      private function onSpinResult(param1:WorldEvent) : void
      {
         this.m_spinState = SPIN_STATE_REWARD;
         this.m_spinResults = param1.eventData;
         SoundEvent.getSoundEvent("GPVPSlotMachineSpinEnd").play();
         this.endSoundByCategory(SPIN_CATEGORY);
         this.startSound(this.m_rewardNormalClass,REWARD_CATEGORY);
         this.selectTier(this.m_tierSelected);
      }
      
      private function onRewardClose(param1:Event) : void
      {
         this.m_spinState = SPIN_STATE_IDLE;
         param1.currentTarget.removeEventListener(Event.CLOSE,this.onRewardClose);
         this.updateButtons(this.m_tierSelected);
         this.mc.exit_bt.enabled = true;
         this.mc.exit_bt.mouseEnabled = true;
         this.mc.exit_bt.filters = null;
      }
      
      private function startSpinSoundLoop() : void
      {
         this.startSound(this.m_spinSoundClass,SPIN_CATEGORY,SPINLOOP_VOLUME_TWEEN_SECS,SPINLOOP_COUNT);
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
         this.m_rewardNormalClass = param1.getAssetClass(REWARDNORMALSOUND_CLASSNAME);
      }
      
      private function get soundMuted() : Boolean
      {
         var _loc1_:SoundManager = Zlab.soundManager as SoundManager;
         return !_loc1_ || _loc1_.getCategoryMuted(SoundManager.SFX_MIXER_CATEGORY);
      }
      
      private function startSound(param1:Class, param2:String, param3:Number = -1, param4:int = 1) : void
      {
         var _loc5_:SoundManager = null;
         var _loc6_:ISoundHandle = null;
         if(!this.soundMuted && Boolean(param1))
         {
            _loc5_ = Zlab.soundManager as SoundManager;
            _loc6_ = _loc5_.play(new param1(),null,param2,0,param4);
            if(param3 > 0)
            {
               _loc6_.volume = 0;
               TweenLite.to(_loc6_,param3,{"volume":1});
            }
         }
      }
   }
}

