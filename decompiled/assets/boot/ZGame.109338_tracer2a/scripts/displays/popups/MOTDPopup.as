package displays.popups
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import ZLocalization.LocalizationObjectToken;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.MOTDManager.MOTDData;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.promoManager.PromoManager;
   import core.managers.survivalModeManager.SurvivalModeManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.player.Player;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.genericPopup.GenericPopup1B;
   import fl.containers.UILoader;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TBuyMOTDItem;
   import transactions.TPurchaseContractUnlock;
   import transactions.TPurchaseUnlock;
   import utils.BitArray;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class MOTDPopup extends GallantPopup
   {
      
      public static const MERCH_CARD_YPOS_UNLOCK:Number = 124.55;
      
      public static const MERCH_CARD_YPOS_BUY:Number = 152.1;
      
      private static const LIGHTNINGDEAL_CLAIM_X:int = 420;
      
      private static const LIGHTNINGDEAL_CLAIM_Y:int = 310;
      
      private static var adjustedHeight:Boolean = false;
      
      private var m_data:MOTDData;
      
      private var m_titleTF:TextField;
      
      private var m_descriptionTF:TextField;
      
      private var m_iconUILoader:UILoader;
      
      private var m_acceptButton:ZGameButton;
      
      private var m_linkClip:MovieClip = null;
      
      private var m_linkButton:ZGameButton = null;
      
      private var m_exitButton:SimpleButton;
      
      private var m_clock:CountdownClock = null;
      
      private var m_loaders:Vector.<ImageLoader> = new Vector.<ImageLoader>();
      
      private var m_soundContainer:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      private var m_nextButton:MovieClip;
      
      private var m_prevButton:MovieClip;
      
      public var m_acceptBtnMc:MovieClip;
      
      public var m_clockMc:MovieClip;
      
      public var m_panelMc:MovieClip;
      
      private var m_motdVersion:int = MessageOfTheDayManager.instance.version;
      
      private var m_cardsMc:MovieClip;
      
      private var m_cardSetMc:MovieClip;
      
      private var m_cardCount:int;
      
      private var m_prizeMeterMc:MovieClip;
      
      private var m_prizeMeterHeaderText:TextField;
      
      private var m_prizeMeterPrizeItemText:TextField;
      
      private var m_prizeMeterPrizeItemIconMc:UILoader;
      
      private var m_prizeMeterPrizeItemIconClassMc:UILoader;
      
      private var m_prizeMeterPrizeItemStrengthMc:MovieClip;
      
      private var m_prizeMeterUnlockText:TextField;
      
      private var m_prizeMeterUnlockCountText:TextField;
      
      private var m_prizeMeterUnlockBar:MovieClip;
      
      private var m_prizeMeterBuyText:TextField;
      
      private var m_prizeMeterBuyCountText:TextField;
      
      private var m_prizeMeterBuyBar:MovieClip;
      
      private var m_clockTimerText1:TextField;
      
      private var m_clockTimerText2:TextField;
      
      private var m_cardClips:Object;
      
      private var m_cardGameItems:Vector.<GameItem>;
      
      private var m_cardGameItemLookup:Dictionary = new Dictionary();
      
      private var m_iconLoaders:Array;
      
      private var m_clockBgMc:MovieClip;
      
      private var m_unlockCount:int;
      
      private var m_typeSpecificDeinitFunc:Function;
      
      private var m_confirmationItem:GameItem = null;
      
      private var m_buyContract:Boolean = false;
      
      private var m_prizeItem:GameItem;
      
      private var m_messagePlopper:MOTDPopupPlopper;
      
      private var m_merchButtons:Array;
      
      private var m_initialPlopperMessage:String;
      
      private var m_unlockButtons:Dictionary = new Dictionary();
      
      private var m_purchaseCount:int = 0;
      
      private var m_refreshOnNextPurchase:Boolean = false;
      
      private var m_bgImageUILoader:UILoader = null;
      
      private var m_lightningDealClaimClass:Class;
      
      private var m_lightningDealClaimMC:MovieClip;
      
      public function MOTDPopup(param1:MOTDData)
      {
         var _loc2_:Array = null;
         var _loc3_:UILoader = null;
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:GameItem = null;
         var _loc8_:String = null;
         this.m_data = param1;
         if(this.m_data.swfOverride)
         {
            this.m_motdVersion = 1;
         }
         if(this.m_data.type == MOTDData.MOTD_TYPE_SURVIVALREWARDS)
         {
            this.m_motdVersion = 2;
            _loc2_ = SurvivalModeManager.instance.survivalModeFeaturedRewards;
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               _loc6_ = _loc2_[_loc4_];
               _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc6_,GameItem) as GameItem;
               _loc8_ = ZGlobal.gameSettings.getImageByName(_loc7_.name,"icon",WorldResourceManager.XTRA_LARGE_ICON);
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(_loc8_,_loc3_));
               _loc4_++;
            }
            _loc5_ = ZGlobal.getAssetURL(SurvivalModeManager.instance.questIconName);
            this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(_loc5_,_loc3_));
         }
         super(ZGlobal.getAssetURL(this.swfPath));
      }
      
      private function get swfPath() : String
      {
         var _loc1_:String = this.m_data.swfOverride;
         if(_loc1_)
         {
            return _loc1_;
         }
         if(this.m_motdVersion == 2)
         {
            return "assets/displays/screens/MOTD2.swf";
         }
         return "assets/displays/screens/MOTD.swf";
      }
      
      override protected function initializeScreen() : void
      {
         this.initAssetVars();
         if(this.m_panelMc)
         {
            contentWidth = this.m_panelMc.width;
            contentHeight = this.m_panelMc.height;
         }
         super.initializeScreen();
      }
      
      protected function initAssetVars() : void
      {
         if(this.m_motdVersion == 2)
         {
            switch(this.m_data.type)
            {
               case MOTDData.MOTD_TYPE_MERCHANDISING:
                  this.initAssetVarsMerchandising();
                  break;
               case MOTDData.MOTD_TYPE_PLACEMENT:
                  this.initAssetVarsPlacement();
                  break;
               case MOTDData.MOTD_TYPE_SURVIVALREWARDS:
                  this.initAssetVarsSurvivalRewards();
                  break;
               default:
                  this.initAssetVarsMessage();
            }
         }
         else
         {
            this.initAssetVarsMessage();
         }
      }
      
      protected function initAssetVarsMessage() : void
      {
         if(this.m_motdVersion == 2)
         {
            this.initAssetVarsMessageVersion2();
         }
         else
         {
            this.initAssetVarsMessageVersion1();
         }
      }
      
      private function initAssetVarsMessageVersion1() : void
      {
         this.m_titleTF = m_window.motd_mc.title_tf;
         this.m_descriptionTF = m_window.motd_mc.description_tf;
         this.m_iconUILoader = m_window.motd_mc.icon_uil;
         this.m_exitButton = m_window.motd_mc.exit_bt;
         this.m_nextButton = m_window.motd_mc.next_bt;
         this.m_prevButton = m_window.motd_mc.prev_bt;
         this.m_acceptBtnMc = m_window.motd_mc.accept_mc;
         this.m_clockMc = m_window.motd_mc.clock_mc;
         this.m_panelMc = m_window.motd_mc.panel_mc;
      }
      
      private function initAssetVarsMessageVersion2() : void
      {
         var _loc1_:MovieClip = null;
         this.hideAllElementsVersion2();
         _loc1_ = m_window.motd_mc.message_mc;
         _loc1_.visible = true;
         this.m_bgImageUILoader = _loc1_.motdBkgdImageLoader.bkgdLoader;
         this.m_titleTF = m_window.motd_mc.title_tf;
         this.m_descriptionTF = _loc1_.header_tf;
         if(this.m_data.version == 2)
         {
            this.m_iconUILoader = _loc1_.image_mc;
         }
         else
         {
            this.m_iconUILoader = _loc1_.imageDepreciated_mc;
         }
         this.m_exitButton = m_window.motd_mc.exit_bt;
         this.m_nextButton = m_window.motd_mc.next_bt;
         this.m_prevButton = m_window.motd_mc.prev_bt;
         this.m_acceptBtnMc = _loc1_.action_mc;
         this.m_clockMc = _loc1_.clock_mc;
         this.m_panelMc = m_window.motd_mc.panel_mc;
         _loc1_.timerText1_tf.visible = false;
         _loc1_.timerText2_tf.visible = false;
      }
      
      private function initAssetVarsSurvivalRewards() : void
      {
         this.m_exitButton = m_window.motd_mc.exit_bt;
         this.m_nextButton = m_window.motd_mc.next_bt;
         this.m_prevButton = m_window.motd_mc.prev_bt;
         this.m_titleTF = m_window.motd_mc.title_tf;
         this.m_descriptionTF = m_window.motd_mc.header_tf;
      }
      
      private function initDialogTypeSurvivalModeRewardRefresh() : void
      {
         var _loc8_:String = null;
         var _loc9_:GameItem = null;
         var _loc10_:UnitItem = null;
         var _loc11_:String = null;
         this.m_typeSpecificDeinitFunc = this.deinitSurvivalModeRewardRefreshDialogMessage;
         this.m_acceptButton = new ZGameButton(m_window.motd_mc.finish_bt,this.onAcceptClick);
         this.m_exitButton.addEventListener(MouseEvent.CLICK,this.onCancelSurvivalClick);
         var _loc1_:Array = SurvivalModeManager.instance.survivalModeFeaturedRewards;
         this.m_loaders = new Vector.<ImageLoader>();
         var _loc2_:Array = [m_window.motd_mc.unit_03_nc,m_window.motd_mc.unit_01_nc,m_window.motd_mc.unit_02_nc];
         var _loc3_:Array = [m_window.motd_mc.unit_03_ft,m_window.motd_mc.unit_01_ft,m_window.motd_mc.unit_02_ft];
         var _loc4_:Array = [m_window.motd_mc.unit_name_03_ft,m_window.motd_mc.unit_name_01_ft,m_window.motd_mc.unit_name_02_ft];
         this.initScrollButton(this.m_nextButton);
         this.initScrollButton(this.m_prevButton);
         this.m_nextButton.addEventListener(MouseEvent.CLICK,this.nextButtonClicked,false,0,true);
         this.m_prevButton.addEventListener(MouseEvent.CLICK,this.prevButtonClicked,false,0,true);
         TextFieldUtil.compactTextField(this.m_titleTF,this.m_data.titleText);
         TextFieldUtil.compactTextField(this.m_descriptionTF,this.m_data.descriptionText);
         var _loc5_:String = this.m_data.acceptButtonText;
         this.m_acceptButton.compactText(_loc5_,{
            "maxLines":1,
            "minScale":0.7,
            "onFail":"return"
         });
         var _loc6_:int = 0;
         while(_loc6_ < _loc2_.length)
         {
            _loc8_ = _loc1_[_loc6_];
            _loc9_ = ZGlobal.gameSettings.getItemByCode(_loc8_,GameItem) as GameItem;
            _loc10_ = ZGlobal.gameSettings.getItemByCode(_loc8_,UnitItem) as UnitItem;
            _loc11_ = ZGlobal.gameSettings.getImageByName(_loc9_.name,"icon",WorldResourceManager.XTRA_LARGE_ICON);
            this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(_loc11_,_loc2_[_loc6_]));
            TextFieldUtil.compactTextField(_loc3_[_loc6_],_loc10_.getStrength(null).toString());
            TextFieldUtil.compactTextField(_loc4_[_loc6_],_loc9_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            _loc6_++;
         }
         var _loc7_:String = ZGlobal.getAssetURL(SurvivalModeManager.instance.questIconName);
         this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(_loc7_,m_window.motd_mc.icon_01_nc));
      }
      
      private function initAssetVarsPlacement() : void
      {
         this.initAssetVarsMessage();
      }
      
      private function initAssetVarsMerchandising() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:MovieClip = null;
         this.hideAllElementsVersion2();
         m_window.motd_mc.merchandise_mc.visible = true;
         _loc1_ = m_window.motd_mc.merchandise_mc;
         _loc2_ = m_window.motd_mc;
         this.m_bgImageUILoader = _loc1_.motdBkgdImageLoader.bkgdLoader;
         this.m_titleTF = _loc2_.title_tf;
         this.m_descriptionTF = _loc1_.header_tf;
         this.m_exitButton = _loc2_.exit_bt;
         this.m_nextButton = _loc2_.next_bt;
         this.m_prevButton = _loc2_.prev_bt;
         this.m_clockMc = _loc1_.clock_mc;
         this.m_clockBgMc = _loc1_.clock_bg;
         this.m_panelMc = _loc2_.panel_mc;
         this.m_cardsMc = _loc1_.cards;
         this.m_prizeMeterMc = _loc1_.prizeMeter_mc;
         this.m_prizeMeterMc.mouseEnabled = false;
         this.m_prizeMeterMc.mouseChildren = false;
         this.m_prizeMeterHeaderText = this.m_prizeMeterMc.header_tf;
         this.m_prizeMeterPrizeItemText = this.m_prizeMeterMc.unit_tf;
         this.m_prizeMeterPrizeItemIconMc = this.m_prizeMeterMc.icon;
         this.m_prizeMeterPrizeItemIconClassMc = this.m_prizeMeterMc.icon_class;
         this.m_prizeMeterPrizeItemStrengthMc = this.m_prizeMeterMc.strength_mc;
         this.m_prizeMeterUnlockText = this.m_prizeMeterMc.unlockMeterTitle_tf;
         this.m_prizeMeterUnlockCountText = this.m_prizeMeterMc.unlockMeterCounter_tf;
         this.m_prizeMeterUnlockBar = this.m_prizeMeterMc.unlockMeter_mc;
         this.m_prizeMeterUnlockBar.meterGlow.stop();
         this.m_prizeMeterBuyText = this.m_prizeMeterMc.buyMeterTitle_tf;
         this.m_prizeMeterBuyCountText = this.m_prizeMeterMc.buyMeterCounter_tf;
         this.m_prizeMeterBuyBar = this.m_prizeMeterMc.buyMeter_mc;
         this.m_prizeMeterBuyBar.meterGlow.stop();
         this.m_clockTimerText1 = _loc1_.timerText1_tf;
         this.m_clockTimerText2 = _loc1_.timerText2_tf;
      }
      
      private function hideAllElementsVersion2() : void
      {
         m_window.motd_mc.message_mc.visible = false;
         m_window.motd_mc.merchandise_mc.visible = false;
         m_window.motd_mc.placement_mc.visible = false;
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         if(this.m_motdVersion == 2)
         {
            switch(this.m_data.type)
            {
               case MOTDData.MOTD_TYPE_MERCHANDISING:
                  this.initDialogTypeMerchandising();
                  break;
               case MOTDData.MOTD_TYPE_PLACEMENT:
                  this.initDialogTypePlacement();
                  break;
               case MOTDData.MOTD_TYPE_SURVIVALREWARDS:
                  this.initDialogTypeSurvivalModeRewardRefresh();
                  break;
               default:
                  this.initDialogTypeMessage();
            }
         }
         else
         {
            this.initDialogTypeMessage();
         }
      }
      
      private function initDialogTypePlacement() : void
      {
         this.initDialogTypeMessage();
         this.m_typeSpecificDeinitFunc = this.deinitDialogPlacement;
      }
      
      private function initDialogTypeMerchandising() : void
      {
         this.m_typeSpecificDeinitFunc = this.deinitDialogMerchandising;
         this.initMerchandisingCards();
         this.initMerchandisingPrize();
         this.m_clockTimerText1.visible = false;
         this.m_clockTimerText2.visible = false;
         this.m_exitButton.addEventListener(MouseEvent.CLICK,this.onCancelClick);
         this.initScrollButton(this.m_nextButton);
         this.initScrollButton(this.m_prevButton);
         this.m_nextButton.addEventListener(MouseEvent.CLICK,this.nextButtonClicked,false,0,true);
         this.m_prevButton.addEventListener(MouseEvent.CLICK,this.prevButtonClicked,false,0,true);
         this.refreshButtonVisibility();
         this.m_exitButton.visible = true;
         this.resetDescriptionTextSize();
         if(this.m_data != null)
         {
            TextFieldUtil.compactTextField(this.m_titleTF,this.m_data.titleText,{
               "minScale":0.6,
               "maxLines":1,
               "fontSize":30
            });
            TextFieldUtil.compactTextField(this.m_descriptionTF,this.m_data.descriptionText,{
               "minScale":0.6,
               "maxLines":4,
               "fontSize":20
            });
            this.m_loaders = new Vector.<ImageLoader>();
            if(this.m_bgImageUILoader != null && this.m_data.bgURL != "")
            {
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_data.bgURL),this.m_bgImageUILoader));
            }
            this.motdStatCount();
            this.m_clockMc.visible = this.m_clockBgMc.visible = this.m_data.shouldShowCountdownClock();
            if(this.m_data.shouldShowCountdownClock())
            {
               this.m_clock = this.createCountdownClock();
            }
         }
         this.m_messagePlopper = new MOTDPopupPlopper(m_window.motd_mc.merchandise_mc.message_plopper);
         if(this.m_initialPlopperMessage != null)
         {
            this.addPlopperMessage(this.m_initialPlopperMessage,false,true,true,5000);
         }
      }
      
      private function motdStatCount() : void
      {
         if(this.m_data.isXPromo == true)
         {
            StatsManager.count("dialog","xpromo","view",this.m_data.xPromoGameID,this.m_data.name);
         }
         else if(this.m_data.version >= 2)
         {
            StatsManager.count("dialog",this.m_data.type + "_" + this.m_data.name,"view");
         }
         else
         {
            StatsManager.count("dialog",this.m_data.name,"view");
         }
      }
      
      private function initMerchandisingCards() : void
      {
         var _loc1_:int = 0;
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         var _loc5_:XMLList = null;
         var _loc6_:XML = null;
         var _loc8_:GameItem = null;
         var _loc10_:MovieClip = null;
         var _loc11_:Class = null;
         var _loc12_:String = null;
         var _loc13_:String = null;
         var _loc14_:GameItem = null;
         var _loc15_:* = undefined;
         var _loc7_:int = 0;
         this.m_iconLoaders = new Array();
         this.m_merchButtons = new Array();
         this.m_unlockCount = 0;
         this.m_purchaseCount = 0;
         _loc5_ = this.m_data.xml.merchData.merchItems;
         this.m_cardGameItems = new Vector.<GameItem>();
         for each(_loc6_ in _loc5_.item)
         {
            _loc7_++;
            _loc12_ = _loc6_.@classType;
            if(_loc12_ == "unit")
            {
               _loc8_ = ZGlobal.gameSettings.getItemByCode(_loc6_.@code,UnitItem) as UnitItem;
            }
            else
            {
               _loc8_ = ZGlobal.gameSettings.getItemByCode(_loc6_.@code,GameItem) as GameItem;
            }
            this.m_cardGameItems.push(_loc8_);
         }
         this.setMerchandisingCardSet(_loc7_);
         this.m_cardClips = {};
         _loc1_ = 0;
         while(_loc1_ < this.m_cardCount)
         {
            _loc2_ = this.m_cardSetMc["card" + _loc1_ + "_mc"];
            this.initCard(this.m_cardGameItems[_loc1_],_loc2_);
            _loc1_++;
         }
         var _loc9_:Object = ZGlobal.player.getMotdMerchHistory(this.m_data.name);
         if(_loc9_ != null && Boolean(_loc9_["awarded"]))
         {
            this.m_refreshOnNextPurchase = true;
            this.m_purchaseCount = this.m_cardCount;
            for each(_loc10_ in this.m_cardClips)
            {
               _loc10_.check_mc.visible = true;
            }
            this.m_prizeMeterMc.starBurst_mc.gotoAndPlay(2);
            _loc13_ = this.m_data.merchData.bonusItems[0]["code"];
            _loc14_ = ZGlobal.gameSettings.getItemByCode(_loc13_,GameItem) as GameItem;
            this.m_initialPlopperMessage = ZGameUtils.ZlocT("Main","FeedbackMOTDMerchGiftReceived",{"item":_loc14_.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME)});
         }
         else
         {
            for(_loc15_ in _loc9_)
            {
               if(_loc15_ != "awarded")
               {
                  _loc10_ = this.m_cardClips[_loc15_];
                  _loc10_.check_mc.visible = true;
                  ++this.m_purchaseCount;
               }
            }
         }
         this.updatePrizeBuyBar();
         this.updatePrizeUnlockBar();
      }
      
      private function initCard(param1:GameItem, param2:MovieClip) : void
      {
         this.m_cardClips[param1.code] = param2;
         this.m_cardGameItemLookup[param2] = param1;
         param2.check_mc.visible = false;
         if(param1 is UnitItem)
         {
            this.initCardUnitItem(UnitItem(param1),param2);
         }
         else
         {
            this.initCardGameItem(GameItem(param1),param2);
         }
         param2.cardBkgd_mc.visible = this.m_data.showCardBg;
         param2.highlightSelect.visible = this.m_data.showCardBg;
      }
      
      private function initCardUnitItem(param1:UnitItem, param2:MovieClip) : void
      {
         var _loc3_:Loader = null;
         var _loc5_:ZGameButton = null;
         TextFieldUtil.compactTextField(param2.unit_tf,param1.getFriendlyName(GameItem.MENU_FRIENDLYNAME),{
            "minScale":0.7,
            "maxLines":3,
            "fontSize":16,
            "filter":"ignore"
         });
         _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(param1.name,"icon"),param2.icon);
         this.m_iconLoaders.push(_loc3_);
         var _loc4_:UnitClass = UnitClassManager.instance.unitClassNamed(param1.unitClass);
         param2.strength_mc.visible = true;
         param2.icon_class.visible = true;
         if(_loc4_)
         {
            _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc4_.getSmIconURL()),param2.icon_class);
            this.m_iconLoaders.push(_loc3_);
         }
         TextFieldUtil.processTextField(param2.strength_mc.value_tf,String(param1.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(param1.code))));
         if(param1.contractLocked && param1.canBuyContract())
         {
            param2.unlock_bt.visible = true;
            _loc5_ = new ZGameButton(param2.unlock_bt,this.onBuyContractClick);
            _loc5_.compactText(ZGameUtils.ZlocT("Dialogs","UnlockForAmount",{"amount":param1.contractCost}),{"minScale":0.7});
            _loc5_.sounds = ButtonSound.DEFAULT;
            this.m_merchButtons.push(_loc5_);
            this.m_unlockButtons[param2] = _loc5_;
         }
         else
         {
            param2.unlock_bt.visible = false;
            ++this.m_unlockCount;
            this.checkAndDoCollapseButtonSpace(param2.buy_bt);
         }
         _loc5_ = new ZGameButton(param2.buy_bt,this.onBuyClick,1.1,true);
         _loc5_.compactText(ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":param1.cash}),null);
         _loc5_.sounds = ButtonSound.DEFAULT;
         this.m_merchButtons.push(_loc5_);
      }
      
      private function onBuyContractClick(param1:MouseEvent) : void
      {
         var _loc2_:GameItem = null;
         _loc2_ = this.m_cardGameItemLookup[MovieClip(param1.target).parent];
         this.m_buyContract = true;
         this.doBuyItem(_loc2_,param1);
      }
      
      private function onBuyClick(param1:MouseEvent) : void
      {
         var _loc2_:GameItem = null;
         _loc2_ = this.m_cardGameItemLookup[MovieClip(param1.target).parent.parent];
         this.m_buyContract = false;
         this.doBuyItem(_loc2_,param1);
      }
      
      private function doBuyItem(param1:GameItem, param2:MouseEvent = null) : void
      {
         var _loc4_:Boolean = false;
         var _loc6_:String = null;
         var _loc7_:Object = null;
         var _loc8_:LocalizationObjectToken = null;
         var _loc9_:String = null;
         var _loc10_:Array = null;
         var _loc3_:Boolean = this.isItemUnlockEligible(param1);
         var _loc5_:int = 0;
         if(_loc3_)
         {
            _loc5_ = param1.unlockCost;
         }
         else if(this.m_buyContract && param1.contractLocked && param1.canBuyContract())
         {
            _loc5_ = param1.contractCost;
         }
         else
         {
            _loc5_ = param1.cash;
         }
         if(param1.usesCash() || _loc5_ > 0)
         {
            _loc4_ = ZGlobal.player.canBuyCash(_loc5_,true,"",false);
         }
         else
         {
            _loc4_ = ZGlobal.player.canBuy(param1,true);
         }
         if(_loc4_)
         {
            if(!this.tryBuyPlayerEnergies(param1))
            {
               _loc4_ = false;
            }
         }
         if(_loc4_ && (param1.usesCash() || this.itemIsNotUnlocked(param1) || param1.contractLocked && param1.canBuyContract()))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc5_))
            {
               this.m_confirmationItem = param1;
               _loc7_ = ZGameUtils.CashTokenReplacements(_loc5_);
               _loc8_ = param1.getSentenceNameLocalizationObject("singular",true);
               if(_loc8_)
               {
                  _loc7_.item = _loc8_;
                  if(_loc3_)
                  {
                     _loc6_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockMessage_Object",_loc7_);
                  }
                  else if(this.m_buyContract && param1.contractLocked && param1.canBuyContract())
                  {
                     _loc6_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockContractMessage_Object",_loc7_);
                  }
                  else
                  {
                     _loc6_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage_Object",_loc7_);
                  }
               }
               else
               {
                  _loc7_.item = param1.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                  if(_loc3_)
                  {
                     _loc6_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockMessage",_loc7_);
                  }
                  else if(this.m_buyContract && param1.contractLocked && param1.canBuyContract())
                  {
                     _loc6_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockContractMessage",_loc7_);
                  }
                  else
                  {
                     _loc6_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage",_loc7_);
                  }
               }
               _loc9_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
               _loc10_ = new Array("EmpirePointsConfirm","","","");
               PopupManager.instance.push(GenericPopup2B.NewYesNo(_loc6_,_loc9_,this.onCashBuyPopupClose,_loc10_),0,false);
               return;
            }
         }
         if(_loc4_ == true)
         {
            this.buyItem(param1);
         }
      }
      
      private function isItemUnlockEligible(param1:GameItem) : Boolean
      {
         var _loc2_:BitArray = ZGlobal.player.checkGate(param1);
         var _loc3_:Boolean = _loc2_.isBitSet(Player.GATE_FAILURE_LEVEL);
         var _loc4_:Boolean = _loc2_.isBitSet(Player.GATE_FAILURE_QUEST);
         _loc2_.resetBit(Player.GATE_FAILURE_LEVEL);
         _loc2_.resetBit(Player.GATE_FAILURE_QUEST);
         _loc2_.resetBit(Player.GATE_FAILURE_CAMPAIGN);
         return (_loc3_ || _loc4_) && !_loc2_.anyBitSet() && param1.unlockCost > 0 && !ZGlobal.player.isItemUnlocked(param1.code);
      }
      
      private function tryBuyPlayerEnergies(param1:GameItem) : Boolean
      {
         var _loc4_:GenericPopup = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(param1.energyYield > 0)
         {
            if(!ZGlobal.player.m_energy.canAcceptEnergy(param1.energyYield))
            {
               _loc2_ = "NoAcceptEnergy_Title";
               _loc3_ = "NoAcceptEnergy_Message";
            }
         }
         else if(param1.manaYield > 0)
         {
            if(!ZGlobal.player.mana.allowGive(param1.manaYield))
            {
               _loc2_ = "NoAcceptMana_Title";
               _loc3_ = "NoAcceptMana_Message";
            }
         }
         if(_loc2_)
         {
            _loc4_ = new GenericPopup1B(ZGameUtils.ZlocT("Dialogs",_loc3_),ZGameUtils.ZlocT("Dialogs",_loc2_),GenericPopup.TYPE_OK,null);
            _loc4_.setAdvisorMood(GenericPopup.MOOD_DEFAULT);
            PopupManager.instance.push(_loc4_);
            return false;
         }
         return true;
      }
      
      private function itemIsNotUnlocked(param1:GameItem) : Boolean
      {
         var _loc2_:BitArray = ZGlobal.player.checkGate(param1);
         return (_loc2_.isBitSet(Player.GATE_FAILURE_LEVEL) || _loc2_.isBitSet(Player.GATE_FAILURE_QUEST)) && !ZGlobal.player.isItemUnlocked(param1.code);
      }
      
      private function buyItem(param1:GameItem) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Boolean = false;
         if(this.itemIsNotUnlocked(param1) && param1.canBeUnlocked())
         {
            ZGlobal.player.unlockItem(param1);
            TransactionManager.addTransaction(new TPurchaseUnlock(param1.code));
            this.merchandisingItemUnlocked(param1);
         }
         else if(this.m_buyContract && param1.contractLocked && param1.canBuyContract())
         {
            ZGlobal.player.unlockContract(param1);
            TransactionManager.addTransaction(new TPurchaseContractUnlock(param1.code));
            this.merchandisingItemUnlocked(param1);
         }
         else
         {
            _loc2_ = null;
            _loc2_ = new Object();
            _loc2_.screen = "motd_merchandising";
            _loc2_.unitCode = param1.code;
            this.merchandisingItemPurchased(param1);
            _loc3_ = param1.cash != 0;
            ZGlobal.player.buyItem(param1,_loc3_);
            ZGlobal.player.addToInventory(param1.code);
            TransactionManager.addTransaction(new TBuyMOTDItem(param1.code,_loc3_,1,_loc2_));
         }
         this.m_buyContract = false;
      }
      
      protected function onCashBuyPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.buyItem(this.m_confirmationItem);
            this.m_confirmationItem = null;
         }
         this.m_buyContract = false;
      }
      
      private function merchandisingItemUnlocked(param1:GameItem) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:ZGameButton = null;
         ++this.m_unlockCount;
         this.updatePrizeUnlockBar();
         _loc2_ = this.m_cardClips[param1.code];
         _loc2_.unlock_bt.visible = false;
         this.checkAndDoCollapseButtonSpace(_loc2_.buy_bt);
         _loc3_ = this.m_unlockButtons[_loc2_];
         _loc3_.disable();
         StatsManager.count("dialog",this.m_data.type + "_" + this.m_data.name,"unlock","" + param1.code);
         var _loc4_:String = ZGameUtils.ZlocT("Main","FeedbackGiftReceived",{"item":param1.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME)});
         this.addPlopperMessage(_loc4_,false,true);
      }
      
      private function merchandisingItemPurchased(param1:GameItem) : void
      {
         var _loc2_:MovieClip = null;
         if(!ZGlobal.player.isMotdMerchItemPurchased(this.m_data.name,param1.code))
         {
            if(this.m_refreshOnNextPurchase)
            {
               this.resetCardCheckMarks();
               this.m_prizeMeterMc.starBurst_mc.gotoAndStop(1);
               this.m_refreshOnNextPurchase = false;
               this.m_purchaseCount = 0;
            }
            ++this.m_purchaseCount;
            _loc2_ = this.m_cardClips[param1.code];
            _loc2_.check_mc.visible = true;
            this.updatePrizeBuyBar();
            if(this.m_purchaseCount >= this.m_cardCount)
            {
               this.m_refreshOnNextPurchase = true;
            }
         }
         StatsManager.count("dialog",this.m_data.type + "_" + this.m_data.name,"buy","" + param1.code);
         var _loc3_:String = ZGameUtils.ZlocT("Main","FeedbackGiftReceived",{"item":param1.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME)});
         this.addPlopperMessage(_loc3_,false,true);
      }
      
      public function addPlopperMessage(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false, param5:int = 3000) : void
      {
         this.m_messagePlopper.addPendingMessage(param1,param2,param3,param4,param5);
      }
      
      public function animatePurchaseAwardBar() : void
      {
         this.m_prizeMeterBuyBar.meterGlow.gotoAndPlay(2);
         this.m_prizeMeterMc.starBurst_mc.gotoAndPlay(2);
      }
      
      public function animateUnlockAwardBar() : void
      {
         this.m_prizeMeterUnlockBar.meterGlow.gotoAndPlay(2);
         this.m_prizeMeterMc.orangeBurst_mc.gotoAndPlay(2);
      }
      
      private function resetCardCheckMarks() : void
      {
         var _loc1_:MovieClip = null;
         for each(_loc1_ in this.m_cardClips)
         {
            _loc1_.check_mc.visible = false;
         }
      }
      
      private function initCardGameItem(param1:GameItem, param2:MovieClip) : void
      {
         var _loc3_:Loader = null;
         var _loc4_:ZGameButton = null;
         TextFieldUtil.compactTextField(param2.unit_tf,param1.getFriendlyName(GameItem.MENU_FRIENDLYNAME),{
            "minScale":0.7,
            "maxLines":3,
            "fontSize":16,
            "filter":"ignore"
         });
         _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(param1.name,"icon"),param2.icon);
         this.m_iconLoaders.push(_loc3_);
         param2.strength_mc.visible = false;
         param2.icon_class.visible = false;
         if(param1.contractLocked && param1.canBuyContract())
         {
            param2.unlock_bt.visible = true;
            _loc4_ = new ZGameButton(param2.unlock_bt,this.onBuyContractClick);
            _loc4_.text = ZGameUtils.ZlocT("Dialogs","UnlockForAmount",{"amount":param1.contractCost});
            _loc4_.sounds = ButtonSound.DEFAULT;
            this.m_merchButtons.push(_loc4_);
            this.m_unlockButtons[param2] = _loc4_;
         }
         else
         {
            param2.unlock_bt.visible = false;
            ++this.m_unlockCount;
            this.checkAndDoCollapseButtonSpace(param2.buy_bt);
         }
         _loc4_ = new ZGameButton(param2.buy_bt,this.onBuyClick);
         _loc4_.text = ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":param1.cash});
         _loc4_.sounds = ButtonSound.DEFAULT;
         this.m_merchButtons.push(_loc4_);
      }
      
      public function checkAndDoCollapseButtonSpace(param1:MovieClip) : void
      {
         if(this.m_data.collapseCardButton)
         {
            param1.y = MERCH_CARD_YPOS_UNLOCK;
         }
         else
         {
            param1.y = MERCH_CARD_YPOS_BUY;
         }
      }
      
      private function initMerchandisingPrize() : void
      {
         var _loc1_:XMLList = null;
         var _loc2_:XML = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc3_:int = 0;
         _loc1_ = this.m_data.xml.merchData.bonusItems;
         var _loc6_:int = 0;
         var _loc7_:* = _loc1_.item;
         for each(_loc2_ in _loc7_)
         {
            _loc4_ = _loc2_.@code;
            _loc5_ = _loc2_.@classType;
            if(_loc5_ == "unit")
            {
               this.initMerchandisingPrizeUnitItem(_loc4_);
            }
            else
            {
               this.initMerchandisingPrizeGameItem(_loc4_);
            }
         }
         this.m_prizeMeterMc.bgGlow.visible = this.m_data.showCardBg;
         TextFieldUtil.compactTextField(this.m_prizeMeterHeaderText,ZGameUtils.ZlocT("Main","MOTDMerchBonus"),{
            "maxLines":1,
            "minScale":0.7,
            "onFail":"return"
         });
         TextFieldUtil.processTextField(this.m_prizeMeterUnlockText,ZGameUtils.ZlocT("Dialogs","ResearchUnlockContract"));
         TextFieldUtil.processTextField(this.m_prizeMeterBuyText,ZGameUtils.ZlocT("Dialogs","Buy"));
      }
      
      private function initMerchandisingPrizeGameItem(param1:String) : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:Loader = null;
         this.m_prizeMeterPrizeItemIconClassMc.visible = false;
         this.m_prizeItem = _loc2_ = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         TextFieldUtil.compactTextField(this.m_prizeMeterPrizeItemText,_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME),{
            "minScale":0.5,
            "maxLines":3,
            "fontSize":16
         });
         _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc2_.name,"icon"),this.m_prizeMeterPrizeItemIconMc);
         this.m_iconLoaders.push(_loc3_);
         this.m_prizeMeterPrizeItemStrengthMc.visible = false;
      }
      
      private function initMerchandisingPrizeUnitItem(param1:String) : void
      {
         var _loc2_:UnitItem = null;
         var _loc3_:Loader = null;
         this.m_prizeItem = _loc2_ = ZGlobal.gameSettings.getItemByCode(param1,UnitItem) as UnitItem;
         TextFieldUtil.compactTextField(this.m_prizeMeterPrizeItemText,_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME),{
            "minScale":0.5,
            "maxLines":3,
            "fontSize":16
         });
         _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc2_.name,"icon"),this.m_prizeMeterPrizeItemIconMc);
         this.m_iconLoaders.push(_loc3_);
         var _loc4_:UnitClass = UnitClassManager.instance.unitClassNamed(_loc2_.unitClass);
         if(_loc4_)
         {
            this.m_prizeMeterPrizeItemIconClassMc.visible = true;
            _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc4_.getSmIconURL()),this.m_prizeMeterPrizeItemIconClassMc);
            this.m_iconLoaders.push(_loc3_);
         }
         else
         {
            this.m_prizeMeterPrizeItemIconClassMc.visible = false;
         }
         this.m_prizeMeterPrizeItemStrengthMc.visible = true;
         TextFieldUtil.processTextField(this.m_prizeMeterPrizeItemStrengthMc.value_tf,String(_loc2_.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(_loc2_.code))));
      }
      
      private function updatePrizeBuyBar() : void
      {
         var _loc1_:Number = 145;
         this.m_prizeMeterBuyBar.meterColor.y = _loc1_ - _loc1_ / this.m_cardCount * this.m_purchaseCount;
         TextFieldUtil.processTextField(this.m_prizeMeterBuyCountText,"" + this.m_purchaseCount + "/" + this.m_cardCount);
      }
      
      private function updatePrizeUnlockBar() : void
      {
         var _loc1_:Number = 145;
         this.m_prizeMeterUnlockBar.meterColor.y = _loc1_ - _loc1_ / this.m_cardCount * this.m_unlockCount;
         TextFieldUtil.processTextField(this.m_prizeMeterUnlockCountText,"" + this.m_unlockCount + "/" + this.m_cardCount);
      }
      
      private function hideAllCardSets() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 3;
         while(_loc1_ <= 6)
         {
            this.m_cardsMc["cards" + _loc1_ + "_mc"].visible = false;
            _loc1_++;
         }
         this.m_cardsMc.cards8_mc.visible = false;
      }
      
      private function setMerchandisingCardSet(param1:int) : void
      {
         var _loc2_:int = 0;
         this.m_cardCount = param1;
         this.hideAllCardSets();
         this.m_cardSetMc = this.m_cardsMc["cards" + param1 + "_mc"];
         this.m_cardSetMc.visible = true;
         this.m_cardSetMc.bgGlow.visible = this.m_data.showCardBg;
         _loc2_ = 3;
         while(_loc2_ <= 6)
         {
            this.m_prizeMeterBuyBar["meterMarker" + _loc2_ + "_mc"].visible = false;
            this.m_prizeMeterUnlockBar["meterMarker" + _loc2_ + "_mc"].visible = false;
            _loc2_++;
         }
         this.m_prizeMeterBuyBar["meterMarker" + param1 + "_mc"].visible = true;
         this.m_prizeMeterUnlockBar["meterMarker" + param1 + "_mc"].visible = true;
      }
      
      private function initDialogTypeMessage() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Object = null;
         var _loc3_:Player = null;
         var _loc4_:GameItem = null;
         var _loc5_:String = null;
         var _loc6_:Function = null;
         this.initAssetVarsMessage();
         this.m_typeSpecificDeinitFunc = this.deinitDialogMessage;
         this.initScrollButton(this.m_nextButton);
         this.initScrollButton(this.m_prevButton);
         this.m_acceptButton = new ZGameButton(this.m_acceptBtnMc,this.onAcceptClick);
         this.m_soundContainer.addButton(this.m_acceptButton.m_overlay,ButtonSound.DEFAULT);
         if(!this.m_data.requireUserInteract)
         {
            this.m_exitButton.addEventListener(MouseEvent.CLICK,this.onCancelClick);
         }
         if(this.m_data != null)
         {
            TextFieldUtil.compactTextField(this.m_titleTF,this.m_data.titleText,{
               "maxLines":1,
               "minScale":0.7,
               "onFail":"return"
            });
            if(this.m_data.name == "motd_Miniseries_024")
            {
               _loc2_ = new Object();
               _loc3_ = ZGlobal.player;
               if(_loc3_)
               {
                  _loc2_.empire = _loc3_.empireName;
               }
               TextFieldUtil.compactTextField(this.m_titleTF,ZGameUtils.ZlocT("MessageOfTheDay","motd_MS024_Title",_loc2_),{
                  "minScale":0.6,
                  "maxLines":1,
                  "fontSize":30
               });
            }
            _loc1_ = {"minScale":0.7};
            if(ZGlobal.localizer.localeCode == "ja_JP")
            {
               _loc1_ = {
                  "maxLines":2,
                  "minScale":0.7
               };
            }
            this.resetDescriptionTextSize();
            TextFieldUtil.compactTextField(this.m_descriptionTF,this.m_data.descriptionText,_loc1_);
            if(this.m_data.m_discountCode != null)
            {
               _loc4_ = ZGlobal.gameSettings.getItemByCode(this.m_data.m_discountCode,GameItem) as GameItem;
               _loc5_ = _loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
               TextFieldUtil.compactTextField(this.m_descriptionTF,ZGameUtils.ZlocT("MessageOfTheDay","motd_BuildableDiscounts_Msg",{"item":_loc5_}),{"minScale":0.7});
            }
            else
            {
               TextFieldUtil.compactTextField(this.m_descriptionTF,this.m_data.descriptionText,{"minScale":0.7});
            }
            this.setAcceptButtonText();
            this.setLinkButton();
            this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_data.imageURL),this.m_iconUILoader));
            if(this.m_bgImageUILoader != null && this.m_data.bgURL != "")
            {
               _loc6_ = null;
               if(this.m_data.behavior == MOTDData.BEHAVIOR_LIGHTNINGDEAL)
               {
                  _loc6_ = this.lightningDealCallback;
               }
               this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_data.bgURL),this.m_bgImageUILoader,_loc6_));
            }
            this.initBehaviors();
            this.motdStatCount();
            if(this.m_data.m_discountEndDate)
            {
               this.m_clockMc.visible = true;
               this.m_data.xml.requiredDate.@end = this.m_data.m_discountEndDate;
               this.m_clock = this.createCountdownClock();
            }
            else
            {
               this.m_clockMc.visible = this.m_data.shouldShowCountdownClock();
               if(this.m_data.shouldShowCountdownClock())
               {
                  this.m_clock = this.createCountdownClock();
               }
            }
         }
         this.m_nextButton.addEventListener(MouseEvent.CLICK,this.nextButtonClicked,false,0,true);
         this.m_prevButton.addEventListener(MouseEvent.CLICK,this.prevButtonClicked,false,0,true);
         this.refreshButtonVisibility();
      }
      
      private function resetDescriptionTextSize() : void
      {
         var _loc1_:TextFormat = this.m_descriptionTF.defaultTextFormat;
         _loc1_.size = 20;
         this.m_descriptionTF.defaultTextFormat = _loc1_;
      }
      
      private function createCountdownClock() : CountdownClock
      {
         var _loc1_:int = 0;
         if(this.m_data.behavior == MOTDData.BEHAVIOR_LIGHTNINGDEAL)
         {
            _loc1_ = ZGlobal.player.getLightningDealInfo(PromoManager.LD_MC_KEY_DATEEND);
            return new GenericCountdownClock(this.m_clockMc,_loc1_);
         }
         return new MOTDCountdownClock(this.m_clockMc,this.m_data.clockValuesXML,true);
      }
      
      private function refreshButtonVisibility() : void
      {
         this.m_exitButton.visible = !this.m_data.requireUserInteract;
         this.m_nextButton.visible = !this.m_data.hideScrollBarsOnLoad;
         this.m_prevButton.visible = !this.m_data.hideScrollBarsOnLoad;
      }
      
      private function nextButtonClicked(param1:MouseEvent) : void
      {
         StatsManager.count("dialog",this.m_data.type + "_" + this.m_data.name,"scroll_right");
         MessageOfTheDayManager.instance.dispatchEvent(new WorldEvent(MessageOfTheDayManager.EVENT_DIALOG_NEXT));
      }
      
      private function prevButtonClicked(param1:MouseEvent) : void
      {
         StatsManager.count("dialog",this.m_data.type + "_" + this.m_data.name,"scroll_left");
         MessageOfTheDayManager.instance.dispatchEvent(new WorldEvent(MessageOfTheDayManager.EVENT_DIALOG_PREV));
      }
      
      private function initScrollButton(param1:MovieClip) : void
      {
         param1.stop();
         param1.buttonMode = true;
         param1.mouseChildren = false;
         param1.addEventListener(MouseEvent.MOUSE_OVER,this.scrollButtonMouseOver,false,0,true);
         param1.addEventListener(MouseEvent.MOUSE_OUT,this.scrollButtonMouseOut,false,0,true);
      }
      
      private function deinitScrollButton(param1:MovieClip) : void
      {
         param1.removeEventListener(MouseEvent.MOUSE_OVER,this.scrollButtonMouseOver);
         param1.removeEventListener(MouseEvent.MOUSE_OUT,this.scrollButtonMouseOut);
      }
      
      private function scrollButtonMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         _loc2_ = MovieClip(param1.currentTarget);
         _loc2_.gotoAndStop(2);
      }
      
      private function scrollButtonMouseOut(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         _loc2_ = MovieClip(param1.currentTarget);
         _loc2_.gotoAndStop(1);
      }
      
      protected function setAcceptButtonText() : void
      {
         var _loc1_:String = null;
         if(this.m_data)
         {
            if(this.m_data.acceptButtonBehavior == MOTDData.ACCEPT_PLACE_OBJECT && ZGlobal.player.getNumberOfInventoryItems(this.m_data.acceptButtonBehaviorData) > 0 || !(this.m_data.acceptButtonAlternateText && this.m_data.acceptButtonAlternateText.length > 0))
            {
               _loc1_ = this.m_data.acceptButtonText;
            }
            else
            {
               _loc1_ = this.m_data.acceptButtonAlternateText;
            }
            this.m_acceptButton.compactText(_loc1_,{
               "maxLines":1,
               "minScale":0.7,
               "onFail":"return"
            });
         }
      }
      
      protected function setLinkButton() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Rectangle = null;
         if(Boolean(this.m_data) && Boolean(this.m_data.linkUrl))
         {
            _loc1_ = new MovieClip();
            this.m_descriptionTF.parent.addChild(_loc1_);
            _loc2_ = this.m_descriptionTF.getBounds(this.m_descriptionTF.parent);
            _loc1_.graphics.beginFill(16711680,0);
            _loc1_.graphics.drawRect(_loc2_.x,_loc2_.y,_loc2_.width,_loc2_.height);
            _loc1_.graphics.endFill();
            _loc1_.generic_tf = new TextField();
            this.m_linkButton = new ZGameButton(_loc1_,this.onLinkClick);
         }
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         this.m_typeSpecificDeinitFunc();
         if(this.m_lightningDealClaimMC)
         {
            if(this.m_lightningDealClaimMC.parent)
            {
               this.m_lightningDealClaimMC.parent.removeChild(this.m_lightningDealClaimMC);
            }
            this.m_lightningDealClaimMC = null;
         }
      }
      
      private function deinitDialogMerchandising() : void
      {
         var _loc1_:ImageLoader = null;
         var _loc2_:ZGameButton = null;
         this.m_exitButton.removeEventListener(MouseEvent.CLICK,this.onCancelClick);
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = null;
         if(this.m_clock)
         {
            this.m_clock.dispose();
         }
         this.m_clock = null;
         if(this.m_soundContainer)
         {
            this.m_soundContainer.release();
            this.m_soundContainer = null;
         }
         this.m_messagePlopper.dispose();
         this.m_nextButton.removeEventListener(MouseEvent.CLICK,this.nextButtonClicked);
         this.m_prevButton.removeEventListener(MouseEvent.CLICK,this.prevButtonClicked);
         this.deinitScrollButton(this.m_nextButton);
         this.deinitScrollButton(this.m_prevButton);
         for each(_loc2_ in this.m_merchButtons)
         {
            _loc2_.dispose();
         }
         this.m_unlockButtons = null;
      }
      
      private function deinitSurvivalModeRewardRefreshDialogMessage() : void
      {
         var _loc1_:ImageLoader = null;
         this.m_exitButton.removeEventListener(MouseEvent.CLICK,this.onCancelSurvivalClick);
         if(this.m_acceptButton)
         {
            this.m_acceptButton.dispose();
         }
         for each(_loc1_ in this.m_loaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         this.m_loaders = null;
         this.m_nextButton.removeEventListener(MouseEvent.CLICK,this.nextButtonClicked);
         this.m_prevButton.removeEventListener(MouseEvent.CLICK,this.prevButtonClicked);
         this.deinitScrollButton(this.m_nextButton);
         this.deinitScrollButton(this.m_prevButton);
      }
      
      private function deinitDialogMessage() : void
      {
         var _loc1_:ImageLoader = null;
         this.m_exitButton.removeEventListener(MouseEvent.CLICK,this.onCancelClick);
         if(this.m_acceptButton)
         {
            this.m_acceptButton.dispose();
         }
         if(this.m_linkButton)
         {
            this.m_linkButton.dispose();
         }
         if(this.m_linkClip)
         {
            this.m_descriptionTF.parent.removeChild(this.m_linkClip);
         }
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = null;
         if(this.m_clock)
         {
            this.m_clock.dispose();
         }
         this.m_clock = null;
         if(this.m_soundContainer)
         {
            this.m_soundContainer.release();
            this.m_soundContainer = null;
         }
         this.m_nextButton.removeEventListener(MouseEvent.CLICK,this.nextButtonClicked);
         this.m_prevButton.removeEventListener(MouseEvent.CLICK,this.prevButtonClicked);
         this.deinitScrollButton(this.m_nextButton);
         this.deinitScrollButton(this.m_prevButton);
      }
      
      private function deinitDialogPlacement() : void
      {
         this.deinitDialogMessage();
      }
      
      private function onAcceptClick(param1:MouseEvent) : void
      {
         StatsManager.count("dialog",this.m_data.type + "_" + this.m_data.name,"yes");
         MessageOfTheDayManager.instance.dispatchEvent(new WorldEvent(MessageOfTheDayManager.EVENT_DIALOG_ACCEPT));
         this.close();
      }
      
      private function onLinkClick(param1:MouseEvent) : void
      {
         if(Boolean(this.m_data) && Boolean(this.m_data.linkUrl))
         {
            navigateToURL(new URLRequest(this.m_data.linkUrl),null);
         }
      }
      
      private function onCancelClick(param1:MouseEvent) : void
      {
         StatsManager.count("dialog",this.m_data.type + "_" + this.m_data.name,"no");
         MessageOfTheDayManager.instance.dispatchEvent(new WorldEvent(MessageOfTheDayManager.EVENT_DIALOG_DECLINE));
         this.close();
      }
      
      private function onCancelSurvivalClick(param1:MouseEvent) : void
      {
         StatsManager.count("dialog",this.m_data.type + "_" + this.m_data.name,"no");
         MessageOfTheDayManager.instance.dispatchEvent(new WorldEvent(MessageOfTheDayManager.EVENT_DIALOG_ACCEPT,{"cancelAcceptAction":true}));
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.CANCEL));
         super.close(param1);
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         if(this.m_data.behavior == MOTDData.BEHAVIOR_LIGHTNINGDEAL)
         {
            this.m_lightningDealClaimClass = param1.getAssetClass("claim_mc");
         }
         super.onLoadComplete(param1);
      }
      
      public function isTypeMerchandise() : Boolean
      {
         return this.m_data.isTypeMerchandise();
      }
      
      private function initBehaviors() : void
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         if(this.m_data.behavior == MOTDData.BEHAVIOR_LIGHTNINGDEAL && Boolean(this.m_lightningDealClaimClass))
         {
            this.m_lightningDealClaimMC = new this.m_lightningDealClaimClass();
            this.m_iconUILoader.addChild(this.m_lightningDealClaimMC);
            this.m_lightningDealClaimMC.x = LIGHTNINGDEAL_CLAIM_X;
            this.m_lightningDealClaimMC.y = LIGHTNINGDEAL_CLAIM_Y;
            _loc1_ = ZGlobal.player.lightningDealFractionClaimed;
            this.m_lightningDealClaimMC.loadingBar_mc.width = this.m_lightningDealClaimMC.loadingBar_mc.width * _loc1_ / 100;
            _loc2_ = ZGlobal.player.getFriendlyClaimProgressString(_loc1_);
            TextFieldUtil.processTextField(this.m_lightningDealClaimMC.cliam_tf,_loc2_);
         }
      }
      
      public function lightningDealCallback(param1:String, param2:BitmapData) : void
      {
         if(!adjustedHeight)
         {
            adjustedHeight = true;
            this.m_bgImageUILoader.scaleContent = false;
            this.m_bgImageUILoader.maintainAspectRatio = false;
            this.m_bgImageUILoader.height += 20;
            this.m_clockMc.y += 20;
         }
      }
   }
}

