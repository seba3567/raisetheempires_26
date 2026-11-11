package core.gamemode
{
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import core.ZGameManager;
   import core.ZGlobal;
   import core.gamemode.helpers.PlacementProxy;
   import core.gamemode.helpers.UnitPlacementProxy;
   import core.gameobjects.GameItem;
   import core.managers.WorldObjectManager;
   import core.managers.warehouseManager.WarehouseHoverManager;
   import core.ui.PlayerFeedbackManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import displays.popups.GenericPopup;
   import displays.screens.InventoryDialog;
   import entity.BuildingEntity;
   import entity.EntityInit;
   import entity.GameDataComponent;
   import entity.WarehouseComponent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import rendering.renderingIso.QuadSpatialManager;
   import utils.TileUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.core.PBGroup;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class GMWarehouseObjectPlace extends GMObjectMatchTerrainMove
   {
      
      private var m_type:String;
      
      private var m_statsInfo:Object = null;
      
      private var m_warehouse:WarehouseComponent;
      
      private var m_cursor:Object = new Cursor_Move(1,1);
      
      public function GMWarehouseObjectPlace(param1:String, param2:WarehouseComponent, param3:Object = null)
      {
         this.m_type = param1;
         this.m_warehouse = param2;
         this.m_statsInfo = param3;
         super(null);
         WarehouseHoverManager.instance.source = this.m_warehouse.owner;
         this.createSelectedObjectProxy();
      }
      
      public static function notifyPlacementPopup(param1:GameItem) : void
      {
         var _loc3_:String = null;
         var _loc2_:Object = new Object();
         var _loc4_:String = InventoryDialog.getTabLabelString(param1);
         _loc2_.tab = _loc4_;
         _loc3_ = "TBD_JMR_Cancel_Warehouse_Placement";
         PopupManager.instance.push(new GenericPopup(ZGameUtils.ZlocT("Dialogs",_loc3_,_loc2_)),100);
      }
      
      override protected function highlightEntity(param1:MouseEvent) : void
      {
      }
      
      override protected function getCursor() : Object
      {
         if(contextCursor())
         {
            return super.getCursor();
         }
         return this.m_cursor;
      }
      
      override public function disableMode() : void
      {
         WarehouseHoverManager.instance.source = null;
         super.disableMode();
      }
      
      private function createSelectedObjectProxy() : void
      {
         var _loc1_:IsoViewComponent = null;
         var _loc2_:IsoScene = null;
         var _loc3_:PBGroup = null;
         var _loc4_:GameItem = null;
         var _loc5_:QuadSpatialManager = null;
         var _loc6_:IEntity = null;
         var _loc7_:EntityInit = null;
         if(!m_selectedObjectProxy)
         {
            cacheIsoScene();
            _loc1_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
            _loc2_ = IsoScene(_loc1_.getSceneByID(ZGameManager.SCENE_GROUND_LAYER));
            screenToIso(getMouseStagePos(m_currentPos),m_highlightedPoint);
            _loc3_ = Zlab.nameManager.lookup(ZGameManager.WORLD_OBJECT_GROUP_NAME);
            _loc4_ = ZGlobal.gameSettings.getItemByName(this.m_type,GameItem) as GameItem;
            _loc5_ = QuadSpatialManager.getQuadSpatialManagerFromWorld(IslandWorld.ID,_loc4_);
            switch(_loc4_.type)
            {
               case GameItem.TYPE_BUILDABLE:
               case GameItem.TYPE_BUILDING:
                  _loc7_ = new EntityInit();
                  _loc7_.m_item = _loc4_;
                  _loc7_.m_isoScene = _loc2_;
                  _loc7_.m_fromLoad = false;
                  _loc7_.m_spatialComponent = _loc5_;
                  _loc7_.m_group = _loc3_;
                  _loc7_.m_delayId = true;
                  _loc7_.m_position = Pt.toPt(TileUtil.worldToTile(Pt.toVector3D(m_highlightedPoint),true));
                  _loc6_ = BuildingEntity.createEntity(_loc7_);
            }
            if(UnitDefenseRangeRect.isUnit(_loc6_) || UnitDefenseRangeRect.isImmunityBuilding(_loc6_))
            {
               m_selectedObjectProxy = new UnitPlacementProxy(_loc6_ as IEntity);
            }
            else
            {
               m_selectedObjectProxy = new PlacementProxy(_loc6_);
            }
            m_selectedObjectProxy.moveTo(Pt.toVector3D(m_highlightedPoint));
         }
      }
      
      override public function onMouseUp(param1:MouseEvent) : Boolean
      {
         var _loc3_:XML = null;
         var _loc4_:Boolean = false;
         var _loc5_:GameItem = null;
         var _loc6_:IEntity = null;
         var _loc7_:GameDataComponent = null;
         var _loc8_:GMDefault = null;
         var _loc2_:Boolean = m_dragging;
         super.onMouseUp(param1);
         if(m_objectPlacedSuccess)
         {
            _loc3_ = ZGlobal.gameSettings.getItemXMLByName(this.m_type);
            _loc4_ = true;
            _loc5_ = ZGlobal.gameSettings.getItemByName(this.m_type,GameItem) as GameItem;
            _loc6_ = m_selectedObjectProxy.getMapResource() as IEntity;
            WorldObjectManager.instance.addObjectToCodeDictionary(_loc5_.code);
            WorldObjectManager.instance.addObjectToTypeDictionary(_loc5_.type,_loc5_.subType,_loc6_.name,_loc6_);
            WorldObjectManager.instance.addObjectToCategoryDictionary(_loc5_.categoryLimitName);
            _loc7_ = GameDataComponent.getGameDataComponent(this.m_warehouse.owner);
            this.m_warehouse.owner.eventDispatcher.dispatchEvent(new WorldEvent(WarehouseComponent.EVENT_WAREHOUSE_REMOVE,{
               "warehouseId":_loc7_.id,
               "entity":m_selectedObjectProxy.getMapResource()
            }));
            WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_PLACED_CLIENT,this.m_type));
            m_selectedObjectProxy.onPurchased();
            _loc8_ = GameModeManager.instance.setDefaultGameMode();
            _loc8_.updatePointer();
            _loc8_ = null;
         }
         else if(!_loc2_ && Boolean(m_selectedObjectProxy))
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackCannotPlaceHere"),m_selectedObjectProxy.getMapResource());
         }
         return true;
      }
      
      override protected function validateEntityInteration(param1:IEntity) : Boolean
      {
         if(this.m_warehouse)
         {
            return param1 != this.m_warehouse.owner;
         }
         return true;
      }
      
      override protected function removeFromSource() : void
      {
         if(this.m_warehouse)
         {
            this.m_warehouse.remove(this.m_type);
         }
      }
      
      override protected function onExitMode(param1:Event) : void
      {
         var _loc2_:GameDataComponent = null;
         if(m_selectedObjectProxy)
         {
            _loc2_ = GameDataComponent(m_selectedObjectProxy.getMapResource().lookupComponentByType(GameDataComponent));
            WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_PLACE_CANCELLED,_loc2_.gameData.code));
            super.exitMode();
         }
      }
   }
}

