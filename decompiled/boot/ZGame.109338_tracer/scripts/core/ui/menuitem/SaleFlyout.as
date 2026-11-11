package core.ui.menuitem
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.managers.promoManager.PromoManager;
   import core.ui.Tooltip;
   import displays.ImageLoader;
   import displays.popups.MOTDCountdownClock;
   import displays.popups.promo.FriendFlashPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class SaleFlyout extends PromoMenuItem
   {
      
      private var mSpacer1:int = 60;
      
      private var mSpacer2:int = 20;
      
      private var m_clock:MOTDCountdownClock;
      
      private var m_clip:MovieClip;
      
      private var m_imageLoader:ImageLoader;
      
      public function SaleFlyout(param1:String)
      {
         swfPath = "assets/ui/SaleFlyout.swf";
         toolTipFileName = "Promo";
         visible = false;
         tweenTimeSeconds = 2;
         super(param1);
         var _loc2_:String = ZGlobal.getAssetURL(swfPath);
         Zlab.resourceManager.load(_loc2_,SWFResource,this.onSwfLoadComplete);
      }
      
      override protected function setUp() : void
      {
      }
      
      private function onSwfLoadComplete(param1:SWFResource) : void
      {
         var _loc3_:String = null;
         var _loc4_:XML = null;
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc2_:Class = param1.getAssetClass("sale_flyout_mc");
         this.m_clip = new _loc2_();
         this.m_clip.addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         this.m_clip.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver,false,0,true);
         this.m_clip.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut,false,0,true);
         this.m_clip.x = 25;
         this.m_clip.y = -180;
         this.m_clip.title_mc.title_tf.autoSize = "left";
         this.m_clip.content_mc.message_mc.message_tf.autoSize = "left";
         if(this.m_clip.shoppingCart_mc)
         {
            this.m_clip.shoppingCart_mc.visible = false;
         }
         if(this.m_clip.BatteryIcon_mc)
         {
            this.m_clip.BatteryIcon_mc.visible = false;
         }
         this.m_clip.epGiftIcon_mc.visible = false;
         if(itemID == PromoManager.PROMO_FRIEND_FLASH)
         {
            this.m_clip.flashSaleIcon_mc.visible = false;
            this.m_clip.freeGiftIcon_mc.visible = false;
            this.m_clip.shoppingCart_mc.visible = false;
            this.m_clip.BatteryIcon_mc.visible = false;
            this.m_clip.epGiftIcon_mc.visible = true;
            this.m_clip.title_mc.visible = true;
            toolTipText = "promo_FriendFlash_toolTip";
            _loc3_ = ZGameUtils.ZlocT(toolTipFileName,toolTipText);
            TextFieldUtil.processTextField(this.m_clip.content_mc.message_mc.message_tf,ZLoc.t("Promo","promo_FriendFlash_text"));
            TextFieldUtil.processTextField(this.m_clip.title_mc.title_tf,ZLoc.t("Promo","promo_FriendFlash_textSale"));
            StatsManager.countSample(100,"HUD_icon","friend_flash","view");
            _loc4_ = PromoManager.instance.friendFlashDateXML;
         }
         else if(itemID == PromoManager.PROMO_UNLIMITED_ENERGY)
         {
            this.m_clip.flashSaleIcon_mc.visible = false;
            this.m_clip.freeGiftIcon_mc.visible = false;
            this.m_clip.shoppingCart_mc.visible = false;
            this.m_clip.BatteryIcon_mc.visible = true;
            this.m_clip.title_mc.visible = true;
            toolTipText = "promo_UnlimitedEnergy_toolTip";
            _loc3_ = ZGameUtils.ZlocT(toolTipFileName,toolTipText);
            TextFieldUtil.processTextField(this.m_clip.content_mc.message_mc.message_tf,ZLoc.t("Promo","promo_UnlimitedEnergy_text"));
            TextFieldUtil.processTextField(this.m_clip.title_mc.title_tf,ZLoc.t("Promo","promo_UnlimitedEnergy_textSale"));
            StatsManager.countSample(100,"HUD_icon","unlimited_energy","view");
            _loc4_ = PromoManager.instance.unlimitedEnergyXML;
         }
         else if(itemID == PromoManager.PROMO_PICK_YOUR_OWN)
         {
            this.m_clip.title_mc.visible = true;
            this.m_clip.freeGiftIcon_mc.visible = false;
            this.m_clip.shoppingCart_mc.visible = true;
            this.m_clip.freeGiftBG_mc.visible = true;
            this.m_clip.flashSaleIcon_mc.visible = false;
            this.m_clip.flashSaleBG_mc.visible = false;
            toolTipText = "bundle_PickYourOwn_Oct2011_01_Title";
            _loc3_ = ZGameUtils.ZlocT(toolTipFileName,toolTipText);
            TextFieldUtil.processTextField(this.m_clip.content_mc.message_mc.message_tf,ZLoc.t("Promo","bundle_PickYourOwn_Oct2011_01_Title"));
            TextFieldUtil.processTextField(this.m_clip.title_mc.title_tf,ZLoc.t("Promo","promo_RepeatPackHUD_textSale"));
            _loc4_ = PromoManager.instance.getPickYourOwnXML();
            if(_loc4_)
            {
               _loc4_ = new XML(_loc4_.criteria.toXMLString());
            }
            StatsManager.countSample(100,"HUD_icon","bundle2","view");
         }
         else if(itemID == PromoManager.PROMO_REPEAT_PAYER)
         {
            this.m_clip.title_mc.visible = true;
            this.m_clip.freeGiftIcon_mc.visible = true;
            this.m_clip.shoppingCart_mc.visible = false;
            this.m_clip.freeGiftBG_mc.visible = true;
            this.m_clip.flashSaleIcon_mc.visible = false;
            this.m_clip.flashSaleBG_mc.visible = false;
            this.m_clip.BatteryIcon_mc.visible = false;
            toolTipText = "promo_RepeatPackHUD_toolTip";
            _loc3_ = ZGameUtils.ZlocT(toolTipFileName,toolTipText);
            TextFieldUtil.processTextField(this.m_clip.content_mc.message_mc.message_tf,ZLoc.t("Promo","promo_RepeatPackHUD_textFreeGift"));
            TextFieldUtil.processTextField(this.m_clip.title_mc.title_tf,ZLoc.t("Promo","promo_RepeatPackHUD_textSale"));
            _loc4_ = PromoManager.instance.getRepeatPayerXML();
            StatsManager.countSample(100,"HUD_icon","payer_pack","view");
         }
         else
         {
            this.m_clip.freeGiftIcon_mc.visible = false;
            this.m_clip.shoppingCart_mc.visible = false;
            this.m_clip.freeGiftBG_mc.visible = false;
            this.m_clip.BatteryIcon_mc.visible = false;
            this.m_clip.flashSaleIcon_mc.visible = true;
            this.m_clip.flashSaleBG_mc.visible = true;
            _loc5_ = PromoManager.instance.getFlashSale(itemID);
            _loc6_ = PromoManager.getFlashSaleStatsString(_loc5_,"hudIconKingdom");
            StatsManager.countSample(100,"HUD_icon",_loc6_,"view");
            _loc7_ = PromoManager.instance.getFlashSaleDiscount(_loc5_);
            _loc4_ = _loc5_.criteria[0];
            if(_loc7_ == 0)
            {
               this.m_clip.title_mc.visible = false;
               toolTipText = "promo_FlashSaleHUD_NoDiscount_toolTip";
               _loc3_ = ZGameUtils.ZlocT(toolTipFileName,toolTipText);
               TextFieldUtil.processTextField(this.m_clip.content_mc.message_mc.message_tf,ZLoc.t("Promo","promo_FlashSaleHUD_textNoPercentOff"));
            }
            else
            {
               this.m_clip.title_mc.visible = true;
               toolTipText = "promo_FlashSaleHUD_toolTip";
               _loc3_ = ZGameUtils.ZlocT(toolTipFileName,toolTipText,{"percent":_loc7_});
               TextFieldUtil.processTextField(this.m_clip.content_mc.message_mc.message_tf,ZLoc.t("Promo","promo_FlashSaleHUD_textPercentOff",{"percent":_loc7_}));
               TextFieldUtil.processTextField(this.m_clip.title_mc.title_tf,ZLoc.t("Promo","promo_RepeatPackHUD_textSale"));
            }
         }
         this.m_clock = new MOTDCountdownClock(this.m_clip.content_mc.clock.clock_mc,_loc4_);
         this.hideClock();
         this.FormatFlyout();
         Tooltip.subscribe(this.m_clip,_loc3_);
         addChild(this.m_clip);
         show(false);
      }
      
      private function showClock() : void
      {
         Zlab.processManager.schedule(7000,this,this.hideClock);
         this.m_clip.content_mc.gotoAndPlay("_showClock");
      }
      
      private function hideClock() : void
      {
         Zlab.processManager.schedule(3000,this,this.showClock);
         this.m_clip.content_mc.gotoAndPlay("_hideClock");
      }
      
      private function FormatFlyout() : void
      {
         var _loc1_:Number = (this.m_clip.content_mc.message_mc.width - this.m_clip.content_mc.clock.width) / 2;
         this.m_clip.content_mc.x = (this.m_clip.content_mc.width + this.mSpacer1) * -1;
         this.m_clip.title_mc.x = (this.m_clip.content_mc.width + this.mSpacer1 + this.m_clip.title_mc.width + this.mSpacer2) * -1;
         if(itemID == PromoManager.PROMO_REPEAT_PAYER)
         {
            this.m_clip.freeGiftBG_mc.frame.width = this.m_clip.title_mc.x * -1 - this.mSpacer1;
         }
         else
         {
            this.m_clip.flashSaleBG_mc.frame.width = this.m_clip.title_mc.x * -1 - this.mSpacer1;
         }
         if(_loc1_ > 0)
         {
            this.m_clip.content_mc.clock.clock_mc.x = _loc1_;
         }
         else
         {
            this.m_clip.content_mc.message_mc.message_tf.x = _loc1_ * -1;
         }
         this.m_clip.content_mc.mask_mc.width = this.m_clip.content_mc.width;
      }
      
      override protected function cleanup() : void
      {
         super.cleanup();
         Zlab.processManager.removeScheduledObject(this);
         if(this.m_clip)
         {
            if(this.m_clip.parent)
            {
               this.m_clip.parent.removeChild(this.m_clip);
            }
            this.m_clip.removeEventListener(MouseEvent.CLICK,this.onClicked);
            this.m_clip.removeEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
            this.m_clip.removeEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
            Tooltip.unsubscribe(this.m_clip);
            this.m_clip = null;
         }
         if(this.m_imageLoader)
         {
            this.m_imageLoader.destroy();
            this.m_imageLoader = null;
         }
      }
      
      override protected function onClicked(param1:MouseEvent) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         super.onClicked(param1);
         if(itemID == PromoManager.PROMO_FRIEND_FLASH)
         {
            _loc3_ = "friend_flash";
            PromoManager.instance.openPromoFriendFlash(FriendFlashPopup.SOURCE_HUD);
         }
         else if(itemID == PromoManager.PROMO_UNLIMITED_ENERGY)
         {
            _loc3_ = "unlimited_energy";
            PromoManager.instance.openUnlimitedEnergyPopup();
         }
         else if(itemID == PromoManager.PROMO_PICK_YOUR_OWN)
         {
            _loc3_ = "bundle2";
            PromoManager.instance.openBundledItemsPromoPopup();
         }
         else if(itemID == PromoManager.PROMO_REPEAT_PAYER)
         {
            _loc3_ = "payer_pack";
            PromoManager.instance.openRepeatPayerPackPopup();
         }
         else
         {
            _loc2_ = PromoManager.instance.getFlashSale(itemID);
            _loc3_ = PromoManager.getFlashSaleStatsString(_loc2_,"hudIconKingdom");
            if(PromoManager.instance.getAutoPromotionExperimentVariant() <= 2)
            {
               PromoManager.instance.runPromoFlashSale(_loc2_);
            }
            else
            {
               PromoManager.instance.runAutoPromoFlashSale(_loc2_);
            }
         }
         StatsManager.countSample(100,"HUD_icon",_loc3_,"icon_clicked","delay","","",elapsedSinceShow);
      }
   }
}

