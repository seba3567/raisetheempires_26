package zlabs.rendering.renderingISO
{
   import as3isolib.bounds.IBounds;
   import as3isolib.core.IIsoDisplayObject;
   import as3isolib.data.INode;
   import as3isolib.display.IsoView;
   import as3isolib.display.scene.IIsoScene;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FullScreenEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import zlabs.Zlab;
   import zlabs.core.ITickedObject;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.utils.MathUtils;
   import zlabs.utils.geom.Polygon2D;
   
   public class IsoViewComponent extends EntityComponent implements ITickedObject
   {
      
      public static var GAME_SCENE:String = "gameScene";
      
      public static var UPDATE_VIEW:String = "eventUpdateView";
      
      protected var _isoView:IsoView;
      
      protected var _localDisplayContainer:DisplayObjectContainer;
      
      public var displayObjectContainerProperty:PropertyReference;
      
      private var screenRect:Rectangle = new Rectangle();
      
      private var screenCenter:Point = new Point();
      
      private var topLeftPt:Vector3D = new Vector3D();
      
      private var topRightPt:Vector3D = new Vector3D();
      
      private var bottomRightPt:Vector3D = new Vector3D();
      
      private var bottomLeftPt:Vector3D = new Vector3D();
      
      public function IsoViewComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         this.setRangeOfMotion();
         owner.eventDispatcher.addEventListener(FullScreenEvent.FULL_SCREEN,this.onFullScreen,false,0,true);
      }
      
      public function set isoView(param1:IsoView) : void
      {
         this._isoView = param1;
      }
      
      public function get isoView() : IsoView
      {
         return this._isoView;
      }
      
      public function get viewRect() : Rectangle
      {
         return this._isoView.getBounds(this._isoView.parent);
      }
      
      public function setRangeOfMotion() : void
      {
      }
      
      public function get displayContainer() : DisplayObjectContainer
      {
         if(this.displayObjectContainerProperty != null)
         {
            return owner.getProperty(this.displayObjectContainerProperty) as DisplayObjectContainer;
         }
         return this._localDisplayContainer;
      }
      
      public function set displayContainer(param1:DisplayObjectContainer) : void
      {
         this._localDisplayContainer = param1;
         if(this._localDisplayContainer != null)
         {
            this._localDisplayContainer.addChild(this._isoView as Sprite);
         }
      }
      
      public function createScene(param1:*, param2:Class = null) : IsoScene
      {
         var _loc3_:IsoScene = new IsoScene();
         _loc3_.id = param1;
         if(param2)
         {
            _loc3_.layoutRenderer = new param2();
         }
         this.isoView.addScene(_loc3_);
         return _loc3_;
      }
      
      public function addGameChild(param1:INode) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:IIsoScene = this.getSceneByID("gameScene");
         _loc2_.addChild(param1);
      }
      
      public function removeGameChild(param1:INode) : INode
      {
         if(!param1)
         {
            return null;
         }
         var _loc2_:IIsoScene = this.getSceneByID("gameScene");
         return _loc2_.removeChild(param1);
      }
      
      public function renderGameScene(param1:Boolean = false) : void
      {
         var _loc2_:IIsoScene = this.getSceneByID("gameScene");
         _loc2_.invalidateScene();
         _loc2_.render(param1);
      }
      
      public function getSceneByID(param1:*) : IIsoScene
      {
         return this.isoView.getSceneByID(param1);
      }
      
      public function onTick(param1:Number) : void
      {
         this._isoView.render(true);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         if(!this._isoView)
         {
            return;
         }
         (this._isoView as IsoView).removeAllScenes();
         Zlab.processManager.removeTickedObject(this);
      }
      
      override protected function onReset() : void
      {
         super.onReset();
         if(!this._isoView)
         {
            return;
         }
         if(this.displayContainer != null)
         {
            this.displayContainer.addChild(this._isoView as Sprite);
         }
      }
      
      public function setSize(param1:Number, param2:Number, param3:Number = 0, param4:Number = 0) : void
      {
         this.screenRect.x = param3;
         this.screenRect.y = param4;
         this.screenRect.width = param1;
         this.screenRect.height = param2;
         this.screenCenter.x = this.screenRect.right * 0.5;
         this.screenCenter.y = this.screenRect.bottom * 0.5;
         this.screenRect.inflate(40,40);
         this.isoView.setSize(param1,param2);
         this.isoView.x = param3;
         this.isoView.y = param4;
      }
      
      public function screenCenterPointInIso() : Pt
      {
         var _loc1_:Point = Point.interpolate(this.screenRect.topLeft,this.screenRect.bottomRight,0.5);
         return this.screenToIso(_loc1_);
      }
      
      public function screenRectToIso(param1:Pt = null, param2:Rectangle = null) : Rectangle
      {
         var _loc3_:Pt = null;
         if(param1)
         {
            _loc3_ = IsoMath.screenToIso(MathUtils.convertPointToPt(param1.clone()));
         }
         else
         {
            _loc3_ = this.screenCenterPointInIso();
         }
         var _loc4_:Pt = this.screenToIso(this.screenRect.bottomRight.clone());
         var _loc5_:Point = _loc4_.subtract(_loc3_);
         var _loc6_:Number = _loc5_.length;
         if(!param2)
         {
            param2 = new Rectangle();
         }
         param2.x = _loc3_.x - _loc6_;
         param2.y = _loc3_.y - _loc6_;
         param2.width = _loc6_ * 2;
         param2.height = _loc6_ * 2;
         return param2;
      }
      
      public function screenRectToPoly(param1:Polygon2D = null) : Polygon2D
      {
         if(!param1)
         {
            param1 = new Polygon2D();
         }
         var _loc2_:Pt = this.screenToIso(this.screenRect.topLeft);
         this.topLeftPt.x = _loc2_.x;
         this.topLeftPt.y = _loc2_.y;
         param1.addPoint(this.topLeftPt);
         _loc2_ = this.screenToIso(new Point(this.screenRect.x + this.screenRect.width,this.screenRect.y));
         this.topRightPt.x = _loc2_.x;
         this.topRightPt.y = _loc2_.y;
         param1.addPoint(this.topRightPt);
         _loc2_ = this.screenToIso(this.screenRect.bottomRight);
         this.bottomRightPt.x = _loc2_.x;
         this.bottomRightPt.y = _loc2_.y;
         param1.addPoint(this.bottomRightPt);
         _loc2_ = this.screenToIso(new Point(this.screenRect.x,this.screenRect.y + this.screenRect.height));
         this.bottomLeftPt.x = _loc2_.x;
         this.bottomLeftPt.y = _loc2_.y;
         param1.addPoint(this.bottomLeftPt);
         return param1;
      }
      
      private function onFullScreen(param1:Event) : void
      {
         this.setSize(Zlab.mainStage.stageWidth,Zlab.mainStage.stageHeight);
      }
      
      public function centerOnPt(param1:Pt, param2:Boolean = true) : void
      {
         this._isoView.centerOnPt(param1,param2);
         owner.eventDispatcher.dispatchEvent(new Event(IsoViewComponent.UPDATE_VIEW));
      }
      
      public function centerOnIso(param1:IIsoDisplayObject) : void
      {
         this._isoView.centerOnIso(param1);
         owner.eventDispatcher.dispatchEvent(new Event(IsoViewComponent.UPDATE_VIEW));
      }
      
      public function zoomLevel(param1:Number) : void
      {
         this._isoView.zoom(param1);
      }
      
      public function zoom(param1:Number) : void
      {
         this.zoomLevel(param1);
         owner.eventDispatcher.dispatchEvent(new Event(IsoViewComponent.UPDATE_VIEW));
      }
      
      public function get currentZoom() : Number
      {
         return this._isoView.currentZoom;
      }
      
      public function isoToLocal(param1:Pt) : Point
      {
         return this._isoView.isoToLocal(param1);
      }
      
      public function isoToLocalPoint(param1:Point) : Point
      {
         var _loc2_:Pt = new Pt(param1.x,param1.y);
         this.isoToLocal(_loc2_);
         param1.x = _loc2_.x;
         param1.y = _loc2_.y;
         return param1;
      }
      
      public function localToIso(param1:Point) : Pt
      {
         return this._isoView.localToIso(param1);
      }
      
      public function pan(param1:Number, param2:Number) : void
      {
         this._isoView.pan(param1,param2);
         owner.eventDispatcher.dispatchEvent(new Event(IsoViewComponent.UPDATE_VIEW));
      }
      
      public function get currentPt() : Pt
      {
         return this._isoView.currentPt;
      }
      
      public function get backgroundContainer() : DisplayObject
      {
         return this._isoView.backgroundContainer;
      }
      
      public function screenToIso(param1:Point, param2:IBounds = null, param3:Pt = null) : Pt
      {
         var _loc4_:IIsoScene = this.getSceneByID("gameScene");
         var _loc5_:Point = _loc4_.container.globalToLocal(param1);
         if(!param3)
         {
            param3 = new Pt();
         }
         param3.x = _loc5_.x;
         param3.y = _loc5_.y;
         return IsoMath.screenToIso(param3);
      }
   }
}

