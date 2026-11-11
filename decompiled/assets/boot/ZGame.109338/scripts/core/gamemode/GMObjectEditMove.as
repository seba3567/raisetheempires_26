package core.gamemode
{
   import Engine.Managers.TransactionManager;
   import as3isolib.bounds.IBounds;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.gamemode.helpers.PlacementProxy;
   import core.gamemode.helpers.RoadPlacementProxy;
   import core.gamemode.helpers.UnitPlacementProxy;
   import core.managers.PVPManager;
   import core.managers.visitorManager.VisitorManager;
   import core.managers.warehouseManager.WarehouseExperimentManager;
   import core.ui.PlayerFeedbackManager;
   import core.ui.menuitem.OptionUIItem;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import core.worlds.islandworld.components.Island;
   import core.worlds.islandworld.components.IslandMapComponent;
   import dispatchers.UIDispatcher;
   import displays.popups.genericPopup.GenericPopup1B;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import transactions.TMove;
   import utils.TileUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   import zlabs.utils.MathUtils;
   
   public class GMObjectEditMove extends GMObjectMatchTerrainMove
   {
      
      private var m_cursor:Object = new Cursor_Move(1,1);
      
      public function GMObjectEditMove()
      {
         super(null);
         m_cursorImage = this.m_cursor;
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         VisitorManager.instance.addEventListener(VisitorManager.VISITOR_TARGET_HELPED,this.onTargetHelped,false,0,true);
      }
      
      override public function disableMode() : void
      {
         VisitorManager.instance.removeEventListener(VisitorManager.VISITOR_TARGET_HELPED,this.onTargetHelped);
         super.disableMode();
      }
      
      override protected function getCursor() : Object
      {
         if(contextCursor())
         {
            return super.getCursor();
         }
         return this.m_cursor;
      }
      
      override protected function canBeSelected(param1:IEntity) : Boolean
      {
         var _loc2_:GameDataComponent = null;
         var _loc3_:BuildingSpatialComponent = null;
         var _loc4_:IslandMapComponent = null;
         var _loc5_:Pt = null;
         var _loc6_:Island = null;
         if(Boolean(param1) && Boolean(m_selectedObjectProxy == null) && m_selectedRoadProxy == null)
         {
            _loc2_ = GameDataComponent(param1.lookupComponentByType(GameDataComponent));
            if(_loc2_ != null)
            {
               if(_loc2_.gameData.subType == "prop" || _loc2_.gameData.subType == "hook")
               {
                  return false;
               }
               if(_loc2_.actionActive)
               {
                  return false;
               }
               _loc3_ = param1.lookupComponentByType(BuildingSpatialComponent) as BuildingSpatialComponent;
               _loc4_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IslandMapComponent) as IslandMapComponent;
               _loc5_ = MathUtils.worldToTile(MathUtils.convertVector3DtoPt(_loc3_.position),ZGlobal.cellSize);
               _loc6_ = _loc4_.getIslandByPoint(_loc5_.x,_loc5_.y);
               if(null != _loc6_ && !_loc6_.isOwnedByLocalPlayer())
               {
                  return false;
               }
               return true;
            }
         }
         return false;
      }
      
      override protected function doHandleClick(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:GenericPopup1B = null;
         var _loc4_:IslandMapComponent = null;
         var _loc5_:Point = null;
         var _loc6_:Island = null;
         var _loc7_:IBounds = null;
         var _loc8_:String = null;
         var _loc9_:GenericPopup1B = null;
         var _loc10_:Pt = null;
         super.doHandleClick(param1);
         if(m_objectPlacedSuccess)
         {
            TransactionManager.addTransaction(new TMove(m_selectedObjectProxy.getMapResource(),m_highlightedPoint),true);
            m_objectPlacedSuccess = false;
            m_selectedObjectProxy.onObjectDrop(new Vector3D(m_highlightedPoint.x,m_highlightedPoint.y));
            m_selectedObjectProxy.dispose();
            m_selectedObjectProxy = null;
            PlacementRect.instance.active = false;
            WarehouseExperimentManager.instance.clearArrows();
            this.moveComplete();
         }
         else if(m_roadPlacedSuccess)
         {
            m_selectedRoadProxy.dispose();
            m_selectedRoadProxy = null;
            m_roadPlacedSuccess = false;
         }
         else if(Boolean(m_highlightedObject) && this.canBeSelected(m_highlightedObject))
         {
            if(PVPManager.instance.underInvasionMarkerInfluence(m_highlightedObject))
            {
               _loc2_ = ZGameUtils.ZlocT("Dialogs","PVPCannotMoveBuilding");
               _loc3_ = GenericPopup1B.NewOk(_loc2_,null);
               PopupManager.instance.push(_loc3_);
            }
            else
            {
               if(UnitDefenseRangeRect.isUnit(m_highlightedObject) || UnitDefenseRangeRect.isImmunityBuilding(m_highlightedObject))
               {
                  m_selectedObjectProxy = new UnitPlacementProxy(m_highlightedObject as IEntity);
               }
               else
               {
                  m_selectedObjectProxy = new PlacementProxy(m_highlightedObject as IEntity);
               }
               m_objectStartPos = m_selectedObjectProxy.getPosition();
               _loc4_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IslandMapComponent) as IslandMapComponent;
               _loc5_ = TileUtil.worldPointToTilePoint(m_highlightedPoint,true);
               _loc6_ = _loc4_.getIslandByPoint(_loc5_.x,_loc5_.y);
               if(_loc6_)
               {
                  m_selectedObjectProxy.islandID = _loc6_.code;
               }
               m_selectedObjectProxy.getMapResource().eventDispatcher.dispatchEvent(new Event(IsoSpatialComponent.START));
               SelectionMasker.instance.setEntityTarget(m_selectedObjectProxy.getMapResource(),true);
               _loc7_ = m_selectedObjectProxy.isoBounds();
               PlacementRect.instance.placementArray = m_selectedObjectProxy.placementArray();
               PlacementRect.instance.canBuildOn = m_selectedObjectProxy.canBuildOn;
               PlacementRect.instance.bounds = new Pt(_loc7_.width,_loc7_.length);
               PlacementRect.instance.active = true;
               WarehouseExperimentManager.instance.addArrowToAvailableWarehouseIfValid(m_highlightedObject);
               onMouseMove(null);
            }
         }
         else if(Boolean(m_highlightedRoad) && !m_selectedObjectProxy)
         {
            if(PVPManager.instance.positionUnderInvasionMarkerInfluence(m_highlightedRoad.x,m_highlightedRoad.y))
            {
               _loc8_ = ZGameUtils.ZlocT("Dialogs","PVPCannotMoveBuilding");
               _loc9_ = GenericPopup1B.NewOk(_loc8_,null);
               PopupManager.instance.push(_loc9_);
            }
            else
            {
               _loc10_ = new Pt(m_highlightedRoad.x,m_highlightedRoad.y);
               m_selectedRoadProxy = new RoadPlacementProxy(IslandWorld.ID,_loc10_,true);
               SelectionMasker.instance.setRoadTarget(m_selectedRoadProxy,true);
               onMouseMove(null);
            }
         }
         else if(m_selectedObjectProxy)
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackCannotPlaceHere"),m_selectedObjectProxy.getMapResource());
         }
         else if(m_selectedRoadProxy)
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackCannotPlaceHere"),new Vector3D(m_highlightedPoint.x,m_highlightedPoint.y + ZGlobal.cellSize));
         }
      }
      
      protected function moveComplete() : void
      {
         updatePointer();
      }
      
      private function onTargetHelped(param1:WorldEvent) : void
      {
         var _loc2_:IEntity = null;
         var _loc3_:GameDataComponent = null;
         if(m_selectedObjectProxy)
         {
            _loc2_ = m_selectedObjectProxy.getMapResource();
            if(_loc2_)
            {
               _loc3_ = GameDataComponent.getGameDataComponent(_loc2_);
               if(Boolean(_loc3_) && _loc3_.id == param1.eventData.id)
               {
                  UIDispatcher.instance.dispatchEvent(new Event(OptionUIItem.SELECTED_OBJECT_HELPED));
               }
            }
         }
      }
   }
}

