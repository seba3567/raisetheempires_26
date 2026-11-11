package displays.screens
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.EspionageHQManager;
   import core.ui.GenericButton;
   import core.ui.UIManager;
   import core.ui.menuitem.PlayerStatsUIItem;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.contractScreen.EspionageHQContractGrid;
   import displays.screens.contractScreen.EspionageHQContractSlot;
   import displays.screens.gridScreen.GridSlot;
   import displays.screens.partsGather.EspionageHQSpyPartsGather;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.popups.IWindow;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class EspionageHQScreen extends ZGamePopUp
   {
      
      public static const EXIT:String = "espionageExit";
      
      private var m_grid:EspionageHQContractGrid = null;
      
      protected var m_entity:IEntity = null;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_buildingIconLoader:ImageLoader = null;
      
      protected var m_confirm:GenericButton;
      
      protected var m_cancel:GenericButton;
      
      protected var m_useSavedPageNum:Boolean = false;
      
      public function EspionageHQScreen(param1:EventDispatcher, param2:IEntity)
      {
         this.m_entity = param2;
         this.m_eventDispatcher = param1;
         super(ZGlobal.getAssetURL("assets/displays/screens/EspionageSelectionScreen.swf"));
      }
      
      public static function display(param1:EventDispatcher, param2:IEntity) : IWindow
      {
         var _loc3_:IWindow = new EspionageHQScreen(param1,param2);
         WindowManager.instance.push(_loc3_);
         return _loc3_;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc4_:int = 0;
         var _loc2_:Class = param1.getAssetClass("UnitsScreen");
         m_window = new _loc2_();
         this.m_grid = new EspionageHQContractGrid(m_window["GridDialog_mc"].upperGrid_mc,param1,EspionageHQManager.ESPIONAGE_HQ_SPY_TYPE,EspionageHQManager.ESPIONAGE_HQ_SPY_SUBTYPE);
         TextFieldUtil.processTextField(m_window["GridDialog_mc"].upperGrid_mc.description_tf,ZGameUtils.ZlocT("Dialogs","Espionage_HQ_Dialog_Desc_01"));
         TextFieldUtil.processTextField(m_window["GridDialog_mc"].upperGrid_mc.note_tf,ZGameUtils.ZlocT("Dialogs","Espionage_HQ_Dialog_Desc_02"));
         TextFieldUtil.processTextField(m_window["GridDialog_mc"].upperGrid_mc.instructions_tf,ZGameUtils.ZlocT("Dialogs","Espionage_HQ_Dialog_Subtitle"));
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
         UIDispatcher.instance.addEventListener(GridSlot.SELECTED,this.onSlotSelected,false,0,true);
         UIDispatcher.instance.addEventListener(EspionageHQContractSlot.EQUIP_SPY,this.onEquipSpy,false,0,true);
         UIDispatcher.instance.addEventListener(EspionageHQContractSlot.FINISH_SPY,this.onFinishSpy,false,0,true);
         UIDispatcher.instance.addEventListener(EspionageHQContractSlot.DEPLOY_SPY,this.onDeploySpy,false,0,true);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(true);
         dispatchEvent(new Event(Event.COMPLETE));
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(WindowManager.instance.container,0);
         if(EspionageHQManager.instance.hasStolenUnit)
         {
            _loc4_ = EspionageHQManager.instance.battlesRemaining;
            TextFieldUtil.processTextField(m_window["GridDialog_mc"].completed_tf,ZGameUtils.ZlocT("Dialogs","Espionage_HQ_Dialog_Battles_Remaining",{"num":_loc4_}));
         }
         else
         {
            m_window["GridDialog_mc"].completed_tf.visible = false;
         }
      }
      
      protected function onSlotSelected(param1:WorldEvent) : void
      {
         this.close();
      }
      
      protected function onEquipSpy(param1:WorldEvent) : void
      {
         this.close();
         EspionageHQSpyPartsGather.display(this.m_eventDispatcher,GameItem(GridSlot(param1.eventData).getData()).code,this.m_entity);
      }
      
      protected function onExitClicked(param1:MouseEvent) : void
      {
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
      
      protected function onFinishSpy(param1:WorldEvent) : void
      {
         this.close();
      }
      
      protected function onDeploySpy(param1:WorldEvent) : void
      {
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         m_window["GridDialog_mc"].exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         UIDispatcher.instance.removeEventListener(GridSlot.SELECTED,this.onSlotSelected);
         UIDispatcher.instance.removeEventListener(EspionageHQContractSlot.EQUIP_SPY,this.onEquipSpy);
         UIDispatcher.instance.removeEventListener(EspionageHQContractSlot.FINISH_SPY,this.onFinishSpy);
         UIDispatcher.instance.removeEventListener(EspionageHQContractSlot.DEPLOY_SPY,this.onDeploySpy);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(false);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(UIManager.instance.uiDisplay,0);
         this.m_eventDispatcher.dispatchEvent(new Event(EXIT));
         super.close();
      }
      
      public function dispose() : void
      {
         this.m_grid.dispose();
         this.m_grid = null;
      }
   }
}

