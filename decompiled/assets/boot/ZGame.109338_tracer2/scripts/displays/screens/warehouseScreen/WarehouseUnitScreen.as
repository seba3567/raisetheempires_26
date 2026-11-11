package displays.screens.warehouseScreen
{
   import Engine.Managers.StatsManager;
   import core.ZGlobal;
   import core.gamemode.GMWarehouseObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsBuildingItem;
   import core.gameobjects.UnitItem;
   import dispatchers.UIDispatcher;
   import displays.popups.zgamepopup.ZGamePopUp;
   import displays.screens.gridScreen.GridSlot;
   import displays.screens.partsGather.WarehouseUpgradePartsGather;
   import entity.GameDataComponent;
   import entity.WarehouseComponent;
   import events.CloseEvent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class WarehouseUnitScreen extends ZGamePopUp
   {
      
      public static const EXIT:String = "exit";
      
      public static const SHOW_SPEEDUP_SCREEN:String = "show_speedup_screen";
      
      public static const FINISH_UPGRADE:String = "finishupgrade";
      
      private static const ID:String = "WarehouseUnitScreen";
      
      private var m_unitsGrid:WarehouseUnitsGrid = null;
      
      protected var m_type:String = "Buildable";
      
      private var m_subtype:String = null;
      
      protected var m_entity:IEntity = null;
      
      protected var m_eventDispatcher:EventDispatcher = null;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_tierBar:MovieClip;
      
      protected var m_getMoreSpaceButton:MovieClip;
      
      protected var m_warehouse:WarehouseComponent;
      
      protected var m_buildingItem:GameItem;
      
      protected var m_resource:SWFResource;
      
      protected var m_descriptionCode:String;
      
      protected var m_instructionCode:String;
      
      public function WarehouseUnitScreen(param1:EventDispatcher, param2:String, param3:IEntity, param4:GameItem)
      {
         var _loc7_:String = null;
         this.m_subtype = param2;
         this.m_eventDispatcher = param1;
         this.m_entity = param3;
         this.m_buildingItem = param4;
         var _loc5_:GameDataComponent = GameDataComponent.getGameDataComponent(param3);
         var _loc6_:String = _loc5_.gameData.warehouseType;
         if(_loc6_ == "air")
         {
            _loc7_ = "assets/displays/screens/PU_AirDepot_Browser.swf";
            this.m_descriptionCode = "AirUnitDepotDescription";
            this.m_instructionCode = "AirDepotInstructions";
         }
         else if(_loc6_ == "army")
         {
            _loc7_ = "assets/displays/screens/PU_AirDepot_Browser.swf";
            this.m_descriptionCode = "ArmyUnitDepotDescription";
            this.m_instructionCode = "ArmyDepotInstructions";
         }
         else if(_loc6_ == "navy")
         {
            _loc7_ = "assets/displays/screens/PU_AirDepot_Browser.swf";
            this.m_descriptionCode = "NavyUnitDepotDescription";
            this.m_instructionCode = "NavyDepotInstructions";
         }
         StatsManager.count("dialog","depot_" + _loc6_,"browser","view");
         super(ZGlobal.getAssetURL(_loc7_));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         Logger.print(this,"JMR, onLoadComplete");
         this.m_resource = param1;
         this.m_warehouse = WarehouseComponent(this.m_entity.lookupComponentByType(WarehouseComponent));
         var _loc2_:Class = param1.getAssetClass("UnitsScreen");
         m_window = new _loc2_();
         m_window["GridDialog_mc"].exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         this.m_getMoreSpaceButton = m_window.GridDialog_mc.upperGrid_mc.getMoreBtn;
         this.m_getMoreSpaceButton.generic_tf.mouseEnabled = false;
         this.refreshView();
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(m_window["GridDialog_mc"].exit_bt,ButtonSound.DEFAULT);
         addChild(m_window);
         m_origOffsetX = m_window["GridDialog_mc"].x;
         m_origOffsetY = m_window["GridDialog_mc"].y;
         this.contentWidth = m_window["GridDialog_mc"].panel_mc.width;
         this.contentHeight = m_window["GridDialog_mc"].panel_mc.height;
         initDialog();
         UIDispatcher.instance.addEventListener(GridSlot.SELECTED,this.onSlotSelected,false,0,true);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function initUnitGrid() : void
      {
         if(this.m_unitsGrid)
         {
            this.m_unitsGrid.dispose();
         }
         this.m_unitsGrid = new WarehouseUnitsGrid(m_window["GridDialog_mc"].upperGrid_mc,this.m_resource,this.m_type,this.m_subtype,this.m_warehouse);
         TextFieldUtil.compactTextField(m_window["GridDialog_mc"].upperGrid_mc.title_tf,this.m_buildingItem.getFriendlyName(GameItem.MENU_FRIENDLYNAME),{
            "maxLines":2,
            "minScale":0.7
         });
         TextFieldUtil.compactTextField(m_window["GridDialog_mc"].upperGrid_mc.description_tf,ZGameUtils.ZlocT("Dialogs",this.m_descriptionCode),{
            "maxLines":2,
            "minScale":0.7
         });
         TextFieldUtil.compactTextField(m_window["GridDialog_mc"].upperGrid_mc.instruction_tf,ZGameUtils.ZlocT("Dialogs",this.m_instructionCode),{
            "maxLines":2,
            "minScale":0.7
         });
      }
      
      private function refreshView() : void
      {
         var _loc1_:String = null;
         this.initUnitGrid();
         this.updateTierBar();
         this.updateSpaceLeft();
         this.m_getMoreSpaceButton.removeEventListener(MouseEvent.CLICK,this.getMoreButtonClick);
         if(this.m_warehouse.atMaxTier())
         {
            this.m_getMoreSpaceButton.gotoAndStop(4);
            this.m_getMoreSpaceButton.buttonMode = false;
            _loc1_ = ZGameUtils.ZlocT("Dialogs","DepotFullyUpgraded");
         }
         else
         {
            this.m_getMoreSpaceButton.addEventListener(MouseEvent.CLICK,this.getMoreButtonClick,false,0,true);
            this.m_getMoreSpaceButton.gotoAndStop(1);
            this.m_getMoreSpaceButton.buttonMode = true;
            _loc1_ = ZGameUtils.ZlocT("Dialogs","DepotAddMoreSpace",{"count":this.m_warehouse.getCapacityAtTier(this.m_warehouse.tier + 1)});
         }
         TextFieldUtil.compactTextField(this.m_getMoreSpaceButton.generic_tf,_loc1_,{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
      }
      
      private function updateTierBar() : void
      {
         var _loc1_:String = null;
         _loc1_ = "tier" + this.m_warehouse.tier;
         Logger.print(this,"JMR updateTierBar frame: " + _loc1_);
      }
      
      private function updateSpaceLeft() : void
      {
         Logger.print(this,"JMR updateSpaceLeft: " + this.m_warehouse.spaceReport);
         TextFieldUtil.processTextField(m_window.GridDialog_mc.upperGrid_mc.capacity_tf,this.m_warehouse.spaceReport);
      }
      
      private function getMoreButtonClick(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         Logger.print(this,"JMR, getMoreButtonClick");
         var _loc2_:PartsBuildingItem = null;
         var _loc3_:Array = this.m_buildingItem.warehouseUpgradesAsArray;
         _loc4_ = this.m_warehouse.tier - 1;
         if(_loc4_ >= _loc3_.length)
         {
            _loc4_ = _loc3_.length - 1;
         }
         var _loc5_:String = _loc3_[_loc4_];
         _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc5_,PartsBuildingItem) as PartsBuildingItem;
         if(Boolean(_loc2_) && _loc2_.numParts > 0)
         {
            this.m_eventDispatcher.addEventListener(WarehouseUnitScreen.FINISH_UPGRADE,this.onFinishedParts,false,0,true);
            this.m_eventDispatcher.addEventListener(CloseEvent.CLOSE,this.onCloseClickParts,false,0,true);
            this.visible = false;
            WarehouseUpgradePartsGather.display(EventDispatcher(this.m_eventDispatcher),_loc2_.code,this.getDescriptionCodeByType(),this.m_entity,this.m_warehouse);
         }
      }
      
      private function getDescriptionCodeByType() : String
      {
         var _loc1_:String = null;
         if(this.m_warehouse.type == "navy")
         {
            _loc1_ = "NavyDepotPartsGatherDescription";
         }
         else if(this.m_warehouse.type == "air")
         {
            _loc1_ = "DepotPartsGatherDescription";
         }
         else if(this.m_warehouse.type == "army")
         {
            _loc1_ = "ArmyDepotPartsGatherDescription";
         }
         return _loc1_;
      }
      
      private function onFinishedParts(param1:WorldEvent) : void
      {
         this.m_warehouse.owner.eventDispatcher.dispatchEvent(new WorldEvent(WarehouseComponent.EVENT_WAREHOUSE_UPGRADE,param1.eventData));
         this.onCloseClickParts(null);
         this.refreshView();
      }
      
      private function onCloseClickParts(param1:CloseEvent) : void
      {
         this.visible = true;
         this.m_eventDispatcher.removeEventListener(WarehouseUnitScreen.FINISH_UPGRADE,this.onFinishedParts);
         this.m_eventDispatcher.removeEventListener(CloseEvent.CLOSE,this.onCloseClickParts);
      }
      
      protected function onSlotSelected(param1:WorldEvent) : void
      {
         var _loc2_:WarehouseUnitSlot = null;
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         if(param1.eventData is WarehouseUnitSlot)
         {
            _loc2_ = WarehouseUnitSlot(param1.eventData);
            _loc3_ = UnitItem(_loc2_.getData()).code;
            Logger.print(this,"JMR: onSlotSelected itemCode: " + _loc3_);
            GameModeManager.instance.addGameMode(new GMWarehouseObjectPlace(_loc3_,_loc2_.warehouse,null));
            this.close();
         }
         else if(param1.eventData is WarehouseBuyMoreSpaceSlot)
         {
            this.getMoreButtonClick(null);
         }
      }
      
      protected function onExitClicked(param1:MouseEvent) : void
      {
         WarehouseUnitsGrid.setPageNum(0);
         this.close();
      }
      
      override public function forceClose() : void
      {
         this.close();
      }
      
      override protected function close(param1:Event = null) : void
      {
         m_window["GridDialog_mc"].exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
         UIDispatcher.instance.removeEventListener(GridSlot.SELECTED,this.onSlotSelected);
         this.m_getMoreSpaceButton.removeEventListener(MouseEvent.CLICK,this.getMoreButtonClick);
         this.m_eventDispatcher.dispatchEvent(new Event(EXIT));
         super.close();
         this.dispose();
      }
      
      public function dispose() : void
      {
         if(this.m_unitsGrid)
         {
            this.m_unitsGrid.dispose();
            this.m_unitsGrid = null;
         }
      }
   }
}

