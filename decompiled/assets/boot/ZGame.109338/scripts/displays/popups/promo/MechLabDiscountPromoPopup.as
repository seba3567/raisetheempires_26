package displays.popups.promo
{
   import Engine.Managers.StatsManager;
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.managers.ExperimentsManager;
   import core.managers.promoManager.PromoManager;
   import core.ui.ZGameButton;
   import displays.popups.GallantPopup;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import utils.getVisibleBounds;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class MechLabDiscountPromoPopup extends GallantPopup
   {
      
      private static var m_partsNeeded:Array = null;
      
      private static var m_percentComplete:int = 0;
      
      private const LOCALIZATION_FILE:String = "Promo";
      
      private var m_xml:XML = null;
      
      private var m_bundleItem:GameItem = null;
      
      private var m_buyBtn:ZGameButton = null;
      
      public function MechLabDiscountPromoPopup(param1:XML)
      {
         this.m_xml = param1;
         var _loc2_:String = "assets/displays/dialogs/MechLabBundle.swf";
         if(this.m_xml.@asset != undefined)
         {
            _loc2_ = this.m_xml.@asset.toString();
         }
         super(ZGlobal.getAssetURL(_loc2_));
      }
      
      public static function anyPartsNeeded(param1:XML) : Boolean
      {
         calculatePartsNeeded(param1);
         return m_partsNeeded.length > 0;
      }
      
      private static function calculatePartsNeeded(param1:XML) : void
      {
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         m_partsNeeded = new Array();
         var _loc2_:PartsBuildingItem = ZGlobal.gameSettings.getItemByCode(param1.@buildingItemCode,PartsBuildingItem) as PartsBuildingItem;
         var _loc3_:int = _loc2_.numParts;
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         var _loc6_:int = 0;
         while(_loc6_ < _loc3_)
         {
            _loc7_ = _loc2_.getPartCodeForIndex(_loc6_);
            _loc8_ = _loc2_.getPartCountForIndex(_loc6_);
            _loc9_ = ZGlobal.player.getNumberOfInventoryItems(_loc7_);
            if(_loc9_ < _loc8_)
            {
               m_partsNeeded.push({
                  "code":_loc7_,
                  "quantity":_loc8_ - _loc9_
               });
            }
            _loc4_ += _loc8_;
            _loc5_ += Math.min(_loc9_,_loc8_);
            _loc6_++;
         }
         m_percentComplete = Math.floor(100 * _loc5_ / _loc4_);
      }
      
      override protected function initializeScreen() : void
      {
         var _loc1_:Rectangle = null;
         m_window = m_window.popup_mc;
         _loc1_ = getVisibleBounds(m_window);
         contentWidth = _loc1_.width;
         contentHeight = _loc1_.height;
         super.initializeScreen();
         this.m_bundleItem = ZGlobal.gameSettings.getItemByCode(this.m_xml.@bundleItemCode,GameItem) as GameItem;
         calculatePartsNeeded(this.m_xml);
         this.updateProgressBar(m_window.progressBar_mc,m_percentComplete / 100);
         var _loc2_:MovieClip = m_window;
         TextFieldUtil.compactTextField(_loc2_.title_tf,ZGameUtils.ZlocT(this.LOCALIZATION_FILE,this.m_xml.@title));
         TextFieldUtil.compactTextField(_loc2_.detail_tf,ZGameUtils.ZlocT(this.LOCALIZATION_FILE,this.m_xml.@desc,{"percent":this.getPriceDiscountPercent()}));
         TextFieldUtil.compactTextField(_loc2_.discount_mc.percent_tf,ZGameUtils.ZlocT(this.LOCALIZATION_FILE,this.m_xml.@discount,{"percent":this.getPriceDiscountPercent()}));
         TextFieldUtil.compactTextField(_loc2_.progressText_tf,ZGameUtils.ZlocT(this.LOCALIZATION_FILE,this.m_xml.@percentComplete,{"percent":this.getPercentComplete()}));
         this.m_buyBtn = new ZGameButton(_loc2_.viral_bt,this.onBuyButton,1.1,true);
         this.m_buyBtn.compactText(ZGameUtils.ZlocT("Promo",this.m_xml.@finish,{"cash":this.getPriceTotal()}),null);
         _loc2_.exit_bt.addEventListener(MouseEvent.CLICK,this.onCancel,false,0,true);
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:MovieClip = m_window;
         _loc1_.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCancel);
         if(this.m_buyBtn)
         {
            this.m_buyBtn.dispose();
            this.m_buyBtn = null;
         }
         super.deinitDialog();
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
               _loc3_.item = this.m_bundleItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
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
         this.m_bundleItem.setBundle(this.getPriceTotal(),m_partsNeeded);
         ZGlobal.player.buyGameItem(this.m_bundleItem);
         StatsManager.count("dialog",this.m_xml.@name,"yes");
         var _loc1_:PartsBuildingItem = ZGlobal.gameSettings.getItemByCode(this.m_xml.@buildingItemCode,PartsBuildingItem) as PartsBuildingItem;
         PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","LEUnitPartsSubtitleComplete",{"item":_loc1_.getSentenceNameLocalizationObject()})));
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
            StatsManager.count("dialog",this.m_xml.@name,"no");
            this.closeBundle();
         }
      }
      
      private function closeBundle() : void
      {
         var _loc1_:WorldEvent = new WorldEvent(PromoManager.BUNDLE_POPUP_CLOSED);
         _loc1_.eventData = {"bundleName":this.m_xml.@name.toString()};
         PromoManager.instance.dispatchEvent(_loc1_);
      }
      
      private function getPriceDiscountPercent() : Number
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_MECH_LAB_DISCOUNT);
         switch(_loc1_)
         {
            default:
            case 0:
            case 1:
               return 10;
            case 2:
               return 20;
            case 3:
               return 30;
            case 4:
               return 40;
            case 5:
               return 50;
            case 6:
               return 60;
            case 7:
               return 70;
            case 8:
               return 80;
            case 9:
               return 90;
         }
      }
      
      private function updateProgressBar(param1:MovieClip, param2:Number) : void
      {
         var _loc3_:int = param1.loadBase_mc.width * param2;
         TweenLite.to(param1.loadBar_mc,0.5,{"width":_loc3_});
      }
      
      private function getPercentComplete() : Number
      {
         return m_percentComplete;
      }
      
      private function getPriceTotal() : Number
      {
         var _loc3_:Object = null;
         var _loc4_:GameItem = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc1_:Number = this.getPriceDiscountPercent();
         var _loc2_:Number = 0;
         for each(_loc3_ in m_partsNeeded)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_.code,GameItem) as GameItem;
            _loc5_ = _loc4_.getModifiedCash(_loc3_.quantity);
            _loc6_ = Math.ceil(_loc5_ * (100 - _loc1_) / 100);
            if(_loc6_ == 0)
            {
               _loc6_ = 1;
            }
            _loc2_ += _loc6_;
         }
         return _loc2_;
      }
   }
}

