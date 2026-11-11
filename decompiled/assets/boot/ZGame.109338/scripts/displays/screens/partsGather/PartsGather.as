package displays.screens.partsGather
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsItem;
   import core.gameobjects.UnitItem;
   import core.managers.ExperimentsManager;
   import core.managers.promoManager.PromoManager;
   import core.player.Player;
   import core.ui.UIManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.PlayerStatsUIItem;
   import dispatchers.MessageDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.zgamepopup.ZGamePopUp;
   import events.CloseEvent;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TBuyItem;
   import transactions.TBuyItems;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class PartsGather extends ZGamePopUp
   {
      
      protected static var m_partsItem:PartsItem;
      
      protected static var NUM_SLOTS:int = 4;
      
      protected var m_partsWindow:MovieClip;
      
      protected var m_slotMCs:Array = [];
      
      protected var m_slotData:Array = [];
      
      protected var itemIconLoader:ImageLoader;
      
      protected var m_slotIconLoaders:Array;
      
      protected var m_entity:IEntity = null;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_buyAllButton:ZGameButton = null;
      
      private var m_buyPopup:GenericPopup2B = null;
      
      private var m_discount:int = 0;
      
      public function PartsGather(param1:EventDispatcher, param2:String, param3:IEntity)
      {
         animation = null;
         m_partsItem = this.getPartsItem(param2);
         this.m_eventDispatcher = param1;
         this.m_entity = param3;
         this.m_discount = this.getBuildableDiscount(param2);
         super(ZGlobal.getAssetURL(this.assetUrl));
      }
      
      protected function get assetUrl() : String
      {
         return "";
      }
      
      private function getBuildableDiscount(param1:String) : int
      {
         var expireDate:Date = null;
         var currentDate:Date = null;
         var itemCode:String = param1;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BUILDABLE_DISCOUNT) == ExperimentsManager.VARIANT_BUILDABLE_DISCOUNT_ENABLED)
         {
            if(PromoManager.instance.buildableDiscounts[itemCode] != null && PromoManager.instance.buildableDiscounts[itemCode]["discount"] != null && PromoManager.instance.buildableDiscounts[itemCode]["expiration"] != null)
            {
               expireDate = null;
               try
               {
                  expireDate = new Date(PromoManager.instance.buildableDiscounts[itemCode]["expiration"]);
               }
               catch(e:Error)
               {
                  Logger.debug(this,PromoManager.instance.buildableDiscounts[itemCode]["expiration"],e.message);
               }
               if(expireDate)
               {
                  currentDate = new Date();
                  if(currentDate.getTime() <= expireDate.getTime())
                  {
                     return PromoManager.instance.buildableDiscounts[itemCode]["discount"];
                  }
               }
            }
         }
         return 0;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:Class = param1.getAssetClass("PartsDialog");
         this.m_partsWindow = new _loc2_();
         contentWidth = this.m_partsWindow.width;
         contentHeight = this.m_partsWindow.height;
         this.m_buyAllButton = new ZGameButton(this.m_partsWindow.buyAll_bt,this.onBuyAllClick);
         this.updateBuyAllButton();
         this.loadUnitCardIcon();
         if(this.m_partsWindow.back_bt)
         {
            this.m_partsWindow.back_bt.visible = false;
         }
         var _loc3_:int = 1;
         while(_loc3_ <= NUM_SLOTS)
         {
            this.m_slotMCs.push(this.m_partsWindow.slots_mc["card_mc_" + _loc3_.toString()]);
            _loc3_++;
         }
         this.initDialog();
         this.setTitleText();
         this.setDescriptionText();
         this.setHintText();
         TextFieldUtil.compactTextField(this.m_partsWindow.instructions_tf,this.getBuildingPartsInstructionsString());
         this.m_partsWindow.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitButtonClick,false,0,true);
         MessageDispatcher.instance.addEventListener(MessageDispatcher.ITEM_GIFT,this.onItemGift,false,0,true);
         UIDispatcher.instance.addEventListener(Player.INVENTORY_UPDATED,this.onInventoryUpdated,false,0,true);
         this.m_buttonSounds.addButton(this.m_partsWindow.exit_bt,ButtonSound.DEFAULT);
         this.m_buttonSounds.addButton(this.m_buyAllButton.m_overlay,ButtonSound.DEFAULT);
         var _loc4_:int = Math.min(m_partsItem.numParts,NUM_SLOTS);
         if(_loc4_ == 3)
         {
            this.m_partsWindow.slots_mc.x += 88;
         }
         addChild(this.m_partsWindow);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(true);
         dispatchEvent(new Event(Event.COMPLETE));
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(WindowManager.instance.container,0);
      }
      
      protected function loadUnitCardIcon() : void
      {
         var _loc1_:String = ZGlobal.gameSettings.getImageByName(m_partsItem.name,"screenicon");
         var _loc2_:UnitItem = ZGlobal.gameSettings.getItemByCode(m_partsItem.code,UnitItem) as UnitItem;
         if(_loc2_.hasType(UnitItem.MEGA_UNIT))
         {
            _loc1_ = ZGlobal.gameSettings.getImageByName(m_partsItem.name,"icon");
         }
         if(_loc1_)
         {
            this.itemIconLoader = ImageLoaderFactory.CreateImageLoader(_loc1_,this.m_partsWindow.bigIcon);
            this.itemIconLoader.smooth = true;
            if(!m_partsItem.isUnit())
            {
               if(this.m_partsWindow.hasOwnProperty("unitCard_mc"))
               {
                  this.m_partsWindow.unitCard_mc.upgrades_mc.visible = false;
                  this.m_partsWindow.unitCard_mc.tooltip.visible = false;
               }
            }
         }
         else if(this.m_partsWindow.hasOwnProperty("unitCard_mc"))
         {
            TextFieldUtil.compactTextField(this.m_partsWindow.unitCard_mc.itemName_tf,m_partsItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            this.itemIconLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(m_partsItem.name,"icon"),this.m_partsWindow.unitCard_mc.icon);
            this.m_partsWindow.unitCard_mc.upgrades_mc.visible = false;
            this.m_partsWindow.unitCard_mc.tooltip.visible = false;
         }
      }
      
      override protected function initDialog() : void
      {
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.updateElements();
         super.initDialog();
      }
      
      private function updateElements() : void
      {
         this.purgeSlotData();
         this.m_slotData = new Array();
         this.m_slotIconLoaders = new Array();
         this.updateSlots();
         this.updateBuyAllButton();
      }
      
      public function applyDiscount(param1:int) : int
      {
         var _loc3_:int = 0;
         var _loc2_:int = param1;
         if(this.m_discount > 0)
         {
            _loc3_ = int(Math.floor(param1 * this.m_discount / 100));
            _loc2_ -= _loc3_;
         }
         return _loc2_;
      }
      
      private function updateSlots() : void
      {
         var _loc3_:String = null;
         var _loc4_:GameItem = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:Loader = null;
         var _loc11_:ZGameButton = null;
         var _loc12_:ZGameButton = null;
         var _loc13_:String = null;
         var _loc14_:String = null;
         var _loc1_:int = Math.min(m_partsItem.numParts,NUM_SLOTS);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = m_partsItem.getPartCodeForIndex(_loc2_);
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,GameItem) as GameItem;
            _loc5_ = this.applyDiscount(_loc4_.cash);
            TextFieldUtil.compactTextField(this.m_slotMCs[_loc2_].itemName_tf,_loc4_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            _loc6_ = ZGlobal.player.getNumberOfInventoryItems(_loc3_);
            _loc7_ = m_partsItem.getPartCountForIndex(_loc2_);
            _loc8_ = Math.min(_loc6_,_loc7_);
            TextFieldUtil.compactTextField(this.m_slotMCs[_loc2_].count_tf,ZGameUtils.ZlocT("Dialogs","BuildingPartProgress",{
               "numHave":_loc8_,
               "numRequired":_loc7_
            }));
            _loc9_ = ZGlobal.gameSettings.getImageByName(_loc4_.name,"icon");
            _loc10_ = ImageLoaderFactory.CreateImageLoader(_loc9_,this.m_slotMCs[_loc2_].icon);
            this.m_slotIconLoaders.push(_loc10_);
            if(this.m_slotMCs[_loc2_].hasOwnProperty("discount_mc"))
            {
               if(this.m_discount == 0)
               {
                  this.m_slotMCs[_loc2_].discount_mc.visible = false;
               }
               else
               {
                  this.m_slotMCs[_loc2_].discount_mc.visible = true;
                  TextFieldUtil.compactTextField(this.m_slotMCs[_loc2_].discount_mc.percent_tf,"-" + String(this.m_discount) + "%");
               }
            }
            _loc11_ = null;
            _loc12_ = null;
            if(_loc6_ >= _loc7_)
            {
               this.m_slotMCs[_loc2_].ask_bt.visible = false;
               this.m_slotMCs[_loc2_].buy_bt.visible = false;
               this.m_slotMCs[_loc2_].cashIcon_mc.visible = false;
               if(this.m_slotMCs[_loc2_].checklistIcon_mc)
               {
                  this.m_slotMCs[_loc2_].checklistIcon_mc.visible = false;
               }
            }
            else
            {
               _loc13_ = String(_loc2_);
               _loc11_ = new ZGameButton(this.m_slotMCs[_loc2_].ask_bt,this.onAskClick);
               _loc11_.buttonValue = _loc13_;
               _loc11_.text = this.getAskForPartString();
               this.m_buttonSounds.addButton(_loc11_.m_overlay,ButtonSound.DEFAULT);
               _loc12_ = new ZGameButton(this.m_slotMCs[_loc2_].buy_bt,this.onBuyPartClick);
               _loc12_.buttonValue = _loc13_;
               _loc14_ = ZGameUtils.ZlocT("Dialogs","BuildingPartBuyPartButton",{"amount":_loc5_});
               _loc12_.compactText(_loc14_,{
                  "maxLines":1,
                  "minScale":0.4,
                  "onFail":"return"
               });
               this.m_buttonSounds.addButton(_loc12_.m_overlay,ButtonSound.DEFAULT);
            }
            this.m_slotData.push({
               "partItem":_loc4_,
               "haveCount":_loc6_,
               "requiredCount":_loc7_,
               "askButton":_loc11_,
               "buyButton":_loc12_,
               "amount":_loc5_
            });
            this.m_slotMCs[_loc2_].visible = true;
            _loc2_++;
         }
         while(_loc2_ < NUM_SLOTS)
         {
            if(this.m_slotMCs[_loc2_])
            {
               this.m_slotMCs[_loc2_].visible = false;
            }
            _loc2_++;
         }
      }
      
      protected function getAskForPartString() : String
      {
         return ZGameUtils.ZlocT("Dialogs","BuildingPartAskPartButton");
      }
      
      protected function getBuildingPartsInstructionsString() : String
      {
         return ZGameUtils.ZlocT("Dialogs","BuildingPartsInstructions");
      }
      
      protected function canFinish() : Boolean
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.m_slotData.length)
         {
            if(this.m_slotData[_loc1_].haveCount < this.m_slotData[_loc1_].requiredCount)
            {
               return false;
            }
            _loc1_++;
         }
         return true;
      }
      
      private function updateBuyAllButton() : void
      {
         var _loc1_:Object = this.getRemainingPartsData(m_partsItem);
         var _loc2_:String = _loc1_.cash == 0 ? "BuildingPartsConfirmBuild" : "BuildingPartsBuyAllButton";
         var _loc3_:Object = _loc1_.cash == 0 ? null : ZGameUtils.CashTokenReplacements(_loc1_.cash);
         this.m_partsWindow.buyAll_bt.empirePoints_mc.visible = _loc1_.cash == 0 ? false : true;
         var _loc4_:String = ZGameUtils.ZlocT("Dialogs",_loc2_,_loc3_);
         this.m_buyAllButton.compactText(_loc4_,{
            "maxLines":1,
            "minScale":0.6,
            "onFail":"return"
         });
         if(_loc1_.cash == 0)
         {
            this.setDescriptionText();
            this.m_buyAllButton.callback = this.onFinishClick;
         }
      }
      
      protected function onFinishClick(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:GameItem = null;
         var _loc4_:int = 0;
         if(this.canFinish())
         {
            _loc2_ = 0;
            while(_loc2_ < this.m_slotData.length)
            {
               _loc3_ = this.m_slotData[_loc2_].partItem;
               _loc4_ = int(this.m_slotData[_loc2_].requiredCount);
               ZGlobal.player.removeInventoryItem(_loc3_.code,_loc4_);
               _loc2_++;
            }
            this.completePartsItem();
         }
      }
      
      protected function getPartsItem(param1:String) : PartsItem
      {
         return null;
      }
      
      protected function setTitleText() : void
      {
      }
      
      protected function setDescriptionText() : void
      {
      }
      
      protected function setHintText() : void
      {
      }
      
      protected function completePartsItem() : void
      {
      }
      
      protected function onAskClick(param1:MouseEvent) : void
      {
      }
      
      protected function sendStatsEvent(param1:Boolean) : void
      {
      }
      
      protected function getSlotInfoFromEvent(param1:MouseEvent) : Object
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc2_:String = param1.currentTarget.buttonValue;
         var _loc3_:int = int(_loc2_);
         if(_loc3_ < this.m_slotData.length)
         {
            return {
               "slotIndex":_loc3_,
               "data":this.m_slotData[_loc3_]
            };
         }
         return null;
      }
      
      protected function onExitButtonClick(param1:MouseEvent) : void
      {
         this.closeWindow(param1);
         this.m_eventDispatcher.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
      }
      
      protected function closeWindow(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         this.m_partsWindow.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitButtonClick);
         MessageDispatcher.instance.removeEventListener(MessageDispatcher.ITEM_GIFT,this.onItemGift);
         UIDispatcher.instance.removeEventListener(Player.INVENTORY_UPDATED,this.onInventoryUpdated);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(false);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(UIManager.instance.uiDisplay,0);
         close();
      }
      
      private function onItemGift(param1:WorldEvent) : void
      {
         var _loc4_:String = null;
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         while(_loc3_ < m_partsItem.numParts)
         {
            _loc4_ = m_partsItem.getPartCodeForIndex(_loc3_);
            if(_loc4_ == param1.eventData.code)
            {
               _loc2_ = true;
               break;
            }
            _loc3_++;
         }
         if(_loc2_)
         {
            this.updateElements();
         }
      }
      
      private function onInventoryUpdated(param1:WorldEvent) : void
      {
         var _loc4_:String = null;
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         while(_loc3_ < m_partsItem.numParts)
         {
            _loc4_ = m_partsItem.getPartCodeForIndex(_loc3_);
            if(_loc4_ == param1.eventData.code)
            {
               _loc2_ = true;
               break;
            }
            _loc3_++;
         }
         if(_loc2_)
         {
            this.updateElements();
         }
      }
      
      private function onBuyPartClick(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc2_:Object = this.getSlotInfoFromEvent(param1).data;
         var _loc3_:GameItem = _loc2_.partItem;
         if(_loc3_)
         {
            _loc4_ = this.applyDiscount(_loc3_.cash);
            if(ZGlobal.player.canBuyCash(_loc4_,true))
            {
               if(ZGlobal.gameSettings.showConfirmationPopup(_loc4_))
               {
                  _loc5_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmPartBuyTitle");
                  _loc6_ = ZGameUtils.CashTokenReplacements(_loc4_);
                  _loc6_.item = _loc3_.getSentenceNameLocalizationObject("singular,indefinite",true);
                  _loc7_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmPartBuyMessage",_loc6_);
                  this.m_buyPopup = GenericPopup2B.NewYesNo(_loc7_,_loc5_,this.buyPartConfirmed);
                  this.m_buyPopup.userData = {"partItem":_loc3_};
                  PopupManager.instance.push(this.m_buyPopup);
               }
               else
               {
                  this.buyPart(_loc3_);
               }
            }
         }
      }
      
      private function buyPartConfirmed(param1:GenericPopupEvent) : void
      {
         var _loc2_:GameItem = null;
         if(param1.button == GenericPopup.YES)
         {
            _loc2_ = param1.userData.partItem;
            this.buyPart(_loc2_);
         }
      }
      
      private function buyPart(param1:GameItem) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Object = null;
         var _loc4_:Object = null;
         if(param1 != null)
         {
            _loc2_ = true;
            _loc3_ = new Object();
            _loc3_.discountedCost = this.applyDiscount(param1.cash);
            ZGlobal.player.buyItem(param1,_loc2_,1,null,false,_loc3_);
            ZGlobal.player.addToInventory(param1.code);
            _loc4_ = {"unitCode":m_partsItem.code};
            TransactionManager.addTransaction(new TBuyItem(param1.code,_loc2_,1,_loc4_),true);
            this.updateElements();
            this.sendStatsEvent(false);
            this.buyPartResetScreen();
         }
      }
      
      public function buyPartResetScreen() : void
      {
      }
      
      public function buyAllPartsPopup(param1:MouseEvent) : void
      {
         this.onBuyAllClick(param1);
      }
      
      private function onBuyAllClick(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc5_:String = null;
         var _loc2_:Object = this.getRemainingPartsData(m_partsItem);
         if(ZGlobal.player.canBuyCash(_loc2_.cash,true))
         {
            if(ZGlobal.gameSettings.showConfirmationPopup(_loc2_.cash))
            {
               _loc3_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmPartBuyTitle");
               _loc4_ = ZGameUtils.CashTokenReplacements(_loc2_.cash);
               _loc5_ = ZGameUtils.ZlocT("Dialogs","BuildingPartConfirmAllPartsBuyMessage",_loc4_);
               this.m_buyPopup = GenericPopup2B.NewYesNo(_loc5_,_loc3_,this.buyAllPartsConfirmed);
               this.m_buyPopup.userData = {"partItems":_loc2_.remaining};
               PopupManager.instance.push(this.m_buyPopup);
            }
            else
            {
               this.buyAllParts(_loc2_.remaining);
            }
         }
      }
      
      private function buyAllPartsConfirmed(param1:GenericPopupEvent) : void
      {
         var _loc2_:Dictionary = null;
         if(param1.button == GenericPopup.YES)
         {
            _loc2_ = param1.userData.partItems;
            this.buyAllParts(_loc2_);
         }
      }
      
      public function buyAllParts(param1:Dictionary, param2:Boolean = true) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:GameItem = null;
         var _loc7_:Object = null;
         if(param1 != null)
         {
            _loc3_ = true;
            for(_loc4_ in param1)
            {
               _loc6_ = ZGlobal.gameSettings.getItemByCode(_loc4_,GameItem) as GameItem;
               _loc7_ = new Object();
               _loc7_.discountedCost = this.applyDiscount(_loc6_.cash);
               ZGlobal.player.buyItem(_loc6_,_loc3_,param1[_loc4_],null,false,_loc7_);
               ZGlobal.player.addToInventory(_loc6_.code,param1[_loc4_]);
            }
            _loc5_ = {"unitCode":m_partsItem.code};
            TransactionManager.addTransaction(new TBuyItems(param1,_loc3_,_loc5_),true);
            if(param2)
            {
               this.updateElements();
            }
            this.sendStatsEvent(true);
         }
      }
      
      public function getRemainingPartsAmount(param1:PartsItem = null, param2:Class = null) : int
      {
         var _loc3_:Object = null;
         _loc3_ = this.getRemainingPartsData(param1,param2);
         if(_loc3_)
         {
            return _loc3_.cash;
         }
         return 0;
      }
      
      public function getRemainingPartsData(param1:PartsItem = null, param2:Class = null) : Object
      {
         var _loc3_:Dictionary = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:GameItem = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         if(param1)
         {
            if(Boolean(param2) && !(param1 is param2))
            {
               param1 = ZGlobal.gameSettings.getItemByCode(param1.code,param2) as PartsItem;
            }
            _loc3_ = new Dictionary();
            _loc4_ = Math.min(param1.numParts,NUM_SLOTS);
            _loc5_ = 0;
            _loc6_ = 0;
            while(_loc6_ < _loc4_)
            {
               _loc7_ = param1.getPartCodeForIndex(_loc6_);
               _loc8_ = ZGlobal.gameSettings.getItemByCode(_loc7_,GameItem) as GameItem;
               if(_loc8_)
               {
                  _loc9_ = ZGlobal.player.getNumberOfInventoryItems(_loc7_);
                  _loc10_ = param1.getPartCountForIndex(_loc6_);
                  if(_loc10_ > _loc9_)
                  {
                     _loc11_ = _loc10_ - _loc9_;
                     _loc3_[_loc7_] = _loc11_;
                     _loc5_ += this.applyDiscount(_loc8_.cash) * _loc11_;
                  }
               }
               _loc6_++;
            }
            return {
               "remaining":_loc3_,
               "cash":_loc5_
            };
         }
         return null;
      }
      
      private function purgeSlotData() : void
      {
         var _loc1_:Object = null;
         var _loc2_:ImageLoader = null;
         for each(_loc1_ in this.m_slotData)
         {
            if(_loc1_.askButton)
            {
               this.m_buttonSounds.removeButton(_loc1_.askButton.m_overlay);
               _loc1_.askButton.dispose();
            }
            if(_loc1_.buyButton)
            {
               this.m_buttonSounds.removeButton(_loc1_.buyButton.m_overlay);
               _loc1_.buyButton.dispose();
            }
         }
         if(this.m_slotIconLoaders)
         {
            for each(_loc2_ in this.m_slotIconLoaders)
            {
               _loc2_.destroy();
               _loc2_ = null;
            }
         }
         this.m_slotData = null;
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         this.purgeSlotData();
         if(this.itemIconLoader)
         {
            this.itemIconLoader.destroy();
            this.itemIconLoader = null;
         }
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         if(this.m_buyAllButton != null)
         {
            this.m_buyAllButton.dispose();
            this.m_buyAllButton = null;
         }
      }
   }
}

