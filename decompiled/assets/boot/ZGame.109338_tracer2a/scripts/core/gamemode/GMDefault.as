package core.gamemode
{
   import Engine.MathUtil;
   import as3isolib.display.IsoView;
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.UIControllerComponent;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.managers.BuildManager;
   import core.managers.DebugManager;
   import core.managers.WorldObjectManager;
   import core.ui.CursorManager;
   import core.ui.PlayerFeedbackManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import entity.GameDataComponent;
   import events.IsoViewEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import rendering.rendering2d.AnimationComponent;
   import rendering.rendering2d.GameArtComponent;
   import utils.ZGameUtils;
   import zlabs.Constants;
   import zlabs.Zlab;
   import zlabs.core.InputManager;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.ISpatialObjectISO;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   import zlabs.rendering.renderingISO.IsoSpriteComponent;
   import zlabs.rendering.renderingISO.IsoSpriteRenderer;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class GMDefault extends GameMode
   {
      
      protected var m_dragging:Boolean = false;
      
      protected var m_currentCursor:Object = null;
      
      protected var m_highlightedObject:IEntity = null;
      
      protected var m_viewPan:Point;
      
      private var m_isoView:IsoView = null;
      
      private var m_currentMousePos:Point = new Point();
      
      private var m_pickingCache:Dictionary = null;
      
      private var m_isoPt:Pt = new Pt();
      
      private var m_ignoreUIDeselect:Boolean = false;
      
      protected var m_useSelectionMask:Boolean = true;
      
      public function GMDefault()
      {
         super();
      }
      
      public static function isUnitOwnedByPlayer(param1:IEntity) : Boolean
      {
         if(ZGlobal.player.fleets.hasPlayerOwnedFleetNamed(param1.owningGroup.name,ZGlobal.player.uid))
         {
            return true;
         }
         return false;
      }
      
      public static function isUnitOwnedByEnemy(param1:IEntity) : Boolean
      {
         if(ZGlobal.hostPlayer.fleets.hasEnemyOwnedFleetNamed(param1.owningGroup.name,ZGlobal.player.uid))
         {
            return true;
         }
         return false;
      }
      
      override public function enableMode() : void
      {
         this.m_viewPan = new Point();
         var _loc1_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         this.m_isoView = _loc1_.isoView;
         GameModeManager.instance.addEventListener(BehaviorState.CURSOR_UPDATED_FROM_STATE_CHANGE,this.onCursorUpdatedFromState);
         super.enableMode();
         this.m_pickingCache = new Dictionary();
         Zlab.inputManager.addEventListener(InputManager.MOUSE_LEAVE,this.onMouseLeave);
      }
      
      override public function disableMode() : void
      {
         if(m_cursorId > 0)
         {
            CursorManager.removeCursor(m_cursorId);
            m_cursorId = 0;
         }
         this.deselectObject();
         this.m_isoView = null;
         GameModeManager.instance.removeEventListener(BehaviorState.CURSOR_UPDATED_FROM_STATE_CHANGE,this.onCursorUpdatedFromState);
         this.m_pickingCache = null;
         Zlab.inputManager.removeEventListener(InputManager.MOUSE_LEAVE,this.onMouseLeave);
         super.disableMode();
      }
      
      override public function onMouseDown(param1:MouseEvent) : Boolean
      {
         super.onMouseDown(param1);
         this.m_dragging = false;
         GameModeManager.instance.dispatchEvent(new Event(GameModeManager.DRAGSTOP));
         return true;
      }
      
      override public function onMouseUp(param1:MouseEvent) : Boolean
      {
         if(this.m_dragging == false)
         {
            if(null != m_mouseDownPos)
            {
               this.handleClick(param1);
            }
         }
         this.stopDragging();
         super.onMouseUp(param1);
         return true;
      }
      
      private function onMouseLeave(param1:Event) : void
      {
         this.stopDragging();
      }
      
      private function stopDragging() : void
      {
         if(this.m_dragging)
         {
            this.m_dragging = false;
            GameModeManager.instance.dispatchEvent(new Event(GameModeManager.DRAGSTOP));
         }
         m_mouseDownPos = null;
      }
      
      override public function onMouseMove(param1:MouseEvent) : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc2_:Point = new Point(Zlab.mainStage.mouseX,Zlab.mainStage.mouseY);
         if(Boolean(_loc2_) && Boolean(m_mouseDownPos) && _loc2_.subtract(m_mouseDownPos).length >= Constants.DRAG_CLICK_EPSILON)
         {
            if(!ZGlobal.stencilActive)
            {
               this.m_dragging = true;
               GameModeManager.instance.dispatchEvent(new Event(GameModeManager.DRAGSTART));
            }
         }
         if(this.m_dragging)
         {
            _loc3_ = this.m_isoView.currentZoom;
            this.m_viewPan.x = (m_mouseDownPos.x - _loc2_.x) / _loc3_;
            this.m_viewPan.y = (m_mouseDownPos.y - _loc2_.y) / _loc3_;
            m_mouseDownPos.x = _loc2_.x;
            m_mouseDownPos.y = _loc2_.y;
            this.clampDeltaToMapBorder(this.m_viewPan);
            this.m_isoView.pan(this.m_viewPan.x,this.m_viewPan.y);
            if(_loc2_.subtract(this.m_currentMousePos).length > ZGlobal.cellSize)
            {
               if(GameModeManager.instance.hasEventListener(IsoViewEvent.ISOVIEW_PAN))
               {
                  GameModeManager.instance.dispatchEvent(new IsoViewEvent(IsoViewEvent.ISOVIEW_PAN));
               }
               this.m_currentMousePos = _loc2_;
            }
         }
         else
         {
            this.doHandleMouseMove(_loc2_);
         }
         return true;
      }
      
      protected function clampDeltaToMapBorder(param1:Point) : void
      {
         var _loc2_:Pt = this.m_isoView.currentPt;
         _loc2_.x += param1.x;
         _loc2_.y += param1.y;
         _loc2_ = IsoMath.screenToIso(_loc2_);
         var _loc3_:Number = BuildManager.instance.width * ZGlobal.cellSize;
         var _loc4_:Number = 0;
         var _loc5_:Number = MathUtil.clamp(_loc2_.x,_loc4_,_loc3_);
         if(_loc5_ != _loc2_.x)
         {
            param1.x -= _loc2_.x - _loc5_;
         }
         var _loc6_:Number = MathUtil.clamp(_loc2_.y,_loc4_,_loc3_);
         if(_loc6_ != _loc2_.y)
         {
            param1.y -= _loc2_.y - _loc6_;
         }
      }
      
      protected function doHandleMouseMove(param1:Point) : void
      {
         if(!this.selectObjectAtMousePosition(param1))
         {
            this.deselectObject();
         }
      }
      
      protected function selectObjectAtMousePosition(param1:Point) : Boolean
      {
         var _loc2_:Pt = screenToIso(param1,this.m_isoPt);
         if(this.selectObjectAtGridPosition(_loc2_))
         {
            return true;
         }
         if(this.selectObjectsAtWidePosition(_loc2_,param1))
         {
            return true;
         }
         return false;
      }
      
      private function selectObjectsAtWidePosition(param1:Pt, param2:Point) : Boolean
      {
         var _loc7_:String = null;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc10_:Object = null;
         var _loc11_:IEntity = null;
         var _loc12_:IsoSpriteComponent = null;
         var _loc13_:Point = null;
         var _loc14_:IsoSpriteRenderer = null;
         var _loc15_:Pt = null;
         var _loc16_:GameArtComponent = null;
         var _loc3_:uint = 3;
         var _loc4_:Pt = new Pt();
         var _loc5_:Point = new Point(0,0);
         var _loc6_:Point = new Point(param2.x,param2.y);
         for(_loc7_ in this.m_pickingCache)
         {
            delete this.m_pickingCache[_loc7_];
         }
         _loc8_ = 0;
         while(_loc8_ < _loc3_)
         {
            _loc9_ = 0;
            while(_loc9_ < _loc3_)
            {
               if(!(_loc8_ == 0 && _loc9_ == 0))
               {
                  _loc4_.x = param1.x + _loc9_ * ZGlobal.cellSize;
                  _loc4_.y = param1.y + _loc8_ * ZGlobal.cellSize;
                  _loc10_ = BuildManager.instance.getObjectAt(_loc4_);
                  if(_loc10_)
                  {
                     _loc11_ = IEntity(_loc10_);
                     if(null == this.m_pickingCache[_loc11_.name])
                     {
                        this.m_pickingCache[_loc11_.name] = true;
                        if(this.canBeSelected(_loc11_))
                        {
                           _loc12_ = _loc11_.lookupComponentByType(IsoSpriteComponent) as IsoSpriteComponent;
                           _loc13_ = _loc12_.isoSprite.container.globalToLocal(_loc6_);
                           _loc14_ = _loc11_.lookupComponentByType(IsoSpriteRenderer) as IsoSpriteRenderer;
                           _loc15_ = _loc14_.imageOffset;
                           _loc13_.x -= _loc15_.x;
                           _loc13_.y -= _loc15_.y;
                           _loc16_ = _loc11_.lookupComponentByType(GameArtComponent) as GameArtComponent;
                           if(null != _loc16_.bitmapData && _loc16_.bitmapData.hitTest(_loc5_,1,_loc13_))
                           {
                              this.locallySelectEntity(_loc11_);
                              return true;
                           }
                           if(this.selectObjectAnimationsAtMousePosition(_loc11_,_loc13_))
                           {
                              this.locallySelectEntity(_loc11_);
                              return true;
                           }
                        }
                     }
                  }
               }
               _loc9_++;
            }
            _loc8_++;
         }
         return false;
      }
      
      private function selectObjectAnimationsAtMousePosition(param1:IEntity, param2:Point) : Boolean
      {
         var _loc4_:AnimationComponent = null;
         var _loc3_:Array = param1.lookupComponentsByType(AnimationComponent);
         for each(_loc4_ in _loc3_)
         {
            if(_loc4_.mouseHitTest(param2))
            {
               return true;
            }
         }
         return false;
      }
      
      protected function selectObjectAtGridPosition(param1:Pt) : Boolean
      {
         var _loc3_:IEntity = null;
         var _loc2_:Object = BuildManager.instance.getObjectAt(param1);
         if(_loc2_)
         {
            _loc3_ = IEntity(_loc2_);
            if(this.canBeSelected(_loc3_))
            {
               this.locallySelectEntity(_loc3_);
               return true;
            }
         }
         return false;
      }
      
      private function locallySelectEntity(param1:IEntity) : void
      {
         this.selectEntity(param1,new MouseEvent(MouseEvent.MOUSE_OVER));
         if(this.m_useSelectionMask)
         {
            SelectionMasker.instance.setEntityTarget(param1,false);
         }
         GridPointer.instance.hide = true;
      }
      
      protected function selectObject(param1:ISpatialObjectISO, param2:MouseEvent = null) : void
      {
         var _loc3_:IEntity = param1 ? IsoSpatialComponent(param1).owner : null;
         this.selectEntity(_loc3_,param2);
      }
      
      protected function selectEntity(param1:IEntity, param2:MouseEvent) : void
      {
         if(param1 != this.m_highlightedObject)
         {
            this.deselectObject();
            this.m_highlightedObject = param1;
            this.highlightEntity(param2);
            this.updateCursor();
            this.debugSetHighlightedObject(param1);
         }
      }
      
      private function debugSetHighlightedObject(param1:IEntity) : void
      {
         var _loc3_:GameDataComponent = null;
         var _loc2_:String = "";
         if(param1)
         {
            _loc3_ = GameDataComponent.getGameDataComponent(param1);
            _loc2_ = _loc3_.gameData.name + " (" + _loc3_.gameData.code + ")" + "   (id:" + _loc3_.id + ")";
         }
         DebugManager.instance.highlightedObject = _loc2_;
      }
      
      protected function highlightEntity(param1:MouseEvent) : void
      {
         if(this.m_highlightedObject)
         {
            this.m_highlightedObject.eventDispatcher.dispatchEvent(param1);
         }
      }
      
      protected function canBeClicked(param1:MouseEvent) : Boolean
      {
         var _loc2_:BuildingFSMComponent = null;
         if(this.m_highlightedObject != null)
         {
            if(!isUnitOwnedByEnemy(this.m_highlightedObject))
            {
               _loc2_ = BuildingFSMComponent(this.m_highlightedObject.lookupComponentByType(BuildingFSMComponent));
               if(_loc2_)
               {
                  return BehaviorState(_loc2_.stateMachine.getCurrentState()).isVisitOnly() != true;
               }
            }
         }
         return false;
      }
      
      protected function canBeSelected(param1:IEntity) : Boolean
      {
         return true;
      }
      
      private function handleClick(param1:MouseEvent) : void
      {
         if(this.m_highlightedObject)
         {
            WorldObjectManager.instance.dispatchEvent(new WorldEvent(WorldObjectManager.OBJECT_SELECTED,this.m_highlightedObject));
         }
         this.doHandleClick(param1);
      }
      
      protected function doHandleClick(param1:MouseEvent) : void
      {
         var _loc2_:GameDataComponent = null;
         if(this.m_highlightedObject)
         {
            if(this.canBeClicked(param1))
            {
               this.m_highlightedObject.eventDispatcher.dispatchEvent(param1);
            }
            else
            {
               _loc2_ = GameDataComponent.getGameDataComponent(this.m_highlightedObject);
               if(_loc2_.gameData.type == "Buildable")
               {
                  switch(_loc2_.gameData.subType)
                  {
                     case "army":
                     case "navy":
                     case "air":
                        if(!ZGlobal.isVisiting())
                        {
                           PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Main","FeedbackSelectUnits"),this.m_highlightedObject);
                        }
                  }
               }
            }
         }
      }
      
      private function onCursorUpdatedFromState(param1:Event) : void
      {
         if(null != this.m_highlightedObject)
         {
            this.updateCursor();
         }
      }
      
      protected function updateCursor() : void
      {
         var _loc1_:Object = this.getCursor();
         this.setCursor(_loc1_);
      }
      
      protected function setCursor(param1:Object) : void
      {
         if(param1 != this.m_currentCursor)
         {
            if(m_cursorId > 0)
            {
               CursorManager.removeCursor(m_cursorId);
               m_cursorId = 0;
            }
            if(param1)
            {
               m_cursorId = CursorManager.setCursor(param1);
            }
            this.m_currentCursor = param1;
         }
      }
      
      protected function getCursor() : Object
      {
         var _loc2_:UIControllerComponent = null;
         var _loc1_:Object = m_cursorImage;
         if(this.m_highlightedObject)
         {
            _loc2_ = this.m_highlightedObject.lookupComponentByType(UIControllerComponent) as UIControllerComponent;
            if(_loc2_)
            {
               _loc1_ = _loc2_.getCursor(this.getCursorType());
            }
         }
         return _loc1_;
      }
      
      protected function getCursorType() : String
      {
         return null;
      }
      
      override public function ignoreUIDeselect() : void
      {
         this.m_ignoreUIDeselect = true;
      }
      
      override public function focusLost() : void
      {
         super.focusLost();
         this.deselect();
         this.stopDragging();
      }
      
      override public function deselect() : void
      {
         if(Boolean(this.m_highlightedObject) && !this.m_ignoreUIDeselect)
         {
            this.deselectObject();
         }
         this.m_ignoreUIDeselect = false;
      }
      
      protected function deselectObject() : void
      {
         if(this.m_highlightedObject)
         {
            this.m_highlightedObject.eventDispatcher.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
            this.m_highlightedObject = null;
         }
         this.debugSetHighlightedObject(null);
         GridPointer.instance.hide = false;
         if(this.clearSelectionMaskOnDeselect)
         {
            SelectionMasker.instance.clearTarget(false);
         }
         this.updateCursor();
      }
      
      override public function exitMode() : void
      {
         Zlab.inputManager.dispatchEvent(new Event(CursorManager.HIDE_CURSOR));
         GameModeManager.instance.popGameMode();
         GameModeManager.instance.setDefaultGameMode();
      }
      
      protected function get clearSelectionMaskOnDeselect() : Boolean
      {
         return this.m_useSelectionMask;
      }
      
      protected function onExitMode(param1:Event) : void
      {
         this.exitMode();
      }
   }
}

