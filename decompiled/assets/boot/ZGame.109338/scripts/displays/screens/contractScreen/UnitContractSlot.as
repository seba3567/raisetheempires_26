package displays.screens.contractScreen
{
   import ZLocalization.LocalizationObjectToken;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.LEUnitDiscountManager;
   import core.managers.TierSurfacingManager;
   import core.managers.WorldResourceManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.decorationsManager.DecorationsManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.managers.warehouseManager.WarehouseUnitManager;
   import core.managers.worldUnitManager.WorldUnitManager;
   import core.player.Player;
   import core.resource.WorldResource;
   import core.ui.Style;
   import core.ui.Tooltip;
   import core.ui.UI;
   import core.ui.ZGameButton;
   import dispatchers.ResearchDispatcher;
   import dispatchers.ResourceDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.screens.researchScreens.UpgradesDisplay;
   import entity.GameDataComponent;
   import events.MarketEvent;
   import events.ResearchUpdatedEvent;
   import events.ResourceUpdatedEvent;
   import fl.containers.UILoader;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import utils.BitArray;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class UnitContractSlot extends ContractSlot
   {
      
      protected var m_item:UnitItem = null;
      
      protected var m_upgradesDisplay:UpgradesDisplay = null;
      
      protected var m_confirmationItem:GameItem = null;
      
      protected var m_buyNowButton:ZGameButton = null;
      
      protected var m_discountInfo:Dictionary;
      
      protected var m_decoEffects:Array;
      
      private var m_defaultColor:Object = null;
      
      public function UnitContractSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:EventDispatcher, param5:int, param6:int, param7:IEntity, param8:UnitItem, param9:Number, param10:Dictionary = null, param11:Array = null)
      {
         this.m_item = param8;
         this.m_discountInfo = param10 == null ? new Dictionary() : param10;
         this.m_decoEffects = param11 == null ? [] : param11;
         super(param1,param2,param3,param4,param5,param6,param7,param9);
         UIDispatcher.instance.addEventListener(Player.INVENTORY_UPDATED,this.onInventoryUpdated,false,0,true);
         ResourceDispatcher.instance.addEventListener(ResourceUpdatedEvent.COINS,this.onResourceUpdate);
         ResourceDispatcher.instance.addEventListener(ResourceUpdatedEvent.OIL,this.onResourceUpdate);
      }
      
      override public function dispose() : void
      {
         this.stopNewUnitTimer();
         this.m_item = null;
         if(this.m_upgradesDisplay)
         {
            this.m_upgradesDisplay.dispose();
         }
         Tooltip.unsubscribe(slot.strength_mc);
         if(slot.tierRating_mc)
         {
            Tooltip.unsubscribe(slot.tierRating_mc);
         }
         ResearchDispatcher.instance.removeEventListener(ResearchUpdatedEvent.UPGRADE_ADDED,this.onResearchUpdated);
         UIDispatcher.instance.removeEventListener(Player.INVENTORY_UPDATED,this.onInventoryUpdated);
         ResourceDispatcher.instance.removeEventListener(ResourceUpdatedEvent.COINS,this.onResourceUpdate);
         ResourceDispatcher.instance.removeEventListener(ResourceUpdatedEvent.OIL,this.onResourceUpdate);
         super.dispose();
      }
      
      override protected function createSlot(param1:SWFResource) : MovieClip
      {
         var _loc2_:Class = param1.getAssetClass("UnitCard");
         return new _loc2_();
      }
      
      override protected function getObjectCode() : String
      {
         if(this.m_item)
         {
            return this.m_item.code;
         }
         return null;
      }
      
      override protected function populateCard() : void
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:GameDataComponent = null;
         var _loc6_:Number = NaN;
         var _loc7_:String = null;
         disposeImageLoaders();
         m_imageLoaders = new Array();
         Tooltip.subscribe(slot.strength_mc,ZGameUtils.ZlocT("Tooltips","StrengthTooltip"));
         slot.tooltip.visible = false;
         var _loc1_:Array = new Array(slot.itemName_tf,slot.count_tf,slot.detail_mc.resource0_tf,slot.detail_mc.resource1_tf,slot.detail_mc.resource2_tf,slot.detail_mc.against_tf,slot.detail_mc.duration_tf,slot.detail_mc.cost_tf,slot.detail_mc.class_tf,slot.strength_mc.strength_tf,slot.level_tf);
         if(slot.tierRating_mc)
         {
            _loc1_.push(slot.tierRating_mc.tier_tf);
            Tooltip.subscribe(slot.tierRating_mc,ZGameUtils.ZlocT("Tooltips","TierToolTip"));
            slot.tierRating_mc.visible = false;
         }
         if(slot.doubleXP_mc)
         {
            slot.doubleXP_mc.visible = false;
         }
         TextFieldUtil.setMouseEnabled(_loc1_,false);
         slot.buttonMode = true;
         slot.useHandCursor = true;
         TextFieldUtil.processTextField(slot.itemName_tf,this.m_item.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         slot.detail_mc.secondAbility_tf.visible = false;
         this.hideManaUI();
         m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(this.m_item.name,"icon"),slot.icon));
         this.setupDateStatus();
         slot.emp_bt.visible = false;
         slot.emp_bt.mouseEnabled = false;
         this.updateItemCountDisplay();
         var _loc2_:BitArray = ZGlobal.player.checkGate(this.m_item);
         if(!_loc2_.anyBitSet() || ZGlobal.player.isItemUnlocked(this.m_item.code))
         {
            m_isBuyable = true;
            this.setUpButton();
            slot.locked_mc.visible = false;
            slot.level_tf.visible = false;
            slot.unlock_bt.visible = false;
            ZGameUtils.hideIfExists(slot.locked_mc_dominance);
            this.fillOutUpgrades();
            ResearchDispatcher.instance.addEventListener(ResearchUpdatedEvent.UPGRADE_ADDED,this.onResearchUpdated,false,0,true);
            TextFieldUtil.processTextField(slot.strength_mc.strength_tf,String(this.m_item.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(this.m_item.code))));
            if(Boolean(slot.tierRating_mc) && TierSurfacingManager.instance.tierSurfacingEnabled)
            {
               TextFieldUtil.compactTextField(slot.tierRating_mc.tier_tf,String((ZGlobal.gameSettings.getItemByCode(this.m_item.code,UnitItem) as UnitItem).tier));
               slot.tierRating_mc.visible = true;
            }
            if(Boolean(slot.doubleXP_mc) && Boolean(TierSurfacingManager.instance.tierSurfacing2Enabled) && this.m_item.isBlueDevil)
            {
               slot.doubleXP_mc.visible = true;
            }
            this.displayDiscountSale();
            this.loadUnitClassIconImage(this.m_item.unitClass,slot.detail_mc.classIcon);
            _loc3_ = this.m_item.goodAgainst;
            _loc4_ = int(_loc3_.length);
            switch(_loc4_)
            {
               case 1:
                  slot.detail_mc.against_mc.x = slot.detail_mc.anchor1_mc.x;
                  break;
               case 2:
                  slot.detail_mc.against_mc.x = slot.detail_mc.anchor2_mc.x;
                  break;
               default:
                  slot.detail_mc.against_mc.x = slot.detail_mc.anchor3_mc.x;
            }
            switch(_loc4_)
            {
               case 3:
               case 4:
                  this.loadUnitClassIconImage(_loc3_[2],slot.detail_mc.against_mc.against2,true);
               case 2:
                  this.loadUnitClassIconImage(_loc3_[1],slot.detail_mc.against_mc.against1,true);
               case 1:
                  this.loadUnitClassIconImage(_loc3_[0],slot.detail_mc.against_mc.against0,true);
            }
            this.setupCosts();
            _loc5_ = GameDataComponent(m_entity.lookupComponentByType(GameDataComponent));
            _loc6_ = this.m_item.getMatureDuration(_loc5_.gameData.name);
            if(this.m_decoEffects != null && this.m_decoEffects.indexOf("contractDuration") != -1)
            {
               _loc6_ = DecorationsManager.instance.applyContractDurationDecoEffect(_loc6_,m_entity);
            }
            _loc7_ = ZGameTimeUtil.instance.getTimeString(_loc6_);
            TextFieldUtil.processTextField(slot.detail_mc.duration_tf,_loc7_);
            TextFieldUtil.processTextField(slot.detail_mc.against_tf,this.detailsHeader);
            TextFieldUtil.processTextField(slot.detail_mc.cost_tf,ZLoc.t("Dialogs","ContractCostTitle"));
            TextFieldUtil.processTextField(slot.detail_mc.class_tf,ZLoc.t("Dialogs","ContractClassTitle"));
            TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.UI_ELEMENT,{
               "ui":slot,
               "item":this.m_item
            }));
         }
         else
         {
            this.lockSlot(_loc2_);
         }
      }
      
      protected function lockSlot(param1:BitArray = null) : void
      {
         var _loc2_:String = null;
         slot.build_bt.visible = false;
         slot.strength_mc.visible = false;
         slot.detail_mc.visible = false;
         if(slot.tierRating_mc)
         {
            slot.tierRating_mc.visible = false;
         }
         if(slot.doubleXP_mc)
         {
            slot.doubleXP_mc.visible = false;
         }
         if(Boolean(slot.doubleXP_mc) && Boolean(TierSurfacingManager.instance.tierSurfacing2Enabled) && this.m_item.isBlueDevil)
         {
            slot.doubleXP_mc.visible = true;
         }
         this.displayDiscountSale();
         if(this.m_item.canBeUnlocked())
         {
            m_isUnlockable = true;
            m_unlockBtn = new ZGameButton(slot.unlock_bt,this.onUnlockClicked);
            m_unlockBtn.text = ZGameUtils.ZlocT("Dialogs","UnlockForAmount",{"amount":this.m_item.unlockCost});
            m_unlockBtn.addTooltip(ZGameUtils.ZlocT("Dialogs","StoreUnitUnlockTooltip"));
         }
         else if(this.m_item.contractLocked && this.m_item.canBuyContract() && !this.isLevelLocked(this.m_item))
         {
            m_isUnlockable = true;
            m_unlockBtn = new ZGameButton(slot.unlock_bt,this.onUnlockClicked);
            m_unlockBtn.text = ZGameUtils.ZlocT("Dialogs","UnlockForAmount",{"amount":this.m_item.contractCost});
            TextFieldUtil.processTextField(slot.strength_mc.strength_tf,String(this.m_item.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(this.m_item.code))));
            slot.strength_mc.visible = true;
            if(Boolean(slot.tierRating_mc) && TierSurfacingManager.instance.tierSurfacingEnabled)
            {
               TextFieldUtil.compactTextField(slot.tierRating_mc.tier_tf,String((ZGlobal.gameSettings.getItemByCode(this.m_item.code,UnitItem) as UnitItem).tier));
               slot.tierRating_mc.visible = true;
            }
         }
         else
         {
            slot.unlock_bt.visible = false;
         }
         if(param1)
         {
            _loc2_ = this.m_item.getGateFailureString(param1);
            TextFieldUtil.processTextField(slot.level_tf,_loc2_ ? _loc2_ : "");
            if(param1.isBitSet(Player.GATE_FAILURE_DOMINANCE))
            {
               ZGameUtils.showIfExists(slot.locked_mc_dominance);
               slot.locked_mc.visible = false;
            }
            else
            {
               ZGameUtils.hideIfExists(slot.locked_mc_dominance);
               slot.locked_mc.visible = true;
            }
         }
      }
      
      private function updateItemCountDisplay() : void
      {
         var _loc1_:Dictionary = WorldUnitManager.instance.availableUnits;
         var _loc2_:Dictionary = WarehouseUnitManager.instance.getAvailableUnits();
         var _loc3_:int = ZGlobal.player.inventory[this.m_item.code] ? int(ZGlobal.player.inventory[this.m_item.code]) : 0;
         var _loc4_:int = _loc1_[this.m_item.code] ? int(_loc1_[this.m_item.code]) : 0;
         var _loc5_:int = _loc2_[this.m_item.code] ? int(_loc2_[this.item.code]) : 0;
         TextFieldUtil.processTextField(slot.count_tf,(_loc3_ + _loc4_ + _loc5_).toString());
      }
      
      private function onInventoryUpdated(param1:WorldEvent) : void
      {
         this.updateItemCountDisplay();
         this.updateItemCosts();
      }
      
      private function onResourceUpdate(param1:ResourceUpdatedEvent) : void
      {
         this.updateItemCosts();
      }
      
      private function updateItemCosts() : void
      {
         var _loc2_:int = 0;
         var _loc3_:TextFormat = null;
         var _loc4_:Array = null;
         var _loc5_:WorldResource = null;
         var _loc6_:Dictionary = null;
         var _loc7_:String = null;
         var _loc1_:Array = this.resourceTexts;
         if(_loc1_)
         {
            _loc2_ = 0;
            _loc3_ = null;
            _loc4_ = this.m_item.resourceCosts;
            for each(_loc5_ in _loc4_)
            {
               this.setTextFieldColor(_loc1_[_loc2_],ZGlobal.player.hasResource(_loc5_));
               _loc2_++;
            }
            _loc6_ = this.m_item.itemCosts;
            for(_loc7_ in _loc6_)
            {
               this.setTextFieldColor(_loc1_[_loc2_],ZGlobal.player.getNumberOfInventoryItems(_loc7_) >= _loc6_[_loc7_]);
               _loc2_++;
            }
         }
      }
      
      private function setTextFieldColor(param1:TextField, param2:Boolean) : void
      {
         var _loc3_:TextFormat = null;
         if(param1)
         {
            _loc3_ = param1.getTextFormat();
            if(!this.m_defaultColor)
            {
               this.m_defaultColor = _loc3_.color;
            }
            _loc3_.color = param2 ? this.m_defaultColor : Style.COLOR_UNSUFFICIENT_RESOURCES;
            param1.setTextFormat(_loc3_);
         }
      }
      
      private function hideManaUI() : void
      {
         slot.detail_mc.secondAbility_tf.visible = false;
      }
      
      protected function setUpButton() : void
      {
         m_buildBtn = new ZGameButton(slot.build_bt,onSelectButton);
         m_buildBtn.text = ZLoc.t("Dialogs","SelectButton");
      }
      
      protected function get detailsHeader() : String
      {
         return ZLoc.t("Dialogs","EnemyTooltipGoodAgainst");
      }
      
      private function get resourceTexts() : Array
      {
         if(Boolean(slot) && Boolean(slot.detail_mc))
         {
            return [slot.detail_mc.resource0_tf,slot.detail_mc.resource1_tf,slot.detail_mc.resource2_tf];
         }
         return null;
      }
      
      protected function setupCosts() : void
      {
         var _loc5_:WorldResource = null;
         var _loc6_:Dictionary = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:Object = null;
         var _loc12_:GameItem = null;
         var _loc13_:Boolean = false;
         var _loc1_:Array = [slot.detail_mc.resourceIcon0,slot.detail_mc.resourceIcon1,slot.detail_mc.resourceIcon2];
         var _loc2_:Array = this.resourceTexts;
         var _loc3_:* = 0;
         var _loc4_:Array = this.m_item.resourceCosts;
         for each(_loc5_ in _loc4_)
         {
            if(_loc3_ < _loc1_.length && _loc5_.valid)
            {
               _loc8_ = _loc5_.amount;
               if(this.m_discountInfo)
               {
                  _loc10_ = 0;
                  for each(_loc11_ in this.m_discountInfo)
                  {
                     if(Boolean(_loc11_.resources) && Boolean(_loc11_.resources as Array) && _loc11_.resources.indexOf(_loc5_.type) >= 0)
                     {
                        _loc10_ += _loc11_.amount;
                     }
                  }
                  _loc8_ = DecorationsManager.instance.applyResourceDiscount(_loc8_,_loc10_);
               }
               TextFieldUtil.processTextField(_loc2_[_loc3_],Math.abs(_loc8_).toString());
               _loc9_ = WorldResourceManager.instance.getResourceImageURLByType(_loc5_.type,WorldResourceManager.XTRA_SMALL_ICON);
               m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc9_,_loc1_[_loc3_]));
               if(_loc2_[_loc3_])
               {
                  _loc2_[_loc3_].visible = true;
                  _loc2_[_loc3_].mouseEnabled = false;
                  if(!ZGlobal.player.hasResource(_loc5_))
                  {
                     this.setTextFieldColor(_loc2_[_loc3_],false);
                  }
               }
            }
            _loc3_++;
         }
         _loc6_ = this.m_item.itemCosts;
         for(_loc7_ in _loc6_)
         {
            _loc12_ = ZGlobal.gameSettings.getItemByCode(_loc7_,GameItem) as GameItem;
            m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(_loc12_.getCachedImage("icon").url,_loc1_[_loc3_]));
            TextFieldUtil.processTextField(_loc2_[_loc3_],_loc6_[_loc7_]);
            _loc2_[_loc3_].visible = true;
            _loc2_[_loc3_].mouseEnabled = false;
            _loc13_ = ZGlobal.player.getNumberOfInventoryItems(_loc7_) >= _loc6_[_loc7_];
            if(!_loc13_)
            {
               this.setTextFieldColor(_loc2_[_loc3_],false);
            }
            _loc3_++;
         }
         while(_loc3_ < _loc2_.length)
         {
            _loc2_[_loc3_++].visible = false;
         }
      }
      
      private function setupDateStatus() : void
      {
         var _loc1_:Object = new Object();
         var _loc2_:int = ZGameTimeUtil.instance.getDateStatus(_loc1_,this.m_item.xml);
         var _loc3_:GameItem = ZGlobal.gameSettings.getItemByCode(this.m_item.code,GameItem) as GameItem;
         var _loc4_:Boolean = false;
         switch(_loc2_)
         {
            case ZGameTimeUtil.DATE_STATUS_EARLY:
               _loc4_ = true;
               TextFieldUtil.processTextField(slot.daysLeft_tf,ZGameUtils.ZlocT("Main","ReadyMessage",{"time":_loc1_.string}));
               break;
            case ZGameTimeUtil.DATE_STATUS_ACTIVE:
               _loc4_ = true;
               TextFieldUtil.processTextField(slot.daysLeft_tf,ZGameUtils.ZlocT("Dialogs","LimitedEditionCountdown",{"time":_loc1_.string}));
               break;
            case ZGameTimeUtil.DATE_STATUS_LATE:
               if(this.m_item.contractLocked && ZGlobal.player.hasPurchasedContract(this.m_item.code))
               {
                  _loc4_ = true;
               }
         }
         if(_loc4_)
         {
            this.startNewUnitTimer();
            TextFieldUtil.processTextField(slot.limited_tf,ZGameUtils.ZlocT("Dialogs","LimitedEditionBanner"));
         }
         if(this.m_item.contractLocked)
         {
            if(ZGlobal.player.hasPurchasedContract(this.m_item.code))
            {
               slot.daysLeft_tf.visible = false;
            }
            else
            {
               slot.daysLeft_tf.visible = _loc4_;
            }
         }
         else
         {
            slot.daysLeft_tf.visible = _loc4_;
         }
         slot.limitedCard_mc.visible = _loc4_;
         slot.limited_tf.visible = _loc4_;
         if(_loc3_.isAdvExpUnit == "true")
         {
            slot.limitedCard_mc.visible = false;
            slot.limited_tf.visible = false;
            slot.daysLeft_tf.visible = false;
         }
      }
      
      protected function fillOutUpgrades() : void
      {
         var _loc1_:Array = [slot.upgrades_mc.icon0,slot.upgrades_mc.icon1,slot.upgrades_mc.icon2,slot.upgrades_mc.icon3,slot.upgrades_mc.icon4];
         this.m_upgradesDisplay = new UpgradesDisplay(_loc1_,slot.upgrades_mc,slot.tooltip,m_screen,this.m_item,WorldUpgradeManager.instance.getUpgradesByCode(this.m_item.code));
      }
      
      private function onResearchUpdated(param1:ResearchUpdatedEvent) : void
      {
         if(this.m_upgradesDisplay)
         {
            this.m_upgradesDisplay.dispose();
         }
         this.fillOutUpgrades();
      }
      
      private function startNewUnitTimer() : void
      {
         this.stopNewUnitTimer();
         Zlab.processManager.schedule(1000,this,this.onUpdateNewUnit);
      }
      
      private function stopNewUnitTimer() : void
      {
         Zlab.processManager.removeScheduledObject(this);
      }
      
      private function onUpdateNewUnit() : void
      {
         this.setupDateStatus();
      }
      
      private function loadUnitClassIconImage(param1:String, param2:UILoader, param3:Boolean = false) : void
      {
         var _loc4_:UnitClass = UnitClassManager.instance.unitClassNamed(param1);
         if(_loc4_)
         {
            m_imageLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(param3 ? _loc4_.getAltIconURL() : _loc4_.getIconURL()),param2));
            Tooltip.subscribe(param2,_loc4_.getTooltip());
         }
      }
      
      override protected function purchaseEventObject() : Object
      {
         return this.m_item;
      }
      
      protected function get item() : UnitItem
      {
         return this.m_item;
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         if(m_isUnlockable)
         {
            this.onUnlockClicked(param1);
         }
         else
         {
            super.doOnClick(param1);
         }
      }
      
      private function onUnlockClicked(param1:MouseEvent) : void
      {
         this.beginBuyUnlockProcess(this.m_item);
      }
      
      private function beginBuyUnlockProcess(param1:GameItem) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         var _loc5_:String = null;
         var _loc6_:Object = null;
         var _loc7_:LocalizationObjectToken = null;
         var _loc8_:String = null;
         var _loc9_:Array = null;
         if(param1)
         {
            _loc2_ = param1.contractLocked && param1.canBuyContract();
            _loc3_ = _loc2_ ? param1.contractCost : param1.unlockCost;
            _loc4_ = ZGlobal.player.canBuyCash(_loc3_,true);
            if((_loc4_) && _loc3_ > 0)
            {
               if(ZGlobal.gameSettings.showConfirmationPopup(_loc3_))
               {
                  this.m_confirmationItem = param1;
                  _loc6_ = ZGameUtils.CashTokenReplacements(_loc3_);
                  _loc7_ = this.m_confirmationItem.getSentenceNameLocalizationObject("singular",true);
                  if(_loc7_)
                  {
                     _loc6_.item = _loc7_;
                     if(param1.canBeUnlocked())
                     {
                        _loc5_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockMessage_Object",_loc6_);
                     }
                     else if(param1.contractLocked && param1.canBuyContract())
                     {
                        _loc5_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockContractMessage_Object",_loc6_);
                     }
                     else
                     {
                        _loc5_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage_Object",_loc6_);
                     }
                  }
                  else
                  {
                     _loc6_.item = this.m_confirmationItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                     if(param1.canBeUnlocked())
                     {
                        _loc5_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockMessage",_loc6_);
                     }
                     else if(param1.contractLocked && param1.canBuyContract())
                     {
                        _loc5_ = ZGameUtils.ZlocT("Dialogs","ConfrumCashUnlockContractMessage",_loc6_);
                     }
                     else
                     {
                        _loc5_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage",_loc6_);
                     }
                  }
                  _loc8_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
                  _loc9_ = new Array("EmpirePointsConfirm","","","");
                  PopupManager.instance.push(GenericPopup2B.NewYesNo(_loc5_,_loc8_,this.onPurchaseConfirmationClosed,_loc9_));
                  return;
               }
               this.buyUnlock(param1);
            }
         }
      }
      
      protected function onPurchaseConfirmationClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.buyUnlock(this.m_confirmationItem);
         }
         this.m_confirmationItem = null;
      }
      
      private function buyUnlock(param1:GameItem) : void
      {
         if(param1.canBeUnlocked())
         {
            UI.instance.setupForItemPurchase();
            UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_UNLOCK,0,param1.name,MarketEvent.SOURCE_NONE));
            UIDispatcher.instance.dispatchEvent(new WorldEvent(ContractGrid.EVENT_UPDATE_SLOTS));
         }
         else if(param1.contractLocked && param1.canBuyContract())
         {
            UI.instance.setupForItemPurchase();
            UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_UNLOCK_CONTRACT,0,param1.name,MarketEvent.SOURCE_NONE));
            UIDispatcher.instance.dispatchEvent(new WorldEvent(ContractGrid.EVENT_UPDATE_SLOTS));
         }
      }
      
      private function isLevelLocked(param1:GameItem) : Boolean
      {
         var _loc2_:BitArray = ZGlobal.player.checkGate(param1);
         var _loc3_:Boolean = _loc2_.isBitSet(Player.GATE_FAILURE_LEVEL);
         _loc2_.resetBit(Player.GATE_FAILURE_LEVEL);
         return _loc3_;
      }
      
      private function displayDiscountSale() : void
      {
         var _loc1_:Number = NaN;
         if(slot.discount_tf != null)
         {
            if(LEUnitDiscountManager.instance.isLEDiscountExpEnabled() && LEUnitDiscountManager.instance.isOverrideLEItem(this.m_item.code))
            {
               _loc1_ = Math.floor(LEUnitDiscountManager.instance.getLEOverrideDiscount(this.m_item.code) * 100);
               if(_loc1_ > 0)
               {
                  if(LEUnitDiscountManager.instance.leDiscountVariant == 3)
                  {
                     TextFieldUtil.compactTextField(slot.discount_tf,ZGameUtils.ZlocT("Dialogs","PercentOffExclaim",{"amount":_loc1_}));
                  }
                  else
                  {
                     TextFieldUtil.compactTextField(slot.discount_tf,ZGameUtils.ZlocT("Promo","promo_RepeatPackHUD_textSale"));
                  }
                  slot.discount_tf.visible = true;
               }
               else
               {
                  slot.discount_tf.visible = false;
               }
            }
            else
            {
               slot.discount_tf.visible = false;
            }
         }
      }
   }
}

