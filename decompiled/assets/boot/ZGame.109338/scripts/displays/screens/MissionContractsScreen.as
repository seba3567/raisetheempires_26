package displays.screens
{
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gamemode.mission.GMDeployMission;
   import core.gameobjects.GameItem;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.GenericButton;
   import core.ui.UIManager;
   import core.ui.menuitem.PlayerStatsUIItem;
   import dispatchers.ExperienceDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GenericPopup;
   import displays.popups.MissionCompletePopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.contractScreen.MissionContractGrid;
   import displays.screens.contractScreen.MissionContractSlot;
   import displays.screens.gridScreen.GridSlot;
   import displays.screens.partsGather.MissionPartsGather;
   import entity.GameDataComponent;
   import events.ExperienceUpdatedEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.popups.IWindow;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class MissionContractsScreen extends ZGamePopUp
   {
      
      public static const EXIT:String = "exit";
      
      private static const ID:String = "MissionContractsScreen";
      
      public static const SHOW_MISSIONCONTRACTS_DIALOG:String = "showMissionContractsScreen";
      
      private var m_unitsGrid:MissionContractGrid = null;
      
      protected var m_type:String = "Buildable";
      
      private var m_subtype:String = null;
      
      protected var m_entity:IEntity = null;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_buildingIconLoader:ImageLoader = null;
      
      protected var m_confirm:GenericButton;
      
      protected var m_cancel:GenericButton;
      
      protected var m_useSavedPageNum:Boolean = false;
      
      public function MissionContractsScreen(param1:EventDispatcher, param2:String, param3:IEntity, param4:Boolean)
      {
         this.m_subtype = param2;
         this.m_eventDispatcher = param1;
         this.m_entity = param3;
         this.m_useSavedPageNum = param4;
         super(ZGlobal.getAssetURL("assets/displays/screens/SpecialForcesSelectionScreen.swf"));
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:IEntity, param4:Boolean = true) : IWindow
      {
         var _loc5_:IWindow = new MissionContractsScreen(param1,param2,param3,param4);
         WindowManager.instance.push(_loc5_);
         return _loc5_;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:Class = param1.getAssetClass("UnitsScreen");
         m_window = new _loc2_();
         this.m_unitsGrid = new MissionContractGrid(m_window["GridDialog_mc"].upperGrid_mc,param1,this.m_type,this.m_subtype,this.m_useSavedPageNum);
         TextFieldUtil.processTextField(m_window["GridDialog_mc"].upperGrid_mc.description_tf,ZGameUtils.ZlocT("Dialogs","MissionSelectionSubtitle"));
         TextFieldUtil.processTextField(m_window["GridDialog_mc"].upperGrid_mc.instructions_tf,ZGameUtils.ZlocT("Dialogs","MissionSelectionInstructions"));
         m_window["GridDialog_mc"].exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         var _loc3_:GameDataComponent = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
         if(_loc3_)
         {
            TextFieldUtil.processTextField(m_window["GridDialog_mc"].upperGrid_mc.header_tf,_loc3_.gameData.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            this.m_buildingIconLoader = ImageLoaderFactory.CreateImageLoader(_loc3_.gameData.getCachedImage("screenicon").url,m_window["GridDialog_mc"].upperGrid_mc.buildingicon_mc);
            this.m_buildingIconLoader.smooth = true;
         }
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(m_window["GridDialog_mc"].exit_bt,ButtonSound.DEFAULT);
         addChild(m_window);
         m_origOffsetX = m_window["GridDialog_mc"].x;
         m_origOffsetY = m_window["GridDialog_mc"].y;
         this.contentWidth = m_window["GridDialog_mc"].bg_mc.width;
         this.contentHeight = m_window["GridDialog_mc"].bg_mc.height;
         initDialog();
         ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.LEVEL,this.onLevelUpdated,false,0,true);
         UIDispatcher.instance.addEventListener(GridSlot.SELECTED,this.onSlotSelected,false,0,true);
         UIDispatcher.instance.addEventListener(MissionContractSlot.BUILD_MISSION,this.onBuildMission,false,0,true);
         UIDispatcher.instance.addEventListener(MissionContractSlot.FINISH_MISSION,this.onFinishMission,false,0,true);
         UIDispatcher.instance.addEventListener(MissionContractSlot.UNLOCK_MISSION,this.onUnlockMission,false,0,true);
         UIDispatcher.instance.addEventListener(MissionContractSlot.DEPLOY_MISSION,this.onDeployMission,false,0,true);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(true);
         dispatchEvent(new Event(Event.COMPLETE));
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(WindowManager.instance.container,0);
         var _loc4_:int = this.getNumMissionsDeployed();
         TextFieldUtil.processTextField(m_window["GridDialog_mc"].completed_tf,ZGameUtils.ZlocT("Dialogs","MissionSelectionMissionsCompleted",{"num":_loc4_}));
      }
      
      private function getNumMissionsDeployed() : int
      {
         var _loc3_:GameItem = null;
         var _loc1_:int = 0;
         var _loc2_:Array = this.m_unitsGrid.items;
         for each(_loc3_ in _loc2_)
         {
            _loc1_ += ZGlobal.player.getConsumableUsedByCode(_loc3_.code);
         }
         return _loc1_;
      }
      
      protected function onSlotSelected(param1:WorldEvent) : void
      {
         MissionContractGrid.setPageNum(this.m_unitsGrid.getPage());
         this.close();
      }
      
      protected function onBuildMission(param1:WorldEvent) : void
      {
         MissionContractGrid.setPageNum(this.m_unitsGrid.getPage());
         this.close();
         MissionPartsGather.display(this.m_eventDispatcher,GameItem(GridSlot(param1.eventData).getData()).code,this.m_entity);
      }
      
      protected function onLevelUpdated(param1:ExperienceUpdatedEvent) : void
      {
         this.m_unitsGrid.updateCards();
      }
      
      protected function onExitClicked(param1:MouseEvent) : void
      {
         MissionContractGrid.setPageNum(0);
         this.close();
      }
      
      protected function onConfirmClicked(param1:MouseEvent) : void
      {
         this.close();
      }
      
      override public function forceClose() : void
      {
         this.close();
      }
      
      protected function onFinishMission(param1:WorldEvent) : void
      {
         this.close();
      }
      
      protected function onUnlockMission(param1:WorldEvent) : void
      {
      }
      
      protected function onDeployMission(param1:WorldEvent) : void
      {
         GameModeManager.instance.addGameMode(new GMDeployMission(param1.eventData.unitItem.code));
         this.close();
      }
      
      private function onMissionBought(param1:Object) : void
      {
         if(param1.popup as MissionCompletePopup)
         {
            this.close();
            PopupManager.instance.push(param1.popup as MissionCompletePopup);
         }
      }
      
      private function onMissionCompleteDialogClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = "mission_complete";
            ViralsManager.instance.sendFeed(_loc2_,{
               "itemCode":param1.userData.itemCode,
               "ITEMTOKitem":param1.userData.name + "|"
            });
         }
      }
      
      override protected function close(param1:Event = null) : void
      {
         m_window["GridDialog_mc"].exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         UIDispatcher.instance.removeEventListener(GridSlot.SELECTED,this.onSlotSelected);
         UIDispatcher.instance.removeEventListener(MissionContractSlot.BUILD_MISSION,this.onBuildMission);
         UIDispatcher.instance.removeEventListener(MissionContractSlot.FINISH_MISSION,this.onFinishMission);
         UIDispatcher.instance.removeEventListener(MissionContractSlot.UNLOCK_MISSION,this.onUnlockMission);
         UIDispatcher.instance.removeEventListener(MissionContractSlot.DEPLOY_MISSION,this.onDeployMission);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(false);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(UIManager.instance.uiDisplay,0);
         this.m_eventDispatcher.dispatchEvent(new Event(EXIT));
         super.close();
      }
      
      public function dispose() : void
      {
         this.m_unitsGrid.dispose();
         this.m_unitsGrid = null;
      }
   }
}

