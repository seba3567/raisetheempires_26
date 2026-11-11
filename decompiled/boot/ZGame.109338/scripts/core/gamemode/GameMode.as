package core.gamemode
{
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import core.ui.CursorManager;
   import core.views.ViewManager;
   import core.worlds.islandworld.IslandWorld;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import zlabs.Zlab;
   import zlabs.core.InputManager;
   import zlabs.rendering.renderingISO.IsoViewComponent;
   
   public class GameMode
   {
      
      protected var m_enabled:Boolean = false;
      
      protected var m_cursorImage:Object = null;
      
      protected var m_cursorId:Object;
      
      protected var m_mouseDownPos:Point;
      
      private var m_cachedIsoScene:IsoScene = null;
      
      public function GameMode()
      {
         super();
      }
      
      public function dispose() : void
      {
      }
      
      public function updatePointer() : void
      {
         if(InputManager.enabled)
         {
            this.onMouseMove(null);
         }
      }
      
      public function ignoreUIDeselect() : void
      {
      }
      
      public function enableMode() : void
      {
         Zlab.inputManager.dispatchEvent(new Event(CursorManager.SHOW_CURSOR));
         Zlab.inputManager.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,1,true);
         Zlab.inputManager.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove,false,1,true);
         Zlab.inputManager.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,1,true);
         Zlab.inputManager.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel,false,0,true);
         if(this.m_cursorImage)
         {
            this.m_cursorId = CursorManager.setCursor(this.m_cursorImage);
         }
         this.cacheIsoScene();
         GridPointer.instance.snapScale = this.gridScale;
         this.m_enabled = true;
      }
      
      protected function cacheIsoScene() : void
      {
         var _loc1_:IsoViewComponent = null;
         if(null == this.m_cachedIsoScene)
         {
            _loc1_ = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
            this.m_cachedIsoScene = IsoScene(_loc1_.getSceneByID("gameScene"));
         }
      }
      
      public function disableMode() : void
      {
         this.m_enabled = false;
         this.m_cachedIsoScene = null;
         Zlab.inputManager.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
         Zlab.inputManager.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         Zlab.inputManager.removeEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
         Zlab.inputManager.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
         Zlab.inputManager.removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         if(this.m_cursorId != 0)
         {
            CursorManager.removeCursor(this.m_cursorId);
            this.m_cursorId = 0;
         }
      }
      
      public function screenToIso(param1:Point, param2:Pt = null) : Pt
      {
         var _loc3_:Point = this.m_cachedIsoScene.getContainer().globalToLocal(param1);
         if(param2)
         {
            param2.x = _loc3_.x;
            param2.y = _loc3_.y;
         }
         else
         {
            param2 = new Pt(_loc3_.x,_loc3_.y,0);
         }
         return IsoMath.screenToIso(param2);
      }
      
      public function isoToScreen(param1:Pt, param2:Point) : Point
      {
         var _loc3_:IsoViewComponent = ViewManager.instance.getComponentFromView(IslandWorld.ID,IsoViewComponent) as IsoViewComponent;
         return _loc3_.isoToLocal(param1);
      }
      
      public function get gridScale() : Number
      {
         return 1;
      }
      
      public function get tooltip() : String
      {
         return null;
      }
      
      public function get canSwitchToTutorial() : Boolean
      {
         return true;
      }
      
      public function get createParticlesOnLootPickup() : Boolean
      {
         return false;
      }
      
      protected function getMouseStagePos(param1:Point = null) : Point
      {
         if(!param1)
         {
            param1 = new Point();
         }
         param1.x = Zlab.mainStage.mouseX;
         param1.y = Zlab.mainStage.mouseY;
         return param1;
      }
      
      public function onMouseOut(param1:MouseEvent) : Boolean
      {
         return false;
      }
      
      public function onMouseDown(param1:MouseEvent) : Boolean
      {
         this.m_mouseDownPos = new Point(Zlab.mainStage.mouseX,Zlab.mainStage.mouseY);
         return false;
      }
      
      public function onMouseUp(param1:MouseEvent) : Boolean
      {
         this.m_mouseDownPos = null;
         return false;
      }
      
      public function onMouseDoubleClick(param1:MouseEvent) : Boolean
      {
         return false;
      }
      
      public function onMouseMove(param1:MouseEvent) : Boolean
      {
         return false;
      }
      
      public function onMouseWheel(param1:MouseEvent) : Boolean
      {
         return false;
      }
      
      public function onKeyDown(param1:KeyboardEvent) : Boolean
      {
         return false;
      }
      
      public function onKeyUp(param1:KeyboardEvent) : Boolean
      {
         return false;
      }
      
      protected function isDragging() : Boolean
      {
         return this.m_mouseDownPos != null;
      }
      
      public function deselect() : void
      {
      }
      
      public function focusLost() : void
      {
      }
      
      public function set overUI(param1:Boolean) : void
      {
      }
      
      public function exitMode() : void
      {
      }
   }
}

