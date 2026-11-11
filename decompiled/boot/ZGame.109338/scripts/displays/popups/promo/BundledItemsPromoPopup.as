package displays.popups.promo
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.promoManager.PromoManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.MOTDCountdownClock;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class BundledItemsPromoPopup extends GallantPopup
   {
      
      private const LOCALIZATION_FILE:String = "Promo";
      
      private var m_xml:XML = null;
      
      private var m_item:GameItem = null;
      
      private var m_buyBtn:ZGameButton = null;
      
      private var m_iconLoaders:Array = null;
      
      private var m_clock:MOTDCountdownClock = null;
      
      public function BundledItemsPromoPopup(param1:XML)
      {
         this.m_xml = param1;
         var _loc2_:String = "assets/displays/dialogs/PU_LaborDayPack.swf";
         if(this.m_xml.@asset != undefined)
         {
            _loc2_ = this.m_xml.@asset.toString();
         }
         super(ZGlobal.getAssetURL(_loc2_));
      }
      
      override protected function initializeScreen() : void
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:MovieClip = null;
         var _loc6_:XML = null;
         var _loc7_:GameItem = null;
         var _loc8_:String = null;
         var _loc9_:ImageLoader = null;
         var _loc10_:UnitItem = null;
         var _loc11_:int = 0;
         contentWidth = m_window.background_mc.width;
         contentHeight = m_window.background_mc.height;
         m_window.background_mc.visible = false;
         super.initializeScreen();
         var _loc1_:MovieClip = m_window.dialog_mc;
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
         ZGameUtils.hideIfExists(_loc1_.discount_tf);
         TextFieldUtil.processTextField(_loc1_.description_tf,this.localizedStringForKey(this.m_xml.@desc));
         TextFieldUtil.processTextField(_loc1_.description_tf2,this.localizedStringForKey(this.m_xml.@subDesc));
         _loc1_.exit_bt.addEventListener(MouseEvent.CLICK,this.onCancel,false,0,true);
         this.m_buyBtn = new ZGameButton(_loc1_.buy_bt,this.onBuyButton);
         this.m_clock = new MOTDCountdownClock(_loc1_.clock_mc,this.m_xml.criteria[0]);
         this.m_iconLoaders = new Array();
         this.m_item = ZGlobal.gameSettings.getItemByCode(this.m_xml.@bundleItemCode,GameItem) as GameItem;
         if(Boolean(this.m_item) && this.m_item.isBundle)
         {
            switch(this.m_item.bundleSize)
            {
               case 1:
                  _loc3_ = [_loc1_.icons1slot.icon1];
                  _loc1_.icons2slots.visible = false;
                  _loc1_.icons.visible = false;
                  break;
               case 2:
                  _loc1_.icons1slot.visible = false;
                  _loc3_ = [_loc1_.icons2slots.icon1,_loc1_.icons2slots.icon2];
                  _loc1_.icons.visible = false;
                  break;
               default:
               case 3:
                  _loc1_.icons1slot.visible = false;
                  _loc1_.icons2slots.visible = false;
                  _loc3_ = [_loc1_.icons.icon1,_loc1_.icons.icon2,_loc1_.icons.icon3];
            }
            _loc4_ = 0;
            while(_loc4_ < this.m_item.bundleSize)
            {
               _loc5_ = _loc3_[_loc4_];
               _loc6_ = this.m_item.bundleXML(_loc4_);
               _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc6_.@item,GameItem) as GameItem;
               _loc8_ = _loc7_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
               _loc9_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc7_.name,"icon"),_loc5_.icon);
               this.m_iconLoaders.push(_loc9_);
               if(_loc7_.isUnit())
               {
                  _loc10_ = ZGlobal.gameSettings.getItemByCode(_loc6_.@item,UnitItem) as UnitItem;
                  _loc11_ = _loc10_.getStrength(null);
                  TextFieldUtil.processTextField(_loc5_.name_tf,_loc8_);
                  TextFieldUtil.processTextField(_loc5_.strength_mc.strength_tf,_loc11_.toString());
                  _loc5_.name2_tf.visible = false;
               }
               else
               {
                  TextFieldUtil.processTextField(_loc5_.name2_tf,_loc8_);
                  _loc5_.name_tf.visible = false;
                  _loc5_.strength_mc.visible = false;
               }
               _loc4_++;
            }
            this.m_buyBtn.text = ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":this.m_item.cash});
         }
         StatsManager.count("dialog",this.m_xml.@name,"view");
         ZGlobal.player.setSeenFlag(this.m_xml.@name);
      }
      
      override protected function deinitDialog() : void
      {
         var _loc2_:ImageLoader = null;
         var _loc1_:MovieClip = m_window.dialog_mc;
         _loc1_.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCancel);
         if(this.m_buyBtn)
         {
            this.m_buyBtn.dispose();
         }
         this.m_buyBtn = null;
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
         }
         this.m_clock = null;
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
      
      private function onCancel(param1:MouseEvent) : void
      {
         close();
         StatsManager.count("dialog",this.m_xml.@name,"no");
         this.closeBundle();
      }
      
      private function onBuyButton(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         if(ZGlobal.player.canBuyCash(this.m_item.cash,true))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(this.m_item.cash))
            {
               _loc2_ = ZGameUtils.CashTokenReplacements(this.m_item.cash);
               _loc2_.item = this.m_item.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
               _loc3_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage",_loc2_);
               _loc4_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
               _loc5_ = new Array("EmpirePointsConfirm","","","");
               PopupManager.instance.push(GenericPopup2B.NewYesNo(_loc3_,_loc4_,this.onCashBuyPopupClose,_loc5_));
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
         ZGlobal.player.buyGameItem(this.m_item);
         StatsManager.count("dialog",this.m_xml.@name,"yes");
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
   }
}

