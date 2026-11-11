package core.gamemode
{
   import as3isolib.bounds.IBounds;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.Pt;
   import core.ZGameManager;
   import core.ZGlobal;
   import core.gamemode.helpers.PlacementProxy;
   import core.gamemode.helpers.RoadPlacementProxy;
   import core.gamemode.island.GMIsland;
   import core.gameobjects.RoadGameItem;
   import core.managers.BuildManager;
   import core.managers.PVPManager;
   import core.managers.warehouseManager.WarehouseExperimentManager;
   import core.managers.warehouseManager.WarehouseHoverManager;
   import core.ui.PickManager;
   import core.ui.menuitem.OptionUIItem;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.IslandMapComponent;
   import dispatchers.UIDispatcher;
   import entity.GameDataComponent;
   import entity.WarehouseComponent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import rendering.renderingIso.QuadTreeLayoutRenderer;
   import rendering.road.RoadRendererComponent;
   import sound.SoundEvent;
   import utils.TileUtil;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.ISpatialObjectISO;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   import zlabs.utils.MathUtils;
   
   public class GMObjectMove extends GMIsland
   {
      
      protected var m_cid:int;
      
      protected var m_highlightedPoint:Pt = new Pt();
      
      protected var m_currentPos:Point = new Point();
      
      protected var m_isoPt:Pt = new Pt();
      
      protected var m_positionValid:Boolean = false;
      
      protected var m_objectStartPos:Vector3D = null;
      
      protected var m_source:int = 0;
      
      protected var m_storageCursor:Object = new Cursor_Storage(1,1);
      
      protected var m_objectPlacedSuccess:Boolean = false;
      
      protected var m_validWarehousePlace:Boolean = false;
      
      protected var m_roadPlacedSuccess:Boolean = false;
      
      protected var m_validStorageClasses:Array = new Array();
      
      private const INVALIDBUILD_NONE:int = 0;
      
      private const INVALIDBUILD_TERRAIN:int = 1;
      
      private const INVALIDBUILD_OBSTACLE:int = 2;
      
      private const INVALIDBUILD_INVASION:int = 3;
      
      private var m_dragStartPos:Point;
      
      protected var m_oldState:String;
      
      protected var m_storedOrigin:int = 0;
      
      protected var m_containerCollided:Boolean = false;
      
      protected var m_selectedObjectProxy:PlacementProxy;
      
      private var m_objectsCollided:Array = new Array();
      
      protected var delta:Point = new Point();
      
      protected var m_highlightedRoad:RoadGameItem;
      
      protected var m_selectedRoadProxy:RoadPlacementProxy;
      
      public function GMObjectMove(param1:IEntity, param2:String = null)
      {
         if(GameModeManager.instance.getTopGameMode() is GMObjectMove)
         {
            GameModeManager.instance.popGameMode();
         }
         if(param1 != null && !this.m_selectedObjectProxy)
         {
            this.m_selectedObjectProxy = new PlacementProxy(param1 as IEntity);
         }
         this.m_oldState = param2;
         if(this.m_selectedObjectProxy)
         {
            this.m_objectStartPos = this.m_selectedObjectProxy.getPosition();
         }
         super();
      }
      
      override public function enableMode() : void
      {
         var _loc1_:IBounds = null;
         super.enableMode();
         getMouseStagePos(this.m_currentPos);
         if(Boolean(this.m_selectedObjectProxy) && Boolean(this.m_selectedObjectProxy.getMapResource()))
         {
            this.m_selectedObjectProxy.getMapResource().eventDispatcher.dispatchEvent(new Event(IsoSpatialComponent.START));
            _loc1_ = this.m_selectedObjectProxy.isoBounds();
            PlacementRect.instance.placementArray = this.m_selectedObjectProxy.placementArray();
            PlacementRect.instance.canBuildOn = this.m_selectedObjectProxy.canBuildOn;
            PlacementRect.instance.bounds = new Pt(_loc1_.width,_loc1_.length);
            PlacementRect.instance.active = true;
            WarehouseExperimentManager.instance.addArrowToAvailableWarehouseIfValid(this.m_selectedObjectProxy.getMapResource());
            if(m_useSelectionMask)
            {
               SelectionMasker.instance.setEntityTarget(this.m_selectedObjectProxy.getMapResource(),true);
            }
         }
         UIDispatcher.instance.addEventListener(OptionUIItem.EXIT,onExitMode,false,0,true);
         PickManager.picksEnabled = false;
         this.onMouseMove(null);
      }
      
      override public function get tooltip() : String
      {
         return "generic_move";
      }
      
      override public function onMouseMove(param1:MouseEvent) : Boolean
      {
         var _loc2_:int = 0;
         getMouseStagePos(this.m_currentPos);
         screenToIso(this.m_currentPos,this.m_highlightedPoint);
         if(this.m_selectedObjectProxy)
         {
            _loc2_ = this.updateHighlightPoint(this.m_highlightedPoint);
            this.m_positionValid = _loc2_ == this.INVALIDBUILD_NONE;
            if(WarehouseExperimentManager.instance.masterOn)
            {
               WarehouseHoverManager.instance.update(this.m_positionValid,this.m_highlightedPoint,this.m_currentPos,this.m_selectedObjectProxy);
            }
            this.m_selectedObjectProxy.moveTo(Pt.toVector3D(this.m_highlightedPoint));
            SelectionMasker.instance.updateTargetPosition(this.m_highlightedPoint);
            PlacementRect.instance.invalidate = _loc2_ == this.INVALIDBUILD_OBSTACLE;
            PlacementRect.instance.position = this.m_highlightedPoint;
         }
         else if(this.m_selectedRoadProxy)
         {
            TileUtil.snapPointToGrid(this.m_highlightedPoint,false);
            this.m_selectedRoadProxy.onMouseMove(this.m_highlightedPoint);
            SelectionMasker.instance.updateTargetPosition(this.m_highlightedPoint);
         }
         return super.onMouseMove(param1);
      }
      
      protected function updateHighlightPoint(param1:Pt) : int
      {
         var _loc11_:Pt = null;
         var _loc2_:ISpatialObjectISO = this.m_selectedObjectProxy.isoSpatial;
         var _loc3_:IBounds = _loc2_.isoBounds;
         getMouseStagePos(this.m_currentPos);
         screenToIso(this.m_currentPos,param1);
         this.calculateRawHighlightedPoint(param1.clone() as Pt,_loc3_.width,_loc3_.length);
         var _loc4_:Pt = param1.clone() as Pt;
         MathUtils.snapToGrid(_loc4_,ZGlobal.cellSize);
         param1.x -= _loc3_.width * 0.5 - ZGlobal.cellSize * 0.5;
         param1.y -= _loc3_.length * 0.5 - ZGlobal.cellSize * 0.5;
         MathUtils.snapToGrid(param1,ZGlobal.cellSize);
         BuildManager.instance.clamp(param1,_loc3_.width * 0.5);
         param1.z = 1;
         var _loc5_:GameDataComponent = GameDataComponent((this.m_selectedObjectProxy.getMapResource() as IEntity).lookupComponentByType(GameDataComponent));
         var _loc6_:IslandMapComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IslandMapComponent) as IslandMapComponent;
         var _loc7_:Pt = this.m_selectedObjectProxy.originalBounds;
         var _loc8_:Pt = param1.clone() as Pt;
         var _loc9_:int = _loc5_.direction;
         var _loc10_:Pt = new Pt(_loc3_.width,_loc3_.length);
         BuildManager.instance.modifyPosForPlacement(_loc9_,_loc10_,_loc8_);
         if(!BuildManager.instance.isValidForBuild(_loc8_,_loc9_,_loc7_.x,_loc7_.y,this.m_selectedObjectProxy.placementArray(),_loc5_.gameData.canBuildOn,_loc6_))
         {
            return this.INVALIDBUILD_TERRAIN;
         }
         if(_loc5_.gameData.isAreaImmunityBuilding())
         {
            _loc11_ = new Pt(_loc3_.width,_loc3_.width);
            if(PVPManager.instance.buildingUnderInvasionMarkerInfluence(this.m_selectedObjectProxy.getMapResource() as IEntity,_loc8_))
            {
               return this.INVALIDBUILD_INVASION;
            }
         }
         return this.INVALIDBUILD_NONE;
      }
      
      private function calculateRawHighlightedPoint(param1:Pt, param2:Number, param3:Number) : void
      {
         var _loc4_:Pt = param1;
         var _loc5_:Number = int(param2 / ZGlobal.cellSize) % 2 ? 0 : 1;
         var _loc6_:Number = int(param3 / ZGlobal.cellSize) % 2 ? 0 : 1;
         _loc5_ *= ZGlobal.cellSize * 0.5;
         _loc6_ *= ZGlobal.cellSize * 0.5;
         _loc4_.x -= _loc5_;
         _loc4_.y -= _loc6_;
         MathUtils.snapToGrid(_loc4_,ZGlobal.cellSize);
         BuildManager.instance.clamp(_loc4_,param2 * 0.5);
         _loc4_.x += _loc5_;
         _loc4_.y += _loc6_;
         BuildManager.instance.rawPlacementPosition = _loc4_;
      }
      
      private function warehouseValidate() : Boolean
      {
         if(this.m_positionValid && WarehouseExperimentManager.instance.masterOn)
         {
            if(WarehouseHoverManager.instance.cachedState)
            {
               if(Boolean(WarehouseHoverManager.instance.cachedState.noAccept) || Boolean(WarehouseHoverManager.instance.cachedState.atLimit) || Boolean(WarehouseHoverManager.instance.cachedState.invalidUnit))
               {
                  return false;
               }
            }
         }
         return this.m_positionValid;
      }
      
      override protected function doHandleClick(param1:MouseEvent) : void
      {
         var _loc3_:IsoViewComponent = null;
         var _loc4_:IsoScene = null;
         var _loc5_:IEntity = null;
         var _loc6_:Object = null;
         var _loc7_:IEntity = null;
         var _loc8_:Object = null;
         var _loc9_:IEntity = null;
         var _loc10_:Boolean = false;
         if(!this.m_selectedObjectProxy && !this.m_selectedRoadProxy)
         {
            return;
         }
         var _loc2_:Boolean = false;
         if(this.m_selectedObjectProxy)
         {
            this.m_positionValid = this.updateHighlightPoint(this.m_highlightedPoint) == this.INVALIDBUILD_NONE;
            this.m_positionValid = this.warehouseValidate();
            if(this.m_positionValid)
            {
               _loc3_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
               _loc4_ = IsoScene(_loc3_.getSceneByID(ZGameManager.SCENE_GROUND_LAYER));
               this.m_highlightedPoint.z = 0;
               this.m_selectedObjectProxy.moveTo(Pt.toVector3D(this.m_highlightedPoint),false);
               SoundEvent.getSoundEvent("PlaceItem").play();
               this.m_selectedObjectProxy.getMapResource().eventDispatcher.dispatchEvent(new Event(IsoSpatialComponent.STOP));
               this.m_objectPlacedSuccess = true;
               this.m_objectStartPos = null;
               _loc5_ = ViewManager.instance.getView(IslandWorld.ID);
               _loc5_.eventDispatcher.dispatchEvent(new Event(IsoViewComponent.UPDATE_VIEW));
               _loc2_ = true;
               PlacementRect.instance.active = false;
               WarehouseExperimentManager.instance.clearArrows();
            }
         }
         else if(this.m_selectedRoadProxy)
         {
            this.m_roadPlacedSuccess = this.m_selectedRoadProxy.onMouseClick();
            if(this.m_roadPlacedSuccess)
            {
               SoundEvent.getSoundEvent("PlaceRoad").play();
               _loc2_ = true;
            }
         }
         if(_loc2_ && m_useSelectionMask)
         {
            SelectionMasker.instance.clearTarget(true);
         }
         if(WarehouseExperimentManager.instance.masterOn && Boolean(WarehouseHoverManager.instance.cachedState))
         {
            _loc6_ = WarehouseHoverManager.instance.cachedState;
            Logger.print(this,"JMR: validWarehousePlacement: " + _loc6_.validWarehousePlacement);
            Logger.print(this,"JMR: targetType: " + _loc6_.targetType);
            Logger.print(this,"JMR: currentType: " + _loc6_.currentType);
            Logger.print(this,"JMR: itemName: " + _loc6_.itemName);
            Logger.print(this,"JMR: itemCode: " + _loc6_.itemCode);
            if(WarehouseHoverManager.instance.cachedState.validWarehousePlacement)
            {
               _loc8_ = WarehouseHoverManager.instance.cachedState;
               _loc7_ = _loc8_.warehouseEntity;
               _loc9_ = this.m_selectedObjectProxy.getMapResource();
               if(this.validateEntityInteration(_loc7_))
               {
                  Logger.print(this,"JMR: Adding item to warehouse: " + _loc7_.alias);
                  _loc7_.eventDispatcher.dispatchEvent(new WorldEvent(WarehouseComponent.EVENT_WAREHOUSE_ADD,{
                     "item":_loc9_,
                     "itemCode":_loc8_.itemCode,
                     "source":this.m_source
                  }));
                  this.removeFromSource();
                  WarehouseHoverManager.instance.source = null;
               }
               Logger.print(this,"JMR: Removing item from board: " + _loc9_.alias);
               _loc10_ = true;
               GameModeManager.instance.setDefaultGameMode();
               GMSell.clearObject(_loc9_,_loc10_);
               this.m_objectPlacedSuccess = false;
               this.m_selectedObjectProxy.dispose();
               this.m_selectedObjectProxy = null;
            }
            if(WarehouseHoverManager.instance.cachedState.validWarehousePlacement)
            {
               WarehouseHoverManager.instance.clearCache();
            }
         }
      }
      
      protected function contextCursor() : Boolean
      {
         if(WarehouseExperimentManager.instance.masterOn && Boolean(WarehouseHoverManager.instance.cachedState))
         {
            if(WarehouseHoverManager.instance.cachedState.validWarehousePlacement)
            {
               return true;
            }
         }
         return false;
      }
      
      override protected function getCursor() : Object
      {
         if(this.contextCursor())
         {
            return this.m_storageCursor;
         }
         return super.getCursor();
      }
      
      private function placeObject(param1:Vector3D, param2:Boolean = false) : void
      {
         this.m_selectedObjectProxy.moveTo(this.m_objectStartPos,false);
         var _loc3_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         var _loc4_:IsoScene = IsoScene(_loc3_.getSceneByID(ZGameManager.SCENE_GROUND_LAYER));
         QuadTreeLayoutRenderer(_loc4_.layoutRenderer).sortAllObjects(_loc4_);
         this.m_selectedObjectProxy.getMapResource().eventDispatcher.dispatchEvent(new Event(IsoSpatialComponent.STOP));
         this.m_selectedObjectProxy.onObjectDrop();
      }
      
      override public function disableMode() : void
      {
         UIDispatcher.instance.removeEventListener(OptionUIItem.EXIT,onExitMode);
         if(this.m_objectPlacedSuccess == false && Boolean(this.m_selectedObjectProxy))
         {
            if(this.m_objectStartPos)
            {
               this.placeObject(this.m_objectStartPos);
            }
            this.m_selectedObjectProxy.dispose();
         }
         if(this.m_roadPlacedSuccess == false && Boolean(this.m_selectedRoadProxy))
         {
            this.m_selectedRoadProxy.dispose();
            this.m_selectedRoadProxy = null;
         }
         GridPointer.instance.highlight = false;
         if(m_useSelectionMask)
         {
            SelectionMasker.instance.clearTarget(true);
         }
         if(PlacementRect)
         {
            PlacementRect.instance.active = false;
            WarehouseExperimentManager.instance.clearArrows();
         }
         if(WarehouseExperimentManager.instance.masterOn)
         {
            WarehouseHoverManager.instance.clearCache();
         }
         this.m_highlightedRoad = null;
         PickManager.picksEnabled = true;
         super.disableMode();
      }
      
      protected function validateEntityInteration(param1:IEntity) : Boolean
      {
         return true;
      }
      
      protected function removeFromSource() : void
      {
      }
      
      override protected function selectObjectAtMousePosition(param1:Point) : Boolean
      {
         var _loc3_:Pt = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Boolean = false;
         var _loc7_:RoadRendererComponent = null;
         var _loc2_:Boolean = null != this.m_highlightedRoad;
         this.m_highlightedRoad = null;
         if(!this.m_selectedRoadProxy)
         {
            _loc3_ = screenToIso(new Pt(param1.x,param1.y,0));
            _loc4_ = _loc3_.x / ZGlobal.cellSize;
            _loc5_ = _loc3_.y / ZGlobal.cellSize;
            _loc6_ = BuildManager.instance.getBuildType(_loc4_,_loc5_,BuildManager.instance.ROAD_STR);
            if((_loc6_) && !selectObjectAtGridPosition(_loc3_))
            {
               _loc7_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,RoadRendererComponent) as RoadRendererComponent;
               this.m_highlightedRoad = _loc7_.getSellDataObject(_loc4_,_loc5_);
               GridPointer.instance.hide = false;
               GridPointer.instance.highlight = true;
               SelectionMasker.instance.setGridTarget(new Point(_loc4_,_loc5_),false);
               return false;
            }
            GridPointer.instance.highlight = false;
            if(_loc2_)
            {
               SelectionMasker.instance.clearTarget(false);
            }
         }
         if(super.selectObjectAtMousePosition(param1))
         {
            GridPointer.instance.hide = true;
            return true;
         }
         return false;
      }
      
      override protected function get clearSelectionMaskOnDeselect() : Boolean
      {
         return super.clearSelectionMaskOnDeselect && null == this.m_highlightedRoad;
      }
      
      public function get isCurrentPlacementValid() : Boolean
      {
         return this.m_positionValid;
      }
   }
}

