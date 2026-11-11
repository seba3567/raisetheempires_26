package displays.popups.promo
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.gameobjects.UnitItem;
   import core.managers.promoManager.PromoManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import displays.popups.GenericPopup;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   
   public class StarterPackPopup extends GallantPopup
   {
      
      public static const PACKAGE_LOW:String = "low";
      
      public static const PACKAGE_MEDIUM:String = "medium";
      
      public static const PACKAGE_HIGH:String = "high";
      
      public static const STP01:String = "STP01";
      
      public static const STP02:String = "STP02";
      
      public static const STP03:String = "STP03";
      
      public static const STARTER_PACK_PAYMENT1:String = "STPP1";
      
      public static const STARTER_PACK_PAYMENT2:String = "STPP2";
      
      public static const STARTER_PACK_PAYMENT3:String = "STPP3";
      
      public static const STARTER_PACK_PAYMENT4:String = "STPP4";
      
      public static const PERCENT_OFF:String = "promo_StarterPack_percentOff";
      
      public static const MONEY_COST:String = "promo_MoneyCost";
      
      public static const VARIANT_1:Number = 2;
      
      public static const VARIANT_2:Number = 3;
      
      public static const VARIANT_3:Number = 4;
      
      private const LOCALIZATION_FILE:String = "Promo";
      
      private var m_variant:Number = 0;
      
      private var m_starterPackData:XMLList;
      
      private var m_data:XML;
      
      private var m_bgd:MovieClip;
      
      private var m_titleTF:TextField;
      
      private var m_descriptionTF:TextField;
      
      private var m_costTFs:Vector.<TextField>;
      
      private var m_discounts:Vector.<MovieClip>;
      
      private var m_acceptButtons:Vector.<ZGameButton>;
      
      private var m_exitButton:SimpleButton;
      
      private var m_valueTF:TextField;
      
      private var m_icons:Vector.<MovieClip>;
      
      private var m_loaders:Vector.<ImageLoader>;
      
      private var m_buttonToStarterPackPaymentXML:Object;
      
      public function StarterPackPopup(param1:XMLList, param2:Number)
      {
         var _loc3_:String = null;
         this.m_starterPackData = param1;
         this.m_variant = param2;
         switch(this.m_variant)
         {
            case VARIANT_1:
               _loc3_ = ZGlobal.getAssetURL("assets/displays/dialogs/PU_StarterPack_1Slot.swf");
               this.m_data = this.getDataByCodeName(STP01);
               break;
            case VARIANT_2:
               _loc3_ = ZGlobal.getAssetURL("assets/displays/dialogs/PU_StarterPack_2Slot.swf");
               this.m_data = this.getDataByCodeName(STP02);
               break;
            case VARIANT_3:
               _loc3_ = ZGlobal.getAssetURL("assets/displays/dialogs/PU_StarterPack_3Slot.swf");
               this.m_data = this.getDataByCodeName(STP03);
         }
         super(_loc3_);
      }
      
      private function getDataByCodeName(param1:String) : XML
      {
         var _loc2_:XML = null;
         for each(_loc2_ in this.m_starterPackData.starterPack)
         {
            if(_loc2_.attribute("code") == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      override protected function initDialog() : void
      {
         this.m_loaders = new Vector.<ImageLoader>();
         this.m_costTFs = new Vector.<TextField>();
         this.m_discounts = new Vector.<MovieClip>();
         this.m_acceptButtons = new Vector.<ZGameButton>();
         this.m_bgd = m_window.background_mc;
         this.m_bgd.visible = false;
         this.contentWidth = this.m_bgd.width;
         this.contentHeight = this.m_bgd.height;
         super.initDialog();
         this.m_buttonToStarterPackPaymentXML = new Object();
         switch(this.m_variant)
         {
            case VARIANT_1:
               this.initVariant1();
               break;
            case VARIANT_2:
               this.initVariant2();
               break;
            case VARIANT_3:
               this.initVariant3();
         }
         StatsManager.count("dialog","MOTDpopup_starter_pack","view");
      }
      
      private function initVariant1() : void
      {
         var _loc1_:XML = PromoManager.instance.getStarterPackPaymentFromCodeName(STARTER_PACK_PAYMENT1);
         this.m_titleTF = m_window.starterUI_Slot.title_tf;
         this.m_descriptionTF = m_window.starterUI_Slot.description_tf;
         this.m_exitButton = m_window.starterUI_Slot.exit_bt;
         this.m_costTFs.push(m_window.starterUI_Slot.cost.cost_tf);
         this.m_discounts.push(m_window.starterUI_Slot.discount);
         this.m_icons = new Vector.<MovieClip>();
         this.m_icons.push(m_window.starterUI_Slot.icons.icon0);
         this.m_icons.push(m_window.starterUI_Slot.icons.icon1);
         this.m_icons.push(m_window.starterUI_Slot.icons.icon2);
         this.m_icons.push(m_window.starterUI_Slot.icons.icon3);
         this.initButton(m_window.starterUI_Slot.buy_bt,_loc1_);
         this.m_exitButton.addEventListener(MouseEvent.CLICK,this.onCancelClick);
         TextFieldUtil.compactTextField(this.m_titleTF,this.textFromKey(this.m_data.attribute("title")));
         TextFieldUtil.processTextField(this.m_descriptionTF,this.textFromKey(this.m_data.attribute("desc")));
         TextFieldUtil.processTextField(this.m_costTFs[0],ZLoc.t(this.LOCALIZATION_FILE,MONEY_COST,{"cost":_loc1_.attribute("cost")}));
         this.m_acceptButtons[0].compactText(this.textFromKey(this.m_data.attribute("buyButtonText")),{
            "maxLines":1,
            "minScale":0.7,
            "onFail":"return"
         });
         TextFieldUtil.processTextField(this.m_discounts[0].num_tf,ZLoc.t("Promo",PERCENT_OFF,{"amount":_loc1_.attribute("percentOff")}));
         this.setUpIcons(this.m_data.icon0[0],_loc1_,this.m_icons[0]);
         this.setUpIcons(this.m_data.icon1[0],_loc1_,this.m_icons[1]);
         this.setUpIcons(this.m_data.icon2[0],_loc1_,this.m_icons[2]);
         this.setUpIcons(this.m_data.icon3[0],_loc1_,this.m_icons[3]);
         this.setUpUnitStrength(_loc1_,m_window.starterUI_Slot.icons.strength_mc.strength_tf);
      }
      
      private function initVariant2() : void
      {
         var _loc1_:XML = PromoManager.instance.getStarterPackPaymentFromCodeName(STARTER_PACK_PAYMENT2);
         var _loc2_:XML = PromoManager.instance.getStarterPackPaymentFromCodeName(STARTER_PACK_PAYMENT4);
         this.m_titleTF = m_window.starterUI_Slot.title_tf;
         this.m_descriptionTF = m_window.starterUI_Slot.description_tf;
         this.m_exitButton = m_window.starterUI_Slot.exit_bt;
         this.m_valueTF = m_window.starterUI_Slot.value_tf;
         this.m_costTFs.push(m_window.starterUI_Slot.cost_0.cost_tf);
         this.m_costTFs.push(m_window.starterUI_Slot.cost_1.cost_tf);
         this.m_discounts.push(m_window.starterUI_Slot.discount0);
         this.m_discounts.push(m_window.starterUI_Slot.discount1);
         this.m_icons = new Vector.<MovieClip>();
         this.m_icons.push(m_window.starterUI_Slot.icons_0.icon0);
         this.m_icons.push(m_window.starterUI_Slot.icons_0.icon1);
         this.m_icons.push(m_window.starterUI_Slot.icons_0.icon2);
         this.m_icons.push(m_window.starterUI_Slot.icons_1.icon0);
         this.m_icons.push(m_window.starterUI_Slot.icons_1.icon1);
         this.m_icons.push(m_window.starterUI_Slot.icons_1.icon2);
         this.m_icons.push(m_window.starterUI_Slot.icons_1.icon3);
         this.initButton(m_window.starterUI_Slot.buy_bt_0,_loc1_);
         this.initButton(m_window.starterUI_Slot.buy_bt_1,_loc2_);
         this.m_exitButton.addEventListener(MouseEvent.CLICK,this.onCancelClick);
         TextFieldUtil.compactTextField(this.m_titleTF,this.textFromKey(this.m_data.attribute("title")));
         TextFieldUtil.processTextField(this.m_descriptionTF,this.textFromKey(this.m_data.attribute("desc")));
         TextFieldUtil.processTextField(this.m_costTFs[0],ZLoc.t(this.LOCALIZATION_FILE,MONEY_COST,{"cost":_loc1_.attribute("cost")}));
         TextFieldUtil.processTextField(this.m_costTFs[1],ZLoc.t(this.LOCALIZATION_FILE,MONEY_COST,{"cost":_loc2_.attribute("cost")}));
         TextFieldUtil.processTextField(this.m_valueTF,this.textFromKey("Promo:promo_StarterPack_BestValue"));
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
         TextFieldUtil.processTextField(this.m_discounts[0].num_tf,ZLoc.t("Promo",PERCENT_OFF,{"amount":_loc1_.attribute("percentOff")}));
         TextFieldUtil.processTextField(this.m_discounts[1].num_tf,ZLoc.t("Promo",PERCENT_OFF,{"amount":_loc2_.attribute("percentOff")}));
         this.setUpIcons(this.m_data.icon0[0],_loc1_,this.m_icons[0]);
         this.setUpIcons(this.m_data.icon1[0],_loc1_,this.m_icons[1]);
         this.setUpIcons(this.m_data.icon2[0],_loc1_,this.m_icons[2]);
         this.setUpIcons(this.m_data.icon3[0],_loc2_,this.m_icons[3]);
         this.setUpIcons(this.m_data.icon4[0],_loc2_,this.m_icons[4]);
         this.setUpIcons(this.m_data.icon5[0],_loc2_,this.m_icons[5]);
         this.setUpIcons(this.m_data.icon6[0],_loc2_,this.m_icons[6]);
         this.setUpUnitStrength(_loc2_,m_window.starterUI_Slot.icons_1.strength_mc.strength_tf);
      }
      
      private function initVariant3() : void
      {
         var _loc1_:XML = PromoManager.instance.getStarterPackPaymentFromCodeName(STARTER_PACK_PAYMENT3);
         var _loc2_:XML = PromoManager.instance.getStarterPackPaymentFromCodeName(STARTER_PACK_PAYMENT2);
         var _loc3_:XML = PromoManager.instance.getStarterPackPaymentFromCodeName(STARTER_PACK_PAYMENT4);
         this.m_titleTF = m_window.starterUI_Slot.title_tf;
         this.m_descriptionTF = m_window.starterUI_Slot.description_tf;
         this.m_exitButton = m_window.starterUI_Slot.exit_bt;
         this.m_valueTF = m_window.starterUI_Slot.value_tf;
         this.m_costTFs.push(m_window.starterUI_Slot.cost_0.cost_tf);
         this.m_costTFs.push(m_window.starterUI_Slot.cost_1.cost_tf);
         this.m_costTFs.push(m_window.starterUI_Slot.cost_2.cost_tf);
         this.m_discounts.push(m_window.starterUI_Slot.discount0);
         this.m_discounts.push(m_window.starterUI_Slot.discount1);
         this.m_discounts.push(m_window.starterUI_Slot.discount2);
         this.m_icons = new Vector.<MovieClip>();
         this.m_icons.push(m_window.starterUI_Slot.icons_0.icon0);
         this.m_icons.push(m_window.starterUI_Slot.icons_0.icon1);
         this.m_icons.push(m_window.starterUI_Slot.icons_0.icon2);
         this.m_icons.push(m_window.starterUI_Slot.icons_1.icon0);
         this.m_icons.push(m_window.starterUI_Slot.icons_1.icon1);
         this.m_icons.push(m_window.starterUI_Slot.icons_1.icon2);
         this.m_icons.push(m_window.starterUI_Slot.icons_2.icon0);
         this.m_icons.push(m_window.starterUI_Slot.icons_2.icon1);
         this.m_icons.push(m_window.starterUI_Slot.icons_2.icon2);
         this.m_icons.push(m_window.starterUI_Slot.icons_2.icon3);
         this.initButton(m_window.starterUI_Slot.buy_bt_0,_loc1_);
         this.initButton(m_window.starterUI_Slot.buy_bt_1,_loc2_);
         this.initButton(m_window.starterUI_Slot.buy_bt_2,_loc3_);
         this.m_exitButton.addEventListener(MouseEvent.CLICK,this.onCancelClick);
         TextFieldUtil.compactTextField(this.m_titleTF,this.textFromKey(this.m_data.attribute("title")));
         TextFieldUtil.processTextField(this.m_descriptionTF,this.textFromKey(this.m_data.attribute("desc")));
         TextFieldUtil.processTextField(this.m_costTFs[0],ZLoc.t(this.LOCALIZATION_FILE,MONEY_COST,{"cost":_loc1_.attribute("cost")}));
         TextFieldUtil.processTextField(this.m_costTFs[1],ZLoc.t(this.LOCALIZATION_FILE,MONEY_COST,{"cost":_loc2_.attribute("cost")}));
         TextFieldUtil.processTextField(this.m_costTFs[2],ZLoc.t(this.LOCALIZATION_FILE,MONEY_COST,{"cost":_loc3_.attribute("cost")}));
         TextFieldUtil.processTextField(this.m_valueTF,this.textFromKey("Promo:promo_StarterPack_BestValue"));
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
         TextFieldUtil.processTextField(this.m_discounts[0].num_tf,ZLoc.t("Promo",PERCENT_OFF,{"amount":_loc1_.attribute("percentOff")}));
         TextFieldUtil.processTextField(this.m_discounts[1].num_tf,ZLoc.t("Promo",PERCENT_OFF,{"amount":_loc2_.attribute("percentOff")}));
         TextFieldUtil.processTextField(this.m_discounts[2].num_tf,ZLoc.t("Promo",PERCENT_OFF,{"amount":_loc3_.attribute("percentOff")}));
         this.setUpIcons(this.m_data.icon0[0],_loc1_,this.m_icons[0]);
         this.setUpIcons(this.m_data.icon1[0],_loc1_,this.m_icons[1]);
         this.setUpIcons(this.m_data.icon2[0],_loc1_,this.m_icons[2]);
         this.setUpIcons(this.m_data.icon3[0],_loc2_,this.m_icons[3]);
         this.setUpIcons(this.m_data.icon4[0],_loc2_,this.m_icons[4]);
         this.setUpIcons(this.m_data.icon5[0],_loc2_,this.m_icons[5]);
         this.setUpIcons(this.m_data.icon6[0],_loc3_,this.m_icons[6]);
         this.setUpIcons(this.m_data.icon7[0],_loc3_,this.m_icons[7]);
         this.setUpIcons(this.m_data.icon8[0],_loc3_,this.m_icons[8]);
         this.setUpIcons(this.m_data.icon9[0],_loc3_,this.m_icons[9]);
         this.setUpUnitStrength(_loc3_,m_window.starterUI_Slot.icons_2.strength_mc.strength_tf);
      }
      
      private function setUpUnitStrength(param1:XML, param2:TextField) : void
      {
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1.attribute("unitCode"),UnitItem) as UnitItem;
         var _loc4_:Number = _loc3_.getStrength(null);
         TextFieldUtil.processTextField(param2,_loc4_.toString());
      }
      
      private function setUpIcons(param1:XML, param2:XML, param3:MovieClip) : void
      {
         var _loc4_:String = param1.attribute("imageURL");
         var _loc5_:String = "";
         if(_loc4_.indexOf("EmpirePoints") >= 0)
         {
            _loc5_ = param2.attribute("ep");
         }
         else if(_loc4_.indexOf("Coins") >= 0)
         {
            _loc5_ = param2.attribute("coins");
         }
         else if(_loc4_.toLowerCase().indexOf("energy") >= 0)
         {
            _loc5_ = param2.attribute("energy");
         }
         else
         {
            _loc5_ = this.textFromKey(param2.attribute("unit"));
            if(_loc5_.indexOf("Cannot") >= 0)
            {
               _loc5_ = "";
            }
         }
         TextFieldUtil.processTextField(param3.generic_tf,_loc5_);
         param3.icon.scaleContent = false;
         this.m_loaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc4_),param3.icon));
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
         this.m_costTFs = null;
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
         var _loc5_:String = "in_game_v" + ZGlobal.starterBundleVariant + "_code" + _loc3_;
         var _loc6_:PromoData = new PromoData();
         _loc6_.popup = this;
         _loc6_.trackingConfirmPromoKingdom = "MOTDPopup_conf_starter_pack";
         _loc6_.shareFeedFunction = ViralsManager.instance.feedStarterPackShare;
         if(!_loc2_.attribute("unitCode"))
         {
         }
         PromoManager.instance.dispatchEvent(new WorldEvent(PromoManager.EVENT_DIALOG_ACCEPT,{
            "packageType":_loc3_,
            "phylum":_loc5_,
            "promoData":_loc6_
         }));
         StatsManager.count("dialog","MOTDpopup_starter_pack","yes","cost " + _loc4_,"itemcode: " + _loc3_);
         ZGlobal.player.setSeenSessionFlag(PromoManager.FLAG_SESSION_STARTER_PACK_POPUP);
      }
      
      private function onCancelClick(param1:MouseEvent) : void
      {
         PromoManager.instance.dispatchEvent(new WorldEvent(PromoManager.EVENT_DIALOG_DECLINE));
         StatsManager.count("dialog","MOTDpopup_starter_pack","no");
         ZGlobal.player.setSeenSessionFlag(PromoManager.FLAG_SESSION_STARTER_PACK_POPUP);
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

