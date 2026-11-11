package displays.screens.partsGather
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gamemode.battle.BattleMechlab;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.managers.promoManager.PromoManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import core.ui.ZGameBuyButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.SpeechPopup;
   import displays.screens.MechLabScreen;
   import displays.screens.requests.RequestAskPartsDialog;
   import entity.GameDataComponent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import transactions.TPartUnlock;
   import transactions.TUpdatePartUnlocks;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class MechLabPartsGather extends MechLabScreen
   {
      
      public static const SHOW_MECHLAB_PARTS_GATHER:String = "showMechLabPartsGather";
      
      public static const FINISHED:String = "finished";
      
      private static const NUM_PART_TYPES:uint = 8;
      
      private static const BADGE_UNINITIALIZED:String = "uninitialized";
      
      private static const BADGE_LOCKED:String = "locked";
      
      private static const BADGE_UNLOCKED:String = "unlocked";
      
      private static const BADGE_SELECTED:String = "selected";
      
      private static const BADGE_FINISHED:String = "finished";
      
      private var m_currentSelection:uint = 4294967295;
      
      private var m_dataMap:Array = null;
      
      private var m_partsDetailLoader:ImageLoader = null;
      
      private var m_fightButton:ZGameButton = null;
      
      private var m_askButton:ZGameButton = null;
      
      private var m_buyButton:ZGameBuyButton = null;
      
      private var m_finishButton:ZGameButton = null;
      
      public function MechLabPartsGather(param1:EventDispatcher, param2:IEntity, param3:String = "assets/displays/screens/MechLabMain.swf")
      {
         super(param1,param2,ZGlobal.getAssetURL(param3));
      }
      
      public static function display(param1:EventDispatcher, param2:IEntity) : void
      {
         WindowManager.instance.push(new MechLabPartsGather(param1,param2));
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         screen.complete_mc.visible = false;
         screen.comingSoon_mc.visible = false;
         this.initButtons();
         this.initText();
         this.initParts();
         this.addEventListeners();
         this.selectFirstAvailablePart();
      }
      
      override protected function initUI() : void
      {
         screen.activationPanel_mc.visible = false;
         screen.consumablePanel_mc.visible = false;
         screen.mech2_mc.visible = false;
         screen.buildPanel_mc.visible = false;
      }
      
      private function initButtons() : void
      {
         this.m_fightButton = new ZGameButton(screen.partsPanel_mc.fight_bt,this.onFightClicked);
         this.m_askButton = new ZGameButton(screen.partsPanel_mc.ask_bt,this.onAskClicked);
         this.m_buyButton = new ZGameBuyButton(screen.partsPanel_mc.accept_bt2,null,this.onBuyClicked);
         this.m_finishButton = new ZGameButton(screen.finish_bt,this.onFinish);
         this.m_finishButton.text = ZGameUtils.ZlocT("Dialogs","BuildingPartsConfirmBuild");
         this.m_finishButton.hide();
      }
      
      private function initText() : void
      {
         TextFieldUtil.processTextField(screen.screenTitle_tf,ZGameUtils.ZlocT("Dialogs","MechLabAssembleTitle"));
         TextFieldUtil.compactTextField(screen.partsPanel_mc.title_tf,ZGameUtils.ZlocT("Dialogs","MechLabPartDetailTitle"),{"minScale":0.65});
         TextFieldUtil.processTextField(screen.partsPanel_mc.desc_tf,ZGameUtils.ZlocT("Dialogs","MechLabPartDetailDescription"));
         TextFieldUtil.processTextField(screen.complete_mc.complete_tf,ZGameUtils.ZlocT("Dialogs","MechLabResearchComplete"));
      }
      
      private function initParts() : void
      {
         this.m_dataMap = new Array();
         this.m_dataMap.push({
            "badge":screen.badges_mc.mechItemBadge06_mc,
            "mechItems":[screen.mech_mc.mechItemArmRight_mc],
            "state":MechLabPartsGather.BADGE_UNINITIALIZED,
            "unlockButton":null
         });
         this.m_dataMap.push({
            "badge":screen.badges_mc.mechItemBadge00_mc,
            "mechItems":[screen.mech_mc.mechItemLegLeft_mc,screen.mech_mc.mechItemLegRight_mc],
            "state":MechLabPartsGather.BADGE_UNINITIALIZED,
            "unlockButton":null
         });
         this.m_dataMap.push({
            "badge":screen.badges_mc.mechItemBadge07_mc,
            "mechItems":[screen.mech_mc.mechItemFootLeft_mc,screen.mech_mc.mechItemFootRight_mc],
            "state":MechLabPartsGather.BADGE_UNINITIALIZED,
            "unlockButton":null
         });
         this.m_dataMap.push({
            "badge":screen.badges_mc.mechItemBadge05_mc,
            "mechItems":[screen.mech_mc.mechItemBack_mc],
            "state":MechLabPartsGather.BADGE_UNINITIALIZED,
            "unlockButton":null
         });
         this.m_dataMap.push({
            "badge":screen.badges_mc.mechItemBadge01_mc,
            "mechItems":[screen.mech_mc.mechItemArmLeft_mc],
            "state":MechLabPartsGather.BADGE_UNINITIALIZED,
            "unlockButton":null
         });
         this.m_dataMap.push({
            "badge":screen.badges_mc.mechItemBadge04_mc,
            "mechItems":[screen.mech_mc.mechItemBody_mc],
            "state":MechLabPartsGather.BADGE_UNINITIALIZED,
            "unlockButton":null
         });
         this.m_dataMap.push({
            "badge":screen.badges_mc.mechItemBadge02_mc,
            "mechItems":[screen.mech_mc.mechItemHead_mc],
            "state":MechLabPartsGather.BADGE_UNINITIALIZED,
            "unlockButton":null
         });
         this.m_dataMap.push({
            "badge":screen.badges_mc.mechItemBadge03_mc,
            "mechItems":[screen.mech_mc.mechItemHeadGun_mc],
            "state":MechLabPartsGather.BADGE_UNINITIALIZED,
            "unlockButton":null
         });
         var _loc1_:uint = 0;
         while(_loc1_ < MechLabPartsGather.NUM_PART_TYPES)
         {
            this.updatePartUI(_loc1_);
            _loc1_++;
         }
      }
      
      private function selectFirstAvailablePart() : void
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc1_:uint = 0;
         var _loc2_:uint = 0;
         for each(_loc3_ in this.m_dataMap)
         {
            if(_loc3_.state == MechLabPartsGather.BADGE_FINISHED)
            {
               _loc1_++;
            }
            if(_loc3_.state == MechLabPartsGather.BADGE_UNLOCKED)
            {
               this.selectPartUI(_loc2_);
               break;
            }
            _loc2_++;
         }
         if(_loc1_ == MechLabPartsGather.NUM_PART_TYPES)
         {
            this.onAllPartsCollected();
         }
         else
         {
            _loc4_ = MechLabPartsGather.NUM_PART_TYPES - _loc1_;
            TextFieldUtil.processTextField(screen.partsPanel_mc.progressText_tf,ZGameUtils.ZlocT("Dialogs","MechLabPartDetailProgress",{
               "owned":_loc4_,
               "required":MechLabPartsGather.NUM_PART_TYPES
            }));
            MechLabScreen.updateProgressBar(screen.partsPanel_mc.progressBar_mc,_loc1_,MechLabPartsGather.NUM_PART_TYPES);
         }
      }
      
      private function addEventListeners() : void
      {
         var _loc1_:Object = null;
         for each(_loc1_ in this.m_dataMap)
         {
            _loc1_.badge.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
            _loc1_.badge.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
            _loc1_.badge.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         }
      }
      
      private function removeEventListeners() : void
      {
         var _loc1_:Object = null;
         for each(_loc1_ in this.m_dataMap)
         {
            _loc1_.badge.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
            _loc1_.badge.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
            _loc1_.badge.removeEventListener(MouseEvent.CLICK,this.onClick);
         }
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:Object = null;
         this.removeEventListeners();
         this.destroyLoaders();
         this.m_fightButton.dispose();
         this.m_askButton.dispose();
         this.m_buyButton.dispose();
         this.m_finishButton.dispose();
         for each(_loc1_ in this.m_dataMap)
         {
            if(_loc1_.unlockButton)
            {
               _loc1_.unlockButton.dispose();
            }
         }
         super.deinitDialog();
      }
      
      private function destroyLoaders() : void
      {
         if(this.m_partsDetailLoader)
         {
            this.m_partsDetailLoader.destroy();
            this.m_partsDetailLoader = null;
         }
      }
      
      private function updatePartUI(param1:uint) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:Object = this.m_dataMap[param1];
         if(this.isPartLocked(param1))
         {
            _loc2_.state = MechLabPartsGather.BADGE_LOCKED;
            _loc2_.badge.gotoAndStop("locked");
            for each(_loc3_ in _loc2_.mechItems)
            {
               _loc3_.gotoAndStop("locked");
               _loc3_.visible = true;
            }
         }
         else if(this.areAllPartsCollected(param1))
         {
            _loc2_.state = MechLabPartsGather.BADGE_FINISHED;
            _loc2_.badge.gotoAndStop("completed");
            for each(_loc3_ in _loc2_.mechItems)
            {
               _loc3_.visible = false;
            }
            this.unlockNextPart(param1);
            if(param1 == this.m_currentSelection)
            {
               this.selectFirstAvailablePart();
            }
         }
         else
         {
            if(param1 == this.m_currentSelection)
            {
               _loc2_.state = MechLabPartsGather.BADGE_SELECTED;
               _loc2_.badge.gotoAndStop("selected");
               for each(_loc3_ in _loc2_.mechItems)
               {
                  _loc3_.gotoAndStop("unlockedSelected");
               }
            }
            else
            {
               _loc2_.state = MechLabPartsGather.BADGE_UNLOCKED;
               _loc2_.badge.gotoAndStop("unlocked");
               for each(_loc3_ in _loc2_.mechItems)
               {
                  _loc3_.gotoAndStop("unlocked");
                  _loc3_.visible = true;
               }
            }
            this.updateUnlockedBadge(param1);
         }
      }
      
      private function selectPartUI(param1:uint) : void
      {
         var _loc2_:uint = 0;
         if(param1 < MechLabPartsGather.NUM_PART_TYPES)
         {
            _loc2_ = this.m_currentSelection;
            this.m_currentSelection = param1;
            if(_loc2_ < MechLabPartsGather.NUM_PART_TYPES)
            {
               this.updatePartUI(_loc2_);
            }
            this.updatePartUI(this.m_currentSelection);
            this.updatePartDetailsUI();
            this.m_buyButton.data = this.generatePartBuyButtonData(this.m_currentSelection);
         }
      }
      
      private function updatePartDetailsUI() : void
      {
         var _loc1_:String = m_partsItem.getPartCodeForIndex(this.m_currentSelection);
         var _loc2_:PartsBuildingItem = ZGlobal.gameSettings.getItemByCode(_loc1_,PartsBuildingItem) as PartsBuildingItem;
         this.m_fightButton.text = ZGameUtils.ZlocT("Dialogs","MechLabPartDetailButtonFight",{"item":_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME)});
         this.m_askButton.text = ZGameUtils.ZlocT("Dialogs","MechLabPartDetailButtonAsk",{"item":_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME)});
         this.m_buyButton.text = ZGameUtils.ZlocT("Dialogs","MechLabPartDetailButtonBuy",{
            "amount":_loc2_.cash,
            "item":_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME)
         });
         TextFieldUtil.processTextField(screen.partsPanel_mc.partName_tf,_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
         this.destroyLoaders();
         this.m_partsDetailLoader = ImageLoaderFactory.CreateImageLoader(_loc2_.getCachedImage("icon").url,screen.partsPanel_mc.icon);
         this.m_partsDetailLoader.smooth = true;
         this.updatePartDetailsProgress();
      }
      
      private function updatePartDetailsProgress() : void
      {
         var _loc1_:String = m_partsItem.getPartCodeForIndex(this.m_currentSelection);
         var _loc2_:PartsBuildingItem = ZGlobal.gameSettings.getItemByCode(_loc1_,PartsBuildingItem) as PartsBuildingItem;
         var _loc3_:int = ZGlobal.player.getNumberOfInventoryItems(_loc1_);
         var _loc4_:int = m_partsItem.getPartCountForIndex(this.m_currentSelection);
         TextFieldUtil.processTextField(screen.partsPanel_mc.partsProgressText_tf,ZGameUtils.ZlocT("Dialogs","MechLabPartDetailPartProgress",{
            "owned":_loc3_,
            "required":_loc4_,
            "item":_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME)
         }));
         MechLabScreen.updateProgressBar(screen.partsPanel_mc.partsProgressBar_mc,_loc3_,_loc4_);
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         var _loc4_:Object = null;
         var _loc5_:MovieClip = null;
         var _loc6_:int = 0;
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         var _loc3_:uint = this.getPartIndex(_loc2_);
         if(_loc3_ < this.m_dataMap.length)
         {
            _loc4_ = this.m_dataMap[_loc3_];
            switch(this.m_dataMap[_loc3_].state)
            {
               case MechLabPartsGather.BADGE_LOCKED:
                  _loc2_.gotoAndPlay("lockedOver");
                  for each(_loc5_ in _loc4_.mechItems)
                  {
                     _loc5_.gotoAndPlay("lockedOver");
                  }
                  if(_loc4_.unlockButton == null)
                  {
                     _loc6_ = m_partsItem.getPartUnlockCost(_loc3_);
                     _loc4_.unlockButton = new ZGameBuyButton(_loc2_.flyout_mc.buy_bt,this.generateUnlockPartBuyButtonData(_loc3_),this.onPartUnlockClicked);
                     (_loc4_.unlockButton as ZGameButton).text = ZGameUtils.ZlocT("Dialogs","MechLabPartButtonUnlock",{"amount":_loc6_});
                     (_loc4_.unlockButton as ZGameButton).buttonObject = {"partIndex":_loc3_};
                  }
                  break;
               case MechLabPartsGather.BADGE_UNLOCKED:
                  _loc2_.gotoAndPlay("over");
                  for each(_loc5_ in _loc4_.mechItems)
                  {
                     _loc5_.gotoAndPlay("unlockedOver");
                  }
                  this.updateUnlockedBadge(_loc3_);
                  break;
               case MechLabPartsGather.BADGE_SELECTED:
               case MechLabPartsGather.BADGE_FINISHED:
            }
         }
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         var _loc4_:Object = null;
         var _loc5_:MovieClip = null;
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         var _loc3_:uint = this.getPartIndex(_loc2_);
         if(_loc3_ < this.m_dataMap.length)
         {
            _loc4_ = this.m_dataMap[_loc3_];
            switch(this.m_dataMap[_loc3_].state)
            {
               case MechLabPartsGather.BADGE_LOCKED:
                  if(_loc4_.unlockButton)
                  {
                     (_loc4_.unlockButton as ZGameButton).dispose();
                     _loc4_.unlockButton = null;
                  }
                  _loc2_.gotoAndStop("locked");
                  for each(_loc5_ in _loc4_.mechItems)
                  {
                     _loc5_.gotoAndStop("locked");
                  }
                  break;
               case MechLabPartsGather.BADGE_UNLOCKED:
                  _loc2_.gotoAndStop("unlocked");
                  for each(_loc5_ in _loc4_.mechItems)
                  {
                     _loc5_.gotoAndStop("unlocked");
                  }
                  this.updateUnlockedBadge(_loc3_);
                  break;
               case MechLabPartsGather.BADGE_SELECTED:
               case MechLabPartsGather.BADGE_FINISHED:
            }
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         var _loc3_:uint = this.getPartIndex(_loc2_);
         if(_loc3_ < this.m_dataMap.length)
         {
            switch(this.m_dataMap[_loc3_].state)
            {
               case MechLabPartsGather.BADGE_LOCKED:
                  break;
               case MechLabPartsGather.BADGE_UNLOCKED:
                  this.selectPartUI(_loc3_);
                  break;
               case MechLabPartsGather.BADGE_SELECTED:
               case MechLabPartsGather.BADGE_FINISHED:
            }
         }
      }
      
      private function onPartUnlockClicked(param1:MouseEvent) : void
      {
         var _loc2_:uint = uint(param1.currentTarget.buttonObject.partIndex);
         var _loc3_:int = m_partsItem.getPartUnlockCost(_loc2_);
         ZGlobal.player.cash -= _loc3_;
         this.unlockPart(_loc2_);
      }
      
      private function onFightClicked(param1:MouseEvent) : void
      {
         BattleMechlab.startBattle(this.m_currentSelection,m_partsItem.code);
         close();
      }
      
      private function onAskClicked(param1:MouseEvent) : void
      {
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         var _loc2_:String = m_partsItem.getPartCodeForIndex(this.m_currentSelection);
         var _loc3_:PartsBuildingItem = ZGlobal.gameSettings.getItemByCode(_loc2_,PartsBuildingItem) as PartsBuildingItem;
         if(_loc3_ != null)
         {
            if(this.m_currentSelection % 2 == 1)
            {
               ViralsManager.instance.sendFeedWithLotsOfFriction("ask_for_parts_titan_lab",{
                  "itemCode":_loc3_.code,
                  "mechlabPartName":m_partsItem.name,
                  "ITEMTOKitem":m_partsItem.name + "|",
                  "ITEMTOKreward":_loc3_.name + "|"
               },null);
            }
            else
            {
               _loc4_ = new Array();
               _loc5_ = _loc3_.getSentenceNameLocalizationObject("singular",true);
               _loc4_["request_body"] = ZGameUtils.ZlocT("Requests","PartRequest_mechlabpart",{"gift":_loc5_});
               PopupManager.instance.push(new RequestAskPartsDialog(_loc3_.name,m_partsItem.name,_loc4_),0,false);
            }
         }
      }
      
      private function onBuyClicked(param1:MouseEvent) : void
      {
         var _loc2_:String = m_partsItem.getPartCodeForIndex(this.m_currentSelection);
         var _loc3_:PartsBuildingItem = ZGlobal.gameSettings.getItemByCode(_loc2_,PartsBuildingItem) as PartsBuildingItem;
         ZGlobal.player.buyGameItem(_loc3_);
         this.updatePartUI(this.m_currentSelection);
         this.updatePartDetailsProgress();
      }
      
      override protected function onExit(param1:MouseEvent) : void
      {
         super.onExit(param1);
         if(PromoManager.instance.meetsCriteriaMechLabDiscountPromo())
         {
            PromoManager.instance.runPromoMechLabDiscountPromo();
         }
      }
      
      private function onFinish(param1:MouseEvent) : void
      {
         stateEventDispatcher.dispatchEvent(new Event(FINISHED));
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         close();
         PopupManager.instance.push(new SpeechPopup("Speech_Seabolt_MechLabConstructed",null,SpeechPopup.EXIT_TEXT_OK));
      }
      
      private function onAllPartsCollected() : void
      {
         var _loc1_:Object = null;
         for each(_loc1_ in this.m_dataMap)
         {
            _loc1_.badge.visible = false;
         }
         screen.partsPanel_mc.visible = false;
         screen.complete_mc.visible = true;
         this.m_finishButton.show();
      }
      
      private function getPartIndex(param1:MovieClip) : uint
      {
         var _loc3_:Object = null;
         var _loc2_:uint = 0;
         for each(_loc3_ in this.m_dataMap)
         {
            if(_loc3_.badge == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return uint.MAX_VALUE;
      }
      
      private function isPartLocked(param1:uint) : Boolean
      {
         var _loc2_:String = m_partsItem.getPartCodeForIndex(param1);
         if(m_partsItem.getLocked(param1))
         {
            if(!this.partUnlocks.hasOwnProperty(_loc2_) || !this.partUnlocks[_loc2_])
            {
               return true;
            }
         }
         return false;
      }
      
      private function areAllPartsCollected(param1:uint) : Boolean
      {
         var _loc2_:String = m_partsItem.getPartCodeForIndex(param1);
         var _loc3_:int = m_partsItem.getPartCountForIndex(param1);
         var _loc4_:int = ZGlobal.player.getNumberOfInventoryItems(_loc2_);
         if(_loc4_ < _loc3_)
         {
            return false;
         }
         return true;
      }
      
      private function get partUnlocks() : Object
      {
         var _loc1_:GameDataComponent = GameDataComponent(stateEntity.lookupComponentByType(GameDataComponent));
         if(!_loc1_.userData.hasOwnProperty("data"))
         {
            _loc1_.userData["data"] = new Object();
         }
         if(!_loc1_.userData.data.hasOwnProperty("partUnlocks"))
         {
            _loc1_.userData.data["partUnlocks"] = new Object();
         }
         return _loc1_.userData.data.partUnlocks;
      }
      
      private function unlockPart(param1:uint) : void
      {
         var _loc2_:String = m_partsItem.getPartCodeForIndex(param1);
         this.partUnlocks[_loc2_] = true;
         this.updatePartUI(param1);
         TransactionManager.addTransaction(new TPartUnlock(stateEntity,_loc2_));
      }
      
      private function unlockNextPart(param1:uint) : void
      {
         var _loc3_:String = null;
         var _loc2_:int = m_partsItem.getUnlocks(param1);
         if(_loc2_ != -1 && this.isPartLocked(_loc2_))
         {
            _loc3_ = m_partsItem.getPartCodeForIndex(_loc2_);
            this.partUnlocks[_loc3_] = true;
            this.updatePartUI(_loc2_);
            TransactionManager.addTransaction(new TUpdatePartUnlocks(stateEntity));
         }
      }
      
      private function updateUnlockedBadge(param1:uint) : void
      {
         var _loc2_:Object = this.m_dataMap[param1];
         var _loc3_:MovieClip = _loc2_.badge;
         TextFieldUtil.processTextField(_loc3_.label_tf,String(param1 + 1));
         var _loc4_:String = m_partsItem.getPartCodeForIndex(param1);
         var _loc5_:int = ZGlobal.player.getNumberOfInventoryItems(_loc4_);
         var _loc6_:int = m_partsItem.getPartCountForIndex(param1);
         MechLabScreen.updateProgressBar(_loc3_.partsProgressBar_mc,_loc5_,_loc6_);
      }
      
      private function generatePartBuyButtonData(param1:uint) : Object
      {
         var _loc2_:String = m_partsItem.getPartCodeForIndex(param1);
         var _loc3_:PartsBuildingItem = ZGlobal.gameSettings.getItemByCode(_loc2_,PartsBuildingItem) as PartsBuildingItem;
         var _loc4_:Object = new Object();
         _loc4_.cash = _loc3_.cash;
         _loc4_.confirmationData = new Object();
         _loc4_.confirmationData.title = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
         var _loc5_:Object = ZGameUtils.CashTokenReplacements(_loc3_.cash);
         _loc5_.item = _loc3_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
         _loc4_.confirmationData.message = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseMessage",_loc5_);
         return _loc4_;
      }
      
      private function generateUnlockPartBuyButtonData(param1:uint) : Object
      {
         var _loc2_:String = m_partsItem.getPartCodeForIndex(param1);
         var _loc3_:PartsBuildingItem = ZGlobal.gameSettings.getItemByCode(_loc2_,PartsBuildingItem) as PartsBuildingItem;
         var _loc4_:int = m_partsItem.getPartUnlockCost(param1);
         var _loc5_:Object = new Object();
         _loc5_.cash = _loc4_;
         _loc5_.confirmationData = new Object();
         _loc5_.confirmationData.title = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
         var _loc6_:Object = ZGameUtils.CashTokenReplacements(_loc4_);
         _loc6_.item = _loc3_.getFriendlyName(GameItem.MENU_FRIENDLYNAME);
         _loc5_.confirmationData.message = ZGameUtils.ZlocT("Dialogs","MechLabConfirmUnlockMessage",_loc6_);
         return _loc5_;
      }
      
      override protected function get panel() : MovieClip
      {
         return screen.partsPanel_mc;
      }
      
      override protected function get currentActivationStage() : uint
      {
         return 1;
      }
   }
}

