package displays.popups.promo
{
   import Engine.Managers.StatsManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.ExperimentsManager;
   import core.managers.TierSurfacingManager;
   import core.managers.promoManager.PromoManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.MOTDCountdownClock;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.ItemTooltip;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class PickYourOwnPromoPopup extends GallantPopup
   {
      
      private const LOCALIZATION_FILE:String = "Promo";
      
      private const SELECTED_CARDS_COUNT:int = 3;
      
      private const AVAILABLE_CARDS_COUNT:int = 5;
      
      private var m_xml:XML = null;
      
      private var m_item:GameItem = null;
      
      private var m_buyBtn:ZGameButton = null;
      
      private var m_exitBtn:ZGameButton = null;
      
      private var m_iconLoaders:Array = null;
      
      private var m_clock:MOTDCountdownClock = null;
      
      private var m_itemsAvailable:Array;
      
      private var m_itemsSelected:Array;
      
      private var m_availableCards:Array;
      
      private var m_selectedCards:Array;
      
      private var m_scrollOffset:int = 0;
      
      private var m_tooltip:ItemTooltip;
      
      public function PickYourOwnPromoPopup(param1:XML)
      {
         this.m_xml = param1;
         var _loc2_:String = "assets/displays/dialogs/PU_CustomBundle.swf";
         if(this.m_xml.@asset != undefined)
         {
            _loc2_ = this.m_xml.@asset.toString();
         }
         super(ZGlobal.getAssetURL(_loc2_));
      }
      
      public static function getPriceDiscountPercent() : Number
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         if(PromoManager.instance.getAutoPromotionExperimentVariant() > 2)
         {
            _loc2_ = PromoManager.instance.getOngoingAutopromoParamByName("discount");
            return Number(_loc2_);
         }
         _loc1_ = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BUNDLE_PICK_YOUR_OWN);
         switch(_loc1_)
         {
            default:
            case 0:
            case 1:
               return 0;
            case 2:
               return 20;
            case 3:
               return 30;
            case 4:
               return 40;
            case 5:
               return 50;
            case 6:
               return 75;
            case 7:
               return 90;
         }
      }
      
      override protected function initializeScreen() : void
      {
         var _loc3_:* = 0;
         var _loc4_:MovieClip = null;
         m_window = m_window.customBundle_mc;
         contentWidth = m_window.background_mc.width;
         contentHeight = m_window.background_mc.height;
         super.initializeScreen();
         m_window.background_mc.visible = false;
         var _loc1_:MovieClip = m_window;
         TextFieldUtil.processTextField(_loc1_.title_tf,this.localizedStringForKey(this.m_xml.@title));
         var _loc2_:String = this.m_xml.@discount;
         if(_loc2_.length)
         {
            TextFieldUtil.processTextField(_loc1_.burst_tf,this.localizedStringForKey(this.m_xml.@discount));
         }
         else
         {
            TextFieldUtil.processTextField(_loc1_.burst_tf,this.localizedStringForKey("Dialogs:BuyNow"));
         }
         TextFieldUtil.compactTextField(_loc1_.sale_mc.percent_tf,ZGameUtils.ZlocT("Promo","promo_FlashSale_OfferTextDiscount",{"percent":getPriceDiscountPercent()}));
         TextFieldUtil.processTextField(_loc1_.available_tf,ZGameUtils.ZlocT("Dialogs","CombatSetupUnitSelectTitle"));
         ZGameUtils.hideIfExists(_loc1_.discount_tf);
         TextFieldUtil.processTextField(_loc1_.body_tf,this.localizedStringForKey(this.m_xml.@desc));
         TextFieldUtil.processTextField(_loc1_.body2_tf,this.localizedStringForKey(this.m_xml.@subDesc));
         _loc1_.exit_mc.generic_tf = new TextField();
         this.m_exitBtn = new ZGameButton(_loc1_.exit_mc,this.onCancel,1.1,true);
         this.m_buyBtn = new ZGameButton(_loc1_.buy_mc,this.onBuyButton,1.1,true);
         this.m_clock = new MOTDCountdownClock(_loc1_.clock_mc,this.m_xml.criteria[0]);
         this.m_iconLoaders = new Array();
         this.m_item = ZGlobal.gameSettings.getItemByCode(this.m_xml.@bundleItemCode,GameItem) as GameItem;
         if(this.m_item)
         {
            this.m_itemsAvailable = this.m_xml.@itemChoices.split(",");
            _loc3_ = 0;
            while(_loc3_ < this.m_itemsAvailable.length)
            {
               if(!ZGlobal.gameSettings.getItemByCode(this.m_itemsAvailable[_loc3_],GameItem))
               {
                  this.m_itemsAvailable.splice(_loc3_,1);
                  _loc3_--;
               }
               _loc3_++;
            }
            this.m_itemsSelected = new Array();
            this.m_scrollOffset = 0;
            this.m_selectedCards = new Array();
            _loc3_ = 0;
            while(_loc3_ < this.SELECTED_CARDS_COUNT)
            {
               _loc4_ = _loc1_["unitCard" + (_loc3_ + 1) + "_mc"];
               _loc4_.cardIdx = _loc3_;
               _loc4_.on_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onRemoveClick,false,0,true);
               TextFieldUtil.processTextField(_loc4_.off_mc.add_tf,ZGameUtils.ZlocT("Dialogs","Add"));
               this.m_selectedCards.push(_loc4_);
               _loc3_++;
            }
            this.m_availableCards = new Array();
            _loc3_ = 0;
            while(_loc3_ < this.AVAILABLE_CARDS_COUNT)
            {
               _loc4_ = _loc1_["addUnitCard" + (_loc3_ + 1) + "_mc"];
               _loc4_.cardIdx = _loc3_;
               _loc4_.addButton = new ZGameButton(_loc4_.add_mc,this.onAddClick);
               TextFieldUtil.processTextField(_loc4_.add_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","Add"));
               _loc4_.unitIcon.addEventListener(MouseEvent.MOUSE_OVER,this.onRollOver,false,0,true);
               _loc4_.unitIcon.addEventListener(MouseEvent.MOUSE_OUT,this.onRollOut,false,0,true);
               this.m_availableCards.push(_loc4_);
               _loc3_++;
            }
            _loc1_.left_bt.addEventListener(MouseEvent.CLICK,this.onScrollLeftClick,false,0,true);
            _loc1_.right_bt.addEventListener(MouseEvent.CLICK,this.onScrollRightClick,false,0,true);
            this.updateCards();
         }
         else
         {
            this.onCancel(null);
         }
         m_window.parent.y -= 15;
         StatsManager.count("dialog",this.m_xml.@name,"view");
         ZGlobal.player.setSeenFlag(this.m_xml.@name);
      }
      
      private function updateCards() : void
      {
         var _loc1_:ImageLoader = null;
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc8_:TextFormat = null;
         var _loc9_:MovieClip = null;
         var _loc10_:String = null;
         var _loc11_:GameItem = null;
         var _loc12_:ImageLoader = null;
         var _loc13_:UnitItem = null;
         var _loc14_:int = 0;
         var _loc15_:UnitClass = null;
         var _loc16_:String = null;
         var _loc17_:int = 0;
         for each(_loc1_ in this.m_iconLoaders)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         _loc2_ = {
            "maxLines":2,
            "minScale":0.2
         };
         _loc3_ = 0;
         while(_loc3_ < this.m_selectedCards.length)
         {
            _loc9_ = this.m_selectedCards[_loc3_];
            if(_loc3_ < this.m_itemsSelected.length)
            {
               _loc9_.on_mc.visible = true;
               _loc9_.off_mc.visible = false;
               _loc10_ = this.m_itemsSelected[_loc3_];
               if(_loc9_.on_mc.tierRating_mc)
               {
                  _loc9_.on_mc.tierRating_mc.visible = false;
               }
               _loc11_ = ZGlobal.gameSettings.getItemByCode(this.m_itemsSelected[_loc3_],GameItem) as GameItem;
               _loc12_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc11_.name,"icon"),_loc9_.on_mc.unitIcon);
               this.m_iconLoaders.push(_loc12_);
               _loc8_ = _loc9_.on_mc.unitName_tf.defaultTextFormat;
               _loc8_.size = 12.5;
               _loc9_.on_mc.unitName_tf.defaultTextFormat = _loc8_;
               TextFieldUtil.compactTextField(_loc9_.on_mc.unitName_tf,_loc11_.getFriendlyName(GameItem.MENU_FRIENDLYNAME),_loc2_);
               _loc9_.on_mc.underlay_mc.visible = _loc9_.on_mc.unitName_tf.numLines > 1;
               _loc9_.on_mc.quantity_tf.visible = false;
               if(_loc11_.isUnit())
               {
                  _loc13_ = ZGlobal.gameSettings.getItemByCode(_loc10_,UnitItem) as UnitItem;
                  _loc14_ = _loc13_.getStrength(null);
                  _loc15_ = UnitClassManager.instance.unitClassForUnit(_loc13_);
                  _loc9_.on_mc.class_mc.visible = true;
                  _loc12_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc15_.getIconURL()),_loc9_.on_mc.class_mc.classIcon);
                  this.m_iconLoaders.push(_loc12_);
                  _loc9_.on_mc.class_mc.visible = true;
                  TextFieldUtil.processTextField(_loc9_.on_mc.class_mc.energy_tf,_loc14_.toString());
                  if(Boolean(_loc9_.on_mc.tierRating_mc) && TierSurfacingManager.instance.tierSurfacingEnabled)
                  {
                     TextFieldUtil.compactTextField(_loc9_.on_mc.tierRating_mc.tier_tf,_loc13_.tier.toString());
                     _loc9_.on_mc.tierRating_mc.visible = true;
                  }
               }
               else
               {
                  _loc9_.on_mc.class_mc.visible = false;
               }
            }
            else
            {
               _loc9_.on_mc.visible = false;
               _loc9_.off_mc.visible = true;
            }
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < this.m_availableCards.length)
         {
            _loc9_ = this.m_availableCards[_loc3_];
            _loc9_.tooltip_mc.visible = false;
            _loc9_.tooltipSmall_mc.visible = false;
            if(_loc9_.tierRating_mc)
            {
               _loc9_.tierRating_mc.visible = false;
            }
            _loc10_ = this.m_itemsAvailable[_loc3_ + this.m_scrollOffset];
            _loc11_ = ZGlobal.gameSettings.getItemByCode(_loc10_,GameItem) as GameItem;
            _loc12_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc11_.name,"icon"),_loc9_.unitIcon);
            this.m_iconLoaders.push(_loc12_);
            _loc8_ = _loc9_.unitName_tf.defaultTextFormat;
            _loc8_.size = 12.5;
            _loc9_.unitName_tf.defaultTextFormat = _loc8_;
            TextFieldUtil.compactTextField(_loc9_.unitName_tf,_loc11_.getFriendlyName(GameItem.MENU_FRIENDLYNAME),_loc2_);
            _loc9_.underlay_mc.visible = _loc9_.unitName_tf.numLines > 1;
            _loc9_.quantity_tf.visible = false;
            if(_loc11_.isUnit())
            {
               _loc13_ = ZGlobal.gameSettings.getItemByCode(_loc10_,UnitItem) as UnitItem;
               _loc14_ = _loc13_.getStrength(null);
               _loc15_ = UnitClassManager.instance.unitClassForUnit(_loc13_);
               _loc9_.class_mc.visible = true;
               _loc12_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc15_.getIconURL()),_loc9_.class_mc.classIcon);
               this.m_iconLoaders.push(_loc12_);
               TextFieldUtil.processTextField(_loc9_.class_mc.energy_tf,_loc14_.toString());
               if(Boolean(_loc9_.tierRating_mc) && TierSurfacingManager.instance.tierSurfacingEnabled)
               {
                  TextFieldUtil.compactTextField(_loc9_.tierRating_mc.tier_tf,_loc13_.tier.toString());
                  _loc9_.tierRating_mc.visible = true;
               }
            }
            else
            {
               _loc9_.class_mc.visible = false;
            }
            if(this.m_itemsSelected.length == this.m_selectedCards.length)
            {
               _loc9_.addButton.disable_visual();
            }
            else
            {
               _loc9_.addButton.enable();
            }
            _loc3_++;
         }
         var _loc4_:MovieClip = m_window;
         var _loc5_:Boolean = this.m_scrollOffset > 0;
         var _loc6_:Boolean = this.m_scrollOffset + this.m_availableCards.length < this.m_itemsAvailable.length;
         _loc4_.left_bt.mouseEnabled = _loc5_;
         _loc4_.left_bt.filters = _loc5_ ? [] : [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
         _loc4_.right_bt.mouseEnabled = _loc6_;
         _loc4_.right_bt.filters = _loc6_ ? [] : [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
         var _loc7_:Number = this.getPriceTotal();
         if(_loc7_ > 0)
         {
            _loc4_.body2_tf.visible = true;
            _loc16_ = ZGameUtils.ZlocT("Promo","promo_FlashSale_Was",{"amount":this.getPriceOriginal()});
            _loc16_ = _loc16_.split("$").join("");
            _loc16_ = _loc16_.split("USD").join("");
            _loc16_ = _loc16_.split("  ").join(" ");
            TextFieldUtil.processTextField(_loc4_.body2_tf,_loc16_);
            _loc17_ = 5;
            _loc4_.strikethrough_mc.visible = true;
            _loc4_.strikethrough_mc.x = _loc4_.body2_tf.x + _loc4_.body2_tf.width / 2;
            _loc4_.strikethrough_mc.width = _loc4_.body2_tf.textWidth + _loc17_ * 2;
            TextFieldUtil.processTextField(_loc4_.buy_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":_loc7_}));
         }
         else
         {
            _loc4_.body2_tf.visible = false;
            _loc4_.strikethrough_mc.visible = false;
            TextFieldUtil.processTextField(_loc4_.buy_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","BuyNow"));
         }
         if(this.m_itemsSelected.length < this.m_selectedCards.length)
         {
            this.m_buyBtn.disable_visual();
         }
         else
         {
            this.m_buyBtn.enable();
         }
      }
      
      override protected function deinitDialog() : void
      {
         var _loc2_:ImageLoader = null;
         var _loc3_:MovieClip = null;
         var _loc1_:MovieClip = m_window;
         _loc1_.exit_mc.removeEventListener(MouseEvent.CLICK,this.onCancel);
         if(this.m_exitBtn)
         {
            this.m_exitBtn.dispose();
            this.m_exitBtn = null;
         }
         if(this.m_buyBtn)
         {
            this.m_buyBtn.dispose();
            this.m_buyBtn = null;
         }
         for each(_loc2_ in this.m_iconLoaders)
         {
            if(_loc2_)
            {
               _loc2_.destroy();
            }
         }
         if(this.m_clock)
         {
            this.m_clock.dispose();
            this.m_clock = null;
         }
         for each(_loc3_ in this.m_selectedCards)
         {
            _loc3_.on_mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.onRemoveClick);
         }
         for each(_loc3_ in this.m_availableCards)
         {
            _loc3_.unitIcon.removeEventListener(MouseEvent.MOUSE_OVER,this.onRollOver);
            _loc3_.unitIcon.removeEventListener(MouseEvent.MOUSE_OUT,this.onRollOut);
            _loc3_.addButton.dispose();
            _loc3_.addButton = null;
         }
         if(this.m_tooltip)
         {
            this.m_tooltip.destroy();
            this.m_tooltip = null;
         }
         _loc1_.left_bt.removeEventListener(MouseEvent.CLICK,this.onScrollLeftClick);
         _loc1_.right_bt.removeEventListener(MouseEvent.CLICK,this.onScrollRightClick);
         super.deinitDialog();
      }
      
      private function localizedStringForKey(param1:String) : String
      {
         if(param1 == null || param1 == "")
         {
            return "";
         }
         var _loc2_:Array = param1.split(":");
         if(_loc2_.length > 1)
         {
            return ZGameUtils.ZlocT(_loc2_[0],_loc2_[1]);
         }
         return ZGameUtils.ZlocT(this.LOCALIZATION_FILE,param1);
      }
      
      private function onAddClick(param1:MouseEvent) : void
      {
         var _loc2_:int = int(param1.currentTarget.parent.cardIdx);
         if(this.m_itemsSelected.length < this.SELECTED_CARDS_COUNT)
         {
            this.m_itemsSelected.push(this.m_itemsAvailable[_loc2_ + this.m_scrollOffset]);
            this.updateCards();
         }
      }
      
      private function onRemoveClick(param1:MouseEvent) : void
      {
         var _loc2_:int = int(param1.currentTarget.parent.parent.cardIdx);
         if(_loc2_ >= 0 && _loc2_ < this.m_itemsSelected.length)
         {
            this.m_itemsSelected.splice(_loc2_,1);
            this.updateCards();
         }
      }
      
      private function onScrollLeftClick(param1:MouseEvent) : void
      {
         if(this.m_scrollOffset > 0)
         {
            --this.m_scrollOffset;
            this.updateCards();
         }
      }
      
      private function onScrollRightClick(param1:MouseEvent) : void
      {
         if(this.m_scrollOffset + this.m_availableCards.length < this.m_itemsAvailable.length)
         {
            ++this.m_scrollOffset;
            this.updateCards();
         }
      }
      
      private function onCancel(param1:MouseEvent) : void
      {
         close();
         StatsManager.count("dialog",this.m_xml.@name,"no");
         this.closeBundle();
      }
      
      private function onBuyButton(param1:MouseEvent) : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Array = null;
         var _loc2_:Number = this.getPriceTotal();
         if(ZGlobal.player.canBuyCash(_loc2_,true))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc2_))
            {
               _loc3_ = ZGameUtils.CashTokenReplacements(_loc2_);
               _loc3_.item = this.m_item.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
               _loc4_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage",_loc3_);
               _loc5_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
               _loc6_ = new Array("EmpirePointsConfirm","","","");
               PopupManager.instance.push(GenericPopup2B.NewYesNo(_loc4_,_loc5_,this.onCashBuyPopupClose,_loc6_));
            }
            else
            {
               this.doItemPurchase();
            }
         }
         close();
      }
      
      private function doItemPurchase() : void
      {
         var _loc2_:String = null;
         var _loc3_:PromoData = null;
         var _loc4_:ZGamePopUp = null;
         var _loc1_:Array = new Array();
         for each(_loc2_ in this.m_itemsSelected)
         {
            _loc1_.push({
               "code":_loc2_,
               "quantity":1
            });
         }
         this.m_item.setBundle(this.getPriceTotal(),_loc1_);
         ZGlobal.player.buyGameItem(this.m_item);
         StatsManager.count("dialog",this.m_xml.@name,"yes");
         _loc3_ = new PromoData();
         _loc3_.items = this.m_itemsSelected;
         _loc3_.shareFeedFunction = ViralsManager.instance.feedPickYourOwnShare;
         _loc3_.trackingConfirmPromoKingdom = "MOTDPopup_conf_bundle2";
         _loc4_ = new StarterPackRewardPopup(_loc3_);
         PopupManager.instance.push(_loc4_);
         this.closeBundle();
      }
      
      private function onCashBuyPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.doItemPurchase();
         }
         else
         {
            this.closeBundle();
         }
      }
      
      private function closeBundle() : void
      {
         var _loc1_:WorldEvent = new WorldEvent(PromoManager.BUNDLE_POPUP_CLOSED);
         _loc1_.eventData = {"bundleName":this.m_xml.@name.toString()};
         PromoManager.instance.dispatchEvent(_loc1_);
      }
      
      private function getPriceOriginal() : Number
      {
         var _loc2_:String = null;
         var _loc3_:GameItem = null;
         var _loc4_:Number = NaN;
         var _loc1_:Number = 0;
         for each(_loc2_ in this.m_itemsSelected)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_,GameItem) as GameItem;
            _loc4_ = _loc3_.cash;
            _loc1_ += _loc4_;
         }
         return _loc1_;
      }
      
      private function getPriceTotal() : Number
      {
         var _loc3_:String = null;
         var _loc4_:GameItem = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc1_:Number = getPriceDiscountPercent();
         var _loc2_:Number = 0;
         for each(_loc3_ in this.m_itemsSelected)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
            _loc5_ = _loc4_.getModifiedCash(1);
            _loc6_ = Math.ceil(_loc5_ * (100 - _loc1_) / 100);
            if(_loc6_ == 0)
            {
               _loc6_ = 1;
            }
            _loc2_ += _loc6_;
         }
         return _loc2_;
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         var _loc6_:UnitItem = null;
         var _loc2_:int = int(param1.currentTarget.parent.cardIdx);
         var _loc3_:String = this.m_itemsAvailable[_loc2_ + this.m_scrollOffset];
         var _loc5_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
         if(_loc5_)
         {
            _loc4_ = _loc5_.tooltipType;
         }
         if(_loc4_ != GameItem.NO_TOOLTIP)
         {
            if(_loc4_ == GameItem.UNIT_TOOLTIP || _loc4_ == GameItem.SUPPORT_UNIT_TOOLTIP)
            {
               _loc6_ = ZGlobal.gameSettings.getItemByCode(_loc5_.code,UnitItem) as UnitItem;
               this.m_tooltip = new ItemTooltip(_loc4_,_loc6_,ItemTooltip.SOURCE_STORE);
            }
            else
            {
               this.m_tooltip = new ItemTooltip(_loc4_,_loc5_,ItemTooltip.SOURCE_STORE);
            }
            this.m_availableCards[_loc2_].addChild(this.m_tooltip);
            this.m_tooltip.moveBy(this.m_availableCards[_loc2_].width * 0.25,0);
            this.m_tooltip.alpha = 0;
            TweenLite.to(this.m_tooltip,0.5,{"alpha":1});
         }
      }
      
      protected function onRollOut(param1:MouseEvent) : void
      {
         var _loc2_:int = int(param1.currentTarget.parent.cardIdx);
         if(Boolean(this.m_tooltip) && Boolean(this.m_availableCards[_loc2_].contains(this.m_tooltip)))
         {
            this.m_availableCards[_loc2_].removeChild(this.m_tooltip);
            this.m_tooltip.destroy();
         }
         this.m_tooltip = null;
      }
   }
}

