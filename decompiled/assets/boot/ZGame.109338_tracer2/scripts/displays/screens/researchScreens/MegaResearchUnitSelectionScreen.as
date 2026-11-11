package displays.screens.researchScreens
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.managers.WorldUpgradeManager;
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
   import flash.display.MovieClip;
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
   
   public class MegaResearchUnitSelectionScreen extends ZGamePopUp
   {
      
      public static const SHOW_ONLY_IF_OWNED:String = "onlyIfOwned";
      
      public static const EXIT:String = "exit";
      
      public static const SHOW_SPEEDUP_SCREEN:String = "show_speedup_screen";
      
      private static const ID:String = "MegaResearchUnitSelectionScreen";
      
      public static const RECENT_PLAYERS_RECEIVED:String = "recentPlayersReceived";
      
      public static const NUMTABS:uint = 3;
      
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
      
      protected var m_tabData:Array = null;
      
      protected var m_currentTab:uint = 4294967295;
      
      public function MegaResearchUnitSelectionScreen(param1:EventDispatcher, param2:String, param3:IEntity, param4:UnitItem, param5:Boolean, param6:Boolean)
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
         super(ZGlobal.getAssetURL("assets/displays/screens/TitanLabPartsGatherSelectionScreen.swf"));
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:IEntity, param4:UnitItem = null, param5:Boolean = true, param6:Boolean = true) : PopUpBase
      {
         var _loc7_:PopUpBase = new MegaResearchUnitSelectionScreen(param1,param2,param3,param4,param5,param6);
         WindowManager.instance.push(_loc7_);
         return _loc7_;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         ZGlobal.player.setSeenFlag(WorldUpgradeManager.FIRST_RESEARCH_DIALOG);
         var _loc2_:Class = param1.getAssetClass("UnitsScreen");
         m_window = new _loc2_();
         this.m_unitsGrid = new ResearchUnitsGrid(m_window["GridDialog_mc"].upperGrid_mc,param1,this.m_type,this.m_subtype,this.m_unitItem,this.m_useSavedPageNum,true);
         this.initTabs(m_window["GridDialog_mc"].upperGrid_mc);
         TextFieldUtil.compactTextField(m_window["GridDialog_mc"].upperGrid_mc.description_tf,ZGameUtils.ZlocT("Dialogs","TitanResearchUnitSelectionSubtitle"));
         TextFieldUtil.compactTextField(m_window["GridDialog_mc"].upperGrid_mc.instructions_tf,ZGameUtils.ZlocT("Dialogs","ResearchUnitSelectionInstructions"));
         m_window["GridDialog_mc"].exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         var _loc3_:GameDataComponent = GameDataComponent(this.m_entity.lookupComponentByType(GameDataComponent));
         if(_loc3_)
         {
            TextFieldUtil.compactTextField(m_window["GridDialog_mc"].upperGrid_mc.header_tf,_loc3_.gameData.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
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
         UIDispatcher.instance.addEventListener(GridSlot.SELECTED,this.onSlotSelected,false,0,true);
         UIDispatcher.instance.addEventListener(ResearchUnitSlot.UNLOCK,this.onSlotUnlock,false,0,true);
         UIDispatcher.instance.addEventListener(ResearchUnitSlot.FINISH_NOW,this.onFinishNow,false,0,true);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(true);
         dispatchEvent(new Event(Event.COMPLETE));
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(WindowManager.instance.container,0);
      }
      
      private function initTabs(param1:MovieClip) : void
      {
         var _loc3_:Object = null;
         this.m_tabData = [{
            "tabClip":param1.tab01_mc,
            "text":ZGameUtils.ZlocT("Dialogs","MechLabProductionTab1"),
            "requiredUnitType":"controller"
         },{
            "tabClip":param1.tab02_mc,
            "text":ZGameUtils.ZlocT("Dialogs","MechLabProductionTab2"),
            "requiredUnitType":"arm"
         },{
            "tabClip":param1.tab03_mc,
            "text":ZGameUtils.ZlocT("Dialogs","MechLabProductionTab3"),
            "requiredUnitType":"shoulder"
         }];
         var _loc2_:uint = 0;
         while(_loc2_ < NUMTABS)
         {
            _loc3_ = this.m_tabData[_loc2_];
            _loc3_.tabClip.addEventListener(MouseEvent.MOUSE_OUT,this.onTabOut,false,0,true);
            _loc3_.tabClip.addEventListener(MouseEvent.MOUSE_OVER,this.onTabOver,false,0,true);
            _loc3_.tabClip.addEventListener(MouseEvent.CLICK,this.onTabClick,false,0,true);
            _loc2_++;
         }
         if(!this.m_unitItem)
         {
            this.currentTab = 0;
         }
         else
         {
            this.currentTab = this.m_unitsGrid.findIndex([this.m_tabData[0].requiredUnitType,this.m_tabData[1].requiredUnitType,this.m_tabData[2].requiredUnitType]);
         }
      }
      
      private function onTabOut(param1:MouseEvent) : void
      {
         var _loc3_:Object = null;
         var _loc2_:uint = this.getIndexForClip(param1.currentTarget as MovieClip);
         if(_loc2_ != this.currentTab)
         {
            _loc3_ = this.m_tabData[_loc2_];
            (_loc3_.tabClip as MovieClip).gotoAndStop(1);
            TextFieldUtil.compactTextField(_loc3_.tabClip.tabName_tf,_loc3_.text);
         }
      }
      
      private function onTabOver(param1:MouseEvent) : void
      {
         var _loc3_:Object = null;
         var _loc2_:uint = this.getIndexForClip(param1.currentTarget as MovieClip);
         if(_loc2_ != this.currentTab)
         {
            _loc3_ = this.m_tabData[_loc2_];
            (_loc3_.tabClip as MovieClip).gotoAndStop(2);
            TextFieldUtil.compactTextField(_loc3_.tabClip.tabName_tf,_loc3_.text);
         }
      }
      
      private function onTabClick(param1:MouseEvent) : void
      {
         var _loc2_:uint = this.getIndexForClip(param1.currentTarget as MovieClip);
         if(_loc2_ != this.currentTab)
         {
            this.currentTab = _loc2_;
         }
      }
      
      private function getIndexForClip(param1:MovieClip) : uint
      {
         var _loc3_:Object = null;
         var _loc2_:uint = 0;
         while(_loc2_ < NUMTABS)
         {
            _loc3_ = this.m_tabData[_loc2_];
            if(_loc3_.tabClip == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return uint.MAX_VALUE;
      }
      
      private function get currentTab() : uint
      {
         return this.m_currentTab;
      }
      
      private function set currentTab(param1:uint) : void
      {
         var _loc2_:uint = 0;
         var _loc3_:Object = null;
         if(this.m_currentTab != param1)
         {
            if(param1 < NUMTABS)
            {
               _loc2_ = 0;
               while(_loc2_ < NUMTABS)
               {
                  _loc3_ = this.m_tabData[_loc2_];
                  if(_loc2_ == param1)
                  {
                     _loc3_.tabClip.gotoAndStop(4);
                     TextFieldUtil.compactTextField(_loc3_.tabClip.tabName_tf,_loc3_.text);
                     this.m_unitsGrid.filterRequiredUnitType = _loc3_.requiredUnitType;
                  }
                  else
                  {
                     _loc3_.tabClip.gotoAndStop(1);
                     TextFieldUtil.compactTextField(_loc3_.tabClip.tabName_tf,_loc3_.text);
                  }
                  _loc2_++;
               }
               this.m_currentTab = param1;
            }
         }
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
         var _loc3_:Object = null;
         m_window["GridDialog_mc"].exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         var _loc2_:uint = 0;
         while(_loc2_ < NUMTABS)
         {
            _loc3_ = this.m_tabData[_loc2_];
            _loc3_.tabClip.removeEventListener(MouseEvent.MOUSE_OUT,this.onTabOut);
            _loc3_.tabClip.removeEventListener(MouseEvent.MOUSE_OVER,this.onTabOver);
            _loc3_.tabClip.removeEventListener(MouseEvent.CLICK,this.onTabClick);
            _loc2_++;
         }
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
         this.m_unitsGrid.dispose();
         this.m_unitsGrid = null;
      }
   }
}

