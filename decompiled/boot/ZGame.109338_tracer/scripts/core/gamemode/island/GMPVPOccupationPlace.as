package core.gamemode.island
{
   import Engine.MathUtil;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.PVPOccupationMarkerPickOnlyComponent;
   import core.entities.components.PVPOccupationMarkerPillageComponent;
   import core.gamemode.GMVisit;
   import core.gamemode.GridPointer;
   import core.managers.BuildManager;
   import core.managers.PVPManager;
   import core.ui.PlayerFeedbackManager;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import utils.TileUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.ISpatialObjectISO;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   
   public class GMPVPOccupationPlace extends GMVisit
   {
      
      private static var m_existingMarkerName:String;
      
      private var m_currentPos:Point;
      
      private var m_markerEntity:IEntity;
      
      private var m_locked:Boolean;
      
      public function GMPVPOccupationPlace()
      {
         super();
      }
      
      override public function enableMode() : void
      {
         super.enableMode();
         GridPointer.instance.hide = true;
      }
      
      override public function disableMode() : void
      {
         super.disableMode();
         Zlab.processManager.removeScheduledObject(this);
         this.disposeMarkerProxy();
         PVPManager.instance.removeEventListener(PVPManager.LAST_MINUTE_IMMUNITY,this.onLastMinuteImmunity);
      }
      
      override protected function onDoEnteredMode(param1:Object) : void
      {
         super.onDoEnteredMode(param1);
         this.doIslandLoadedActions();
         PVPManager.instance.addEventListener(PVPManager.LAST_MINUTE_IMMUNITY,this.onLastMinuteImmunity,false,0,true);
      }
      
      override protected function doHandleMouseMove(param1:Point) : void
      {
         this.mouseMoved();
      }
      
      override protected function getCursor() : Object
      {
         if(this.m_markerEntity)
         {
            return new Cursor_Attack(1,1);
         }
         return super.getCursor();
      }
      
      private function disposeMarkerProxy() : void
      {
         this.m_markerEntity = null;
      }
      
      private function mouseMoved() : Boolean
      {
         var _loc1_:Point = null;
         var _loc2_:Point = null;
         var _loc3_:ISpatialObjectISO = null;
         var _loc4_:Vector3D = null;
         var _loc5_:Point = null;
         var _loc6_:int = 0;
         var _loc7_:Point = null;
         if(Boolean(this.m_markerEntity) && !this.m_locked)
         {
            _loc1_ = this.currentTilePos;
            if(!this.m_currentPos || (_loc1_.x != this.m_currentPos.x || _loc1_.y != this.m_currentPos.y))
            {
               _loc2_ = TileUtil.tilePointToWorldPoint(_loc1_,true);
               _loc3_ = ISpatialObjectISO(this.m_markerEntity.lookupComponentByType(ISpatialObjectISO));
               _loc4_ = new Vector3D(_loc2_.x,_loc2_.y,0);
               _loc4_.x = MathUtil.clamp(_loc4_.x,0,BuildManager.instance.width * ZGlobal.cellSize);
               _loc4_.y = MathUtil.clamp(_loc4_.y,0,BuildManager.instance.length * ZGlobal.cellSize);
               _loc3_.position = _loc4_;
               if(this.m_currentPos)
               {
                  _loc7_ = PVPManager.instance.activityAreaCenterToRoot(this.m_currentPos,PVPManager.pvpLiveInvasionAreaSize);
                  PVPManager.instance.pillageMarkerInactive(ZGlobal.player.uid,_loc7_);
               }
               this.m_currentPos = _loc1_.clone();
               _loc5_ = PVPManager.instance.activityAreaCenterToRoot(_loc1_,PVPManager.pvpLiveInvasionAreaSize);
               _loc6_ = PVPManager.instance.isValidOccupationLocation(ZGlobal.hostPlayer.uid,_loc5_);
               if(_loc6_ != PVPManager.OCCUPATION_INVALID)
               {
                  if(_loc6_ == PVPManager.OCCUPATION_VALID_PROTECTED_BUILDING || _loc6_ == PVPManager.OCCUPATION_VALID_PROTECTED_AREA)
                  {
                     this.m_markerEntity.eventDispatcher.dispatchEvent(new Event(PVPOccupationMarkerPillageComponent.PLACING_VALID_PROTECTED));
                  }
                  else
                  {
                     this.m_markerEntity.eventDispatcher.dispatchEvent(new Event(PVPOccupationMarkerPillageComponent.PLACING_VALID));
                  }
                  PVPManager.instance.pillageMarkerActive(ZGlobal.player.uid,_loc5_,PVPManager.pvpLiveInvasionAreaSize,true,_loc6_);
               }
               else
               {
                  this.m_markerEntity.eventDispatcher.dispatchEvent(new Event(PVPOccupationMarkerPillageComponent.PLACING_INVALID));
               }
            }
            return true;
         }
         return false;
      }
      
      override protected function canBeSelected(param1:IEntity) : Boolean
      {
         return false;
      }
      
      override protected function doHandleClick(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         var _loc3_:PVPOccupationMarkerPillageComponent = null;
         if(Boolean(this.m_markerEntity) && Boolean(this.m_currentPos))
         {
            _loc2_ = PVPManager.instance.activityAreaCenterToRoot(this.m_currentPos,PVPManager.pvpLiveInvasionAreaSize);
            if(PVPManager.instance.isValidOccupationLocation(ZGlobal.hostPlayer.uid,_loc2_) != PVPManager.OCCUPATION_INVALID)
            {
               this.m_locked = true;
               this.m_markerEntity.eventDispatcher.dispatchEvent(new Event(IsoSpatialComponent.STOP));
               _loc3_ = PVPOccupationMarkerPillageComponent(this.m_markerEntity.lookupComponentByType(PVPOccupationMarkerPillageComponent));
               _loc3_.activityMarkerRoot = _loc2_;
               PVPManager.instance.finalizePillage(_loc2_);
            }
            else
            {
               PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackPVPMarkerInvalidPlacement"),this.m_markerEntity);
            }
         }
      }
      
      private function get currentWorldPos() : Pt
      {
         var _loc1_:Point = new Point(Zlab.mainStage.mouseX,Zlab.mainStage.mouseY);
         return screenToIso(new Pt(_loc1_.x,_loc1_.y,0));
      }
      
      private function get currentTilePos() : Point
      {
         var _loc1_:Pt = this.currentWorldPos;
         var _loc2_:Point = TileUtil.worldPointToTilePoint(_loc1_);
         _loc2_.x = int(_loc2_.x);
         _loc2_.y = int(_loc2_.y);
         return _loc2_;
      }
      
      private function getExistingOrCreatePillageEntity(param1:Point) : IEntity
      {
         var _loc2_:IEntity = null;
         if(m_existingMarkerName)
         {
            _loc2_ = Zlab.nameManager.lookup(m_existingMarkerName);
         }
         if(!_loc2_)
         {
            _loc2_ = PVPManager.instance.createPillageEntity(param1,PVPManager.pvpLiveInvasionAreaSize);
            m_existingMarkerName = _loc2_.name;
         }
         return _loc2_;
      }
      
      private function getExistingPillageEntity(param1:Point) : IEntity
      {
         var _loc2_:IEntity = null;
         if(m_existingMarkerName)
         {
            _loc2_ = Zlab.nameManager.lookup(m_existingMarkerName);
         }
         return _loc2_;
      }
      
      private function doIslandLoadedActions() : void
      {
         var _loc2_:Point = null;
         var _loc3_:IEntity = null;
         var _loc4_:Point = null;
         var _loc5_:Point = null;
         var _loc6_:ISpatialObjectISO = null;
         var _loc7_:Point = null;
         var _loc8_:IEntity = null;
         var _loc9_:PVPOccupationMarkerPickOnlyComponent = null;
         var _loc1_:Object = PVPManager.instance.getLocalPlayerInvasion();
         if(PVPManager.instance.canPlace())
         {
            PVPManager.instance.clearAreaImmunity();
            PVPManager.instance.updateAreaImmunity();
            PVPManager.instance.updateAreaImmunityBuildings();
            PVPManager.instance.updateAreaImmunityMarkers();
            PVPManager.instance.pillageMarkerDeactivateAll(ZGlobal.player.uid);
            this.m_markerEntity = this.getExistingOrCreatePillageEntity(this.currentTilePos);
            PVPManager.instance.startPillage(this.currentTilePos);
            this.m_markerEntity.eventDispatcher.dispatchEvent(new Event(IsoSpatialComponent.START));
            this.mouseMoved();
            updateCursor();
         }
         else if(Boolean(_loc1_) && _loc1_.status == PVPManager.STATUS_INCOMBAT)
         {
            _loc2_ = PVPManager.instance.parsePosition(_loc1_.pos);
            _loc3_ = this.getExistingOrCreatePillageEntity(_loc2_);
            _loc3_.eventDispatcher.dispatchEvent(new Event(PVPOccupationMarkerPillageComponent.PLACING_VALID));
            _loc4_ = PVPManager.activityAreaRootToCenter(_loc2_,PVPManager.pvpLiveInvasionAreaSize);
            _loc5_ = TileUtil.tilePointToWorldPoint(_loc4_,true);
            _loc6_ = ISpatialObjectISO(_loc3_.lookupComponentByType(ISpatialObjectISO));
            _loc6_.position = new Vector3D(_loc5_.x,_loc5_.y,0);
            PVPManager.instance.pillageMarkerActive(ZGlobal.player.uid,_loc2_,PVPManager.pvpLiveInvasionAreaSize,true);
         }
         else if(Boolean(_loc1_) && _loc1_.status == PVPManager.STATUS_OCCUPIED)
         {
            _loc7_ = PVPManager.instance.parsePosition(_loc1_.pos);
            _loc8_ = this.getExistingPillageEntity(_loc7_);
            if(_loc8_)
            {
               _loc9_ = _loc8_.lookupComponentByName("pvpmarkerpillage") as PVPOccupationMarkerPickOnlyComponent;
               _loc9_.isoOutlineRectSize = PVPManager.getInvasionAreaFromInvader(_loc1_);
               _loc9_.createOrUpdateRect();
            }
         }
      }
      
      private function onLastMinuteImmunity(param1:WorldEvent) : void
      {
         PVPManager.instance.performLastMinuteImmunity(param1.eventData);
         param1.stopImmediatePropagation();
      }
   }
}

