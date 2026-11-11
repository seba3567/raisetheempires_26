package displays.screens.powerupFactoryScreens
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.GenericButton;
   import core.ui.UIManager;
   import core.ui.menuitem.PlayerStatsUIItem;
   import dispatchers.ExperienceDispatcher;
   import dispatchers.UIDispatcher;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.FeedPopup;
   import displays.popups.GenericPopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.gridScreen.GridSlot;
   import displays.screens.partsGather.PowerupPartsGather;
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
   
   public class PowerupSelectionScreen extends ZGamePopUp
   {
      
      public static const EXIT:String = "exit";
      
      public static const FINISH_POWERUP:String = "finishpowerup";
      
      public static const BUY_POWERUP:String = "buypowerup";
      
      private static const ID:String = "PowerupSelectionScreen";
      
      private var m_unitsGrid:PowerupsGrid = null;
      
      protected var m_type:String = "Buildable";
      
      private var m_subtype:String = null;
      
      protected var m_entity:IEntity = null;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_buildingIconLoader:ImageLoader = null;
      
      protected var m_confirm:GenericButton;
      
      protected var m_cancel:GenericButton;
      
      protected var m_useSavedPageNum:Boolean = false;
      
      public function PowerupSelectionScreen(param1:EventDispatcher, param2:String, param3:IEntity, param4:Boolean)
      {
         this.m_subtype = param2;
         this.m_eventDispatcher = param1;
         this.m_entity = param3;
         this.m_useSavedPageNum = param4;
         super(ZGlobal.getAssetURL("assets/displays/screens/PartsGatherSelectionScreen.swf"));
      }
      
      public static function display(param1:EventDispatcher, param2:String, param3:IEntity, param4:Boolean = true) : IWindow
      {
         var _loc5_:IWindow = new PowerupSelectionScreen(param1,param2,param3,param4);
         WindowManager.instance.push(_loc5_);
         return _loc5_;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         var _loc2_:Class = param1.getAssetClass("UnitsScreen");
         m_window = new _loc2_();
         this.m_unitsGrid = new PowerupsGrid(m_window["GridDialog_mc"].upperGrid_mc,param1,this.m_type,this.m_subtype,this.m_useSavedPageNum);
         TextFieldUtil.processTextField(m_window["GridDialog_mc"].upperGrid_mc.description_tf,ZGameUtils.ZlocT("Dialogs","PowerupSelectionSubtitle"));
         TextFieldUtil.processTextField(m_window["GridDialog_mc"].upperGrid_mc.instructions_tf,ZGameUtils.ZlocT("Dialogs","PowerupSelectionInstructions"));
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
         UIDispatcher.instance.addEventListener(PowerupSlot.BUILD_POWERUP,this.onBuildPowerup,false,0,true);
         UIDispatcher.instance.addEventListener(PowerupSlot.FINISH_POWERUP,this.onFinishPowerup,false,0,true);
         UIDispatcher.instance.addEventListener(PowerupSlot.BUY_POWERUP,this.onBuyPowerup,false,0,true);
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).toggleRarePanel(true);
         dispatchEvent(new Event(Event.COMPLETE));
         PlayerStatsUIItem(PlayerStatsUIItem.getPlayerStats()).moveToNewLayer(WindowManager.instance.container,0);
      }
      
      protected function onSlotSelected(param1:WorldEvent) : void
      {
         PowerupsGrid.setPageNum(this.m_unitsGrid.getPage());
         this.close();
      }
      
      protected function onBuildPowerup(param1:WorldEvent) : void
      {
         PowerupsGrid.setPageNum(this.m_unitsGrid.getPage());
         this.close();
         PowerupPartsGather.display(this.m_eventDispatcher,GameItem(GridSlot(param1.eventData).getData()).code,this.m_entity);
      }
      
      protected function onLevelUpdated(param1:ExperienceUpdatedEvent) : void
      {
         this.m_unitsGrid.updateCards();
      }
      
      protected function onExitClicked(param1:MouseEvent) : void
      {
         PowerupsGrid.setPageNum(0);
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
      
      protected function onFinishPowerup(param1:WorldEvent) : void
      {
         this.close();
      }
      
      protected function onBuyPowerup(param1:WorldEvent) : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:FeedPopup = null;
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         if(ZGlobal.player.canBuyCash(param1.eventData.unitItem.cash,true))
         {
            _loc2_ = ZGlobal.gameSettings.getItemByName(param1.eventData.unitItem.name,GameItem) as GameItem;
            _loc3_ = new FeedPopup(ZGameUtils.ZlocT("FeedPopups","powerup_complete",{"powerupname":_loc2_.getSentenceNameLocalizationObject("singular")}),ZGameUtils.ZlocT("FeedPopups","powerup_complete_title"),ZGameUtils.ZlocT("FeedPopups","feed_share_bttn"),GenericPopup.TYPE_SHARECANCEL,this.onPowerupCompleteDialogClosed,ZGlobal.gameSettings.getImageByName(param1.eventData.unitItem.name,"icon"));
            _loc4_ = new Object();
            _loc4_.name = _loc2_.name;
            _loc4_.itemCode = _loc2_.code;
            _loc3_.userData = _loc4_;
            _loc5_ = {"screen":"powerup_factory"};
            ZGlobal.player.buyPremiumGameItem(param1.eventData.unitItem,false,false,_loc5_,this.onPowerupBought,null,{"popup":_loc3_});
         }
      }
      
      private function onPowerupBought(param1:Object) : void
      {
         if(param1.popup as FeedPopup)
         {
            this.close();
            PopupManager.instance.push(param1.popup as FeedPopup);
         }
      }
      
      private function onPowerupCompleteDialogClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = "powerup_complete";
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
         UIDispatcher.instance.removeEventListener(PowerupSlot.BUILD_POWERUP,this.onBuildPowerup);
         UIDispatcher.instance.removeEventListener(PowerupSlot.FINISH_POWERUP,this.onFinishPowerup);
         UIDispatcher.instance.removeEventListener(PowerupSlot.BUY_POWERUP,this.onBuyPowerup);
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

