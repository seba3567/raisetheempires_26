package displays.screens
{
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.gameobjects.GameItem;
   import core.gameobjects.SpeedupItem;
   import core.gameobjects.UnitItem;
   import core.managers.SuperOreManager;
   import core.managers.WorldResourceManager;
   import core.ui.GenericButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.zgamepopup.ZGamePopUp;
   import entity.GameDataComponent;
   import events.ProgressBarEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class SpeedupScreen extends ZGamePopUp
   {
      
      public static const CANCEL:String = "cancel";
      
      public static const FINISH:String = "finish";
      
      public static const SPEEDUP:String = "speedup";
      
      public static const EXIT:String = "exit";
      
      private static const ID:String = "SpeedupScreen";
      
      private var m_entity:IEntity = null;
      
      private var m_buildingFSMComponent:BuildingFSMComponent = null;
      
      private var m_buildingGameDataComponent:GameDataComponent = null;
      
      private var m_eventDispatcher:EventDispatcher = EventDispatcher(this.m_entity.eventDispatcher);
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_iconLoader:ImageLoader = null;
      
      protected var m_speedupBtn:GenericButton;
      
      protected var m_finishBtn:GenericButton;
      
      protected var m_cancelBtn:GenericButton;
      
      protected var m_item:GameItem = null;
      
      protected var m_speedupItem:SpeedupItem = null;
      
      protected var m_popup:GenericPopup = null;
      
      public function SpeedupScreen(param1:IEntity)
      {
         this.m_entity = param1;
         super(ZGlobal.getAssetURL(this.assetURL));
      }
      
      public static function display(param1:IEntity) : PopUpBase
      {
         var _loc2_:PopUpBase = new SpeedupScreen(param1);
         WindowManager.instance.push(_loc2_);
         return _loc2_;
      }
      
      private function get assetURL() : String
      {
         var _loc1_:BuildingFSMComponent = BuildingFSMComponent(this.m_entity.lookupComponentByType(BuildingFSMComponent));
         var _loc2_:String = BehaviorStateMachine(_loc1_.stateMachine).researchItemName;
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByName(_loc2_,UnitItem) as UnitItem;
         if(Boolean(_loc3_) && _loc3_.hasType(UnitItem.MEGA_UNIT))
         {
            return "assets/displays/screens/Titan_ResearchUpgradeInProgressScreen.swf";
         }
         return "assets/displays/screens/ResearchUpgradeInProgressScreen.swf";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc6_:String = null;
         var _loc9_:String = null;
         var _loc2_:Class = param1.getAssetClass("ResearchUpgradeInProgressScreen");
         m_window = new _loc2_();
         m_window["exit_bt"].addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(m_window["exit_bt"],ButtonSound.DEFAULT);
         this.m_eventDispatcher.addEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onProgress,false,0,true);
         this.m_eventDispatcher.addEventListener(ProgressBarEvent.STOP_PROGRESS_BAR,this.onProgressComplete,false,0,true);
         addChild(m_window);
         m_origOffsetX = m_window.x;
         m_origOffsetY = m_window.y;
         this.contentWidth = m_window["background_mc"].width;
         this.contentHeight = m_window["background_mc"].height;
         initDialog();
         this.m_buildingFSMComponent = BuildingFSMComponent(this.m_entity.lookupComponentByType(BuildingFSMComponent));
         var _loc3_:String = BehaviorStateMachine(this.m_buildingFSMComponent.stateMachine).referenceItemName;
         this.m_item = ZGlobal.gameSettings.getItemByName(_loc3_,GameItem) as GameItem;
         var _loc4_:String = this.m_item.speedupCode;
         if(_loc4_.length == 0)
         {
            this.m_speedupItem = new SpeedupItem(null);
         }
         else
         {
            this.m_speedupItem = ZGlobal.gameSettings.getItemByCode(this.m_item.speedupCode,SpeedupItem) as SpeedupItem;
         }
         var _loc5_:Number = BehaviorState(this.m_buildingFSMComponent.stateMachine.currentState).updateHelper.currentProgress;
         this.m_speedupItem.elapsedTime = BehaviorState(this.m_buildingFSMComponent.stateMachine.currentState).updateHelper.elapsedTime;
         this.m_speedupItem.duration = BehaviorState(this.m_buildingFSMComponent.stateMachine.currentState).updateHelper.actionDuration;
         this.m_buildingGameDataComponent = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
         var _loc7_:Boolean = this.m_buildingGameDataComponent.gameData.isResearchItem();
         this.m_cancelBtn = new GenericButton(m_window["cancel_bt"],this.onCancelClicked);
         _loc6_ = _loc7_ ? "SpeedupCancelUpgradeButtonText" : "SpeedupCancelContractButtonText";
         this.m_cancelBtn.text = ZGameUtils.ZlocT("Dialogs",_loc6_);
         this.m_buttonSounds.addButton(this.m_cancelBtn.m_overlay,ButtonSound.DEFAULT);
         this.m_speedupBtn = new GenericButton(m_window["speedup_bt"],this.onSpeedupClicked);
         this.m_speedupBtn.text = ZGameUtils.ZlocT("Dialogs","UpgradeSpeedupButtonText");
         this.m_buttonSounds.addButton(this.m_speedupBtn.m_overlay,ButtonSound.DEFAULT);
         TextFieldUtil.compactTextField(m_window["card_mc"].itemName_tf,this.m_item.getFriendlyName(GameItem.MENU_FRIENDLYNAME),{"minScale":0.7});
         var _loc8_:String = null;
         if(this.m_buildingGameDataComponent.gameData.isSuperOre())
         {
            _loc9_ = SuperOreManager.instance.getResourceName();
            if(_loc9_)
            {
               _loc8_ = WorldResourceManager.instance.getResourceImageURLByType(_loc9_);
            }
         }
         else
         {
            _loc8_ = ZGlobal.gameSettings.getImageByName(this.m_item.name,"icon",WorldResourceManager.XTRA_LARGE_ICON);
         }
         this.m_iconLoader = ImageLoaderFactory.CreateImageLoader(_loc8_,m_window["card_mc"].icon);
         this.m_iconLoader.smooth = true;
         _loc6_ = _loc7_ ? "SpeedupScreenUpgradeTitle" : "SpeedupScreenContractTitle";
         TextFieldUtil.processTextField(m_window["title_tf"],ZGameUtils.ZlocT("Dialogs",_loc6_));
         TextFieldUtil.processTextField(m_window["popupBox_tf"],ZGameUtils.ZlocT("Dialogs","SpeedupScreenSubtitle"));
         TextFieldUtil.processTextField(m_window["generic_03_tf"],ZGameUtils.ZlocT("Dialogs","SpeedupScreen_ConnectingText"));
         if(_loc7_)
         {
            if(this.m_buildingFSMComponent)
            {
               this.updateRequestText(_loc5_);
            }
         }
         else
         {
            TextFieldUtil.processTextField(m_window["generic_01_tf"],ZGameUtils.ZlocT("Dialogs","SpeedupScreen_SpeedupContractDescription"));
         }
         this.m_finishBtn = new GenericButton(m_window["finish_bt"],this.onFinishClicked);
         this.m_buttonSounds.addButton(this.m_finishBtn.m_overlay,ButtonSound.DEFAULT);
         this.updateFinishText(_loc5_);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function updateRequestText(param1:Number) : void
      {
         var _loc2_:Number = Number(ZGlobal.gameSettings.getXML().rewardSpeedupResearch.@percent);
         var _loc3_:Number = _loc2_ / 100;
         var _loc4_:Number = this.m_speedupItem.duration * _loc3_;
         _loc4_ = Math.ceil(_loc4_ / 1000);
         var _loc5_:Number = _loc4_ * 1000 / this.m_speedupItem.duration;
         var _loc6_:int = Math.ceil((1 - param1) / _loc5_);
         TextFieldUtil.processTextField(m_window["generic_01_tf"],ZGameUtils.ZlocT("Dialogs","SpeedupScreen_SpeedupResearchDescription",{
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
         TextFieldUtil.processTextField(m_window["generic_02_tf"],ZGameUtils.ZlocT("Dialogs",_loc4_,ZGameUtils.CashTokenReplacements(_loc2_)));
      }
      
      protected function onCancelClicked(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         m_window.visible = false;
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
         this.m_eventDispatcher.dispatchEvent(new Event(EXIT));
      }
      
      protected function onSpeedupClicked(param1:MouseEvent) : void
      {
         this.close();
         this.m_eventDispatcher.dispatchEvent(new Event(SPEEDUP));
      }
      
      protected function onFinishClicked(param1:MouseEvent) : void
      {
         var _loc3_:GameDataComponent = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc2_:int = this.m_speedupItem.cash;
         if(ZGlobal.gameSettings.showConfirmationPopup(_loc2_))
         {
            m_window.visible = false;
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
            m_window.visible = true;
         }
      }
      
      private function onCancelPopupClose(param1:GenericPopupEvent) : void
      {
         this.m_popup = null;
         if(param1.button == GenericPopup.CANCEL)
         {
            this.close();
            this.m_eventDispatcher.dispatchEvent(new Event(CANCEL));
         }
         else
         {
            m_window.visible = true;
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
            this.m_eventDispatcher.dispatchEvent(new WorldEvent(FINISH,this.m_speedupItem));
         }
      }
      
      protected function onProgress(param1:ProgressBarEvent) : void
      {
         TextFieldUtil.processTextField(m_window["card_mc"].countdown_tf,param1.timeRemaining);
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
         this.m_eventDispatcher.dispatchEvent(new Event(EXIT));
      }
      
      protected function onProgressComplete(param1:ProgressBarEvent) : void
      {
         this.forceClose();
      }
      
      override protected function close(param1:Event = null) : void
      {
         m_window["exit_bt"].removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         this.m_eventDispatcher.removeEventListener(ProgressBarEvent.UPDATE_PROGRESS,this.onProgress);
         this.m_eventDispatcher.removeEventListener(ProgressBarEvent.STOP_PROGRESS_BAR,this.onProgressComplete);
         super.close();
      }
      
      public function dispose() : void
      {
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_speedupItem = null;
      }
   }
}

