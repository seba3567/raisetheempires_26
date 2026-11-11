package displays.screens.researchScreens
{
   import ZLocalization.LocalizationObjectToken;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.AutoDialogState;
   import core.entities.components.behaviors.states.SimpleAutoState;
   import core.entities.components.behaviors.states.SimpleClickState;
   import core.entities.components.states.IState;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.gameobjects.UpgradeItem;
   import core.managers.ExperimentsManager;
   import core.managers.LEUnitDiscountManager;
   import core.managers.TierSurfacingManager;
   import core.managers.WorldObjectManager;
   import core.managers.WorldUpgradeManager;
   import core.player.Player;
   import core.ui.Tooltip;
   import core.ui.UI;
   import core.ui.ZGameButton;
   import dispatchers.UIDispatcher;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.screens.ItemTooltip;
   import displays.screens.pickUnitsScreen.UnitSlot;
   import entity.GameDataComponent;
   import events.MarketEvent;
   import events.ProgressBarEvent;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.utils.Dictionary;
   import sound.ButtonSound;
   import utils.BitArray;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class ResearchUnitSlot extends UnitSlot
   {
      
      public static const UNLOCK:String = "unlock";
      
      public static const FINISH_NOW:String = "finish_now";
      
      private const BUBBLE_TEXT_OFFSET:int = 5;
      
      protected var m_buildingUnitItem:UnitItem = null;
      
      protected var m_researchBtn:ZGameButton;
      
      protected var m_unlockBtn:ZGameButton;
      
      protected var m_finishNowBtn:ZGameButton;
      
      protected var m_unlockContractBtn:ZGameButton;
      
      protected var m_progressBuilding:IEntity = null;
      
      protected var m_upgradesDisplay:UpgradesDisplay = null;
      
      protected var m_upgradeTooltip:MovieClip = null;
      
      protected var m_upgradeItem:UpgradeItem = null;
      
      private var m_confirmationItem:GameItem = null;
      
      public function ResearchUnitSlot(param1:SWFResource, param2:MovieClip, param3:MovieClip, param4:int, param5:int, param6:UnitItem, param7:Number, param8:UnitItem)
      {
         this.m_buildingUnitItem = param8;
         super(param1,param2,param3,param4,param5,param6,false,0,param7);
         slot.unitCard_mc.highlightSelect_mc.visible = false;
         if(slot.unitCard_mc.bg2_mc)
         {
            slot.unitCard_mc.bg2_mc.visible = false;
         }
      }
      
      override public function getData() : Object
      {
         return m_unitItem;
      }
      
      override public function fillOutTooltip() : ItemTooltip
      {
         return new ItemTooltip(GameItem.BONUS_AGAINST_TOOLTIP,m_unitItem,ItemTooltip.SOURCE_NONE);
      }
      
      override public function get tooltipAnchorPositionY() : Number
      {
         return 0;
      }
      
      override protected function doOnClick(param1:MouseEvent) : void
      {
         if(Boolean(this.m_researchBtn) && this.m_researchBtn.enabled)
         {
            this.onResearchClicked(param1);
         }
         else if(Boolean(this.m_unlockBtn) && this.m_unlockBtn.enabled)
         {
            this.onUnlockClicked(param1);
         }
         else if(Boolean(this.m_finishNowBtn) && this.m_finishNowBtn.enabled)
         {
            this.onFinishNowClicked(param1);
         }
         else if(Boolean(this.m_unlockContractBtn) && this.m_unlockContractBtn.enabled)
         {
            this.beginBuyContractProcess(m_unitItem);
         }
      }
      
      override protected function filloutStats() : void
      {
         var _loc3_:IEntity = null;
         var _loc4_:IState = null;
         var _loc8_:GameDataComponent = null;
         var _loc9_:BuildingFSMComponent = null;
         var _loc10_:String = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:String = null;
         var _loc14_:GameItem = null;
         var _loc15_:LocalizationObjectToken = null;
         var _loc16_:LocalizationObjectToken = null;
         var _loc17_:Object = null;
         var _loc18_:String = null;
         var _loc19_:LocalizationObjectToken = null;
         var _loc1_:int = WorldUpgradeManager.instance.getNumCompletedUpgrades(m_unitItem.code);
         var _loc2_:Dictionary = WorldObjectManager.instance.getObjectsBySubType("building","military");
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_)
            {
               _loc8_ = GameDataComponent(_loc3_.lookupComponentByType(GameDataComponent));
               _loc9_ = BuildingFSMComponent(_loc3_.lookupComponentByType(BuildingFSMComponent));
               if(_loc8_)
               {
                  if(_loc8_.gameData.isResearchItem())
                  {
                     if(BehaviorStateMachine(_loc9_.stateMachine).researchItemName == m_unitItem.name)
                     {
                        _loc10_ = BehaviorStateMachine(_loc9_.stateMachine).referenceItemName;
                        this.m_upgradeItem = ZGlobal.gameSettings.getItemByName(_loc10_,UpgradeItem) as UpgradeItem;
                        this.m_progressBuilding = _loc3_;
                        break;
                     }
                  }
               }
            }
         }
         _loc4_ = BehaviorStateMachine(_loc9_.stateMachine).currentState;
         slot.unitCard_mc.icon.filters = [];
         slot.unitCard_mc.upgradeStatus_tf.visible = false;
         slot.unitCard_mc.upgradeStatus_tf.mouseEnabled = false;
         if(Boolean(slot.unitCard_mc.tierRating_mc) && Boolean(slot.unitCard_mc.doubleXP_mc))
         {
            slot.unitCard_mc.tierRating_mc.visible = slot.unitCard_mc.doubleXP_mc.visible = false;
            if(TierSurfacingManager.instance.tierSurfacing2Enabled)
            {
               _loc11_ = (ZGlobal.gameSettings.getItemByCode(m_unitItem.code,UnitItem) as UnitItem).tier;
               TextFieldUtil.compactTextField(slot.unitCard_mc.tierRating_mc.tier_tf,String(_loc11_));
               slot.unitCard_mc.tierRating_mc.visible = true;
               if(m_unitItem.isBlueDevil)
               {
                  slot.unitCard_mc.doubleXP_mc.visible = true;
               }
            }
         }
         this.displayDiscountSale();
         if(ZGameTimeUtil.instance.isLimitedEdition(m_unitItem.xml))
         {
            slot.unitCard_mc.bg_mc_le.visible = true;
            slot.unitCard_mc.bg_mc.visible = false;
         }
         else
         {
            slot.unitCard_mc.bg_mc_le.visible = false;
            slot.unitCard_mc.bg_mc.visible = true;
         }
         var _loc5_:Boolean = ZGlobal.player.isItemUnlocked(m_unitItem.code);
         var _loc6_:BitArray = ZGlobal.player.checkGate(m_unitItem);
         if(Boolean(this.m_progressBuilding) && !(_loc4_ is SimpleAutoState))
         {
            slot.unitCard_mc.gotoAndStop("inProgress");
            slot.unitCard_mc.finishNow_bt.visible = false;
            if(_loc4_ is SimpleClickState && !(_loc4_ is AutoDialogState))
            {
               TextFieldUtil.processTextField(slot.unitCard_mc.countdown_tf,ZGameUtils.ZlocT("Dialogs","ResearchReady_Line"));
            }
            else
            {
               slot.unitCard_mc.upgradeStatus_tf.visible = true;
               this.m_progressBuilding.eventDispatcher.addEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onProgress,false,0,true);
               this.m_progressBuilding.eventDispatcher.addEventListener(ProgressBarEvent.STOP_PROGRESS_BAR,this.onProgressComplete,false,0,true);
               if(Boolean(this.m_buildingUnitItem) && this.m_buildingUnitItem.name == m_unitItem.name)
               {
                  this.m_finishNowBtn = new ZGameButton(slot.unitCard_mc.finishNow_bt,this.onFinishNowClicked);
                  this.m_finishNowBtn.text = ZGameUtils.ZlocT("Dialogs","FinishNowButtonText");
                  m_buttonSounds.addButton(this.m_finishNowBtn.m_overlay,ButtonSound.DEFAULT);
                  slot.unitCard_mc.finishNow_bt.visible = true;
                  TextFieldUtil.processTextField(slot.unitCard_mc.upgradeStatus_tf,ZGameUtils.ZlocT("Dialogs","UpgradeStatusText"));
               }
               else
               {
                  TextFieldUtil.processTextField(slot.unitCard_mc.upgradeStatus_tf,ZGameUtils.ZlocT("Dialogs","UpgradeElsewhereStatusText"));
               }
               slot.unitCard_mc.underlay_mc.visible = slot.unitCard_mc.upgradeStatus_tf.numLines > 1;
            }
            slot.unitCard_mc.countdown_tf.mouseEnabled = false;
         }
         else if(_loc6_.isBitSet(Player.GATE_FAILURE_DOMINANCE))
         {
            slot.unitCard_mc.gotoAndStop("locked");
            slot.unitCard_mc.unlock_bt.visible = false;
            slot.unitCard_mc.locked_tf.visible = false;
            slot.unitCard_mc.locked_mc.visible = false;
            slot.unitCard_mc.icon.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
            slot.unitCard_mc.buy_bt.visible = false;
            slot.unitCard_mc.locked_mc_dominance.visible = true;
            slot.unitCard_mc.underlay_mc.visible = false;
            _loc12_ = int(m_unitItem.requiredDominanceRank);
            TextFieldUtil.processTextField(slot.unitCard_mc.locked_mc_dominance.locked_tf,String(_loc12_));
            _loc13_ = ZGameUtils.ZlocT("Dialogs","DominationRewardLocked",{"num":_loc12_});
            Tooltip.subscribe(slot.unitCard_mc,_loc13_);
            if(Boolean(slot.unitCard_mc.tierRating_mc) && Boolean(slot.unitCard_mc.doubleXP_mc))
            {
               slot.unitCard_mc.tierRating_mc.visible = slot.unitCard_mc.doubleXP_mc.visible = false;
            }
            if(slot.unitCard_mc.discount_tf)
            {
               slot.unitCard_mc.discount_tf.visible = false;
            }
         }
         else if(_loc6_.isBitSet(Player.GATE_FAILURE_LEVEL) && !_loc5_)
         {
            slot.unitCard_mc.gotoAndStop("locked");
            slot.unitCard_mc.unlock_bt.visible = false;
            TextFieldUtil.processTextField(slot.unitCard_mc.locked_tf,ZGameUtils.ZlocT("Dialogs","LevelRequired",{"num":m_unitItem.requiredLevel}));
            slot.unitCard_mc.locked_tf.mouseEnabled = false;
            slot.unitCard_mc.locked_mc.visible = true;
            slot.unitCard_mc.locked_mc_dominance.visible = false;
            slot.unitCard_mc.buy_bt.visible = false;
            if(Boolean(slot.unitCard_mc.tierRating_mc) && Boolean(slot.unitCard_mc.doubleXP_mc))
            {
               slot.unitCard_mc.tierRating_mc.visible = slot.unitCard_mc.doubleXP_mc.visible = false;
            }
            if(slot.unitCard_mc.discount_tf)
            {
               slot.unitCard_mc.discount_tf.visible = false;
            }
         }
         else if(m_unitItem.contractLocked && !ZGlobal.player.hasPurchasedContract(m_unitItem.code))
         {
            slot.unitCard_mc.gotoAndStop("locked");
            slot.unitCard_mc.unlock_bt.visible = false;
            TextFieldUtil.processTextField(slot.unitCard_mc.locked_tf,ZGameUtils.ZlocT("Dialogs","LevelRequired",{"num":m_unitItem.requiredLevel}));
            slot.unitCard_mc.locked_tf.mouseEnabled = false;
            slot.unitCard_mc.locked_mc.visible = false;
            slot.unitCard_mc.locked_mc_dominance.visible = false;
            slot.unitCard_mc.buy_bt.visible = true;
            this.m_unlockContractBtn = new ZGameButton(slot.unitCard_mc.buy_bt,this.onBuyContractClicked);
            this.m_unlockContractBtn.text = ZGameUtils.ZlocT("Dialogs","UnlockForAmount",{"amount":m_unitItem.contractCost});
            m_buttonSounds.addButton(this.m_unlockContractBtn.m_overlay,ButtonSound.DEFAULT);
            _loc14_ = m_unitItem.builtFromStructure;
            if(_loc14_)
            {
               _loc15_ = m_unitItem.getSentenceNameLocalizationObject("singular,indefinite",true);
               _loc16_ = _loc14_.getSentenceNameLocalizationObject("singular,definite",true);
               if(Boolean(_loc15_) && Boolean(_loc16_))
               {
                  _loc17_ = {
                     "item":_loc15_,
                     "building":_loc16_
                  };
                  this.m_unlockContractBtn.addTooltip(ZGameUtils.ZlocT("Dialogs","BuyContractButtonTooltip",_loc17_));
               }
            }
         }
         else if(!ZGlobal.player.hasUnlockedUnit(m_unitItem.code))
         {
            if(slot.unitCard_mc.discount_tf)
            {
               slot.unitCard_mc.discount_tf.visible = false;
            }
            slot.unitCard_mc.gotoAndStop("locked");
            this.m_unlockBtn = new ZGameButton(slot.unitCard_mc.unlock_bt,this.onUnlockClicked);
            this.m_unlockBtn.text = ZGameUtils.ZlocT("Dialogs","ResearchUnlockButtonText");
            m_buttonSounds.addButton(this.m_unlockBtn.m_overlay,ButtonSound.DEFAULT);
            slot.unitCard_mc.locked_tf.visible = false;
            slot.unitCard_mc.locked_mc.visible = false;
            slot.unitCard_mc.locked_mc_dominance.visible = false;
            slot.unitCard_mc.buy_bt.visible = false;
         }
         else if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RESEARCH_SHIELD_UPGRADE) == ExperimentsManager.VARIANT_RESEARCH_SHIELD_UPGRADE_ON && _loc1_ == WorldUpgradeManager.instance.getTotalUpgrades(m_unitItem.code) - 1 && WorldUpgradeManager.instance.isStrengthUpgraded(m_unitItem.code) && WorldUpgradeManager.instance.isTechResearch(m_unitItem.researchTemplate))
         {
            slot.unitCard_mc.gotoAndStop("available");
            this.m_researchBtn = new ZGameButton(slot.unitCard_mc.research_bt,this.onResearchClicked);
            this.m_researchBtn.text = ZGameUtils.ZlocT("Dialogs","ResearchButtonNewUpgradeAvailable");
            m_buttonSounds.addButton(this.m_researchBtn.m_overlay,ButtonSound.DEFAULT);
         }
         else if(_loc1_ == WorldUpgradeManager.instance.getTotalUpgrades(m_unitItem.code))
         {
            slot.unitCard_mc.gotoAndStop("completed");
            TextFieldUtil.processTextField(slot.unitCard_mc.completed_tf,ZGameUtils.ZlocT("Dialogs","ResearchUnitComplete"));
            slot.unitCard_mc.completed_tf.mouseEnabled = false;
         }
         else
         {
            slot.unitCard_mc.gotoAndStop("available");
            this.m_researchBtn = new ZGameButton(slot.unitCard_mc.research_bt,this.onResearchClicked);
            this.m_researchBtn.text = ZGameUtils.ZlocT("Dialogs","ResearchButtonText");
            m_buttonSounds.addButton(this.m_researchBtn.m_overlay,ButtonSound.DEFAULT);
            if(this.m_buildingUnitItem)
            {
               _loc19_ = this.m_buildingUnitItem.getSentenceNameLocalizationObject();
               if(_loc19_)
               {
                  _loc18_ = ZGameUtils.ZlocT("Dialogs","UpgradeButtonLocked_Object",{"unit":_loc19_});
               }
               else
               {
                  _loc18_ = ZGameUtils.ZlocT("Dialogs","UpgradeButtonLocked",{"unit":this.m_buildingUnitItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME)});
               }
               this.m_researchBtn.disableWithTooltip(_loc18_);
            }
         }
         m_iconLoaders = new Array();
         m_iconLoaders.push(ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName(m_unitItem.name,"icon"),slot.unitCard_mc.icon));
         TextFieldUtil.processTextField(slot.unitCard_mc.itemName_tf,m_unitItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         slot.unitCard_mc.itemName_tf.mouseEnabled = false;
         var _loc7_:Array = [slot.unitCard_mc.upgrades_mc.icon0,slot.unitCard_mc.upgrades_mc.icon1,slot.unitCard_mc.upgrades_mc.icon2,slot.unitCard_mc.upgrades_mc.icon3,slot.unitCard_mc.upgrades_mc.icon4,slot.unitCard_mc.upgrades_mc.icon4];
         if(slot.unitCard_mc.currentLabel == "inProgress")
         {
            slot.unitCard_mc.upgrades_mc.visible = false;
            slot.unitCard_mc.tooltip.visible = false;
         }
         else
         {
            this.m_upgradesDisplay = new UpgradesDisplay(_loc7_,slot.unitCard_mc.upgrades_mc,slot.unitCard_mc.tooltip,m_screen,m_unitItem,WorldUpgradeManager.instance.getUpgradesByCode(m_unitItem.code));
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
      
      private function onResearchClicked(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(SELECTED,this));
      }
      
      private function onUnlockClicked(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(UNLOCK,this));
      }
      
      private function onFinishNowClicked(param1:MouseEvent) : void
      {
         UIDispatcher.instance.dispatchEvent(new WorldEvent(FINISH_NOW,{
            "unitItem":m_unitItem,
            "upgradeItem":this.m_upgradeItem
         }));
      }
      
      private function onBuyContractClicked(param1:MouseEvent) : void
      {
         this.beginBuyContractProcess(m_unitItem);
      }
      
      override protected function onRollOver(param1:MouseEvent) : void
      {
         if(slot.unitCard_mc.currentFrameLabel != "completed" && !(slot.unitCard_mc.currentFrameLabel == "available" && !this.m_researchBtn.enabled))
         {
            slot.unitCard_mc.highlightSelect_mc.visible = true;
         }
      }
      
      override protected function onRollOut(param1:MouseEvent) : void
      {
         if(slot.unitCard_mc.currentFrameLabel != "completed" && !(slot.unitCard_mc.currentFrameLabel == "available" && !this.m_researchBtn.enabled))
         {
            slot.unitCard_mc.highlightSelect_mc.visible = false;
         }
      }
      
      override public function dispose() : void
      {
         if(this.m_progressBuilding)
         {
            this.m_progressBuilding.eventDispatcher.removeEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onProgress);
         }
         if(this.m_researchBtn)
         {
            this.m_researchBtn.dispose();
         }
         if(this.m_unlockBtn)
         {
            this.m_unlockBtn.dispose();
         }
         if(this.m_finishNowBtn)
         {
            this.m_finishNowBtn.dispose();
         }
         if(this.m_unlockContractBtn)
         {
            this.m_unlockContractBtn.dispose();
         }
         if(this.m_upgradesDisplay)
         {
            this.m_upgradesDisplay.dispose();
         }
         super.dispose();
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
      
      protected function onPurchaseConfirmationClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            this.buyContractUnlock(this.m_confirmationItem);
         }
         this.m_confirmationItem = null;
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
      
      private function displayDiscountSale() : void
      {
         var _loc1_:Number = NaN;
         if(slot.unitCard_mc.discount_tf != null)
         {
            if(LEUnitDiscountManager.instance.isLEDiscountExpEnabled() && LEUnitDiscountManager.instance.isOverrideLEItem(m_unitItem.code))
            {
               _loc1_ = Math.floor(LEUnitDiscountManager.instance.getLEOverrideDiscount(m_unitItem.code) * 100);
               if(_loc1_ > 0)
               {
                  if(LEUnitDiscountManager.instance.leDiscountVariant == 3)
                  {
                     TextFieldUtil.compactTextField(slot.unitCard_mc.discount_tf,ZGameUtils.ZlocT("Dialogs","PercentOffExclaim",{"amount":_loc1_}));
                  }
                  else
                  {
                     TextFieldUtil.compactTextField(slot.unitCard_mc.discount_tf,ZGameUtils.ZlocT("Promo","promo_RepeatPackHUD_textSale"));
                  }
                  slot.unitCard_mc.discount_tf.visible = true;
               }
               else
               {
                  slot.unitCard_mc.discount_tf.visible = false;
               }
            }
            else
            {
               slot.unitCard_mc.discount_tf.visible = false;
            }
         }
      }
   }
}

