package displays.popups.obtainRequirement
{
   import ZLocalization.LocalizationObjectToken;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   
   public class ObtainRequirementPopup extends GenericPopup
   {
      
      protected var m_info:IObtainRequirementPopupInfo = null;
      
      protected var m_dialog:MovieClip = null;
      
      protected var m_askCard:ObtainRequirementCard = null;
      
      protected var m_buyCard:ObtainRequirementCard = null;
      
      public function ObtainRequirementPopup(param1:IObtainRequirementPopupInfo)
      {
         this.m_info = param1;
         super("",GenericPopup.TYPE_CANCEL,null);
      }
      
      override protected function initDialog() : void
      {
         this.contentWidth = this.m_dialog.width;
         this.contentHeight = this.m_dialog.height;
         super.initDialog();
      }
      
      override protected function setUpLook() : void
      {
         hideAllDialogs();
         this.m_dialog = m_window.popupBox_mc.obtain_mc;
         this.m_dialog.visible = true;
         TextFieldUtil.processTextField(this.m_dialog.title_tf,this.m_info.dialogTitleText);
         TextFieldUtil.processTextField(this.m_dialog.popupBox_tf,this.m_info.dialogSubtitleText);
         this.m_askCard = new ObtainRequirementCard(this.m_dialog.card_mc_01,this.m_info,ObtainRequirementCard.TYPE_ASK,this.onAskButton);
         this.m_buyCard = new ObtainRequirementCard(this.m_dialog.card_mc_02,this.m_info,ObtainRequirementCard.TYPE_BUY,this.onBuyButton);
      }
      
      override protected function getCancelButtonClip() : DisplayObject
      {
         return this.m_dialog.exit_bt;
      }
      
      override protected function deinitDialog() : void
      {
         this.m_askCard.dispose();
         this.m_buyCard.dispose();
         super.deinitDialog();
      }
      
      private function onAskButton(param1:MouseEvent) : void
      {
         this.m_info.onAskButton();
         close();
      }
      
      private function onBuyButton(param1:MouseEvent) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:uint = 0;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:LocalizationObjectToken = null;
         var _loc2_:GameItem = this.m_info.requirementGameItem;
         if(_loc2_)
         {
            _loc3_ = ZGlobal.player.canBuy(_loc2_,true);
            if(_loc3_ && _loc2_.usesCash())
            {
               _loc4_ = this.m_info.buyCost;
               _loc3_ = ZGlobal.player.canBuyCash(_loc4_,true);
               if(_loc3_)
               {
                  if(ZGlobal.gameSettings.showConfirmationPopup(_loc4_))
                  {
                     _loc6_ = ZGameUtils.CashTokenReplacements(_loc4_);
                     _loc7_ = _loc2_.getSentenceNameLocalizationObject("singular");
                     if(_loc7_)
                     {
                        _loc6_.item = _loc7_;
                        _loc5_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage_Object",_loc6_);
                     }
                     else
                     {
                        _loc6_.item = _loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                        _loc6_.quantity = this.m_info.buyQuantity;
                        _loc5_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseQuantityMessage",_loc6_);
                     }
                     PopupManager.instance.push(GenericPopup2B.NewYesNo(_loc5_,ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle"),this.onCashBuyPopupClose));
                     _loc3_ = false;
                  }
               }
            }
            if(_loc3_)
            {
               this.m_info.onPurchase();
            }
            close();
         }
      }
      
      protected function onCashBuyPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.m_info.onPurchase();
         }
      }
   }
}

