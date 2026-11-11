package displays.screens.researchScreens
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.WorldUpgradeManager;
   import core.managers.domination.DominationModeManager;
   import core.ui.GenericButton;
   import core.ui.UIManager;
   import core.ui.menuitem.PlayerStatsUIItem;
   import dispatchers.ExperienceDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.gridScreen.GridSlot;
   import displays.screens.partsGather.UnitPartsGather;
   import entity.GameDataComponent;
   import events.ExperienceUpdatedEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class ResearchUnitSelectionScreen extends ZGamePopUp
   {
      
      public static const SHOW_ONLY_IF_OWNED:String = "onlyIfOwned";
      
      public static const EXIT:String = "exit";
      
      public static const SHOW_SPEEDUP_SCREEN:String = "show_speedup_screen";
      
      private static const ID:String = "ResearchUnitSelectionScreen";
      
      public static const RECENT_PLAYERS_RECEIVED:String = "recentPlayersReceived";
      
      private var m_unitsGrid:ResearchUnitsGrid = null;
      
      protected var m_type:String = "Buildable";
      
      private var m_subtype:String = null;
      
      protected var m_entity:IEntity = null;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_buildingIconLoader:ImageLoader = null;
      
      protected var m_confirm:GenericButton;
      
      protected var m_cancel:GenericButton;
      
      protected var m_unitItem:UnitItem = null;
      
      protected var m_useSavedPageNum:Boolean = false;
      
      protected var m_unitItemIsInProgress:Boolean = true;
      
      public function ResearchUnitSelectionScreen(param1:EventDispatcher, param2:String, param3:IEntity, param4:UnitItem, param5:Boolean, param6:Boolean)
      {
         this.m_subtype = param2;
         this.m_eventDispatcher = param1;
         this.m_entity = param3;
         this.m_unitItemIsInProgress = param6;
         if(this.m_unitItemIsInProgress)
         {
            this.m_unitItem = param4;
         }
         this.m_useSavedPageNum = param5;
         super(ZGlobal.getAssetURL("assets/displays/screens/PartsGatherSelectionScreen.swf"));
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:IEntity, param4:UnitItem = null, param5:Boolean = true, param6:Boolean = true) : PopUpBase
      {
         var _loc7_:PopUpBase = new ResearchUnitSelectionScreen(param1,param2,param3,param4,param5,param6);
         WindowManager.instance.push(_loc7_);
         return _loc7_;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         ZGlobal.player.setSeenFlag(WorldUpgradeManager.FIRST_RESEARCH_DIALOG);
         var _loc2_:Class = param1.getAssetClass("UnitsScreen");
         m_window = new _loc2_();
         this.m_unitsGrid = new ResearchUnitsGrid(m_window["GridDialog_mc"].upperGrid_mc,param1,this.m_type,this.m_subtype,this.m_unitItem,this.m_useSavedPageNum);
         TextFieldUtil.processTextField(m_window["GridDialog_mc"].upperGrid_mc.description_tf,ZGameUtils.ZlocT("Dialogs","ResearchUnitSelectionSubtitle"));
         TextFieldUtil.processTextField(m_window["GridDialog_mc"].upperGrid_mc.instructions_tf,ZGameUtils.ZlocT("Dialogs","ResearchUnitSelectionInstructions"));
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
         this.contentWidth = m_window["GridDialog_mc"].panel_mc.width;
         this.contentHeight = m_window["GridDialog_mc"].panel_mc.height;
         initDialog();
         ExperienceDispatcher.instance.addEventListener(ExperienceUpdatedEvent.LEVEL,this.onLevelUpdated,false,0,true);
         DominationModeManager.instance.addEventListener(DominationModeManager.UPDATED_DOMINANCE_RANK,this.onDominationRankUpdated,false,0,true);
         UIDispatcher.instance.addEventListener(GridSlot.SELECTED,this.onSlotSelected,false,0,true);
         UIDispatcher.instance.addEventListener(ResearchUnitSlot.UNLOCK,this.onSlotUnlock,false,0,true);
         UIDispatcher.instance.addEventListener(ResearchUnitSlot.FINISH_NOW,this.onFinishNow,false,0,true);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(true);
         dispatchEvent(new Event(Event.COMPLETE));
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(WindowManager.instance.container,0);
      }
      
      protected function onSlotSelected(param1:WorldEvent) : void
      {
         ResearchUnitsGrid.setPageNum(this.m_unitsGrid.getPage());
         this.close();
         ResearchUpgradeScreen.display(this.m_eventDispatcher,this.m_entity,UnitItem(GridSlot(param1.eventData).getData()));
      }
      
      protected function onSlotUnlock(param1:WorldEvent) : void
      {
         ResearchUnitsGrid.setPageNum(this.m_unitsGrid.getPage());
         this.close();
         UnitPartsGather.display(this.m_eventDispatcher,GameItem(GridSlot(param1.eventData).getData()).code,this.m_entity,this.m_unitItem);
      }
      
      protected function onDominationRankUpdated(param1:Event) : void
      {
         this.m_unitsGrid.updateCards();
      }
      
      protected function onLevelUpdated(param1:ExperienceUpdatedEvent) : void
      {
         this.m_unitsGrid.updateCards();
      }
      
      protected function onExitClicked(param1:MouseEvent) : void
      {
         ResearchUnitsGrid.setPageNum(0);
         this.close();
      }
      
      protected function onConfirmClicked(param1:MouseEvent) : void
      {
      }
      
      override public function forceClose() : void
      {
         this.close();
      }
      
      protected function onFinishNow(param1:WorldEvent) : void
      {
         this.close();
         UIDispatcher.instance.dispatchEvent(new WorldEvent(SHOW_SPEEDUP_SCREEN,param1.eventData));
      }
      
      override protected function close(param1:Event = null) : void
      {
         m_window["GridDialog_mc"].exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         UIDispatcher.instance.removeEventListener(GridSlot.SELECTED,this.onSlotSelected);
         UIDispatcher.instance.removeEventListener(ResearchUnitSlot.UNLOCK,this.onSlotUnlock);
         UIDispatcher.instance.removeEventListener(ResearchUnitSlot.FINISH_NOW,this.onFinishNow);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(false);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(UIManager.instance.uiDisplay,0);
         this.m_eventDispatcher.dispatchEvent(new Event(EXIT));
         super.close();
      }
      
      public function dispose() : void
      {
         DominationModeManager.instance.removeEventListener(DominationModeManager.UPDATED_DOMINANCE_RANK,this.onDominationRankUpdated);
         this.m_unitsGrid.dispose();
         this.m_unitsGrid = null;
      }
   }
}

