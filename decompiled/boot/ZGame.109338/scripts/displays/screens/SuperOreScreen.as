package displays.screens
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.gameobjects.GameItem;
   import core.gameobjects.SpeedupItem;
   import core.managers.ExperimentsManager;
   import core.managers.SuperOreManager;
   import core.managers.WorldObjectManager;
   import core.managers.WorldResourceManager;
   import core.ui.GenericButton;
   import core.ui.UIManager;
   import core.ui.menuitem.PlayerStatsUIItem;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.contractScreen.ContractSlot;
   import displays.screens.contractScreen.SuperOreContractGrid;
   import displays.screens.partsGather.PartsGatherGrid;
   import entity.GameDataComponent;
   import events.CloseEvent;
   import events.MarketEvent;
   import events.ProgressBarEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class SuperOreScreen extends ZGamePopUp
   {
      
      public static const CONTRACT_SELECTED:String = "contractSelected";
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var m_entity:IEntity = null;
      
      protected var m_tabData:Array = null;
      
      protected var m_itemCode:String = null;
      
      protected var m_PartsWindow:MovieClip = null;
      
      protected var m_speedupWindow:MovieClip = null;
      
      protected var m_currentTab:uint = 0;
      
      protected var m_currentMul:int = 0;
      
      protected var m_partsWindow:Object;
      
      protected var m_resource:SWFResource;
      
      protected var m_type:String = null;
      
      private var m_mulCallback:Function = null;
      
      protected var m_speedup:Boolean = false;
      
      protected var m_speedupBtn:GenericButton;
      
      protected var m_finishBtn:GenericButton;
      
      protected var m_cancelBtn:GenericButton;
      
      protected var m_item:GameItem = null;
      
      protected var m_speedupItem:SpeedupItem = null;
      
      private var m_buildingFSMComponent:BuildingFSMComponent = null;
      
      private var m_buildingGameDataComponent:GameDataComponent = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_popup:GenericPopup = null;
      
      protected var m_tooltip:AssetGroupTooltip;
      
      public function SuperOreScreen(param1:EventDispatcher, param2:String, param3:IEntity, param4:Function, param5:String = "", param6:int = 0, param7:Boolean = false)
      {
         this.m_eventDispatcher = param1;
         this.m_entity = param3;
         this.m_itemCode = param2;
         this.m_type = param5;
         this.m_currentMul = param6;
         this.m_mulCallback = param4;
         this.m_speedup = param7;
         super(ZGlobal.getAssetURL("assets/displays/screens/OreMine.swf"));
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:IEntity, param4:Function = null, param5:String = "", param6:int = 0, param7:Boolean = false) : PopUpBase
      {
         var _loc8_:PopUpBase = new SuperOreScreen(param1,param2,param3,param4,param5,param6,param7);
         WindowManager.instance.push(_loc8_);
         return _loc8_;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         this.m_resource = param1;
         super.onLoadComplete(param1);
         var _loc2_:Class = param1.getAssetClass("PartsDialog");
         m_window = new _loc2_();
         contentWidth = m_window.width;
         contentHeight = m_window.height;
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitButtonClick,false,0,true);
         this.m_speedupWindow = m_window.inProgres_mc;
         this.initTabs(m_window);
         if(!this.m_speedup)
         {
            this.m_speedupWindow.visible = false;
            m_window.parts_mc.exit_bt = m_window.exit_bt;
            this.setupDialog();
         }
         else
         {
            this.m_speedupWindow.visible = true;
            m_window.parts_mc.visible = false;
            m_window.contracts_mc.visible = false;
            this.speedup();
         }
         addChild(m_window);
         m_origOffsetX = m_window.x;
         m_origOffsetY = m_window.y;
         centerWithinStage(Zlab.mainStage);
         TextFieldUtil.compactTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs","SuperOreMine_Title"));
         UIDispatcher.instance.addEventListener(PartsGatherGrid.FINISHED,this.onFinished,false,0,true);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(WindowManager.instance.container,0);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(true);
         dispatchEvent(new Event(Event.COMPLETE));
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(WindowManager.instance.container,0);
      }
      
      private function initTabs(param1:MovieClip) : void
      {
         var _loc3_:String = null;
         var _loc4_:MovieClip = null;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         this.m_tabData = [{
            "tabClip":param1.tab01_mc,
            "text":ZGameUtils.ZlocT("Items","aluminum_menuName"),
            "type":"aluminum"
         },{
            "tabClip":param1.tab02_mc,
            "text":ZGameUtils.ZlocT("Items","copper_menuName"),
            "type":"copper"
         },{
            "tabClip":param1.tab03_mc,
            "text":ZGameUtils.ZlocT("Items","gold_menuName"),
            "type":"gold"
         },{
            "tabClip":param1.tab04_mc,
            "text":ZGameUtils.ZlocT("Items","iron_menuName"),
            "type":"iron"
         }];
         var _loc2_:Array = SuperOreManager.instance.resourceOrder;
         var _loc5_:int = 0;
         while(_loc5_ < _loc2_.length)
         {
            _loc6_ = this.m_tabData[_loc5_];
            _loc3_ = _loc2_[_loc5_];
            _loc4_ = _loc6_.tabClip as MovieClip;
            _loc6_.text = ZGameUtils.ZlocT("Items",_loc3_ + "_menuName");
            TextFieldUtil.compactTextField(_loc6_.tabClip.name_tf,_loc6_.text);
            _loc6_.type = _loc3_;
            _loc7_ = WorldResourceManager.instance.getResourceImageURLByType(_loc3_,WorldResourceManager.MEDIUM_ICON);
            ImageLoaderFactory.CreateImageLoader(_loc7_,_loc4_.icon);
            if(!ZGlobal.player.hasResourceUnlock(_loc3_))
            {
               _loc4_.gotoAndStop(_loc4_.totalFrames);
               TextFieldUtil.compactTextField(_loc4_.status_tf,ZGameUtils.ZlocT("Gifts","locked"));
            }
            else
            {
               _loc4_.gotoAndStop(2);
               _loc4_.status_tf.visible = false;
               _loc6_.tabClip.addEventListener(MouseEvent.MOUSE_OUT,this.onTabOut,false,0,true);
               _loc6_.tabClip.addEventListener(MouseEvent.MOUSE_OVER,this.onTabOver,false,0,true);
               _loc6_.tabClip.addEventListener(MouseEvent.CLICK,this.onTabClick,false,0,true);
               if(this.m_type != "" && this.m_type == _loc3_)
               {
                  this.m_currentTab = _loc5_;
               }
            }
            _loc5_++;
         }
         if(this.m_type == "")
         {
            this.m_currentTab = 0;
         }
         this.currentTab = this.m_currentTab;
      }
      
      private function onTabOut(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         var _loc3_:uint = 0;
         while(_loc3_ < this.m_tabData.length)
         {
            if(this.m_tabData[_loc3_].tabClip == _loc2_)
            {
               break;
            }
            _loc3_++;
         }
         if(_loc3_ != this.currentTab)
         {
            _loc2_.gotoAndStop(2);
         }
      }
      
      private function onTabOver(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         var _loc3_:uint = 0;
         while(_loc3_ < this.m_tabData.length)
         {
            if(this.m_tabData[_loc3_].tabClip == _loc2_)
            {
               break;
            }
            _loc3_++;
         }
         if(_loc3_ != this.currentTab)
         {
            _loc2_.gotoAndStop(3);
         }
      }
      
      private function onTabClick(param1:MouseEvent) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:MovieClip = param1.currentTarget as MovieClip;
         _loc2_ = 0;
         while(_loc2_ < this.m_tabData.length)
         {
            if(this.m_tabData[_loc2_].tabClip == _loc3_)
            {
               break;
            }
            _loc2_++;
         }
         if(_loc2_ != this.m_currentTab && _loc2_ != this.m_tabData.length)
         {
            this.currentTab = _loc2_;
         }
      }
      
      private function setupDialog() : void
      {
         var _loc1_:String = this.m_tabData[this.m_currentTab].type;
         this.currentTab = this.m_currentTab;
      }
      
      private function set currentTab(param1:uint) : void
      {
         var _loc2_:String = this.m_tabData[param1].type;
         this.m_tabData[this.m_currentTab].tabClip.gotoAndPlay(2);
         this.m_tabData[param1].tabClip.gotoAndPlay(4);
         this.m_currentTab = param1;
         this.multiplier = ZGlobal.player.currentResourceMultiplier(_loc2_) - 1;
         if(ZGlobal.player.hasResourceUnlock(_loc2_,1) && !this.m_speedup)
         {
            m_window.parts_mc.visible = false;
            m_window.inProgres_mc.visible = false;
            this.setupContractGrid(_loc2_);
            m_window.contracts_mc.visible = true;
         }
         else if(_loc2_ == this.m_type && this.m_speedup)
         {
            m_window.parts_mc.visible = false;
            m_window.inProgres_mc.visible = true;
            m_window.contracts_mc.visible = false;
            this.speedup();
         }
         else if(!this.m_speedup)
         {
            m_window.contracts_mc.visible = false;
            m_window.inProgres_mc.visible = false;
            this.setupPartsGrid(_loc2_);
            m_window.parts_mc.visible = true;
         }
      }
      
      private function set multiplier(param1:int) : void
      {
         this.m_currentMul = param1;
         if(this.m_mulCallback != null)
         {
            this.m_mulCallback(this.m_currentMul + 1);
         }
      }
      
      private function get currentTab() : uint
      {
         return this.m_currentTab;
      }
      
      private function setupPartsGrid(param1:String) : void
      {
         this.m_partsWindow = new PartsGatherGrid(m_window.parts_mc,this.m_itemCode,param1);
         this.m_partsWindow.setTitleText(ZGameUtils.ZlocT("Dialogs","SuperOreMineParts_Title",{"type":this.m_tabData[this.currentTab].text}));
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","SuperOreMine_Body",{"type":ZGameUtils.ZlocT("Items",param1 + "_menuName")});
         this.m_partsWindow.setDescriptionText(_loc2_);
         this.m_partsWindow.loadUnitCardIcon(WorldResourceManager.instance.getResourceImageURLByType(param1,WorldResourceManager.LARGE_ICON));
      }
      
      private function setupContractGrid(param1:String) : void
      {
         TextFieldUtil.compactTextField(m_window.contracts_mc.title_tf,ZGameUtils.ZlocT("Dialogs","SuperOreMineUnlock_Title"));
         TextFieldUtil.compactTextField(m_window.contracts_mc.description_tf,ZGameUtils.ZlocT("Dialogs","SuperOreMine_Multiplier_Body"),{"minScale":1});
         var _loc2_:String = WorldResourceManager.instance.getResourceImageURLByType(param1,WorldResourceManager.LARGE_ICON);
         ImageLoaderFactory.CreateImageLoader(_loc2_,m_window.contracts_mc.icon);
         this.m_eventDispatcher.addEventListener(ContractSlot.CONTRACT_SLOT_PURCHASE,this.onContractSelected,false,0,true);
         this.m_partsWindow = new SuperOreContractGrid(m_window.contracts_mc,this.m_resource,this.m_eventDispatcher,this.m_entity,"OreMineContract","contract",param1,this.m_currentMul + 1);
         this.setupMultipliers(param1);
      }
      
      private function setupMultipliers(param1:String) : void
      {
         this.clearMulTabs();
         var _loc2_:MovieClip = m_window.contracts_mc;
         var _loc3_:int = ZGlobal.player.currentResourceMultiplier(param1);
         var _loc4_:uint = 0;
         while(_loc4_ < 6)
         {
            TextFieldUtil.compactTextField(_loc2_["x" + (_loc4_ + 1) + "_bt"].generic_tf,"x" + (_loc4_ + 1));
            if(_loc4_ > _loc3_)
            {
               _loc2_["x" + (_loc4_ + 1) + "_bt"].gotoAndStop(5);
               TextFieldUtil.compactTextField(_loc2_["x" + (_loc4_ + 1) + "_bt"].generic_tf,"x" + (_loc4_ + 1));
            }
            else
            {
               _loc2_["x" + (_loc4_ + 1) + "_bt"].gotoAndStop(6);
               if(!ZGlobal.player.hasResourceUnlock(param1,_loc4_ + 1))
               {
                  _loc2_["x" + (_loc4_ + 1) + "_bt"].gotoAndStop(2);
               }
               TextFieldUtil.compactTextField(_loc2_["x" + (_loc4_ + 1) + "_bt"].generic_tf,"x" + (_loc4_ + 1));
               _loc2_["x" + (_loc4_ + 1) + "_bt"].buttonMode = true;
               _loc2_["x" + (_loc4_ + 1) + "_bt"].addEventListener(MouseEvent.MOUSE_OUT,this.onMulTabOut,false,0,true);
               _loc2_["x" + (_loc4_ + 1) + "_bt"].addEventListener(MouseEvent.MOUSE_OVER,this.onMulTabOver,false,0,true);
               _loc2_["x" + (_loc4_ + 1) + "_bt"].addEventListener(MouseEvent.CLICK,this.onMulTabClick,false,0,true);
            }
            _loc4_++;
         }
      }
      
      public function isMultiplierLocked(param1:String, param2:uint) : Boolean
      {
         var _loc3_:Number = ExperimentsManager.instance.getExperimentVariant("empire_superore_multiplier_unlock");
         if(_loc3_ >= 3 || ZGlobal.player.hasResourceUnlock(param1,param2))
         {
            return true;
         }
         return false;
      }
      
      private function onMulTabOut(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         var _loc3_:uint = uint(this.currentMultTab(_loc2_));
         var _loc4_:MovieClip = m_window.contracts_mc;
         if(!ZGlobal.player.hasResourceUnlock(this.m_tabData[this.currentTab].type,_loc3_) && _loc3_ != this.m_currentMul)
         {
            _loc2_.gotoAndStop(2);
            TextFieldUtil.compactTextField(_loc4_["x" + (_loc3_ + 1) + "_bt"].generic_tf,"x" + (_loc3_ + 1));
         }
         if(Boolean(this.m_tooltip) && _loc2_.contains(this.m_tooltip))
         {
            _loc2_.removeChild(this.m_tooltip);
         }
         this.m_tooltip = null;
      }
      
      private function onMulTabOver(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         var _loc3_:uint = uint(this.currentMultTab(_loc2_));
         var _loc4_:MovieClip = m_window.contracts_mc;
         if(ZGlobal.player.hasResourceUnlock(this.m_tabData[this.currentTab].type,_loc3_) && _loc3_ != this.m_currentMul)
         {
            if(!ZGlobal.player.hasResourceUnlock(this.m_tabData[this.currentTab].type,_loc3_ + 1))
            {
               _loc2_.gotoAndStop(3);
               TextFieldUtil.compactTextField(_loc4_["x" + (_loc3_ + 1) + "_bt"].generic_tf,"x" + (_loc3_ + 1));
            }
         }
         var _loc5_:GameItem = ZGlobal.gameSettings.getItemByCode(this.m_itemCode,GameItem) as GameItem;
         this.m_tooltip = new AssetGroupTooltip();
         this.m_tooltip.gotoAndStop("1");
         var _loc6_:String = ZGameUtils.ZlocT("Items",this.m_tabData[this.currentTab].type + "_menuName");
         var _loc7_:String = ZGameUtils.ZlocT("Dialogs","SuperOreMine_Multiplier_Title",{
            "type":_loc6_,
            "multiplier":_loc3_ + 1
         });
         TextFieldUtil.compactTextField(this.m_tooltip.description_tf,_loc7_,{"minScale":2});
         this.m_tooltip.x = param1.currentTarget.mouseX;
         this.m_tooltip.y = param1.currentTarget.mouseY;
         this.m_tooltip.alpha = 0;
         TweenLite.to(this.m_tooltip,0.5,{"alpha":1});
         _loc2_.addChild(this.m_tooltip);
      }
      
      private function onMulTabClick(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         var _loc3_:uint = uint(this.currentMultTab(_loc2_));
         if(_loc3_ >= ZGlobal.player.currentResourceMultiplier(this.m_tabData[this.currentTab].type))
         {
            this.onExitButtonClick(null);
            SuperOreMultipler.display(this.m_eventDispatcher,this.m_itemCode,this.m_entity,this.m_tabData[this.currentTab].type,_loc3_ + 1);
         }
      }
      
      private function currentMultTab(param1:MovieClip) : int
      {
         var _loc2_:MovieClip = m_window.contracts_mc;
         var _loc3_:uint = 0;
         while(_loc3_ < 6)
         {
            if(_loc2_["x" + (_loc3_ + 1) + "_bt"] == param1)
            {
               break;
            }
            _loc3_++;
         }
         return _loc3_;
      }
      
      public function updateMultiplierContracts() : void
      {
         this.m_partsWindow = null;
         this.setupContractGrid(this.m_tabData[this.m_currentTab].type);
      }
      
      public function onFinished(param1:WorldEvent) : void
      {
         if(this.m_currentMul < 1)
         {
            ZGlobal.player.unlockResource(param1.eventData.type,1);
            this.multiplier = 0;
         }
         m_window.parts_mc.visible = false;
         this.setupContractGrid(param1.eventData.type);
         m_window.contracts_mc.visible = true;
      }
      
      public function onContractSelected(param1:WorldEvent) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         this.m_eventDispatcher.removeEventListener(ContractSlot.CONTRACT_SLOT_PURCHASE,this.onContractSelected);
         var _loc2_:GameItem = param1.eventData as GameItem;
         if(_loc2_)
         {
            _loc3_ = false;
            _loc4_ = false;
            if(_loc2_.usesCashOnly())
            {
               _loc3_ = ZGlobal.player.canBuyCash(_loc2_.cash,true);
               _loc4_ = !_loc3_;
            }
            else
            {
               _loc3_ = ZGlobal.player.canBuy(_loc2_,true);
            }
            if(_loc3_)
            {
               this.m_type = this.m_tabData[this.m_currentTab].type;
               dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY,MarketEvent.CONTRACT,_loc2_.name,MarketEvent.SOURCE_NONE));
               WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.ITEM_PURCHASED,_loc2_.code));
               this.m_eventDispatcher.dispatchEvent(new WorldEvent(CONTRACT_SELECTED,_loc2_));
               this.closeWindow(null);
            }
            else if(_loc4_)
            {
               this.closeWindow(null);
            }
            else
            {
               this.closeWindow(null);
            }
         }
      }
      
      protected function onExitButtonClick(param1:MouseEvent) : void
      {
         this.closeWindow(param1);
         if(this.m_speedup)
         {
            this.onExitClicked(param1);
         }
         this.m_eventDispatcher.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
      }
      
      protected function clearMulTabs() : void
      {
         var _loc1_:uint = 0;
         var _loc3_:MovieClip = null;
         var _loc2_:MovieClip = m_window.contracts_mc;
         _loc1_ = 0;
         while(_loc1_ < 6)
         {
            _loc3_ = _loc2_["x" + (_loc1_ + 1) + "_bt"];
            if(_loc3_.hasEventListener(MouseEvent.MOUSE_OUT))
            {
               _loc3_.removeEventListener(MouseEvent.MOUSE_OUT,this.onMulTabOut);
            }
            if(_loc3_.hasEventListener(MouseEvent.MOUSE_OVER))
            {
               _loc3_.removeEventListener(MouseEvent.MOUSE_OVER,this.onMulTabOver);
            }
            if(_loc3_.hasEventListener(MouseEvent.CLICK))
            {
               _loc3_.removeEventListener(MouseEvent.CLICK,this.onMulTabClick);
            }
            _loc1_++;
         }
      }
      
      protected function closeWindow(param1:MouseEvent) : void
      {
         var _loc3_:MovieClip = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         var _loc2_:uint = 0;
         _loc2_ = 0;
         while(_loc2_ < this.m_tabData.length)
         {
            _loc3_ = this.m_tabData[_loc2_].tabClip;
            if(_loc3_.hasEventListener(MouseEvent.MOUSE_OUT))
            {
               _loc3_.removeEventListener(MouseEvent.MOUSE_OUT,this.onTabOut);
            }
            if(_loc3_.hasEventListener(MouseEvent.MOUSE_OVER))
            {
               _loc3_.removeEventListener(MouseEvent.MOUSE_OVER,this.onTabOver);
            }
            if(_loc3_.hasEventListener(MouseEvent.CLICK))
            {
               _loc3_.removeEventListener(MouseEvent.CLICK,this.onTabClick);
            }
            _loc2_++;
         }
         var _loc4_:MovieClip = m_window.contracts_mc;
         _loc2_ = 0;
         while(_loc2_ < 6)
         {
            _loc3_ = _loc4_["x" + (_loc2_ + 1) + "_bt"];
            if(_loc3_.hasEventListener(MouseEvent.MOUSE_OUT))
            {
               _loc3_.removeEventListener(MouseEvent.MOUSE_OUT,this.onMulTabOut);
            }
            if(_loc3_.hasEventListener(MouseEvent.MOUSE_OVER))
            {
               _loc3_.removeEventListener(MouseEvent.MOUSE_OVER,this.onMulTabOver);
            }
            if(_loc3_.hasEventListener(MouseEvent.CLICK))
            {
               _loc3_.removeEventListener(MouseEvent.CLICK,this.onMulTabClick);
            }
            _loc2_++;
         }
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitButtonClick);
         UIDispatcher.instance.removeEventListener(PartsGatherGrid.FINISHED,this.onFinished);
         this.m_eventDispatcher.removeEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onProgress);
         this.m_eventDispatcher.removeEventListener(ProgressBarEvent.STOP_PROGRESS_BAR,this.onProgressComplete);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(false);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(UIManager.instance.uiDisplay,0);
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(false);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(UIManager.instance.uiDisplay,0);
         super.close();
      }
      
      private function speedup() : void
      {
         var _loc8_:String = null;
         this.m_eventDispatcher.addEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onProgress,false,0,true);
         this.m_eventDispatcher.addEventListener(ProgressBarEvent.STOP_PROGRESS_BAR,this.onProgressComplete,false,0,true);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buildingFSMComponent = BuildingFSMComponent(this.m_entity.lookupComponentByType(BuildingFSMComponent));
         var _loc1_:String = BehaviorStateMachine(this.m_buildingFSMComponent.stateMachine).referenceItemName;
         this.m_item = ZGlobal.gameSettings.getItemByName(_loc1_,GameItem) as GameItem;
         var _loc2_:String = this.m_item.speedupCode;
         if(_loc2_.length == 0)
         {
            this.m_speedupItem = new SpeedupItem(null);
         }
         else
         {
            this.m_speedupItem = ZGlobal.gameSettings.getItemByCode(this.m_item.speedupCode,SpeedupItem) as SpeedupItem;
         }
         var _loc3_:Number = BehaviorState(this.m_buildingFSMComponent.stateMachine.currentState).updateHelper.currentProgress;
         this.m_speedupItem.elapsedTime = BehaviorState(this.m_buildingFSMComponent.stateMachine.currentState).updateHelper.elapsedTime;
         this.m_speedupItem.duration = BehaviorState(this.m_buildingFSMComponent.stateMachine.currentState).updateHelper.actionDuration;
         this.m_buildingGameDataComponent = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
         this.m_cancelBtn = new GenericButton(this.m_speedupWindow["cancel_bt"],this.onCancelClicked);
         this.m_cancelBtn.text = ZGameUtils.ZlocT("Dialogs","SpeedupCancelContractButtonText");
         this.m_buttonSounds.addButton(this.m_cancelBtn.m_overlay,ButtonSound.DEFAULT);
         this.m_speedupBtn = new GenericButton(this.m_speedupWindow["speedup_bt"],this.onSpeedupClicked);
         this.m_speedupBtn.text = ZGameUtils.ZlocT("Dialogs","UpgradeSpeedupButtonText");
         this.m_buttonSounds.addButton(this.m_speedupBtn.m_overlay,ButtonSound.DEFAULT);
         TextFieldUtil.compactTextField(this.m_speedupWindow["card_mc"].itemName_tf,this.m_item.getFriendlyName(GameItem.MENU_FRIENDLYNAME),{"minScale":0.7});
         var _loc4_:String = null;
         if(this.m_buildingGameDataComponent.gameData.isSuperOre())
         {
            _loc8_ = BehaviorStateMachine(this.m_buildingFSMComponent.stateMachine).resourceType;
            if(_loc8_)
            {
               _loc4_ = WorldResourceManager.instance.getResourceImageURLByType(_loc8_,WorldResourceManager.XTRA_LARGE_ICON);
            }
         }
         else
         {
            _loc4_ = ZGlobal.gameSettings.getImageByName(this.m_item.name,"icon",WorldResourceManager.XTRA_LARGE_ICON);
         }
         var _loc5_:ImageLoader = ImageLoaderFactory.CreateImageLoader(_loc4_,this.m_speedupWindow["card_mc"].icon);
         _loc5_.smooth = true;
         TextFieldUtil.compactTextField(this.m_speedupWindow["title_tf"],ZGameUtils.ZlocT("Dialogs","SpeedupScreenContractTitle"));
         TextFieldUtil.compactTextField(this.m_speedupWindow["popupBox_tf"],ZGameUtils.ZlocT("Dialogs","SpeedupScreenSubtitle"));
         TextFieldUtil.compactTextField(this.m_speedupWindow["generic_03_tf"],ZGameUtils.ZlocT("Dialogs","SpeedupScreen_ConnectingText"));
         TextFieldUtil.compactTextField(this.m_speedupWindow["generic_01_tf"],ZGameUtils.ZlocT("Dialogs","SpeedupScreen_SpeedupContractDescription"));
         this.m_finishBtn = new GenericButton(this.m_speedupWindow["finish_bt"],this.onFinishClicked);
         this.m_buttonSounds.addButton(this.m_finishBtn.m_overlay,ButtonSound.DEFAULT);
         this.m_speedupItem.elapsedTime = BehaviorState(this.m_buildingFSMComponent.stateMachine.currentState).updateHelper.elapsedTime;
         var _loc6_:int = this.m_speedupItem.cash;
         this.m_finishBtn.text = ZGameUtils.ZlocT("Dialogs","SpeedupFinishButtonText",{"amount":_loc6_});
         var _loc7_:String = "SpeedupScreen_FinishContractDescription";
         TextFieldUtil.compactTextField(this.m_speedupWindow["generic_02_tf"],ZGameUtils.ZlocT("Dialogs",_loc7_,ZGameUtils.CashTokenReplacements(_loc6_)));
      }
      
      private function updateRequestText(param1:Number) : void
      {
         var _loc2_:Number = Number(ZGlobal.gameSettings.getXML().rewardSpeedupResearch.@percent);
         var _loc3_:Number = _loc2_ / 100;
         var _loc4_:Number = this.m_speedupItem.duration * _loc3_;
         _loc4_ = Math.ceil(_loc4_ / 1000);
         var _loc5_:Number = _loc4_ * 1000 / this.m_speedupItem.duration;
         var _loc6_:int = Math.ceil((1 - param1) / _loc5_);
         TextFieldUtil.compactTextField(this.m_speedupWindow["generic_01_tf"],ZGameUtils.ZlocT("Dialogs","SpeedupScreen_SpeedupResearchDescription",{
            "num":_loc6_,
            "friend":ZGameUtils.ZlocTk("Objects","friend","",_loc6_)
         }));
      }
      
      private function updateFinishText(param1:Number) : void
      {
         this.m_speedupItem.elapsedTime = BehaviorState(this.m_buildingFSMComponent.stateMachine.currentState).updateHelper.elapsedTime;
         var _loc2_:int = this.m_speedupItem.cash;
         this.m_finishBtn.text = ZGameUtils.ZlocT("Dialogs","SpeedupFinishButtonText",{"amount":_loc2_});
         var _loc3_:Boolean = this.m_buildingGameDataComponent.gameData.isResearchItem();
         var _loc4_:String = _loc3_ ? "SpeedupScreen_FinishUpgradeDescription" : "SpeedupScreen_FinishContractDescription";
         TextFieldUtil.compactTextField(this.m_speedupWindow["generic_02_tf"],ZGameUtils.ZlocT("Dialogs",_loc4_,ZGameUtils.CashTokenReplacements(_loc2_)));
      }
      
      protected function onCancelClicked(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         this.m_speedupWindow.visible = false;
         var _loc2_:GameDataComponent = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
         if(_loc2_.gameData.isResearchItem())
         {
            _loc3_ = "SpeedupScreen_ResearchCancelConfirm";
         }
         else if(_loc2_.gameData.subType == "military")
         {
            _loc3_ = "SpeedupScreen_UnitsCancelConfirm";
         }
         else
         {
            _loc3_ = "SpeedupScreen_CancelConfirm";
         }
         var _loc4_:String = ZGameUtils.ZlocT("Dialogs",_loc3_);
         this.m_popup = GenericPopup2B.NewAcceptCancel(_loc4_,null,this.onCancelPopupClose);
         this.m_popup.setAcceptTextName("SpeedupScreen_CancelAccept");
         this.m_popup.setCancelTextName("SpeedupScreen_CancelCancel");
         this.m_popup.setAdvisorMood(GenericPopup.MOOD_DEFAULT);
         PopupManager.instance.push(this.m_popup);
      }
      
      protected function onExitClicked(param1:MouseEvent) : void
      {
         this.close();
         this.m_eventDispatcher.dispatchEvent(new Event(SpeedupScreen.EXIT));
      }
      
      protected function onSpeedupClicked(param1:MouseEvent) : void
      {
         this.close();
         this.m_eventDispatcher.dispatchEvent(new Event(SpeedupScreen.SPEEDUP));
      }
      
      protected function onFinishClicked(param1:MouseEvent) : void
      {
         var _loc3_:GameDataComponent = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc2_:int = this.m_speedupItem.cash;
         if(ZGlobal.gameSettings.showConfirmationPopup(_loc2_))
         {
            this.m_speedupWindow.visible = false;
            _loc3_ = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
            if(_loc3_.gameData.isResearchItem())
            {
               _loc4_ = "SpeedupScreen_ResearchFinishConfirm";
            }
            else if(_loc3_.gameData.subType == "military")
            {
               _loc4_ = "SpeedupScreen_UnitsFinishConfirm";
            }
            else
            {
               _loc4_ = "SpeedupScreen_FinishConfirm";
            }
            _loc5_ = ZGameUtils.ZlocT("Dialogs",_loc4_,ZGameUtils.CashTokenReplacements(_loc2_));
            this.m_popup = GenericPopup2B.NewAcceptCancel(_loc5_,null,this.onPopupClose);
            PopupManager.instance.push(this.m_popup);
         }
         else
         {
            this.buySpeedup();
         }
      }
      
      protected function onPopupClose(param1:GenericPopupEvent) : void
      {
         this.m_popup = null;
         if(param1.button == GenericPopup.OK)
         {
            this.buySpeedup();
         }
         else
         {
            this.m_speedupWindow.visible = true;
         }
      }
      
      private function onCancelPopupClose(param1:GenericPopupEvent) : void
      {
         this.m_popup = null;
         if(param1.button == GenericPopup.CANCEL)
         {
            this.close();
            this.m_eventDispatcher.dispatchEvent(new Event(SpeedupScreen.CANCEL));
         }
         else
         {
            this.m_speedupWindow.visible = true;
         }
      }
      
      private function buySpeedup() : void
      {
         var _loc1_:BuildingFSMComponent = BuildingFSMComponent(this.m_entity.lookupComponentByType(BuildingFSMComponent));
         this.m_speedupItem.elapsedTime = BehaviorState(_loc1_.stateMachine.currentState).updateHelper.elapsedTime;
         this.m_speedupItem.duration = BehaviorState(_loc1_.stateMachine.currentState).updateHelper.actionDuration;
         if(ZGlobal.player.canBuyCash(this.m_speedupItem.cash,true,ZGameUtils.ZlocT("Dialogs","ImpulseCashContract")))
         {
            this.close();
            this.m_eventDispatcher.dispatchEvent(new WorldEvent(SpeedupScreen.FINISH,this.m_speedupItem));
         }
      }
      
      protected function onProgress(param1:ProgressBarEvent) : void
      {
         TextFieldUtil.compactTextField(this.m_speedupWindow["card_mc"].countdown_tf,param1.timeRemaining);
         var _loc2_:GameDataComponent = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
         if(_loc2_.gameData.isResearchItem())
         {
            this.updateRequestText(param1.progress);
            this.updateFinishText(param1.progress);
         }
      }
      
      override public function forceClose() : void
      {
         if(this.m_popup)
         {
            this.m_popup.closeWindow();
            this.m_popup = null;
         }
         this.close();
         this.m_eventDispatcher.dispatchEvent(new Event(SpeedupScreen.EXIT));
      }
      
      protected function onProgressComplete(param1:ProgressBarEvent) : void
      {
         this.forceClose();
      }
   }
}

