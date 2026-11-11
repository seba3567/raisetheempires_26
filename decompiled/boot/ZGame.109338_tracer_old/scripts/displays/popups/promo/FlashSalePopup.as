package displays.popups.promo
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.promoManager.PromoManager;
   import core.ui.ZGameButton;
   import displays.popups.GallantPopup;
   import displays.popups.MOTDCountdownClock;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TPromoAction;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class FlashSalePopup extends GallantPopup
   {
      
      private var m_flashSale:XML = null;
      
      private var m_optionData:XMLList = null;
      
      private var m_discountData:XMLList = null;
      
      private var m_optionCards:Vector.<MovieClip>;
      
      private var m_purchaseButtons:Vector.<ZGameButton>;
      
      private var m_clock:MOTDCountdownClock = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_isSpecial:Boolean = false;
      
      public function FlashSalePopup(param1:XML, param2:XMLList, param3:XMLList, param4:Boolean = false)
      {
         this.m_flashSale = param1;
         this.m_optionData = param2;
         this.m_discountData = param3;
         this.m_isSpecial = param4;
         var _loc5_:String = "assets/displays/dialogs/PU_FlashSale.swf";
         if(this.m_isSpecial == true)
         {
            _loc5_ = "assets/displays/dialogs/PU_FlashSaleSpecial.swf";
         }
         super(ZGlobal.getAssetURL(_loc5_));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc5_:MovieClip = null;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         super.onLoadComplete(param1);
         var _loc2_:Class = param1.getAssetClass("OptionCard");
         this.m_optionCards = new Vector.<MovieClip>();
         this.m_purchaseButtons = new Vector.<ZGameButton>();
         var _loc3_:XMLList = this.m_flashSale.options.option;
         var _loc4_:int = 0;
         while(_loc4_ < 3 && _loc4_ < _loc3_.length())
         {
            _loc5_ = new _loc2_();
            this.m_optionCards.push(_loc5_);
            m_window.dialog_mc["anchor" + _loc4_].addChild(this.m_optionCards[_loc4_]);
            this.fillOutOptionCard(_loc4_,_loc3_[_loc4_]);
            _loc4_++;
         }
      }
      
      override protected function initDialog() : void
      {
         this.contentWidth = m_window.dialog_mc.bg_mc.width;
         this.contentHeight = m_window.dialog_mc.bg_mc.height;
         super.initDialog();
         m_window.dialog_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClick,false,0,true);
         this.m_buttonSounds.addButton(m_window.dialog_mc.exit_bt,ButtonSound.DEFAULT);
         var _loc1_:String = "promo_FlashSale_Title";
         var _loc2_:String = "promo_FlashSale_OfferTextTopPart";
         var _loc3_:String = "promo_FlashSale_OfferTextDiscount";
         var _loc4_:String = "promo_FlashSale_OfferTextBottomPart";
         if(this.m_isSpecial == true)
         {
            _loc1_ = "promo_FlashSale_Title_special";
            _loc2_ = "promo_FlashSale_OfferTextTopPart_special";
            _loc3_ = "promo_FlashSale_OfferTextDiscount_special";
            _loc4_ = "promo_FlashSale_OfferTextBottomPart_special";
         }
         TextFieldUtil.compactTextField(m_window.dialog_mc.congrats_mc.title_tf,ZGameUtils.ZlocT("Promo",_loc1_));
         TextFieldUtil.compactTextField(m_window.dialog_mc.congrats_mc.playerName_tf,ZGlobal.player.snUser.name);
         TextFieldUtil.compactTextField(m_window.dialog_mc.countdown_tf,ZGameUtils.ZlocT("Promo","promo_FlashSale_EndsIn"));
         if(this.m_discountData.@percent == undefined || parseInt(this.m_discountData.@percent) == 0)
         {
            m_window.dialog_mc.congrats_mc.specialOffer_tf.visible = false;
            m_window.dialog_mc.congrats_mc.info_tf.visible = false;
            TextFieldUtil.compactTextField(m_window.dialog_mc.congrats_mc.noDiscount_tf,ZGameUtils.ZlocT("Promo","promo_FlashSale_OfferTextNoDiscount"));
            TextFieldUtil.compactTextField(m_window.dialog_mc.congrats_mc.percentOff_tf,ZGameUtils.ZlocT("Promo","promo_FlashSale_BuyNow",{"percent":this.m_discountData.@percent}));
            m_window.dialog_mc.congrats_mc.percentOff_tf.y = 130;
         }
         else
         {
            m_window.dialog_mc.congrats_mc.noDiscount_tf.visible = false;
            TextFieldUtil.compactTextField(m_window.dialog_mc.congrats_mc.specialOffer_tf,ZGameUtils.ZlocT("Promo",_loc2_));
            TextFieldUtil.compactTextField(m_window.dialog_mc.congrats_mc.percentOff_tf,ZGameUtils.ZlocT("Promo",_loc3_,{"percent":this.m_discountData.@percent}));
            TextFieldUtil.compactTextField(m_window.dialog_mc.congrats_mc.info_tf,ZGameUtils.ZlocT("Promo",_loc4_));
            m_window.dialog_mc.congrats_mc.percentOff_tf.y = 111;
         }
         this.m_clock = new MOTDCountdownClock(m_window.dialog_mc.clock_mc,this.m_flashSale.criteria[0]);
         StatsManager.count("dialog",PromoManager.getFlashSaleStatsString(this.m_flashSale,"dialogKingdom"),"view");
         TransactionManager.addTransaction(new TPromoAction("view",this.m_flashSale.@type));
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ZGameButton = null;
         super.deinitDialog();
         for each(_loc1_ in this.m_purchaseButtons)
         {
            _loc1_.dispose();
         }
         m_window.dialog_mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClick);
         this.m_buttonSounds.release();
      }
      
      protected function fillOutOptionCard(param1:int, param2:String) : void
      {
         var cost:Number = NaN;
         var costString:String = null;
         var purchaseButton:ZGameButton = null;
         var index:int = param1;
         var optionCode:String = param2;
         var percentDiscount:Number = Number(this.m_discountData.@percent);
         var optionData:XMLList = null;
         if(optionCode)
         {
            optionData = this.m_optionData.(@optionCode == optionCode);
         }
         if(Boolean(this.m_optionCards[index]) && Boolean(optionData))
         {
            TextFieldUtil.compactTextField(this.m_optionCards[index].title_tf,ZGameUtils.ZlocT("Promo","promo_FlashSale_Option",{"num":index + 1}));
            TextFieldUtil.compactTextField(this.m_optionCards[index].points_tf,optionData.@ep.toString());
            cost = optionData.@cost - optionData.@cost * (percentDiscount / 100);
            costString = cost.toString();
            if(costString.indexOf(".") > -1)
            {
               costString = cost.toFixed(2);
            }
            if(isNaN(percentDiscount) || percentDiscount == 0)
            {
               TextFieldUtil.compactTextField(this.m_optionCards[index].currentAmount_tf,ZGameUtils.ZlocT("Promo","promo_FlashSale_Only",{"amount":costString}));
               this.m_optionCards[index].oldAmount_tf.visible = false;
            }
            else
            {
               TextFieldUtil.compactTextField(this.m_optionCards[index].currentAmount_tf,ZGameUtils.ZlocT("Promo","promo_FlashSale_NowOnly",{"amount":costString}));
               TextFieldUtil.compactTextField(this.m_optionCards[index].oldAmount_tf,ZGameUtils.ZlocT("Promo","promo_FlashSale_Was",{"amount":optionData.@cost}));
            }
            purchaseButton = new ZGameButton(this.m_optionCards[index].accept_bt,this.onPurchaseClick);
            purchaseButton.text = ZGameUtils.ZlocT("Promo","promo_FlashSale_PurchaseBtn");
            purchaseButton.buttonObject = {
               "code":this.m_discountData.@itemCode,
               "cost":cost,
               "quantity":optionData.@ep
            };
            this.m_purchaseButtons.push(purchaseButton);
            this.m_buttonSounds.addButton(purchaseButton.m_overlay,ButtonSound.DEFAULT);
         }
      }
      
      protected function onExitClick(param1:MouseEvent) : void
      {
         StatsManager.count("dialog",PromoManager.getFlashSaleStatsString(this.m_flashSale,"dialogKingdom"),"no");
         TransactionManager.addTransaction(new TPromoAction("dismiss",this.m_flashSale.@type));
         close();
      }
      
      private function onPurchaseClick(param1:MouseEvent) : void
      {
         var _loc2_:String = param1.currentTarget.buttonObject.code;
         var _loc3_:Number = Number(param1.currentTarget.buttonObject.cost);
         var _loc4_:int = int(param1.currentTarget.buttonObject.quantity);
         var _loc5_:String = this.m_flashSale.experiment.@name;
         var _loc6_:int = ExperimentsManager.instance.getExperimentVariant(_loc5_);
         var _loc7_:String = PromoManager.getFlashSaleStatsString(this.m_flashSale,"purchasePhylumPrefix") + _loc6_ + "_code" + _loc2_;
         var _loc8_:PromoData = new PromoData();
         _loc8_.popup = this;
         PromoManager.instance.dispatchEvent(new WorldEvent(PromoManager.EVENT_DIALOG_ACCEPT,{
            "packageType":_loc2_,
            "phylum":_loc7_,
            "promoData":_loc8_,
            "quantity":_loc4_
         }));
         StatsManager.count("dialog",PromoManager.getFlashSaleStatsString(this.m_flashSale,"dialogKingdom"),"yes","cost " + _loc3_,"itemcode: " + _loc2_);
      }
   }
}

