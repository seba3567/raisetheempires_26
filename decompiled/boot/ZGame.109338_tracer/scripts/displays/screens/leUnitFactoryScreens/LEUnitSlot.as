package displays.screens.leUnitFactoryScreens
{
   import ZLocalization.LocalizationObjectToken;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsItem;
   import core.gameobjects.PartsLEUnitItem;
   import core.gameobjects.UnitItem;
   import core.managers.TierSurfacingManager;
   import core.managers.WorldObjectManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.unitClassManager.UnitClass;
   import core.managers.unitClassManager.UnitClassManager;
   import core.player.Player;
   import core.ui.UI;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.screens.ItemTooltip;
   import displays.screens.gridScreen.GridSlot;
   import displays.screens.researchScreens.ResearchUnitSlot;
   import displays.screens.researchScreens.ResearchUnitsGrid;
   import entity.GameDataComponent;
   import events.MarketEvent;
   import events.ProgressBarEvent;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.utils.Dictionary;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class LEUnitSlot extends GridSlot
   {
      
      public static const BUILD_LE_UNIT:String = "buildLEUnit";
      
      public static const FINISH_LE_UNIT:String = "finishLEUnit";
      
      public static const BUY_LE_UNIT:String = "buyLEUnit";
      
      public static const UNLOCK_LEVEL_GATE:String = "unlockLevelGate";
      
      private static const NUM_SLOTS:int = 4;
      
      protected var m_buildBtn:ZGameButton;
      
      protected var m_buyBtn:ZGameButton;
      
      protected var m_finishNowBtn:ZGameButton;
      
      protected var m_progressBuilding:IEntity = null;
      
      protected var m_leUnitItem:PartsLEUnitItem = null;
      
      protected var m_iconLoaders:Array = null;
      
      private var m_confirmationItem:GameItem = null;
      
      protected var m_unlockBtn:ZGameButton;
      
      public function LEUnitSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:PartsLEUnitItem, param7:Number, param8:Boolean)
      {
         super(param1,param2,param3);
         this.m_leUnitItem = param6;
         slot.unitCard_mc.bg_mc_le.visible = false;
         slot.unitCard_mc.bg_mc.visible = false;
         slot.unitCard_mc.bg_mc_powerup_tier3.visible = param8;
         slot.unitCard_mc.bg_mc_powerup.visible = !param8;
         slot.unitCard_mc.bg_mc_locked.visible = false;
         slot.unitCard_mc.underlay_mc.visible = false;
         slot.x = param4 * (sizerWidth * param7);
         slot.y = param5 * (sizerHeight * param7);
         slot.unitCard_mc.highlightSelect_mc.visible = false;
         this.filloutStats();
      }
      
      override protected function get className() : String
      {
         return "UnitCard";
      }
      
      override public function getData() : Object
      {
         return this.m_leUnitItem;
      }
      
      override public function fillOutTooltip() : ItemTooltip
      {
         return new ItemTooltip(GameItem.BONUS_AGAINST_WITH_UPGRADES_TOOLTIP,this.m_leUnitItem.unit,ItemTooltip.SOURCE_NONE);
      }
      
      override public function get tooltipAnchorPositionY() : Number
      {
         return 0;
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         if(Boolean(this.m_buildBtn) && Boolean(this.m_buildBtn.enabled) || Boolean(this.m_finishNowBtn) && Boolean(this.m_finishNowBtn.enabled))
         {
            this.onBuildClicked(param1);
         }
         else if(Boolean(this.m_unlockBtn) && this.m_unlockBtn.enabled)
         {
            this.onUnlockClicked(param1);
         }
      }
      
      private function checkRemainingParts() : Boolean
      {
         var _loc1_:PartsItem = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:GameItem = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(this.m_leUnitItem)
         {
            _loc1_ = ZGlobal.gameSettings.getItemByCode(this.m_leUnitItem.code,PartsItem) as PartsItem;
            _loc2_ = Math.min(this.m_leUnitItem.numParts,NUM_SLOTS);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               _loc4_ = this.m_leUnitItem.getPartCodeForIndex(_loc3_);
               _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_,GameItem) as GameItem;
               if(_loc5_)
               {
                  _loc6_ = ZGlobal.player.getNumberOfInventoryItems(_loc4_);
                  _loc7_ = this.m_leUnitItem.getPartCountForIndex(_loc3_);
                  if(_loc7_ > _loc6_)
                  {
                     return true;
                  }
               }
               _loc3_++;
            }
         }
         return false;
      }
      
      protected function filloutStats() : void
      {
         var _loc2_:IEntity = null;
         var _loc4_:UnitItem = null;
         var _loc6_:ImageLoader = null;
         var _loc7_:GameDataComponent = null;
         var _loc8_:BuildingFSMComponent = null;
         var _loc1_:Dictionary = WorldObjectManager.instance.getObjectsBySubType("building","military");
         for each(_loc2_ in _loc1_)
         {
            if(_loc2_)
            {
               _loc7_ = GameDataComponent(_loc2_.lookupComponentByType(GameDataComponent));
               _loc8_ = BuildingFSMComponent(_loc2_.lookupComponentByType(BuildingFSMComponent));
            }
         }
         slot.unitCard_mc.icon.filters = [];
         slot.unitCard_mc.upgradeStatus_tf.visible = false;
         slot.unitCard_mc.upgradeStatus_tf.mouseEnabled = false;
         if(slot.unitCard_mc.tierRating_mc)
         {
            slot.unitCard_mc.tierRating_mc.visible = false;
         }
         slot.unitCard_mc.gotoAndStop("powerup");
         var _loc3_:Boolean = ZGlobal.player.isItemUnlocked(this.m_leUnitItem.unitCode);
         if(ZGlobal.player.checkGate(this.m_leUnitItem.unit).isBitSet(Player.GATE_FAILURE_LEVEL) && !_loc3_)
         {
            slot.unitCard_mc.gotoAndStop("locked");
            slot.unitCard_mc.unlock_bt.visible = false;
            slot.unitCard_mc.buy_bt.visible = false;
            slot.unitCard_mc.tooltip.visible = false;
            TextFieldUtil.processTextField(slot.unitCard_mc.locked_tf,ZGameUtils.ZlocT("Dialogs","LevelRequired",{"num":this.m_leUnitItem.unit.requiredLevel}));
            slot.unitCard_mc.locked_tf.mouseEnabled = false;
            slot.unitCard_mc.locked_mc.visible = true;
            slot.unitCard_mc.icon.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            slot.unitCard_mc.bg_mc_powerup_tier3.visible = false;
            slot.unitCard_mc.bg_mc_powerup.visible = false;
            slot.unitCard_mc.bg_mc_locked.visible = true;
         }
         else if(!this.checkRemainingParts())
         {
            slot.unitCard_mc.build_bt.visible = false;
            this.m_finishNowBtn = new ZGameButton(slot.unitCard_mc.finishNow_bt,this.onBuildClicked);
            this.m_finishNowBtn.text = ZGameUtils.ZlocT("Dialogs","PowerupSelectionFinishButtonText");
            slot.unitCard_mc.cashIcon_mc.visible = false;
            slot.unitCard_mc.finishNow_bt.visible = true;
            m_buttonSounds.addButton(this.m_finishNowBtn.m_overlay,ButtonSound.DEFAULT);
            this.m_finishNowBtn.enable();
         }
         else
         {
            this.m_buildBtn = new ZGameButton(slot.unitCard_mc.build_bt,this.onBuildClicked);
            this.m_buildBtn.text = ZGameUtils.ZlocT("Dialogs","PowerupSelectionBuildButtonText");
            this.m_buildBtn.enable();
            m_buttonSounds.addButton(this.m_buildBtn.m_overlay,ButtonSound.DEFAULT);
            this.m_buyBtn = new ZGameButton(slot.unitCard_mc.finishNow_bt,this.onBuyClicked);
            this.m_buyBtn.text = ZGameUtils.ZlocT("Dialogs","BuyForAmount",{"amount":this.m_leUnitItem.cash});
            slot.unitCard_mc.cashIcon_mc.visible = true;
            slot.unitCard_mc.finishNow_bt.visible = true;
            m_buttonSounds.addButton(this.m_buyBtn.m_overlay,ButtonSound.DEFAULT);
         }
         this.m_iconLoaders = new Array();
         _loc4_ = ZGlobal.gameSettings.getItemByCode(this.m_leUnitItem.unitCode,UnitItem) as UnitItem;
         this.m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(_loc4_.name,"icon"),slot.unitCard_mc.icon));
         TextFieldUtil.processTextField(slot.unitCard_mc.itemName_tf,this.m_leUnitItem.unit.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         slot.unitCard_mc.itemName_tf.mouseEnabled = false;
         if(slot.unitCard_mc.currentLabel == "inProgress")
         {
            slot.unitCard_mc.upgrades_mc.visible = false;
            slot.unitCard_mc.tooltip.visible = false;
         }
         var _loc5_:UnitClass = UnitClassManager.instance.unitClassNamed(_loc4_.unitClass);
         slot.unitCard_mc.unitStats_mc.visible = true;
         if(_loc5_)
         {
            _loc6_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(_loc5_.getSmIconURL()),slot.unitCard_mc.unitStats_mc.icon_class);
            this.m_iconLoaders.push(_loc6_);
         }
         TextFieldUtil.processTextField(slot.unitCard_mc.unitStats_mc.strength_tf,String(_loc4_.getStrength(null,WorldUpgradeManager.instance.getUpgradesByCode(_loc4_.code))));
         if(Boolean(slot.unitCard_mc.tierRating_mc) && TierSurfacingManager.instance.tierSurfacingEnabled)
         {
            TextFieldUtil.compactTextField(slot.unitCard_mc.tierRating_mc.tier_tf,String(_loc4_.tier));
            slot.unitCard_mc.tierRating_mc.visible = true;
         }
      }
      
      protected function onProgress(param1:ProgressBarEvent) : void
      {
         TextFieldUtil.processTextField(slot.unitCard_mc.countdown_tf,param1.timeRemaining);
      }
      
      protected function onProgressComplete(param1:ProgressBarEvent) : void
      {
         slot.unitCard_mc.upgradeStatus_tf.visible = false;
         slot.unitCard_mc.finishNow_bt.visible = false;
         TextFieldUtil.processTextField(slot.unitCard_mc.countdown_tf,ZGameUtils.ZlocT("Dialogs","ResearchReady_Line"));
         this.m_progressBuilding.eventDispatcher.removeEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onProgress);
         this.m_progressBuilding.eventDispatcher.removeEventListener(ProgressBarEvent.STOP_PROGRESS_BAR,this.onProgressComplete);
      }
      
      private function onBuyClicked(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(BUY_LE_UNIT,{"unitItem":this.m_leUnitItem.unit}));
      }
      
      private function onBuildClicked(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(BUILD_LE_UNIT,this));
      }
      
      private function onUnlockLevelClicked(param1:MouseEvent) : void
      {
         var _loc2_:int = this.m_leUnitItem.unit.contractCost;
         var _loc3_:Boolean = ZGlobal.player.canBuyCash(_loc2_,true);
         if(_loc3_)
         {
            ZGlobal.player.cash -= _loc2_;
            UIDispatcher.instance.dispatchEvent(new WorldEvent(UNLOCK_LEVEL_GATE,this));
         }
      }
      
      private function beginBuyContractProcess(param1:GameItem) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:LocalizationObjectToken = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         if(param1)
         {
            _loc2_ = param1.contractCost;
            _loc3_ = ZGlobal.player.canBuyCash(_loc2_,true);
            if(_loc3_ && _loc2_ > 0)
            {
               if(ZGlobal.gameSettings.showConfirmationPopup(_loc2_))
               {
                  this.m_confirmationItem = param1;
                  _loc5_ = ZGameUtils.CashTokenReplacements(_loc2_);
                  _loc6_ = this.m_confirmationItem.getSentenceNameLocalizationObject("singular",true);
                  if(_loc6_)
                  {
                     _loc5_.item = _loc6_;
                     if(param1.contractLocked && param1.canBuyContract())
                     {
                        _loc4_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashUnlockContractMessage_Object",_loc5_);
                     }
                     else
                     {
                        _loc4_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage_Object",_loc5_);
                     }
                  }
                  else
                  {
                     _loc5_.item = this.m_confirmationItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
                     if(param1.contractLocked && param1.canBuyContract())
                     {
                        _loc4_ = ZGameUtils.ZlocT("Dialogs","ConfrumCashUnlockContractMessage",_loc5_);
                     }
                     else
                     {
                        _loc4_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage",_loc5_);
                     }
                  }
                  _loc7_ = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
                  _loc8_ = new Array("EmpirePointsConfirm","","","");
                  PopupManager.instance.push(GenericPopup2B.NewYesNo(_loc4_,_loc7_,this.onPurchaseConfirmationClosed,_loc8_));
                  return;
               }
               this.buyContractUnlock(param1);
            }
         }
      }
      
      private function buyContractUnlock(param1:GameItem) : void
      {
         if(param1.contractLocked && param1.canBuyContract())
         {
            UI.instance.setupForItemPurchase();
            UIDispatcher.instance.dispatchEvent(new MarketEvent(MarketEvent.MARKET_UNLOCK_CONTRACT,0,param1.name,MarketEvent.SOURCE_NONE,{"genus":"research"}));
            UIDispatcher.instance.dispatchEvent(new WorldEvent(ResearchUnitsGrid.EVENT_UPDATE_RESEARCH_SLOTS));
         }
      }
      
      protected function onPurchaseConfirmationClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.buyContractUnlock(this.m_confirmationItem);
         }
         this.m_confirmationItem = null;
      }
      
      private function onUnlockClicked(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(ResearchUnitSlot.UNLOCK,this));
      }
      
      override public function dispose() : void
      {
         var _loc1_:ImageLoader = null;
         if(this.m_progressBuilding)
         {
            this.m_progressBuilding.eventDispatcher.removeEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onProgress);
         }
         if(this.m_buyBtn)
         {
            this.m_buyBtn.dispose();
         }
         if(this.m_buildBtn)
         {
            this.m_buildBtn.dispose();
         }
         if(this.m_finishNowBtn)
         {
            this.m_finishNowBtn.dispose();
         }
         if(this.m_unlockBtn)
         {
            this.m_unlockBtn.dispose();
         }
         for each(_loc1_ in this.m_iconLoaders)
         {
            _loc1_.destroy();
         }
         this.m_iconLoaders = null;
         super.dispose();
      }
   }
}

