package displays.popups.obtainRequirement
{
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.managers.PriceTestManager;
   import core.managers.SuperOreManager;
   import core.managers.WorldObjectManager;
   import core.managers.mayhemManager.MayhemManager;
   import core.ui.UI;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.popups.GallantPopup;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.screens.SuperOreScreen;
   import events.MarketEvent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class ObtainMultiRequirementsPopup extends GallantPopup
   {
      
      public static const EVENT_PURCHASE_ITEM:String = "purchaseItemEvent";
      
      private static const CARD_HORIZ_SPACING:int = 12;
      
      protected static const MAX_CARDS:int = 3;
      
      protected var m_resource:SWFResource = null;
      
      protected var m_info:ObtainMultiRequirementsInfoGameItem = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_variableCards:Array = null;
      
      protected var m_askCard:ObtainRequirementCard = null;
      
      protected var m_goNowCard:ObtainRequirementCard = null;
      
      private var m_buyAllBtn:ZGameButton = null;
      
      private var m_tray:MovieClip = null;
      
      private var m_buyAll:Boolean = false;
      
      private var numAskCards:int = 0;
      
      private var numUseCards:int = 0;
      
      private var m_useCardInfo:ObtainRequirementPopupInfoUseItem;
      
      public function ObtainMultiRequirementsPopup(param1:ObtainMultiRequirementsInfoGameItem)
      {
         this.m_info = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_ObtainRequirementPopup.swf"));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_resource = param1;
         super.onLoadComplete(param1);
      }
      
      protected function get dialog() : MovieClip
      {
         return m_window.obtain_mc;
      }
      
      protected function get trackNeedResources() : Boolean
      {
         return false;
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.dialog.exit_bt.addEventListener(MouseEvent.CLICK,this.onCancel,false,0,true);
         this.m_buttonSounds.addButton(this.dialog.exit_bt,ButtonSound.DEFAULT);
         this.m_tray = new MovieClip();
         this.initializeCards();
         this.initializeTray();
         this.initializeUI();
      }
      
      protected function initializeCards() : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:IObtainRequirementPopupInfo = null;
         var _loc9_:ObtainRequirementCard = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:IEntity = null;
         var _loc16_:Boolean = false;
         var _loc17_:Boolean = false;
         this.m_variableCards = new Array();
         var _loc1_:Class = this.m_resource.getAssetClass("card");
         var _loc2_:MovieClip = null;
         if(this.m_info.numRequirements < MAX_CARDS)
         {
            _loc4_ = false;
            _loc5_ = 0;
            while(_loc5_ < this.m_info.numRequirements)
            {
               if(!this.m_info.isResourceRequirement(_loc5_) && this.m_info.requirementItem(_loc5_).code == "xk01")
               {
                  _loc4_ = true;
                  break;
               }
               _loc5_++;
            }
            if(_loc4_)
            {
               _loc2_ = new _loc1_();
               this.m_askCard = new ObtainRequirementCard(_loc2_,new ObtainRequirementPopupInfoGameItem(this.m_info.requirementItem(_loc5_).code,1),ObtainRequirementCard.TYPE_ASK,this.onAskClicked);
               this.addClipToTray(_loc2_);
               ++this.numAskCards;
            }
            else
            {
               _loc6_ = 0;
               _loc7_ = 1;
               while(_loc7_ < this.m_info.numRequirements)
               {
                  if(this.m_info.requirementQuantity(_loc7_) > this.m_info.requirementQuantity(_loc6_))
                  {
                     _loc6_ = _loc7_;
                  }
                  _loc7_++;
               }
               if(this.m_info.requirementType(_loc6_) == "energy")
               {
                  if(this.m_info.numRequirements == 1)
                  {
                     this.createOnlyEnergyCards(_loc6_);
                     return;
                  }
                  if(this.hasEnergyItemInInventory(this.m_info.requirementItem(_loc6_)))
                  {
                     _loc2_ = new _loc1_();
                     this.addClipToTray(_loc2_);
                     this.createEnergyUseCard(_loc6_,_loc2_);
                  }
               }
               else
               {
                  _loc2_ = new _loc1_();
                  this.m_askCard = new ObtainRequirementCard(_loc2_,new ObtainRequirementPopupInfoResources([this.m_info.requirementType(_loc6_)]),ObtainRequirementCard.TYPE_ASK,this.onAskClicked);
                  this.addClipToTray(_loc2_);
                  ++this.numAskCards;
               }
            }
         }
         var _loc3_:int = 0;
         for(; _loc3_ < this.m_info.numRequirements; _loc3_++)
         {
            _loc2_ = new _loc1_();
            this.addClipToTray(_loc2_);
            _loc8_ = null;
            if(!this.m_info.isResourceRequirement(_loc3_))
            {
               _loc8_ = new ObtainRequirementPopupInfoGameItemPurchase(this.m_info.requirementItem(_loc3_),this.m_info.requirementQuantity(_loc3_));
            }
            else
            {
               if(this.m_info.requirementType(_loc3_) == "energy" && this.m_info.requirementType(_loc6_) != "energy" && this.hasEnergyItemInInventory(this.m_info.requirementItem(_loc3_)))
               {
                  this.createEnergyUseCard(_loc3_,_loc2_);
                  if(Boolean(this.numAskCards) || this.m_info.numRequirements >= MAX_CARDS)
                  {
                     continue;
                  }
               }
               _loc8_ = new ObtainRequirementPopupInfoResourcePurchase(this.m_info.requirementType(_loc3_),this.m_info.requirementQuantity(_loc3_));
            }
            _loc9_ = new ObtainRequirementCard(_loc2_,_loc8_,ObtainRequirementCard.TYPE_BUY_CASH,this.onCardClicked);
            this.m_variableCards.push(_loc9_);
         }
         if(this.m_info.numRequirements + this.numAskCards < MAX_CARDS)
         {
            _loc10_ = ZGlobal.player.getNumberOfInventoryItems(SuperOreManager.ITEM_CODE);
            _loc11_ = WorldObjectManager.instance.getNumberObjectsWithCode(SuperOreManager.ITEM_CODE);
            _loc12_ = -1;
            _loc13_ = 0;
            while(_loc13_ < this.m_info.numRequirements)
            {
               if(this.isNrare(this.m_info.requirementType(_loc13_)))
               {
                  _loc12_ = _loc13_;
                  break;
               }
               _loc13_++;
            }
            if(_loc12_ != -1)
            {
               _loc14_ = _loc12_;
               _loc13_ = _loc12_ + 1;
               while(_loc13_ < this.m_info.numRequirements)
               {
                  if(this.isNrare(this.m_info.requirementType(_loc13_)) && this.m_info.requirementQuantity(_loc13_) > this.m_info.requirementQuantity(_loc14_))
                  {
                     _loc14_ = _loc13_;
                  }
                  _loc13_++;
               }
               _loc15_ = MayhemManager.instance.getBuildingByCode(SuperOreManager.ITEM_CODE);
               _loc2_ = new _loc1_();
               _loc16_ = WorldObjectManager.instance.getNumberBuiltObjectsWithCode(SuperOreManager.ITEM_CODE) == 0;
               _loc17_ = !(_loc11_ && _loc16_) && (Boolean(_loc11_) || _loc16_);
               this.m_goNowCard = new ObtainRequirementCard(_loc2_,new ObtainRequirementPopupInfoResources([this.m_info.requirementType(_loc14_)]),ObtainRequirementCard.TYPE_GO_NOW,this.onGoNowClicked,false,!_loc17_);
               this.addClipToTray(_loc2_);
            }
         }
      }
      
      private function createEnergyUseCard(param1:int, param2:MovieClip) : void
      {
         var _loc3_:ObtainRequirementPopupInfoUseItem = new ObtainRequirementPopupInfoUseItem(this.m_info.requirementQuantity(param1));
         var _loc4_:ObtainRequirementCard = new ObtainRequirementCard(param2,_loc3_,ObtainRequirementCard.TYPE_USE_ITEM,this.onUseCardClicked);
         this.m_useCardInfo = _loc3_;
         ++this.numUseCards;
      }
      
      private function onUseCardClicked(param1:MouseEvent) : void
      {
         UI.instance.setupForItemPlacement();
         UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_USE,MarketEvent.CONSUMABLE,this.m_useCardInfo.requirementGameItem.name,MarketEvent.SOURCE_INVENTORY));
         close();
      }
      
      private function createEnergyAskCard(param1:int) : void
      {
         var _loc2_:Class = this.m_resource.getAssetClass("card");
         var _loc3_:MovieClip = new _loc2_();
         this.m_askCard = new ObtainRequirementCard(_loc3_,new ObtainRequirementPopupInfoResources([this.m_info.requirementType(param1)]),ObtainRequirementCard.TYPE_ASK,this.onAskClicked);
         this.addClipToTray(_loc3_);
         ++this.numAskCards;
      }
      
      private function createEnergyBuyCard(param1:int) : void
      {
         var _loc2_:Class = this.m_resource.getAssetClass("card");
         var _loc3_:MovieClip = new _loc2_();
         this.addClipToTray(_loc3_);
         var _loc4_:ObtainRequirementPopupInfoResourcePurchase = new ObtainRequirementPopupInfoResourcePurchase(this.m_info.requirementType(param1),this.m_info.requirementQuantity(param1));
         var _loc5_:ObtainRequirementCard = new ObtainRequirementCard(_loc3_,_loc4_,ObtainRequirementCard.TYPE_BUY_CASH,this.onCardClicked);
         this.m_variableCards.push(_loc5_);
      }
      
      private function hasEnergyItemInInventory(param1:GameItem) : Boolean
      {
         return ZGlobal.player.getNumberOfInventoryItems(param1.code) > 0;
      }
      
      private function createOnlyEnergyCards(param1:int) : void
      {
         var _loc2_:Class = null;
         var _loc3_:MovieClip = null;
         if(this.hasEnergyItemInInventory(this.m_info.requirementItem(param1)))
         {
            _loc2_ = this.m_resource.getAssetClass("card");
            _loc3_ = new _loc2_();
            this.addClipToTray(_loc3_);
            this.createEnergyUseCard(param1,_loc3_);
            this.createEnergyBuyCard(param1);
            this.createEnergyAskCard(param1);
         }
         else
         {
            this.createEnergyBuyCard(param1);
            this.createEnergyAskCard(param1);
         }
      }
      
      private function initializeTray() : void
      {
         this.dialog.addChild(this.m_tray);
         this.m_tray.x = this.dialog.cardTray_mc.x + (this.dialog.cardTray_mc.width - this.m_tray.width) / 2;
         this.m_tray.y = this.dialog.cardTray_mc.y + (this.dialog.cardTray_mc.height - this.m_tray.height) / 2;
         this.dialog.cardTray_mc.visible = false;
      }
      
      protected function initializeUI() : void
      {
         var _loc3_:int = 0;
         this.m_buyAllBtn = new ZGameButton(this.dialog.buy_bt,this.onBuyAllBtn);
         TextFieldUtil.compactTextField(this.dialog.title_tf,ZGameUtils.ZlocT("Dialogs","ObtainResourcesDialogTitle"),{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         TextFieldUtil.compactTextField(this.dialog.popupBox_tf,ZGameUtils.ZlocT("Dialogs","ObtainResourcesDialogMessage"),{
            "maxLines":2,
            "minScale":0.7,
            "onFail":"return"
         });
         var _loc1_:int = this.m_info.calculatedCost;
         var _loc2_:int = 0;
         if(this.m_info.item.isExpansionItem)
         {
            _loc3_ = PriceTestManager.instance.costMultiplierByType("expansioncap");
            if(_loc3_ > 0 && _loc1_ > _loc3_)
            {
               _loc2_ = (1 - _loc3_ / _loc1_) * 100;
               _loc1_ = _loc3_;
            }
            this.m_info.overrideCost = _loc1_;
         }
         if(_loc2_ > 0)
         {
            this.m_buyAllBtn.compactText(ZGameUtils.ZlocT("Dialogs","BuyAllForAmountDiscount",{
               "amount":_loc1_,
               "discount":_loc2_
            }),{
               "maxLines":1,
               "minScale":0.5,
               "onFail":"return"
            });
         }
         else
         {
            this.m_buyAllBtn.compactText(ZGameUtils.ZlocT("Dialogs","BuyAllForAmount",{"amount":_loc1_}),{
               "maxLines":1,
               "minScale":0.5,
               "onFail":"return"
            });
         }
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_DYNAMIC_RESOURCE_ACTION,{"action":"view"}));
      }
      
      override protected function deinitDialog() : void
      {
         var _loc2_:ObtainRequirementCard = null;
         var _loc1_:MovieClip = m_window.obtain_mc;
         _loc1_.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCancel);
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
         }
         _loc1_.removeChild(this.m_tray);
         if(this.m_askCard)
         {
            this.m_askCard.dispose();
         }
         if(this.m_goNowCard)
         {
            this.m_goNowCard.dispose();
         }
         for each(_loc2_ in this.m_variableCards)
         {
            _loc2_.dispose();
         }
         this.m_resource = null;
         super.deinitDialog();
      }
      
      protected function addClipToTray(param1:MovieClip) : void
      {
         param1.x = this.m_tray.numChildren * (param1.sizer_mc.width + CARD_HORIZ_SPACING);
         this.m_tray.addChild(param1);
      }
      
      protected function onCardClicked(param1:MouseEvent) : void
      {
         var _loc3_:* = 0;
         var _loc2_:int = this.indexOfCardContaining(param1.target as DisplayObject);
         if(_loc2_ >= 0)
         {
            if(this.m_info.isResourceRequirement(_loc2_))
            {
               ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_DYNAMIC_RESOURCE_ACTION,{"action":"yes_" + this.m_info.requirementType(_loc2_)}));
            }
            _loc3_ = int(this.m_info.numRequirements - 1);
            while(_loc3_ >= 0)
            {
               if(_loc3_ != _loc2_)
               {
                  this.m_info.removeRequirement(_loc3_);
               }
               _loc3_--;
            }
            this.m_info.overrideCost = 0;
            this.purchaseItems();
         }
      }
      
      protected function onAskClicked(param1:MouseEvent) : void
      {
         this.m_askCard.info.onAskButton();
         close();
      }
      
      private function onBuyAllBtn(param1:MouseEvent) : void
      {
         this.purchaseItems(true);
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_DYNAMIC_RESOURCE_ACTION,{"action":"yes_all"}));
      }
      
      private function onGoNowClicked(param1:MouseEvent) : void
      {
         var _loc6_:IEntity = null;
         var _loc7_:GameItem = null;
         var _loc2_:String = SuperOreManager.ITEM_CODE;
         var _loc3_:int = ZGlobal.player.getNumberOfInventoryItems(_loc2_);
         var _loc4_:int = WorldObjectManager.instance.getNumberObjectsWithCode(_loc2_);
         var _loc5_:int = WorldObjectManager.instance.getNumberBuiltObjectsWithCode(_loc2_);
         if(_loc5_ > 0 || _loc4_ > 0)
         {
            _loc6_ = MayhemManager.instance.getBuildingByCode(_loc2_);
            if(_loc6_)
            {
               SuperOreScreen.display(EventDispatcher(_loc6_.eventDispatcher),_loc2_,_loc6_,null);
            }
         }
         else if(_loc3_ > 0)
         {
            _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc2_,GameItem) as GameItem;
            GameModeManager.instance.addGameMode(new GMObjectPlace(_loc7_.name,MarketEvent.SOURCE_INVENTORY,true));
         }
         close();
      }
      
      private function onCancel(param1:MouseEvent) : void
      {
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_DYNAMIC_RESOURCE_ACTION,{"action":"no"}));
         close();
      }
      
      private function indexOfCardContaining(param1:DisplayObject) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.m_variableCards.length)
         {
            if(ObtainRequirementCard(this.m_variableCards[_loc2_]).card.contains(param1))
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      private function purchaseItems(param1:Boolean = false) : void
      {
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc2_:int = this.m_info.cashCostTotal;
         var _loc3_:Boolean = ZGlobal.player.canBuyCash(_loc2_,true);
         if(_loc3_)
         {
            this.m_buyAll = param1;
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc2_))
            {
               _loc4_ = ZGameUtils.CashTokenReplacements(_loc2_);
               _loc5_ = ZGameUtils.ZlocT("Dialogs","ObtainResourcesBuyConfirmationMessage",_loc4_);
               PopupManager.instance.push(GenericPopup2B.NewYesNo(_loc5_,ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle"),this.onCashBuyPopupClose));
            }
            else
            {
               this.doPurchase();
            }
         }
         close();
      }
      
      private function onCashBuyPopupClose(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.doPurchase();
         }
      }
      
      protected function doPurchase() : void
      {
         var _loc1_:Boolean = true;
         var _loc2_:Boolean = !this.m_info.item.isExpansionItem || !this.m_buyAll;
         ZGlobal.player.buyMultiRequirementItem(this.m_info,_loc1_,_loc2_,this.trackNeedResources);
         ZGlobal.player.multiRequirementItemInfo = this.m_info;
         if(this.m_buyAll)
         {
            UIDispatcher.instance.dispatchEvent(new WorldEvent(EVENT_PURCHASE_ITEM,this.m_info.item));
         }
      }
      
      private function isNrare(param1:String) : Boolean
      {
         var _loc2_:Array = ["aluminum","copper","gold","iron","uranium"];
         var _loc3_:String = ZGlobal.player.rareResourceName;
         if(_loc2_.indexOf(param1) >= 0 && param1 != ZGlobal.player.rareResourceName)
         {
            return true;
         }
         return false;
      }
   }
}

