package core.managers
{
   import core.ZGlobal;
   import core.gamemode.GMObjectPlace;
   import core.gamemode.GameModeManager;
   import core.gameobjects.GameItem;
   import core.gameobjects.PartsLEUnitItem;
   import core.gameobjects.UnitItem;
   import core.managers.viralsManager.ViralsManager;
   import core.managers.warehouseManager.WarehouseHoverManager;
   import displays.popups.FeedPopup;
   import displays.popups.GenericPopup;
   import displays.screens.leUnitFactoryScreens.LEUnitSelectionScreen;
   import events.GameModeEvent;
   import events.MarketEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class LEUnitFactoryManager
   {
      
      private static var m_instance:LEUnitFactoryManager = new LEUnitFactoryManager();
      
      public static const START_PLACEMENT:String = "startPlacement";
      
      private var m_lufEndDate:int;
      
      private var m_lufCodes:Object;
      
      private var m_partsConfig:Object;
      
      private var m_lufZRTData:Object;
      
      private var m_lufCodesLevelUnlocked:Object;
      
      private var m_placedToWarehouse:Boolean;
      
      private var m_eventDispatcher:EventDispatcher;
      
      private var m_cachedSlotData:Object;
      
      private var m_unitBeingPlaced:UnitItem;
      
      private var m_leUnitItem:PartsLEUnitItem;
      
      public function LEUnitFactoryManager()
      {
         super();
         this.m_eventDispatcher = new EventDispatcher();
      }
      
      public static function get instance() : LEUnitFactoryManager
      {
         return m_instance;
      }
      
      public function init(param1:Object) : void
      {
         this.lufCodes = param1.lufCodes;
         this.lufEndDate = param1.lufEndDate;
         this.lufZRTData = param1.lufZRTData;
         this.m_lufCodesLevelUnlocked = param1.lufCodesLevelUnlocked;
      }
      
      public function set lufEndDate(param1:int) : void
      {
         this.m_lufEndDate = param1;
      }
      
      public function get lufEndDate() : int
      {
         return this.m_lufEndDate;
      }
      
      public function set lufCodes(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         this.m_lufCodes = param1;
         for(_loc3_ in this.m_lufCodes)
         {
            _loc2_ = this.m_lufCodes[_loc3_];
         }
      }
      
      public function get lufCodes() : Object
      {
         return this.m_lufCodes;
      }
      
      public function set lufZRTData(param1:Object) : void
      {
         this.m_lufZRTData = param1;
      }
      
      public function getPartCountForIndex(param1:String, param2:int) : int
      {
         var _loc4_:String = null;
         var _loc6_:Object = null;
         var _loc3_:Object = this.m_lufZRTData[param1];
         var _loc5_:Object = _loc3_["unitParts"];
         for(_loc4_ in _loc5_)
         {
            _loc6_ = _loc5_[_loc4_];
            if(param2 == int(_loc6_["partIndex"]))
            {
               return int(_loc6_["partCount"]);
            }
         }
         return 0;
      }
      
      public function getPartCodeForIndex(param1:String, param2:int) : String
      {
         var _loc4_:String = null;
         var _loc6_:Object = null;
         var _loc3_:Object = this.m_lufZRTData[param1];
         var _loc5_:Object = _loc3_["unitParts"];
         for(_loc4_ in _loc5_)
         {
            _loc6_ = _loc5_[_loc4_];
            if(param2 == int(_loc6_["partIndex"]))
            {
               return _loc4_;
            }
         }
         return null;
      }
      
      public function extendTime() : void
      {
         var _loc1_:int = 1;
         var _loc2_:int = GlobalEngine.serverTime / 1000 + ZGlobal.player.timeWarpSeconds;
         if(_loc2_ > this.m_lufEndDate)
         {
            this.m_lufEndDate = _loc2_;
         }
         ZGlobal.player.cash -= 20;
         this.m_lufEndDate += 60 * 60 * 24 * _loc1_;
      }
      
      public function isLevelUnlocked(param1:String) : Boolean
      {
         return this.m_lufCodesLevelUnlocked != null ? Boolean(this.m_lufCodesLevelUnlocked[param1]) : false;
      }
      
      public function setLevelUnlocked(param1:String) : void
      {
         if(!this.m_lufCodesLevelUnlocked)
         {
            this.m_lufCodesLevelUnlocked = {};
         }
         this.m_lufCodesLevelUnlocked[param1] = true;
      }
      
      public function get eventDispatcher() : EventDispatcher
      {
         return this.m_eventDispatcher;
      }
      
      public function startBuildPlacement(param1:Object, param2:UnitItem, param3:PartsLEUnitItem, param4:IEntity) : void
      {
         this.m_eventDispatcher.dispatchEvent(new WorldEvent(START_PLACEMENT,{"unitItem":param2}));
         this.m_cachedSlotData = param1;
         this.m_unitBeingPlaced = param2;
         this.m_leUnitItem = param3;
         this.m_placedToWarehouse = false;
         WarehouseHoverManager.instance.source = param4;
         GameModeManager.instance.addGameMode(new GMObjectPlace(this.m_unitBeingPlaced.name,MarketEvent.SOURCE_BUILDING,false,null));
         WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_PLACED_CLIENT,this.onUnitPlaceSuccess,false,0,true);
         WorldObjectManager.instance.addEventListener(WorldObjectManager.OBJECT_PLACE_CANCELLED,this.onUnitPlaceCancel,false,0,true);
         GameModeManager.instance.addEventListener(GameModeEvent.ADD_MODE,this.onGameModeChange,false,0,true);
      }
      
      private function onUnitPlaceSuccess(param1:WorldEvent) : void
      {
         if(param1.eventData == "warehouse")
         {
            this.m_placedToWarehouse = true;
         }
         this.removePlacementListeners();
         this.deductParts();
      }
      
      private function onUnitPlaceCancel(param1:WorldEvent) : void
      {
         this.removePlacementListeners();
      }
      
      private function onGameModeChange(param1:Event) : void
      {
         this.removePlacementListeners();
      }
      
      private function removePlacementListeners() : void
      {
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_PLACED_CLIENT,this.onUnitPlaceSuccess);
         WorldObjectManager.instance.removeEventListener(WorldObjectManager.OBJECT_PLACE_CANCELLED,this.onUnitPlaceCancel);
         GameModeManager.instance.removeEventListener(GameModeEvent.ADD_MODE,this.onGameModeChange);
      }
      
      private function deductParts() : void
      {
         var _loc2_:GameItem = null;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         while(_loc1_ < this.m_cachedSlotData.length)
         {
            _loc2_ = this.m_cachedSlotData[_loc1_].partItem;
            _loc3_ = int(this.m_cachedSlotData[_loc1_].requiredCount);
            ZGlobal.player.removeInventoryItem(_loc2_.code,_loc3_);
            _loc1_++;
         }
         this.completePartsItem();
      }
      
      protected function completePartsItem() : void
      {
         var _loc2_:FeedPopup = null;
         var _loc3_:Object = null;
         if(!this.m_placedToWarehouse)
         {
            this.m_eventDispatcher.dispatchEvent(new WorldEvent(LEUnitSelectionScreen.FINISH_LE_UNIT,{"unitItem":this.m_leUnitItem}));
         }
         var _loc1_:GameItem = ZGlobal.gameSettings.getItemByName(this.m_leUnitItem.unit.name,GameItem) as GameItem;
         var _loc4_:String = "";
         _loc4_ = _loc4_ + ZGameUtils.ZlocT("FeedPopups","le_unit_complete",{"unitname":_loc1_.getSentenceNameLocalizationObject("singular")});
         _loc2_ = new FeedPopup(_loc4_,ZGameUtils.ZlocT("FeedPopups","le_unit_complete_title"),ZGameUtils.ZlocT("FeedPopups","feed_share_bttn"),GenericPopup.TYPE_SHARECANCEL,this.onLEUnitCompleteDialogClosed,ZGlobal.gameSettings.getImageByName(this.m_leUnitItem.unit.name,"icon"));
         _loc3_ = new Object();
         _loc3_.name = _loc1_.name;
         _loc3_.itemCode = _loc1_.code;
         _loc2_.userData = _loc3_;
         PopupManager.instance.push(_loc2_);
      }
      
      private function onLEUnitCompleteDialogClosed(param1:GenericPopupEvent) : void
      {
         var _loc2_:String = null;
         if(param1.button == GenericPopup.ACCEPT)
         {
            _loc2_ = "le_unit_complete";
            ViralsManager.instance.sendFeed(_loc2_,{
               "itemCode":param1.userData.itemCode,
               "ITEMTOKitem":param1.userData.name + "|"
            });
         }
      }
   }
}

