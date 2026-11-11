package displays.screens.dominationMode
{
   import ZLocalization.LocalizationObjectToken;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.TierSurfacingManager;
   import core.managers.domination.DominationModeManager;
   import core.ui.Tooltip;
   import core.ui.UI;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.screens.gridScreen.GridSlot;
   import events.MarketEvent;
   import fl.containers.UILoader;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class DominationModeRewardGridSlot extends GridSlot
   {
      
      private var m_unit:UnitItem = null;
      
      private var m_confirmationItem:GameItem = null;
      
      private var m_imageLoader:ImageLoader;
      
      private var m_buyButton:ZGameButton = null;
      
      private var m_buyable:Boolean = false;
      
      private var m_disableArt:Boolean;
      
      public function DominationModeRewardGridSlot(param1:SWFResource, param2:MovieClip, param3:int, param4:int, param5:UnitItem, param6:Boolean = false)
      {
         this.m_unit = param5;
         this.m_buyable = param6;
         super(param1,param2,null);
         slot.x = param3 * sizerWidth;
         slot.y = param4 * sizerHeight;
      }
      
      override public function dispose() : void
      {
         var _loc1_:UILoader = slot.unitCard_mc.icon;
         if(Boolean(_loc1_) && Boolean(_loc1_.content))
         {
            _loc1_.content.filters = [];
         }
         if(this.m_imageLoader)
         {
            this.m_imageLoader.destroy();
            this.m_imageLoader = null;
         }
         super.dispose();
      }
      
      override protected function get className() : String
      {
         return "Card_mc";
      }
      
      override protected function createSlot(param1:SWFResource) : MovieClip
      {
         var _loc2_:Class = param1.getAssetClass(this.className);
         return new _loc2_();
      }
      
      private function onIconLoadComplete(param1:String, param2:BitmapData) : void
      {
         var _loc3_:UILoader = null;
         if(this.m_disableArt)
         {
            _loc3_ = slot.unitCard_mc.icon;
            _loc3_.content.alpha = 0.5;
            _loc3_.content.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
         }
      }
      
      override protected function onSlotCreated() : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_unit.name,"icon"),slot.unitCard_mc.icon,this.onIconLoadComplete);
         TextFieldUtil.processTextField(slot.unitCard_mc.itemName_tf,this.m_unit.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         var _loc1_:int = int(this.m_unit.requiredDominanceRank);
         var _loc2_:Boolean = ZGlobal.player.hasPurchasedContract(this.m_unit.code);
         if(_loc2_ && this.m_buyable)
         {
            this.m_buyable = false;
         }
         if(DominationModeManager.instance.dominanceRank < _loc1_ && !_loc2_)
         {
            if(this.m_buyable)
            {
               slot.buy_bt.visible = true;
               this.m_buyButton = new ZGameButton(slot.buy_bt,this.onUnlockItem);
               _loc4_ = this.m_unit.contractCost;
               this.m_buyButton.compactText(ZGameUtils.ZlocT("Dialogs","UnlockForAmount",{"amount":_loc4_}),{
                  "minScale":0.7,
                  "fontSize":14
               });
               _loc3_ = true;
            }
            else
            {
               rollOverHighlightEnabled = false;
               slot.buy_bt.visible = false;
               Tooltip.subscribe(slot.unitCard_mc,ZGameUtils.ZlocT("Dialogs","DominationRewardLocked",{"num":_loc1_}),DominationModeManager.instance.tooltipOptions);
               this.m_disableArt = true;
            }
            TextFieldUtil.processTextField(slot.unitCard_mc.locked_mc.locked_tf,_loc1_.toString());
            slot.unitCard_mc.locked_mc.visible = true;
         }
         else
         {
            rollOverHighlightEnabled = false;
            _loc3_ = true;
            slot.buy_bt.visible = false;
            slot.unitCard_mc.locked_mc.visible = false;
            Tooltip.subscribe(slot.unitCard_mc,ZGameUtils.ZlocT("Dialogs","DominationModeBuildLocTooltip",{"location":this.m_unit.builtFromStructure.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME)}),DominationModeManager.instance.tooltipOptions);
         }
         this.activateStrengthBar(_loc3_);
      }
      
      public function get strengthBarVisible() : Boolean
      {
         return slot.unitCard_mc.strength_mc.visible;
      }
      
      private function activateStrengthBar(param1:Boolean) : void
      {
         slot.unitCard_mc.strength_mc.visible = param1;
         if(slot.unitCard_mc.tierRating_mc)
         {
            slot.unitCard_mc.tierRating_mc.visible = false;
         }
         if(param1)
         {
            TextFieldUtil.processTextField(slot.unitCard_mc.strength_mc.strength_tf,this.m_unit.getUpgradedStrength().toString());
            if(TierSurfacingManager.instance.tierSurfacingEnabled && Boolean(slot.unitCard_mc.tierRating_mc))
            {
               TextFieldUtil.compactTextField(slot.unitCard_mc.tierRating_mc.tier_tf,this.m_unit.tier.toString());
               slot.unitCard_mc.tierRating_mc.visible = param1;
            }
         }
      }
      
      private function onUnlockItem(param1:Event) : void
      {
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:LocalizationObjectToken = null;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:GameItem = this.m_unit as GameItem;
         _loc3_ = _loc4_.contractCost;
         if(_loc3_ > 0)
         {
            _loc2_ = ZGlobal.player.canBuyCash(_loc3_,true,"",false);
         }
         if(_loc2_)
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc3_))
            {
               this.m_confirmationItem = _loc4_;
               _loc6_ = ZGameUtils.CashTokenReplacements(_loc3_);
               _loc7_ = this.m_confirmationItem.getSentenceNameLocalizationObject("singular",true);
               if(_loc7_)
               {
                  _loc6_.item = _loc7_;
                  _loc5_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockContractMessage_Object",_loc6_);
               }
               else
               {
                  _loc6_.item = this.m_confirmationItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                  _loc5_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockContractMessage",_loc6_);
               }
               _loc8_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
               _loc9_ = new Array("EmpirePointsConfirm","","","");
               PopupManager.instance.push(GenericPopup2B.NewYesNo(_loc5_,_loc8_,this.onCashBuyPopupClose,_loc9_),0,false,false,false);
               return;
            }
         }
         if(_loc2_ == true)
         {
            this.buyItem(_loc4_);
         }
      }
      
      private function buyItem(param1:GameItem) : void
      {
         slot.buy_bt.visible = false;
         slot.unitCard_mc.locked_mc.visible = false;
         this.activateStrengthBar(true);
         Tooltip.subscribe(slot.unitCard_mc,ZGameUtils.ZlocT("Dialogs","DominationModeBuildLocTooltip",{"location":this.m_unit.builtFromStructure.getFriendlyName(GameItem.SENTENCE_FRIENDLYNAME)}),DominationModeManager.instance.tooltipOptions);
         UI.instance.setupForItemPurchase();
         UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_UNLOCK_CONTRACT,0,param1.name,MarketEvent.SOURCE_NONE));
         DominationModeManager.instance.dispatchEvent(new WorldEvent(DominationModeManager.DOMINATION_REWARD_UNLOCKED,param1));
      }
      
      protected function onCashBuyPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.buyItem(this.m_confirmationItem);
            this.m_confirmationItem = null;
         }
      }
   }
}

