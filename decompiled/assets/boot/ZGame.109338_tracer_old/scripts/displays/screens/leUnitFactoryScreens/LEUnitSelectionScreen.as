package displays.screens.leUnitFactoryScreens
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsLEUnitItem;
   import core.managers.LEUnitFactoryManager;
   import core.managers.WorldObjectManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.UIManager;
   import core.ui.ZGameButton;
   import core.ui.menuitem.PlayerStatsUIItem;
   import dispatchers.ExperienceDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.FeedPopup;
   import displays.popups.GenericCountdownClock;
   import displays.popups.GenericPopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.gridScreen.GridSlot;
   import displays.screens.partsGather.LEUnitPartsGather;
   import displays.screens.researchScreens.ResearchUnitSlot;
   import entity.GameDataComponent;
   import events.ExperienceUpdatedEvent;
   import events.GameModeEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TLEUnitFactoryExtendTime;
   import transactions.TLEUnitFactoryUnlockLevelGate;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.popups.IWindow;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class LEUnitSelectionScreen extends ZGamePopUp
   {
      
      public static const EXIT:String = "exit";
      
      public static const FINISH_LE_UNIT:String = "finishLEUnit";
      
      public static const BUY_LE_UNIT:String = "buyLEUnit";
      
      private static const ID:String = "LEUnitSelectionScreen";
      
      private var m_unitsGrid:LEUnitsGrid = null;
      
      protected var m_type:String = "Buildable";
      
      private var m_subtype:String = null;
      
      protected var m_entity:IEntity = null;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_buildingIconLoader:ImageLoader = null;
      
      protected var m_useSavedPageNum:Boolean = false;
      
      protected var m_extendButton:ZGameButton;
      
      protected var m_clock:GenericCountdownClock = null;
      
      private var m_feedInfo:Object = {};
      
      public function LEUnitSelectionScreen(param1:EventDispatcher, param2:String, param3:IEntity, param4:Boolean)
      {
         this.m_subtype = param2;
         this.m_eventDispatcher = param1;
         this.m_entity = param3;
         this.m_useSavedPageNum = param4;
         super(ZGlobal.getAssetURL("assets/displays/screens/LEFactoryUnitSelector.swf"));
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:IEntity, param4:Boolean = true) : IWindow
      {
         var _loc5_:IWindow = new LEUnitSelectionScreen(param1,param2,param3,param4);
         WindowManager.instance.push(_loc5_);
         return _loc5_;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:Class = param1.getAssetClass("UnitsScreen");
         m_window = new _loc2_();
         this.m_unitsGrid = new LEUnitsGrid(m_window["GridDialog_mc"].upperGrid_mc,param1,this.m_type,this.m_subtype,this.m_useSavedPageNum);
         TextFieldUtil.processTextField(m_window["GridDialog_mc"].upperGrid_mc.description_tf,ZGameUtils.ZlocT("Dialogs","LEUnitSelectionSubtitle"));
         m_window["GridDialog_mc"].upperGrid_mc.instructions_tf.visible = true;
         TextFieldUtil.processTextField(m_window["GridDialog_mc"].upperGrid_mc.instructions_tf,ZGameUtils.ZlocT("Dialogs","LEUnitSelectionInstructions"));
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
         UIDispatcher.instance.addEventListener(GridSlot.SELECTED,this.onSlotSelected,false,0,true);
         UIDispatcher.instance.addEventListener(LEUnitSlot.BUILD_LE_UNIT,this.onBuildLEUnit,false,0,true);
         UIDispatcher.instance.addEventListener(LEUnitSlot.UNLOCK_LEVEL_GATE,this.onUnlockLevelGate,false,0,true);
         UIDispatcher.instance.addEventListener(LEUnitSlot.FINISH_LE_UNIT,this.onFinishLEUnit,false,0,true);
         UIDispatcher.instance.addEventListener(LEUnitSlot.BUY_LE_UNIT,this.onBuyLEUnit,false,0,true);
         UIDispatcher.instance.addEventListener(ResearchUnitSlot.UNLOCK,this.onSlotUnlock,false,0,true);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(true);
         dispatchEvent(new Event(Event.COMPLETE));
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(WindowManager.instance.container,0);
         this.m_extendButton = new ZGameButton(m_window.GridDialog_mc.extend_bt,this.onExtendButtonClick);
         this.m_extendButton.text = ZGameUtils.ZlocT("Dialogs","LEUnitSelectionBuyMoreTime",{"cost":20});
         TextFieldUtil.processTextField(m_window.GridDialog_mc.time_tf,ZGameUtils.ZlocT("Dialogs","LEUnitSelectionTimeRemaining"));
         this.initClock();
      }
      
      protected function onExtendButtonClick(param1:MouseEvent) : void
      {
         if(ZGlobal.player.canBuyCash(20,true))
         {
            TransactionManager.addTransaction(new TLEUnitFactoryExtendTime(this.m_entity));
            LEUnitFactoryManager.instance.extendTime();
            this.m_clock.dispose();
            this.initClock();
         }
      }
      
      protected function initClock() : void
      {
         this.m_clock = new GenericCountdownClock(m_window.GridDialog_mc.clock_mc,LEUnitFactoryManager.instance.lufEndDate - ZGlobal.player.timeWarpSeconds);
      }
      
      public function get clockValuesXML() : XML
      {
         var _loc1_:Object = LEUnitFactoryManager.instance.lufEndDate;
         var _loc2_:String = _loc1_.requiredDate.start;
         var _loc3_:String = _loc1_.requiredDate.end;
         var _loc4_:XML = <requiredDate start={_loc2_} end={_loc3_}/>;
         var _loc5_:XML = <messageOfTheday/>;
         _loc5_.appendChild(_loc4_);
         return _loc5_;
      }
      
      protected function onSlotSelected(param1:WorldEvent) : void
      {
         LEUnitsGrid.setPageNum(this.m_unitsGrid.getPage());
         this.close();
      }
      
      protected function onUnlockLevelGate(param1:WorldEvent) : void
      {
         var _loc2_:PartsLEUnitItem = null;
         _loc2_ = PartsLEUnitItem(GridSlot(param1.eventData).getData());
         TransactionManager.addTransaction(new TLEUnitFactoryUnlockLevelGate(this.m_entity,_loc2_.unitCode));
         LEUnitFactoryManager.instance.setLevelUnlocked(_loc2_.unitCode);
         this.m_unitsGrid.updateCards();
      }
      
      protected function onSlotUnlock(param1:WorldEvent) : void
      {
         var _loc2_:PartsLEUnitItem = null;
         LEUnitsGrid.setPageNum(this.m_unitsGrid.getPage());
         this.close();
         _loc2_ = PartsLEUnitItem(GridSlot(param1.eventData).getData());
         LEUnitPartsGather.display(this.m_eventDispatcher,_loc2_.code,this.m_entity,_loc2_);
      }
      
      protected function onBuildLEUnit(param1:WorldEvent) : void
      {
         var _loc2_:PartsLEUnitItem = null;
         LEUnitsGrid.setPageNum(this.m_unitsGrid.getPage());
         this.close();
         _loc2_ = PartsLEUnitItem(GridSlot(param1.eventData).getData());
         LEUnitPartsGather.display(this.m_eventDispatcher,_loc2_.code,this.m_entity,_loc2_);
      }
      
      protected function onLevelUpdated(param1:ExperienceUpdatedEvent) : void
      {
         this.m_unitsGrid.updateCards();
      }
      
      protected function onExitClicked(param1:MouseEvent) : void
      {
         LEUnitsGrid.setPageNum(0);
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
      
      protected function onFinishLEUnit(param1:WorldEvent) : void
      {
         this.close();
      }
      
      protected function onBuyLEUnit(param1:WorldEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:GameItem = null;
         if(ZGlobal.player.canBuyCash(param1.eventData.unitItem.cash,true))
         {
            this.m_feedInfo = {};
            this.m_feedInfo.referenceItem = ZGlobal.gameSettings.getItemByName(param1.eventData.unitItem.name,GameItem) as GameItem;
            _loc2_ = {"screen":"le_unit_factory"};
            _loc3_ = param1.eventData.unitItem;
            ZGlobal.player.buyPremiumGameItem(param1.eventData.unitItem,false,true,_loc2_,null,null);
            WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_PLACED_CLIENT,this.onLEUnitPlacedFromBuy,false,0,true);
            WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_PLACE_CANCELLED,this.onLEUnitPlacementCanceled,false,0,true);
            GameModeManager.instance.addEventListener(GameModeEvent.ADD_MODE,this.onGameModeChange,false,0,true);
            this.close();
         }
      }
      
      private function showBuyFeed() : void
      {
         var _loc1_:FeedPopup = null;
         var _loc2_:Object = null;
         var _loc3_:String = "";
         var _loc4_:GameItem = this.m_feedInfo.referenceItem;
         _loc3_ += ZGameUtils.ZlocT("FeedPopups","le_unit_purchased",{"unitname":_loc4_.getSentenceNameLocalizationObject("singular")});
         _loc1_ = new FeedPopup(_loc3_,ZGameUtils.ZlocT("FeedPopups","le_unit_purchased_title"),ZGameUtils.ZlocT("FeedPopups","feed_share_bttn"),GenericPopup.TYPE_SHARECANCEL,this.onLEUnitPurchasedDialogClosed,ZGlobal.gameSettings.getImageByName(_loc4_.name,"icon"));
         _loc2_ = new Object();
         _loc2_.name = _loc4_.name;
         _loc2_.itemCode = _loc4_.code;
         _loc1_.userData = _loc2_;
         PopupManager.instance.push(_loc1_);
      }
      
      private function onLEUnitPlacedFromBuy(param1:WorldEvent) : void
      {
         this.removePlacementListeners();
         this.showBuyFeed();
      }
      
      private function onLEUnitPlacementCanceled(param1:WorldEvent) : void
      {
         this.removePlacementListeners();
      }
      
      private function onGameModeChange(param1:Event) : void
      {
         this.removePlacementListeners();
      }
      
      private function removePlacementListeners() : void
      {
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_PLACED_CLIENT,this.onLEUnitPlacedFromBuy);
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_PLACE_CANCELLED,this.onLEUnitPlacementCanceled);
         GameModeManager.instance.removeEventListener(GameModeEvent.ADD_MODE,this.onGameModeChange);
      }
      
      private function onLEUnitPurchasedDialogClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = "le_unit_purchased";
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
         UIDispatcher.instance.removeEventListener(LEUnitSlot.BUILD_LE_UNIT,this.onBuildLEUnit);
         UIDispatcher.instance.removeEventListener(LEUnitSlot.FINISH_LE_UNIT,this.onFinishLEUnit);
         UIDispatcher.instance.removeEventListener(LEUnitSlot.UNLOCK_LEVEL_GATE,this.onUnlockLevelGate);
         UIDispatcher.instance.removeEventListener(LEUnitSlot.BUY_LE_UNIT,this.onBuyLEUnit);
         UIDispatcher.instance.removeEventListener(ResearchUnitSlot.UNLOCK,this.onSlotUnlock);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(false);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(UIManager.instance.uiDisplay,0);
         this.m_eventDispatcher.dispatchEvent(new Event(EXIT));
         super.close();
      }
      
      override protected function deinitDialog() : void
      {
         ExperienceDispatcher.instance.removeEventListener(ExperienceUpdatedEvent.LEVEL,this.onLevelUpdated);
         this.m_unitsGrid.dispose();
         this.m_clock.dispose();
         this.m_extendButton.dispose();
         this.m_unitsGrid = null;
         this.m_clock = null;
         this.m_extendButton = null;
         super.deinitDialog();
      }
   }
}

