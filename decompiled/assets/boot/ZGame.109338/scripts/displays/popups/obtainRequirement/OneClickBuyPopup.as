package displays.popups.obtainRequirement
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGameStats;
   import core.ZGlobal;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import transactions.TBuyItem;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class OneClickBuyPopup extends ObtainMultiRequirementsPopup
   {
      
      private static const PRICETEST_TYPE:String = "oneClickBuy";
      
      private var m_cashCost:int;
      
      private var m_purchaseMade:Boolean = false;
      
      public function OneClickBuyPopup(param1:ObtainMultiRequirementsInfoGameItem)
      {
         super(param1);
         this.m_cashCost = m_info.item.getModifiedCash(1,1,"oneClickBuy");
      }
      
      override protected function initializeCards() : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:IObtainRequirementPopupInfo = null;
         var _loc8_:ObtainRequirementCard = null;
         m_variableCards = new Array();
         var _loc1_:Class = m_resource.getAssetClass("card");
         var _loc2_:MovieClip = null;
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         while(_loc4_ < m_info.numRequirements)
         {
            if(!m_info.isResourceRequirement(_loc4_) && m_info.requirementItem(_loc4_).code == "xk01")
            {
               _loc3_ = true;
               break;
            }
            _loc4_++;
         }
         if(_loc3_)
         {
            _loc2_ = new _loc1_();
            m_askCard = new ObtainRequirementCard(_loc2_,new ObtainRequirementPopupInfoGameItem(m_info.requirementItem(_loc4_).code,1),ObtainRequirementCard.TYPE_ASK,onAskClicked);
            addClipToTray(_loc2_);
         }
         else
         {
            _loc5_ = 0;
            _loc6_ = 1;
            while(_loc6_ < m_info.numRequirements)
            {
               if(m_info.requirementQuantity(_loc6_) > m_info.requirementQuantity(_loc5_))
               {
                  _loc5_ = _loc6_;
               }
               _loc6_++;
            }
            _loc2_ = new _loc1_();
            m_askCard = new ObtainRequirementCard(_loc2_,new ObtainRequirementPopupInfoResources([m_info.requirementType(_loc5_)]),ObtainRequirementCard.TYPE_ASK,onAskClicked);
            addClipToTray(_loc2_);
            _loc2_ = new _loc1_();
            addClipToTray(_loc2_);
            _loc7_ = null;
            if(!m_info.isResourceRequirement(_loc5_))
            {
               _loc7_ = new ObtainRequirementPopupInfoGameItemPurchase(m_info.requirementItem(_loc5_),m_info.requirementQuantity(_loc5_));
            }
            else
            {
               _loc7_ = new ObtainRequirementPopupInfoResourcePurchase(m_info.requirementType(_loc5_),m_info.requirementQuantity(_loc5_));
            }
            _loc8_ = new ObtainRequirementCard(_loc2_,_loc7_,ObtainRequirementCard.TYPE_BUY_CASH,onCardClicked);
            m_variableCards.push(_loc8_);
         }
         _loc2_ = new _loc1_();
         addClipToTray(_loc2_);
         _loc7_ = new OneClickBuyPopupInfoGameItemPurchase(m_info.item,1);
         _loc8_ = new ObtainRequirementCard(_loc2_,_loc7_,ObtainRequirementCard.TYPE_BUY_CASH,this.onBuyItem,true);
         m_variableCards.push(_loc8_);
      }
      
      override protected function initializeUI() : void
      {
         dialog.buy_bt.visible = false;
         TextFieldUtil.compactTextField(dialog.title_tf,ZGameUtils.ZlocT("Dialogs","ObtainResourcesDialogTitle"),{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         TextFieldUtil.compactTextField(dialog.popupBox_tf,ZGameUtils.ZlocT("Dialogs","OneClickBuyDialogMessage"),{
            "maxLines":2,
            "minScale":0.7,
            "onFail":"return"
         });
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_DYNAMIC_RESOURCE_ACTION,{"action":"view"}));
         StatsManager.count("dialog","need_resource","view");
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         if(!this.m_purchaseMade)
         {
            StatsManager.count("dialog","need_resource","skip");
         }
      }
      
      private function onBuyItem(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc5_:GenericPopup = null;
         if(ZGlobal.player.canBuyCash(this.m_cashCost,true,"",false))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(this.m_cashCost))
            {
               _loc2_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmPartBuyTitle");
               _loc3_ = ZGameUtils.CashTokenReplacements(this.m_cashCost);
               _loc3_["item"] = m_info.item.getSentenceNameLocalizationObject("singular");
               _loc4_ = ZGameUtils.ZlocT("Dialogs","OneClickBuyConfirmationMessage",_loc3_);
               _loc5_ = GenericPopup2B.NewYesNo(_loc4_,_loc2_,this.buyItemConfirmed);
               _loc5_.userData = {
                  "item":m_info.item,
                  "amount":1
               };
               PopupManager.instance.push(_loc5_,0,false);
            }
            else
            {
               this.buyItem();
            }
         }
      }
      
      private function buyItemConfirmed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES)
         {
            this.buyItem();
         }
      }
      
      private function buyItem() : void
      {
         ZGlobal.player.buyItem(m_info.item,true,1,OneClickBuyPopup.PRICETEST_TYPE);
         ZGlobal.player.addToInventory(m_info.item.code,1);
         TransactionManager.addTransaction(new TBuyItem(m_info.item.code,true,1,{"needResources":true},OneClickBuyPopup.PRICETEST_TYPE),true);
         this.m_purchaseMade = true;
         StatsManager.count("dialog","need_resource","buy_item");
         close();
         PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs","ItemPlacedIntoInventory")),100);
      }
      
      override protected function doPurchase() : void
      {
         super.doPurchase();
         this.m_purchaseMade = true;
         StatsManager.count("dialog","need_resource","buy_resource");
      }
      
      override protected function get trackNeedResources() : Boolean
      {
         return true;
      }
   }
}

