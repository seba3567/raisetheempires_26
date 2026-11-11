package displays.popups.promo
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.ExperimentsManager;
   import core.managers.promoManager.PromoManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import displays.popups.GenericPopup;
   import displays.popups.MOTDCountdownClock;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import transactions.TGetPromoOverrideData;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   
   public class RepeatPayerPopup extends GallantPopup
   {
      
      public static const PACKAGE_LOW:String = "low";
      
      public static const PACKAGE_MEDIUM:String = "medium";
      
      public static const PACKAGE_HIGH:String = "high";
      
      public static const REPEAT_PACK_PAYMENT1:String = "RPP1";
      
      public static const REPEAT_PACK_PAYMENT2:String = "RPP4";
      
      public static const REPEAT_PACK_PAYMENT3:String = "RPP3";
      
      public static const PERCENT_OFF:String = "promo_StarterPack_percentOff";
      
      public static const MONEY_COST:String = "promo_MoneyCost";
      
      public static const ACTIVE_VARIANT:int = 2;
      
      public static const REPEAT_PACK_CODE_NAME:String = "RepeatPP";
      
      private const LOCALIZATION_FILE:String = "Promo";
      
      private var m_variant:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_FREE_GIFT_WITH_PURCHASE);
      
      private var m_starterPackData:XMLList;
      
      private var m_data:XML = PromoManager.instance.getRepeatPayerXML();
      
      private var m_bgd:MovieClip;
      
      private var m_titleTF:TextField;
      
      private var m_descriptionTF:TextField;
      
      private var m_titleTF2:TextField;
      
      private var m_descriptionTF2:TextField;
      
      private var m_acceptButtons:Vector.<ZGameButton>;
      
      private var m_exitButton:SimpleButton;
      
      private var m_valueTF:TextField;
      
      private var m_clock:MOTDCountdownClock;
      
      private var m_icons:Vector.<MovieClip>;
      
      private var m_loaders:Vector.<ImageLoader>;
      
      private var m_buttonToStarterPackPaymentXML:Object;
      
      private var m_useStartupPromoOverrides:Boolean;
      
      private var m_promoOverridesLoaded:Boolean;
      
      public function RepeatPayerPopup(param1:XMLList, param2:Boolean = true)
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:TGetPromoOverrideData = null;
         this.m_starterPackData = param1;
         _loc3_ = ZGlobal.getAssetURL("assets/displays/dialogs/PU_FreeGiftPack.swf");
         super(_loc3_);
         if(param2)
         {
            this.m_promoOverridesLoaded = true;
         }
         else
         {
            _loc4_ = [REPEAT_PACK_PAYMENT1,REPEAT_PACK_PAYMENT2,REPEAT_PACK_PAYMENT3];
            _loc5_ = new TGetPromoOverrideData(_loc4_,this.onGetPromoData);
            TransactionManager.addTransaction(_loc5_);
            this.m_promoOverridesLoaded = false;
         }
      }
      
      override protected function initDialog() : void
      {
         this.m_loaders = new Vector.<ImageLoader>();
         this.m_acceptButtons = new Vector.<ZGameButton>();
         this.m_bgd = m_window.background_mc;
         this.m_bgd.visible = false;
         this.contentWidth = this.m_bgd.width;
         this.contentHeight = this.m_bgd.height;
         super.initDialog();
         this.m_buttonToStarterPackPaymentXML = new Object();
         this.initVariant();
         StatsManager.count("dialog","MOTDfree_gift_with_purchase","view");
      }
      
      private function initVariant() : void
      {
         var _loc1_:XML = this.getStarterPackPaymentFromCodeName(REPEAT_PACK_PAYMENT1);
         var _loc2_:XML = this.getStarterPackPaymentFromCodeName(REPEAT_PACK_PAYMENT2);
         var _loc3_:XML = this.getStarterPackPaymentFromCodeName(REPEAT_PACK_PAYMENT3);
         this.m_titleTF = m_window.RepeatPayerPack_mc.title_tf;
         this.m_descriptionTF = m_window.RepeatPayerPack_mc.description_tf;
         this.m_titleTF2 = m_window.RepeatPayerPack_mc.title_tf2;
         this.m_descriptionTF2 = m_window.RepeatPayerPack_mc.description_tf1;
         this.m_exitButton = m_window.RepeatPayerPack_mc.exit_bt;
         this.m_valueTF = m_window.RepeatPayerPack_mc.value_tf;
         this.m_icons = new Vector.<MovieClip>();
         this.m_icons.push(m_window.RepeatPayerPack_mc.icons_0);
         this.m_icons.push(m_window.RepeatPayerPack_mc.icons_1);
         this.m_icons.push(m_window.RepeatPayerPack_mc.icons_2);
         m_window.RepeatPayerPack_mc.icons_0.visible = false;
         m_window.RepeatPayerPack_mc.icons_1.visible = false;
         m_window.RepeatPayerPack_mc.icons_2.visible = false;
         this.initButton(m_window.RepeatPayerPack_mc.buy_bt_0,_loc1_);
         this.initButton(m_window.RepeatPayerPack_mc.buy_bt_1,_loc2_);
         this.initButton(m_window.RepeatPayerPack_mc.buy_bt_2,_loc3_);
         this.m_exitButton.addEventListener(MouseEvent.CLICK,this.onCancelClick);
         TextFieldUtil.compactTextField(this.m_titleTF,this.textFromKey(this.m_data.attribute("title")));
         TextFieldUtil.processTextField(this.m_descriptionTF,this.textFromKey(this.m_data.attribute("desc")));
         TextFieldUtil.compactTextField(this.m_titleTF2,this.textFromKey(this.m_data.attribute("title2")));
         TextFieldUtil.processTextField(this.m_descriptionTF2,this.textFromKey(this.m_data.attribute("desc2")));
         TextFieldUtil.processTextField(this.m_valueTF,this.textFromKey("Promo:promo_StarterPack_BestValue"));
         TextFieldUtil.processTextField(m_window.RepeatPayerPack_mc.clock_tf,this.textFromKey("Promo:promo_RepeatPayerPack_ClockText"));
         this.m_acceptButtons[0].compactText(this.textFromKey(this.m_data.attribute("buyButtonText")),{
            "maxLines":1,
            "minScale":0.7,
            "onFail":"return"
         });
         this.m_acceptButtons[1].compactText(this.textFromKey(this.m_data.attribute("buyButtonText")),{
            "maxLines":1,
            "minScale":0.7,
            "onFail":"return"
         });
         this.m_acceptButtons[2].compactText(this.textFromKey(this.m_data.attribute("buyButtonText")),{
            "maxLines":1,
            "minScale":0.7,
            "onFail":"return"
         });
         TextFieldUtil.processTextField(this.m_icons[0].free_tf,this.textFromKey("Promo:promo_freeText"));
         TextFieldUtil.processTextField(this.m_icons[1].free_tf,this.textFromKey("Promo:promo_freeText"));
         TextFieldUtil.processTextField(this.m_icons[2].free_tf,this.textFromKey("Promo:promo_freeText"));
         if(this.m_promoOverridesLoaded)
         {
            this.setUpIcons(_loc1_,this.m_icons[0]);
            this.setUpIcons(_loc2_,this.m_icons[1]);
            this.setUpIcons(_loc3_,this.m_icons[2]);
         }
         TextFieldUtil.processTextField(this.m_icons[0].points_tf,_loc1_.attribute("ep"));
         TextFieldUtil.processTextField(this.m_icons[1].points_tf,_loc2_.attribute("ep"));
         TextFieldUtil.processTextField(this.m_icons[2].points_tf,_loc3_.attribute("ep"));
         TextFieldUtil.processTextField(this.m_icons[0].cost_tf,ZLoc.t("Promo","promo_forAmount",{"amount":_loc1_.attribute("cost")}));
         TextFieldUtil.processTextField(this.m_icons[1].cost_tf,ZLoc.t("Promo","promo_forAmount",{"amount":_loc2_.attribute("cost")}));
         TextFieldUtil.processTextField(this.m_icons[2].cost_tf,ZLoc.t("Promo","promo_forAmount",{"amount":_loc3_.attribute("cost")}));
         if(this.m_promoOverridesLoaded)
         {
            this.setUpUnitStrengths();
         }
         this.m_clock = new MOTDCountdownClock(m_window.RepeatPayerPack_mc.clock_mc,this.m_data);
      }
      
      private function setUpUnitStrengths() : void
      {
         var _loc1_:XML = this.getStarterPackPaymentFromCodeName(REPEAT_PACK_PAYMENT1);
         var _loc2_:XML = this.getStarterPackPaymentFromCodeName(REPEAT_PACK_PAYMENT2);
         var _loc3_:XML = this.getStarterPackPaymentFromCodeName(REPEAT_PACK_PAYMENT3);
         if(!this.setUpUnitStrength(_loc1_,this.m_icons[0].strength_mc.strength_tf))
         {
            this.m_icons[0].strength_mc.visible = false;
         }
         if(!this.setUpUnitStrength(_loc2_,this.m_icons[1].strength_mc.strength_tf))
         {
            this.m_icons[1].strength_mc.visible = false;
         }
         if(!this.setUpUnitStrength(_loc3_,this.m_icons[2].strength_mc.strength_tf))
         {
            this.m_icons[2].strength_mc.visible = false;
         }
      }
      
      private function setUpUnitStrength(param1:XML, param2:TextField) : Boolean
      {
         var _loc5_:Number = NaN;
         var _loc3_:String = this.getPromoUnitCode(param1);
         var _loc4_:UnitItem = ZGlobal.gameSettings.getItemByCode(_loc3_,UnitItem) as UnitItem;
         if(_loc4_ != null)
         {
            _loc5_ = _loc4_.getStrength(null);
            if(_loc5_ > 0)
            {
               TextFieldUtil.processTextField(param2,_loc5_.toString());
               return true;
            }
            return false;
         }
         return false;
      }
      
      private function getStarterPackPaymentFromCodeName(param1:String) : XML
      {
         var _loc2_:XML = null;
         for each(_loc2_ in this.m_starterPackData.starterPackPayment)
         {
            if(_loc2_.attribute("code") == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function onGetPromoData(param1:Object) : void
      {
         var _loc2_:XML = null;
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         PromoManager.instance.promoOverrides = param1;
         this.m_promoOverridesLoaded = true;
         if(this.m_icons != null)
         {
            _loc2_ = this.getStarterPackPaymentFromCodeName(REPEAT_PACK_PAYMENT1);
            _loc3_ = this.getStarterPackPaymentFromCodeName(REPEAT_PACK_PAYMENT2);
            _loc4_ = this.getStarterPackPaymentFromCodeName(REPEAT_PACK_PAYMENT3);
            this.setUpIcons(_loc2_,this.m_icons[0]);
            this.setUpIcons(_loc3_,this.m_icons[1]);
            this.setUpIcons(_loc4_,this.m_icons[2]);
            this.setUpUnitStrengths();
         }
      }
      
      private function getPromoUnitCode(param1:XML) : String
      {
         var _loc2_:String = null;
         var _loc3_:Object = PromoManager.instance.promoOverrides;
         if(Boolean(_loc3_ != null && _loc3_.hasOwnProperty(param1.@code) && _loc3_[param1.@code].hasOwnProperty("unitCodes")) && Boolean(_loc3_[param1.@code]["unitCodes"] is Array) && _loc3_[param1.@code]["unitCodes"].length == 1)
         {
            _loc2_ = _loc3_[param1.@code]["unitCodes"][0];
         }
         if(_loc2_ == null)
         {
            _loc2_ = param1.@unitCode;
         }
         return _loc2_;
      }
      
      private function setUpIcons(param1:XML, param2:MovieClip) : void
      {
         var _loc3_:String = this.getPromoUnitCode(param1);
         var _loc4_:GameItem = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
         if(_loc4_ != null)
         {
            TextFieldUtil.processTextField(param2.name_tf,_loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc4_.name,"icon"),param2.icon));
            param2.visible = true;
         }
      }
      
      private function initButton(param1:MovieClip, param2:XML) : void
      {
         var _loc3_:ZGameButton = null;
         _loc3_ = new ZGameButton(param1,this.buyPackage);
         this.m_acceptButtons.push(_loc3_);
         this.m_buttonToStarterPackPaymentXML[_loc3_.hit.name] = param2;
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         var _loc2_:ZGameButton = null;
         super.deinitDialog();
         this.m_exitButton.removeEventListener(MouseEvent.CLICK,this.onCancelClick);
         this.m_titleTF = null;
         this.m_descriptionTF = null;
         this.m_exitButton = null;
         this.m_bgd = null;
         this.m_icons = null;
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = null;
         for each(_loc2_ in this.m_acceptButtons)
         {
            _loc2_.dispose();
         }
         this.m_acceptButtons = null;
      }
      
      private function buyPackage(param1:MouseEvent) : void
      {
         var _loc2_:XML = this.m_buttonToStarterPackPaymentXML[param1.currentTarget.buttonPointer.hit.name] as XML;
         var _loc3_:String = _loc2_.attribute("itemCode");
         var _loc4_:String = _loc2_.attribute("cost");
         var _loc5_:String = "in_game_v" + this.m_variant + "_code" + _loc3_;
         var _loc6_:PromoData = new PromoData();
         _loc6_.popup = this;
         _loc6_.trackingConfirmPromoKingdom = "MOTDPopup_conf_payer_pack";
         _loc6_.shareFeedFunction = ViralsManager.instance.feedRepeatPayerPackShare;
         _loc6_.shareFeedParams = {"itemCode":_loc3_};
         var _loc7_:String = this.getPromoUnitCode(_loc2_);
         if(_loc7_ != null)
         {
            _loc6_.items = [_loc7_];
         }
         PromoManager.instance.dispatchEvent(new WorldEvent(PromoManager.EVENT_DIALOG_ACCEPT,{
            "packageType":_loc3_,
            "phylum":_loc5_,
            "promoData":_loc6_
         }));
         StatsManager.count("dialog","MOTDfree_gift_with_purchase","yes","cost " + _loc4_,"itemcode: " + _loc3_);
      }
      
      private function onCancelClick(param1:MouseEvent) : void
      {
         PromoManager.instance.dispatchEvent(new WorldEvent(PromoManager.EVENT_DIALOG_DECLINE));
         StatsManager.count("dialog","MOTDfree_gift_with_purchase","no");
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.CANCEL));
         super.close(param1);
      }
      
      private function textFromKey(param1:String) : String
      {
         var _loc2_:Array = param1.split(":");
         if(_loc2_.length > 1)
         {
            return ZGameUtils.ZlocT(_loc2_[0],_loc2_[1]);
         }
         return ZGameUtils.ZlocT(this.LOCALIZATION_FILE,param1);
      }
   }
}

