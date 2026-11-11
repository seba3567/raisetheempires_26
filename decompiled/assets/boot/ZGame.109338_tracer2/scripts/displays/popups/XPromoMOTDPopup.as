package displays.popups
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.ExperimentsManager;
   import core.managers.MOTDManager.MOTDData;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.promoManager.PromoManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import fl.containers.UILoader;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TAcceptXPromo;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class XPromoMOTDPopup extends GallantPopup
   {
      
      public static const MERCH_CARD_YPOS_UNLOCK:Number = 124.55;
      
      public static const MERCH_CARD_YPOS_BUY:Number = 152.1;
      
      private static const LIGHTNINGDEAL_CLAIM_X:int = 325;
      
      private static const LIGHTNINGDEAL_CLAIM_Y:int = 40;
      
      public static const XPROMO_MOTD_VERSION:uint = 2;
      
      public static const XPROMO_STATS_PREFIX:String = "xpromo_motd";
      
      private var m_data:Object;
      
      private var m_titleTF:TextField;
      
      private var m_descriptionTF:TextField;
      
      private var m_iconUILodaer:UILoader;
      
      private var m_acceptButton:ZGameButton;
      
      private var m_linkClip:MovieClip = null;
      
      private var m_linkButton:ZGameButton = null;
      
      private var m_exitButton:SimpleButton;
      
      private var m_clock:CountdownClock = null;
      
      private var m_loaders:Vector.<ImageLoader>;
      
      private var m_soundContainer:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      private var m_nextButton:MovieClip;
      
      private var m_prevButton:MovieClip;
      
      public var m_acceptBtnMc:MovieClip;
      
      public var m_clockMc:MovieClip;
      
      public var m_panelMc:MovieClip;
      
      private var m_motdVersion:int = XPROMO_MOTD_VERSION;
      
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
      
      public function XPromoMOTDPopup(param1:Object)
      {
         this.m_data = param1;
         super(ZGlobal.getAssetURL(this.swfPath));
         this.m_loaders = new Vector.<ImageLoader>();
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
         this.initAssetVarsMessage();
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
         this.m_iconUILodaer = m_window.motd_mc.icon_uil;
         this.m_exitButton = m_window.motd_mc.exit_bt;
         this.m_nextButton = m_window.motd_mc.next_bt;
         this.m_prevButton = m_window.motd_mc.prev_bt;
         this.m_acceptBtnMc = m_window.motd_mc.accept_mc;
         this.m_clockMc = m_window.motd_mc.clock_mc;
         this.m_panelMc = m_window.motd_mc.panel_mc;
         this.m_clockMc.visible = false;
         this.m_nextButton.visible = false;
         this.m_prevButton.visible = false;
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
         this.m_iconUILodaer = _loc1_.image_mc;
         this.m_exitButton = m_window.motd_mc.exit_bt;
         this.m_nextButton = m_window.motd_mc.next_bt;
         this.m_prevButton = m_window.motd_mc.prev_bt;
         this.m_acceptBtnMc = _loc1_.action_mc;
         this.m_clockMc = _loc1_.clock_mc;
         this.m_panelMc = m_window.motd_mc.panel_mc;
         _loc1_.timerText1_tf.visible = false;
         _loc1_.timerText2_tf.visible = false;
         this.m_clockMc.visible = false;
         this.m_nextButton.visible = false;
         this.m_prevButton.visible = false;
         if(ExperimentsManager.instance.getExperimentVariant("empires_xpromo_forced_flow") == 2)
         {
            this.m_exitButton.visible = false;
         }
         else
         {
            this.m_exitButton.visible = true;
         }
      }
      
      private function initAssetVarsPlacement() : void
      {
         this.initAssetVarsMessage();
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
         this.initDialogTypeMessage();
      }
      
      private function initDialogTypePlacement() : void
      {
         this.initDialogTypeMessage();
         this.m_typeSpecificDeinitFunc = this.deinitDialogPlacement;
      }
      
      private function motdStatCount() : void
      {
         if(this.m_data.version >= 2)
         {
            StatsManager.count("dialog",XPROMO_STATS_PREFIX + "_" + this.m_data.id,"view");
         }
         else
         {
            StatsManager.count("dialog",XPROMO_STATS_PREFIX,"view");
         }
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
         TextFieldUtil.compactTextField(param2.unit_tf,param1.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
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
         param2.unlock_bt.visible = false;
      }
      
      private function initCardGameItem(param1:GameItem, param2:MovieClip) : void
      {
         var _loc3_:Loader = null;
         var _loc4_:ZGameButton = null;
         TextFieldUtil.compactTextField(param2.unit_tf,param1.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(param1.name,"icon"),param2.icon);
         this.m_iconLoaders.push(_loc3_);
         param2.strength_mc.visible = false;
         param2.icon_class.visible = false;
         param2.unlock_bt.visible = false;
      }
      
      private function initDialogTypeMessage() : void
      {
         var _loc1_:Object = null;
         var _loc2_:GameItem = null;
         var _loc3_:String = null;
         this.initAssetVarsMessage();
         this.m_typeSpecificDeinitFunc = this.deinitDialogMessage;
         this.m_acceptButton = new ZGameButton(this.m_acceptBtnMc,this.onAcceptClick);
         this.m_soundContainer.addButton(this.m_acceptButton.m_overlay,ButtonSound.DEFAULT);
         if(!this.m_data.requireUserInteract)
         {
            this.m_exitButton.addEventListener(MouseEvent.CLICK,this.onCancelClick);
         }
         if(this.m_data != null)
         {
            TextFieldUtil.compactTextField(this.m_titleTF,ZGameUtils.ZlocT("MessageOfTheDay",this.m_data.ui.popup_title),{
               "maxLines":1,
               "minScale":0.7,
               "onFail":"return"
            });
            _loc1_ = {"minScale":0.7};
            if(ZGlobal.localizer.localeCode == "ja_JP")
            {
               _loc1_ = {
                  "maxLines":2,
                  "minScale":0.7
               };
            }
            TextFieldUtil.compactTextField(this.m_descriptionTF,ZGameUtils.ZlocT("MessageOfTheDay",this.m_data.ui.popup_text),_loc1_);
            if(this.m_data.m_discountCode != null)
            {
               _loc2_ = ZGlobal.gameSettings.getItemByCode(this.m_data.m_discountCode,GameItem) as GameItem;
               _loc3_ = _loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
               TextFieldUtil.compactTextField(this.m_descriptionTF,ZGameUtils.ZlocT("MessageOfTheDay","motd_BuildableDiscounts_Msg",{"item":_loc3_}),{"minScale":0.7});
            }
            else
            {
               TextFieldUtil.compactTextField(this.m_descriptionTF,ZGameUtils.ZlocT("MessageOfTheDay",this.m_data.ui.popup_text),{"minScale":0.7});
            }
            this.setAcceptButtonText();
            this.setLinkButton();
            this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_data.ui.popup_image),this.m_iconUILodaer));
            this.motdStatCount();
         }
         this.m_nextButton.addEventListener(MouseEvent.CLICK,this.nextButtonClicked,false,0,true);
         this.m_prevButton.addEventListener(MouseEvent.CLICK,this.prevButtonClicked,false,0,true);
      }
      
      private function nextButtonClicked(param1:MouseEvent) : void
      {
         StatsManager.count("dialog",XPROMO_STATS_PREFIX + "_" + this.m_data.id,"scroll_right");
         MessageOfTheDayManager.instance.dispatchEvent(new WorldEvent(MessageOfTheDayManager.EVENT_DIALOG_NEXT));
      }
      
      private function prevButtonClicked(param1:MouseEvent) : void
      {
         StatsManager.count("dialog",XPROMO_STATS_PREFIX + "_" + this.m_data.id,"scroll_left");
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
            this.m_acceptButton.compactText(ZGameUtils.ZlocT("MessageOfTheDay",this.m_data.ui.popup_btn_text),{
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
      
      private function deinitDialogMessage() : void
      {
         var _loc1_:ImageLoader = null;
         this.m_exitButton.removeEventListener(MouseEvent.CLICK,this.onCancelClick);
         this.m_acceptButton.dispose();
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
         if(this.m_data.state != "ACCEPTED")
         {
            StatsManager.count("dialog",XPROMO_STATS_PREFIX + "_" + this.m_data.id,"yes");
            TransactionManager.addTransaction(new TAcceptXPromo(this.m_data.id));
         }
         if(this.m_data.state)
         {
            if(this.m_data.state == "NEW" && ExperimentsManager.instance.getExperimentVariant("empires_xpromo_sametab") == 2)
            {
               PromoManager.instance.addEventListener(PromoManager.XPROMO_ACCEPT_TRANSACTION_COMPLETED,this.sendToGame);
            }
            else
            {
               navigateToURL(new URLRequest(this.m_data.ui.play_url),null);
               this.close();
            }
         }
      }
      
      private function sendToGame(param1:WorldEvent) : void
      {
         PromoManager.instance.removeEventListener(PromoManager.XPROMO_ACCEPT_TRANSACTION_COMPLETED,this.sendToGame);
         navigateToURL(new URLRequest(this.m_data.ui.play_url),"_top");
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
         if(this.m_data.state != "ACCEPTED")
         {
            StatsManager.count("dialog",XPROMO_STATS_PREFIX + "_" + this.m_data.id,"no");
            TransactionManager.addTransaction(new TAcceptXPromo(this.m_data.id));
         }
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
   }
}

