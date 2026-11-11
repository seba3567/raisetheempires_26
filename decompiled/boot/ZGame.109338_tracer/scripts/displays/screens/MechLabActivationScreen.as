package displays.screens
{
   import Engine.Managers.TransactionManager;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.gamemode.battle.Battle;
   import core.gameobjects.GameItem;
   import core.gameobjects.ManaRefillItem;
   import core.managers.ExperimentsManager;
   import core.managers.WorldResourceManager;
   import core.managers.viralsManager.ViralsManager;
   import core.player.Player;
   import core.ui.GenericButton;
   import core.ui.UI;
   import core.ui.ZGameButton;
   import core.ui.ZGameBuyButton;
   import dispatchers.ResourceDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.SpeechPopup;
   import entity.GameDataComponent;
   import events.EnergyMarketEvent;
   import events.MarketEvent;
   import events.ResourceUpdatedEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.utils.getQualifiedClassName;
   import transactions.TLogClientString;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.popups.IWindow;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   
   public class MechLabActivationScreen extends MechLabScreen
   {
      
      public static const FINISHED:String = "finished";
      
      private static const NUM_REQUIREMENTS:uint = 6;
      
      private var m_requirementData:Vector.<Object> = null;
      
      private var m_buyButton:ZGameBuyButton = null;
      
      private var m_activateButton:ZGameButton = null;
      
      private var m_imageLoaders:Array = [];
      
      private var m_visibleTooltip:MovieClip = null;
      
      private var m_numCompletedRequirements:uint = 0;
      
      private var m_bypassCode:String = null;
      
      public function MechLabActivationScreen(param1:EventDispatcher, param2:IEntity, param3:String = "assets/displays/screens/MechLabMain.swf")
      {
         super(param1,param2,ZGlobal.getAssetURL(param3));
      }
      
      public static function display(param1:EventDispatcher, param2:IEntity) : IWindow
      {
         var _loc3_:IWindow = null;
         _loc3_ = new MechLabActivationScreen(param1,param2);
         WindowManager.instance.push(_loc3_);
         return _loc3_;
      }
      
      override protected function get kingdom() : String
      {
         return "activation_screen";
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         screen.consumablePanel_mc.visible = false;
         this.m_requirementData = Vector.<Object>([{
            "type":"coins",
            "code":"VR00",
            "complete":false,
            "card":screen.activationPanel_mc.resource00,
            "ownedFunc":this.generateResourceOwnedFunc(),
            "requiredFunc":this.generateResourceRequiredFunc(),
            "iconURLFunc":this.generateResourceIconURLFunc(),
            "costFunc":this.generateResourceCostFunc(),
            "buyFunc":this.generateResourceBuyFunc(),
            "askFunc":this.generateResourceAskFunc(),
            "spendFunc":this.generateResourceSpendFunc()
         },{
            "type":"oil",
            "code":"VR02",
            "complete":false,
            "card":screen.activationPanel_mc.resource01,
            "ownedFunc":this.generateResourceOwnedFunc(),
            "requiredFunc":this.generateResourceRequiredFunc(),
            "iconURLFunc":this.generateResourceIconURLFunc(),
            "costFunc":this.generateResourceCostFunc(),
            "buyFunc":this.generateResourceBuyFunc(),
            "askFunc":this.generateResourceAskFunc(),
            "spendFunc":this.generateResourceSpendFunc()
         },{
            "type":"wood",
            "code":"VR01",
            "complete":false,
            "card":screen.activationPanel_mc.resource02,
            "ownedFunc":this.generateResourceOwnedFunc(),
            "requiredFunc":this.generateResourceRequiredFunc(),
            "iconURLFunc":this.generateResourceIconURLFunc(),
            "costFunc":this.generateResourceCostFunc(),
            "buyFunc":this.generateResourceBuyFunc(),
            "askFunc":this.generateResourceAskFunc(),
            "spendFunc":this.generateResourceSpendFunc()
         },{
            "type":WorldResourceManager.instance.resourceFromRareResource("nrare1"),
            "code":this.rareResourcePurchaseCode(WorldResourceManager.instance.resourceFromRareResource("nrare1")),
            "complete":false,
            "card":screen.activationPanel_mc.resource03,
            "ownedFunc":this.generateResourceOwnedFunc(),
            "requiredFunc":this.generateResourceRequiredFunc(),
            "iconURLFunc":this.generateResourceIconURLFunc(),
            "costFunc":this.generateResourceCostFunc(),
            "buyFunc":this.generateResourceBuyFunc(),
            "askFunc":this.generateResourceAskFunc(),
            "spendFunc":this.generateResourceSpendFunc()
         },{
            "type":"mana",
            "code":"MRX",
            "complete":false,
            "card":screen.activationPanel_mc.resource04,
            "ownedFunc":this.generateManaOwnedFunc(),
            "requiredFunc":this.generateManaRequiredFunc(),
            "iconURLFunc":this.generateManaIconURLFunc(),
            "costFunc":this.generateManaCostFunc(),
            "buyFunc":this.generateManaBuyFunc(),
            "askFunc":this.generateManaAskFunc(),
            "spendFunc":this.generateManaSpendFunc()
         },{
            "type":"B289",
            "code":"B289",
            "complete":false,
            "card":screen.activationPanel_mc.resource05,
            "ownedFunc":this.generateItemOwnedFunc(),
            "requiredFunc":this.generateItemRequiredFunc(),
            "iconURLFunc":this.generateItemIconURLFunc(),
            "costFunc":this.generateItemCostFunc(),
            "buyFunc":this.generateItemBuyFunc(),
            "askFunc":this.generateItemAskFunc(),
            "spendFunc":this.generateItemSpendFunc(),
            "consumable":true
         }]);
         this.initBypass();
         this.initText();
         this.initButtons();
         this.initRequirementCards();
         ResourceDispatcher.instance.addEventListener(this.m_requirementData[0].type,this.onResourceUpdated,false,0,true);
         ResourceDispatcher.instance.addEventListener(this.m_requirementData[1].type,this.onResourceUpdated,false,0,true);
         ResourceDispatcher.instance.addEventListener(this.m_requirementData[2].type,this.onResourceUpdated,false,0,true);
         ResourceDispatcher.instance.addEventListener(this.m_requirementData[3].type,this.onResourceUpdated,false,0,true);
         UIDispatcher.instance.addEventListener(Player.INVENTORY_UPDATED,this.onInventoryUpdated,false,0,true);
      }
      
      override protected function initUI() : void
      {
         screen.partsPanel_mc.visible = false;
         screen.mech_mc.visible = false;
         screen.badges_mc.visible = false;
         screen.complete_mc.visible = false;
         screen.comingSoon_mc.visible = false;
         screen.finish_bt.visible = false;
         screen.buildPanel_mc.visible = false;
         screen.leftPanel_mc.activate_bt.visible = false;
         screen.leftPanel_mc.screenDesc_mc.visible = false;
         screen.activationPanel_mc.visible = true;
         screen.mech2_mc.visible = true;
      }
      
      private function initText() : void
      {
         TextFieldUtil.processTextField(screen.screenTitle_tf,ZGameUtils.ZlocT("Dialogs","MechLabActivateTitle"));
         TextFieldUtil.compactTextField(screen.activationPanel_mc.title_tf,ZGameUtils.ZlocT("Dialogs","MechLabActivatePanelTitle"));
         TextFieldUtil.compactTextField(screen.activationPanel_mc.desc_tf,ZGameUtils.ZlocT("Dialogs","MechLabActivatePanelDesc"));
         TextFieldUtil.compactTextField(screen.activationPanel_mc.activate_tf,ZGameUtils.ZlocT("Dialogs","MechLabActivateButtonTitle"));
      }
      
      private function initButtons() : void
      {
         var _loc1_:Object = screen.activationPanel_mc.activateMech_bt;
         var _loc2_:MovieClip = _loc1_ as MovieClip;
         this.m_activateButton = new ZGameButton(screen.activationPanel_mc.activateMech_bt,this.onActivate);
         this.m_activateButton.disable();
         this.m_buyButton = new ZGameBuyButton(screen.activationPanel_mc.buy_bt,null,this.onUnlockRequirements);
         this.updateBuyButton();
      }
      
      private function initRequirementCards() : void
      {
         var _loc2_:Object = null;
         var _loc1_:uint = 0;
         while(_loc1_ < MechLabActivationScreen.NUM_REQUIREMENTS)
         {
            _loc2_ = this.m_requirementData[_loc1_];
            _loc2_["card"].gotoAndStop("locked");
            _loc2_["card"].tooltip_mc.visible = false;
            _loc2_["askButton"] = new ZGameButton(_loc2_["card"].tooltip_mc.ask_bt,this.onAskRequirement);
            _loc2_["askButton"].buttonObject = {"index":_loc1_};
            _loc2_["askButton"].text = ZGameUtils.ZlocT("Dialogs","MissionPartsAsk");
            _loc2_["buyButton"] = new ZGameBuyButton(_loc2_["card"].tooltip_mc.buy_bt,this.generateBuyRequirementButtonData(_loc1_),this.onBuyRequirement);
            _loc2_["buyButton"].buttonObject = {"index":_loc1_};
            _loc2_["buyButton"].text = ZGameUtils.ZlocT("Dialogs","UnlockForAmount",{"amount":this.buyRemainingRequirementCost(_loc1_)});
            _loc2_["card"]["addButton"] = new GenericButton(_loc2_["card"].add_bt,this.onAddRequirementClicked);
            _loc2_["card"]["addButton"].buttonObject = {"index":_loc1_};
            this.updateRequirement(_loc1_);
            _loc1_++;
         }
      }
      
      private function initBypass() : void
      {
         var _loc1_:String = null;
         var _loc2_:GameItem = null;
         if(m_partsItem.xml.activationCosts.activationBypass != undefined)
         {
            _loc1_ = m_partsItem.xml.activationCosts.activationBypass.@item;
            _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_,GameItem) as GameItem;
            if(ExperimentsManager.instance.validateItem(_loc2_.xml))
            {
               this.m_bypassCode = _loc1_;
            }
         }
      }
      
      private function get bypassAvailable() : Boolean
      {
         return this.m_bypassCode != null;
      }
      
      private function get bypassActive() : Boolean
      {
         return this.m_bypassCode != null && ZGlobal.player.getNumberOfInventoryItems(this.m_bypassCode) > 0;
      }
      
      private function updateRequirement(param1:uint) : void
      {
         var _loc2_:Object = this.m_requirementData[param1];
         var _loc3_:uint = uint(_loc2_.ownedFunc(_loc2_.type));
         var _loc4_:uint = uint(_loc2_.requiredFunc(_loc2_.type));
         var _loc5_:String = _loc2_.iconURLFunc(_loc2_.type);
         var _loc6_:ImageLoader = ImageLoaderFactory.CreateImageLoader(_loc5_,_loc2_.card.icon);
         _loc6_.smooth = true;
         this.m_imageLoaders.push(_loc6_);
         TextFieldUtil.compactTextField(_loc2_.card.progressText_tf,ZGameUtils.ZlocT("Dialogs","MechLabActivatePanelProgress",{
            "owned":Math.min(_loc3_,_loc4_),
            "required":_loc4_
         }));
         MechLabScreen.updateProgressBar(_loc2_.card.progressBar_mc,_loc3_,_loc4_);
         if((this.bypassActive || _loc3_ >= _loc4_) && !_loc2_.complete)
         {
            _loc2_.card.gotoAndStop("complete");
            _loc2_.complete = true;
            ++this.m_numCompletedRequirements;
         }
         this.updateActivationButton();
      }
      
      private function updateBuyButton() : void
      {
         this.m_buyButton.data = this.generateBuyAllButtonData();
         this.m_buyButton.compactText(ZGameUtils.ZlocT("Dialogs","MechLabActivateBuyActivationButton",{"amount":this.buyAllRemainingRequirementsCost}),null);
      }
      
      private function updateActivationButton() : void
      {
         if(this.m_numCompletedRequirements >= MechLabActivationScreen.NUM_REQUIREMENTS)
         {
            this.m_activateButton.enable();
            this.m_buyButton.disable();
         }
      }
      
      private function onResourceUpdated(param1:ResourceUpdatedEvent) : void
      {
         var _loc2_:uint = 0;
         while(_loc2_ < MechLabActivationScreen.NUM_REQUIREMENTS)
         {
            this.updateRequirement(_loc2_);
            _loc2_++;
         }
         this.updateBuyButton();
      }
      
      private function onInventoryUpdated(param1:WorldEvent) : void
      {
         var _loc2_:uint = 0;
         while(_loc2_ < MechLabActivationScreen.NUM_REQUIREMENTS)
         {
            this.updateRequirement(_loc2_);
            _loc2_++;
         }
         this.updateBuyButton();
      }
      
      private function onAddRequirementClicked(param1:MouseEvent) : void
      {
         var _loc2_:uint = uint(param1.target.buttonObject["index"]);
         var _loc3_:Object = this.m_requirementData[_loc2_];
         if(this.m_visibleTooltip)
         {
            this.m_visibleTooltip.visible = false;
         }
         if(_loc3_.hasOwnProperty("consumable") && Boolean(_loc3_.consumable))
         {
            consumablePanelVisible = true;
         }
         else
         {
            this.m_visibleTooltip = _loc3_["card"].tooltip_mc;
            _loc3_["card"].tooltip_mc.visible = true;
            _loc3_["card"].tooltip_mc.addEventListener(MouseEvent.ROLL_OUT,this.onHideTooltip,false,0,true);
         }
      }
      
      private function onHideTooltip(param1:MouseEvent) : void
      {
         if(this.m_visibleTooltip)
         {
            param1.target.removeEventListener(MouseEvent.ROLL_OUT,this.onHideTooltip);
            this.m_visibleTooltip.visible = false;
            this.m_visibleTooltip = null;
         }
      }
      
      private function onAskRequirement(param1:MouseEvent) : void
      {
         var _loc2_:uint = uint(param1.target.buttonObject.index);
         var _loc3_:Object = this.m_requirementData[_loc2_];
         _loc3_.askFunc(_loc3_.type);
      }
      
      private function onBuyRequirement(param1:MouseEvent) : void
      {
         var _loc2_:uint = uint(param1.target.buttonObject.index);
         var _loc3_:Object = this.m_requirementData[_loc2_];
         var _loc4_:uint = uint(_loc3_.ownedFunc(_loc3_.type));
         var _loc5_:uint = uint(_loc3_.requiredFunc(_loc3_.type));
         if(_loc4_ < _loc5_)
         {
            _loc3_.buyFunc(_loc3_.code,_loc5_ - _loc4_);
         }
      }
      
      private function getNumRequiredResources(param1:String) : uint
      {
         var _loc2_:int = 30;
         var _loc3_:Object = this.getActivationCosts(param1);
         var _loc4_:int = _loc3_.base * Math.exp(_loc3_.exp * (this.getPlayerLevel() - (_loc2_ - 1)));
         _loc4_ = this.modifyByExperiment(_loc4_);
         return this.reduceAccuracy(_loc4_);
      }
      
      private function getRequiredMana() : uint
      {
         var _loc1_:Object = this.getActivationCosts("mana");
         return Math.min(this.modifyByExperiment(_loc1_.base),ZGlobal.player.mana.cap);
      }
      
      private function getNumRequiredItem(param1:String) : uint
      {
         var _loc2_:Object = this.getActivationCosts(param1);
         return this.modifyByExperiment(_loc2_.base);
      }
      
      private function modifyByExperiment(param1:int) : int
      {
         var _loc4_:Array = null;
         var _loc5_:Number = NaN;
         var _loc2_:String = m_partsItem.xml.activationCosts.experiment.@name;
         var _loc3_:String = m_partsItem.xml.activationCosts.experiment.@values;
         if(_loc3_)
         {
            _loc4_ = _loc3_.split(",");
            _loc5_ = ExperimentsManager.instance.getExperimentValue(_loc2_,_loc4_,1);
            if(_loc5_ != 1)
            {
               param1 = Math.floor(param1 * _loc5_);
            }
         }
         return param1;
      }
      
      private function reduceAccuracy(param1:int) : int
      {
         if(param1 < 1000)
         {
            return this.roundValue(param1,10);
         }
         if(param1 < 10000)
         {
            return this.roundValue(param1,100);
         }
         if(param1 < 100000)
         {
            return this.roundValue(param1,1000);
         }
         if(param1 < 1000000)
         {
            return this.roundValue(param1,10000);
         }
         return this.roundValue(param1,100000);
      }
      
      private function roundValue(param1:int, param2:int) : int
      {
         return int(param1 / param2) * param2;
      }
      
      private function getActivationCosts(param1:String) : Object
      {
         var _loc3_:XML = null;
         var _loc4_:String = null;
         var _loc2_:int = ZGlobal.player.rareResourceType;
         for each(_loc3_ in m_partsItem.xml.activationCosts.activationCost)
         {
            _loc4_ = WorldResourceManager.instance.resourceFromRareResource(_loc3_.@resource,_loc2_);
            if(param1 == _loc4_)
            {
               return {
                  "base":int(_loc3_.@base),
                  "exp":Number(_loc3_.@exp)
               };
            }
         }
         throw new Error("getActivationCosts missing costs for resource type: " + param1);
      }
      
      private function getPlayerLevel() : int
      {
         var _loc2_:String = null;
         var _loc1_:GameDataComponent = GameDataComponent.getGameDataComponent(stateEntity);
         if(!_loc1_.userData.data)
         {
            _loc2_ = getQualifiedClassName(this) + ": userData.data is NULL";
            TransactionManager.addTransaction(new TLogClientString(_loc2_),true);
         }
         return _loc1_.userData.data.playerLevel;
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:Object = null;
         var _loc2_:ImageLoader = null;
         ResourceDispatcher.instance.removeEventListener(this.m_requirementData[0].type,this.onResourceUpdated);
         ResourceDispatcher.instance.removeEventListener(this.m_requirementData[1].type,this.onResourceUpdated);
         ResourceDispatcher.instance.removeEventListener(this.m_requirementData[2].type,this.onResourceUpdated);
         ResourceDispatcher.instance.removeEventListener(this.m_requirementData[3].type,this.onResourceUpdated);
         UIDispatcher.instance.removeEventListener(Player.INVENTORY_UPDATED,this.onInventoryUpdated);
         for each(_loc1_ in this.m_requirementData)
         {
            (_loc1_["askButton"] as ZGameButton).dispose();
            (_loc1_["buyButton"] as ZGameButton).dispose();
         }
         this.m_buyButton.dispose();
         for each(_loc2_ in this.m_imageLoaders)
         {
            _loc2_.destroy();
         }
         this.m_imageLoaders = null;
         super.deinitDialog();
      }
      
      private function onUnlockRequirements(param1:MouseEvent) : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:Object = null;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         if(this.bypassAvailable)
         {
            _loc2_ = ZGlobal.gameSettings.getItemByCode(this.m_bypassCode,GameItem) as GameItem;
            ZGlobal.player.buyGameItem(_loc2_,true);
         }
         else
         {
            for each(_loc3_ in this.m_requirementData)
            {
               _loc4_ = uint(_loc3_.ownedFunc(_loc3_.type));
               _loc5_ = uint(_loc3_.requiredFunc(_loc3_.type));
               if(_loc4_ < _loc5_)
               {
                  _loc3_.buyFunc(_loc3_.code,_loc5_ - _loc4_);
               }
            }
         }
      }
      
      override protected function get currentActivationStage() : uint
      {
         return 3;
      }
      
      private function onActivate(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:XML = null;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         param1.stopPropagation();
         param1.stopImmediatePropagation();
         close();
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_BUTTON_CLICKED,{
            "counter":"activation_screen",
            "kingdom":"mech_lab",
            "phylum":"click"
         }));
         stateEventDispatcher.dispatchEvent(new Event(FINISHED));
         for each(_loc2_ in this.m_requirementData)
         {
            _loc4_ = uint(_loc2_.requiredFunc(_loc2_.type));
            _loc5_ = uint(_loc2_.ownedFunc(_loc2_.type));
            if(this.bypassActive)
            {
               _loc4_ = Math.min(_loc4_,_loc5_);
            }
            _loc2_.spendFunc(_loc2_.type,_loc4_);
         }
         for each(_loc3_ in m_partsItem.xml.activationCosts.reward)
         {
            ZGlobal.player.addToInventory(_loc3_.@code);
         }
         PopupManager.instance.push(new SpeechPopup("Speech_Scarlett_MechLabCompletion",this.onMechLabCompleteSpeechClosed,SpeechPopup.EXIT_TEXT_OK));
      }
      
      private function onMechLabCompleteSpeechClosed(param1:GenericPopupEvent) : void
      {
         ViralsManager.instance.onNewTitanDialog();
      }
      
      private function onRenameTitanSuccessful(param1:WorldEvent) : void
      {
      }
      
      private function generateBuyRequirementButtonData(param1:uint) : Object
      {
         var _loc2_:int = int(this.buyRemainingRequirementCost(param1));
         var _loc3_:Object = new Object();
         _loc3_.cash = _loc2_;
         _loc3_.confirmationData = new Object();
         _loc3_.confirmationData.title = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
         var _loc4_:Object = ZGameUtils.CashTokenReplacements(_loc2_);
         _loc3_.confirmationData.message = ZGameUtils.ZlocT("Dialogs","ResearchUpgradeBuyConfirmMsg",_loc4_);
         return _loc3_;
      }
      
      private function generateBuyAllButtonData() : Object
      {
         var _loc1_:int = int(this.buyAllRemainingRequirementsCost);
         var _loc2_:Object = new Object();
         _loc2_.cash = _loc1_;
         _loc2_.confirmationData = new Object();
         _loc2_.confirmationData.title = ZGameUtils.ZlocT("Dialogs","ConfirmCashPurchaseTitle");
         var _loc3_:Object = ZGameUtils.CashTokenReplacements(_loc1_);
         _loc2_.confirmationData.message = ZGameUtils.ZlocT("Dialogs","MechLabActivateConfirmUnlockMessage",_loc3_);
         return _loc2_;
      }
      
      private function rareResourcePurchaseCode(param1:String) : String
      {
         var _loc2_:GameItem = ZGlobal.player.resourceItem(param1,param1 == ZGlobal.player.rareResourceName);
         return _loc2_.code;
      }
      
      private function getResourceNumPackages(param1:int, param2:int) : int
      {
         return param1 / param2 + (param1 % param2 == 0 ? 0 : 1);
      }
      
      override protected function get panel() : MovieClip
      {
         return screen.activationPanel_mc;
      }
      
      override protected function get hasConsumablePanel() : Boolean
      {
         return true;
      }
      
      override protected function get allowsCollect() : Boolean
      {
         return false;
      }
      
      private function generateResourceOwnedFunc() : Function
      {
         return function(param1:String):uint
         {
            return ZGlobal.player.resources.resourceAmounts[param1];
         };
      }
      
      private function generateResourceRequiredFunc() : Function
      {
         return function(param1:String):uint
         {
            return getNumRequiredResources(param1);
         };
      }
      
      private function generateResourceIconURLFunc() : Function
      {
         return function(param1:String):String
         {
            var _loc2_:* = WorldResourceManager.instance.getResourceInfoByType(param1);
            return WorldResourceManager.instance.getResourceImageURLByType(param1);
         };
      }
      
      private function generateResourceCostFunc() : Function
      {
         return function(param1:String, param2:int):int
         {
            var _loc3_:* = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
            var _loc4_:* = ZGlobal.player.getResourcePackageCost(false);
            var _loc5_:* = ZGlobal.player.getResourcePackageQuantity(_loc3_,_loc4_);
            return _loc4_ * getResourceNumPackages(param2,_loc5_);
         };
      }
      
      private function generateResourceBuyFunc() : Function
      {
         return function(param1:String, param2:int):void
         {
            var _loc3_:* = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
            var _loc4_:* = ZGlobal.player.getResourcePackageCost(false);
            var _loc5_:* = ZGlobal.player.getResourcePackageQuantity(_loc3_,_loc4_);
            var _loc6_:* = getResourceNumPackages(param2,_loc5_);
            ZGlobal.player.buyResourceItem(_loc3_,_loc6_ * _loc5_);
            ZGlobal.player.resources.updateResourceAmount(_loc3_.resourceType,_loc3_.resourceYield * _loc6_ * _loc5_);
         };
      }
      
      private function generateResourceAskFunc() : Function
      {
         return function(param1:String):void
         {
            var _loc2_:* = "titanlab_request_" + param1;
            ViralsManager.instance.sendFeedWithLotsOfFriction(_loc2_,{"resource":ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk("Items",param1 + "_sentenceName","plural"))});
         };
      }
      
      private function generateResourceSpendFunc() : Function
      {
         return function(param1:String, param2:int):void
         {
            ZGlobal.player.resources.updateResourceAmount(param1,-param2);
         };
      }
      
      private function generateManaOwnedFunc() : Function
      {
         return function(param1:String):uint
         {
            return ZGlobal.player.mana.value;
         };
      }
      
      private function generateManaRequiredFunc() : Function
      {
         return function(param1:String):uint
         {
            return getRequiredMana();
         };
      }
      
      private function generateManaIconURLFunc() : Function
      {
         return function(param1:String):String
         {
            return ZGlobal.getAssetURL("assets/game/GeneralAssetGroup_UI.swf/ElementZ_01_60.png");
         };
      }
      
      private function generateManaCostFunc() : Function
      {
         return function(param1:String, param2:int):int
         {
            var _loc3_:* = ZGlobal.gameSettings.getItemByCode(param1,ManaRefillItem) as ManaRefillItem;
            _loc3_.refillAmount = param2;
            return _loc3_.cash;
         };
      }
      
      private function generateManaBuyFunc() : Function
      {
         return function(param1:String, param2:int):void
         {
            UI.instance.setupForItemPurchase();
            var _loc3_:* = ZGlobal.gameSettings.getItemByCode(param1,ManaRefillItem) as ManaRefillItem;
            _loc3_.refillAmount = param2;
            var _loc4_:* = {
               "combatPhase":Battle.BATTLE_STATE_NONE,
               "inCampaign":false,
               "toasterClicked":false,
               "energyDialog":false,
               "gpvp":false,
               "questTree":false
            };
            UIDispatcher.instance.dispatchEvent(new EnergyMarketEvent(MarketEvent.MARKET_BUY,MarketEvent.CONSUMABLE,"",MarketEvent.SOURCE_NONE,_loc4_,_loc3_));
         };
      }
      
      private function generateManaAskFunc() : Function
      {
         return function(param1:String):void
         {
            ViralsManager.instance.sendFeedWithLotsOfFriction("ask_for_parts_mana",{});
         };
      }
      
      private function generateManaSpendFunc() : Function
      {
         return function(param1:String, param2:int):void
         {
            ZGlobal.player.mana.spend(param2);
         };
      }
      
      private function generateItemOwnedFunc() : Function
      {
         return function(param1:String):uint
         {
            return ZGlobal.player.getNumberOfInventoryItems(param1);
         };
      }
      
      private function generateItemRequiredFunc() : Function
      {
         return function(param1:String):uint
         {
            return getNumRequiredItem(param1);
         };
      }
      
      private function generateItemIconURLFunc() : Function
      {
         return function(param1:String):String
         {
            var _loc2_:* = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
            return ZGlobal.gameSettings.getImageByName(_loc2_.name,"icon");
         };
      }
      
      private function generateItemCostFunc() : Function
      {
         return function(param1:String, param2:int):int
         {
            var _loc3_:* = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
            return _loc3_.cash * param2;
         };
      }
      
      private function generateItemBuyFunc() : Function
      {
         return function(param1:String, param2:int):void
         {
            var _loc3_:* = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
            ZGlobal.player.buyGameItem(_loc3_,true,param2);
         };
      }
      
      private function generateItemAskFunc() : Function
      {
         return function(param1:String):void
         {
            var _loc2_:* = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
            var _loc3_:* = "titanlab_request_plating";
            ViralsManager.instance.sendFeedWithLotsOfFriction(_loc3_,{
               "itemCode":_loc2_.code,
               "resource":_loc2_.getFriendlyName(GameItem.MENU_FRIENDLYNAME)
            });
         };
      }
      
      private function generateItemSpendFunc() : Function
      {
         return function(param1:String, param2:int):void
         {
            ZGlobal.player.removeInventoryItem(param1,param2);
         };
      }
      
      private function buyRemainingRequirementCost(param1:uint) : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:Object = this.m_requirementData[param1];
         var _loc4_:uint = uint(_loc3_.ownedFunc(_loc3_.type));
         var _loc5_:uint = uint(_loc3_.requiredFunc(_loc3_.type));
         if(_loc4_ < _loc5_)
         {
            _loc2_ += _loc3_.costFunc(_loc3_.code,_loc5_ - _loc4_);
         }
         return _loc2_;
      }
      
      private function get buyAllRemainingRequirementsCost() : uint
      {
         var _loc1_:GameItem = null;
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         if(this.bypassAvailable)
         {
            _loc1_ = ZGlobal.gameSettings.getItemByCode(this.m_bypassCode,GameItem) as GameItem;
            return _loc1_.getModifiedCash(1);
         }
         _loc2_ = 0;
         _loc3_ = 0;
         while(_loc3_ < this.m_requirementData.length)
         {
            _loc2_ += this.buyRemainingRequirementCost(_loc3_);
            _loc3_++;
         }
         return _loc2_;
      }
   }
}

