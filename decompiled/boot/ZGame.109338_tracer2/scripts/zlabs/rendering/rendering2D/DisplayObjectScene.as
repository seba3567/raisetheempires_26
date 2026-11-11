package zlabs.rendering.rendering2D
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.*;
   import flash.utils.Dictionary;
   import zlabs.Zlab;
   import zlabs.ZlabUtil;
   import zlabs.components.AnimatedComponent;
   import zlabs.core.ObjectType;
   import zlabs.debug.Logger;
   import zlabs.rendering.rendering2D.ui.IUITarget;
   
   public class DisplayObjectScene extends AnimatedComponent implements IScene2D
   {
      
      public var minZoom:Number = 0.01;
      
      public var maxZoom:Number = 1;
      
      public var layers:Array = [];
      
      public var trackObject:DisplayObjectRenderer;
      
      public var trackOffset:Point = new Point(0,0);
      
      protected var _sceneView:IUITarget;
      
      protected var _sceneViewName:String = null;
      
      protected var _rootSprite:Sprite;
      
      protected var _layers:Array = [];
      
      protected var _renderers:Dictionary = new Dictionary(true);
      
      protected var _zoom:Number = 1;
      
      protected var _rootPosition:Point = new Point();
      
      protected var _rootRotation:Number = 0;
      
      protected var _rootTransform:Matrix = new Matrix();
      
      protected var _transformDirty:Boolean = true;
      
      protected var _currentWorldCenter:Point = new Point();
      
      protected var _sceneViewBoundsCache:Rectangle = new Rectangle();
      
      protected var _tempPoint:Point = new Point();
      
      protected var _trackLimitRectangle:Rectangle = null;
      
      protected var _sceneAlignment:SceneAlignment = SceneAlignment.DEFAULT_ALIGNMENT;
      
      public function DisplayObjectScene()
      {
         super();
         updatePriority = -10;
         this._rootSprite = this.generateRootSprite();
      }
      
      public function set sceneAlignment(param1:SceneAlignment) : void
      {
         this._sceneAlignment = param1;
         this._transformDirty = true;
      }
      
      public function get sceneAlignment() : SceneAlignment
      {
         return this._sceneAlignment;
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         this._transformDirty = true;
         this.updateTransform();
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         if(this._sceneView)
         {
            this._sceneView.removeDisplayObject(this._rootSprite);
         }
      }
      
      public function get layerCount() : int
      {
         return this._layers.length;
      }
      
      public function getLayer(param1:int, param2:Boolean = false) : DisplayObjectSceneLayer
      {
         if(this._layers[param1])
         {
            return this._layers[param1];
         }
         if(param2 == false)
         {
            return null;
         }
         this._layers[param1] = this.generateLayer(param1);
         while(this._rootSprite.numChildren)
         {
            this._rootSprite.removeChildAt(this._rootSprite.numChildren - 1);
         }
         var _loc3_:int = 0;
         while(_loc3_ < this.layerCount)
         {
            if(this._layers[_loc3_])
            {
               this._rootSprite.addChild(this._layers[_loc3_]);
            }
            _loc3_++;
         }
         return this._layers[param1];
      }
      
      public function invalidate(param1:DisplayObjectRenderer) : void
      {
         var _loc2_:DisplayObjectSceneLayer = this.getLayer(param1.layerIndex);
         if(!_loc2_)
         {
            return;
         }
         if(_loc2_ is ICachingLayer)
         {
            ICachingLayer(_loc2_).invalidate(param1);
         }
      }
      
      public function invalidateRectangle(param1:Rectangle) : void
      {
         var _loc2_:DisplayObjectSceneLayer = null;
         for each(_loc2_ in this._layers)
         {
            if(_loc2_ is ICachingLayer)
            {
               (_loc2_ as ICachingLayer).invalidateRectangle(param1);
            }
         }
      }
      
      protected function generateRootSprite() : Sprite
      {
         var _loc1_:Sprite = new Sprite();
         _loc1_.name = "DisplayObjectSceneRoot";
         return _loc1_;
      }
      
      protected function generateLayer(param1:int) : DisplayObjectSceneLayer
      {
         var _loc2_:DisplayObjectSceneLayer = null;
         if(Boolean(this.layers) && Boolean(this.layers[param1]))
         {
            _loc2_ = this.layers[param1] as DisplayObjectSceneLayer;
         }
         if(!_loc2_)
         {
            _loc2_ = new DisplayObjectSceneLayer();
         }
         _loc2_.name = "Layer" + param1;
         return _loc2_;
      }
      
      public function get sceneView() : IUITarget
      {
         if(!this._sceneView && Boolean(this._sceneViewName))
         {
            this.sceneView = Zlab.findChild(this._sceneViewName) as IUITarget;
         }
         return this._sceneView;
      }
      
      public function set sceneView(param1:IUITarget) : void
      {
         if(this._sceneView)
         {
            this._sceneView.removeDisplayObject(this._rootSprite);
         }
         this._sceneView = param1;
         if(this._sceneView)
         {
            this._sceneView.addDisplayObject(this._rootSprite);
         }
      }
      
      public function get sceneViewName() : String
      {
         return this._sceneViewName;
      }
      
      public function set sceneViewName(param1:String) : void
      {
         this._sceneViewName = param1;
      }
      
      public function get sceneViewBounds() : Rectangle
      {
         var _loc1_:Rectangle = null;
         if(!this.sceneView)
         {
            return null;
         }
         if(this.trackObject)
         {
            this.position = new Point(-(this.trackObject.position.x + this.trackOffset.x),-(this.trackObject.position.y + this.trackOffset.y));
         }
         if(this.trackLimitRectangle != null)
         {
            _loc1_ = new Rectangle(this.trackLimitRectangle.x + this.sceneView.width * 0.5 / this.zoom,this.trackLimitRectangle.y + this.sceneView.height * 0.5 / this.zoom,this.trackLimitRectangle.width - this.sceneView.width / this.zoom,this.trackLimitRectangle.height - this.sceneView.height / this.zoom);
            this.position = new Point(ZlabUtil.clamp(this.position.x,-_loc1_.right,-_loc1_.left),ZlabUtil.clamp(this.position.y,-_loc1_.bottom,-_loc1_.top));
         }
         this.updateTransform();
         SceneAlignment.calculate(this._tempPoint,this.sceneAlignment,this.sceneView.width / this.zoom,this.sceneView.height / this.zoom);
         this._sceneViewBoundsCache.x = -this.position.x - this._tempPoint.x;
         this._sceneViewBoundsCache.y = -this.position.y - this._tempPoint.y;
         this._sceneViewBoundsCache.width = this.sceneView.width / this.zoom;
         this._sceneViewBoundsCache.height = this.sceneView.height / this.zoom;
         return this._sceneViewBoundsCache;
      }
      
      protected function sceneViewResized(param1:Event) : void
      {
         this._transformDirty = true;
      }
      
      public function get trackLimitRectangle() : Rectangle
      {
         return this._trackLimitRectangle;
      }
      
      public function set trackLimitRectangle(param1:Rectangle) : void
      {
         this._trackLimitRectangle = param1;
      }
      
      public function add(param1:DisplayObjectRenderer) : void
      {
         var _loc2_:DisplayObjectSceneLayer = this.getLayer(param1.layerIndex,true);
         _loc2_.add(param1);
         if(param1.displayObject)
         {
            this._renderers[param1.displayObject] = param1;
         }
      }
      
      public function remove(param1:DisplayObjectRenderer) : void
      {
         var _loc2_:DisplayObjectSceneLayer = this.getLayer(param1.layerIndex,false);
         if(!_loc2_)
         {
            return;
         }
         _loc2_.remove(param1);
         if(param1.displayObject)
         {
            delete this._renderers[param1.displayObject];
         }
      }
      
      public function transformWorldToScene(param1:Point) : Point
      {
         return param1;
      }
      
      public function transformSceneToWorld(param1:Point) : Point
      {
         return param1;
      }
      
      public function transformSceneToScreen(param1:Point) : Point
      {
         this.updateTransform();
         return this._rootSprite.localToGlobal(param1);
      }
      
      public function transformScreenToScene(param1:Point) : Point
      {
         this.updateTransform();
         return this._rootSprite.globalToLocal(param1);
      }
      
      public function transformWorldToScreen(param1:Point) : Point
      {
         this.updateTransform();
         return this._rootSprite.localToGlobal(param1);
      }
      
      public function transformScreenToWorld(param1:Point) : Point
      {
         this.updateTransform();
         return this._rootSprite.globalToLocal(param1);
      }
      
      public function getRenderersUnderPoint(param1:Point, param2:Array, param3:ObjectType = null) : Boolean
      {
         var _loc6_:* = undefined;
         var _loc7_:DisplayObjectSceneLayer = null;
         var _loc8_:DisplayObjectRenderer = null;
         var _loc4_:Array = this._rootSprite.getObjectsUnderPoint(param1);
         var _loc5_:Point = this.transformScreenToScene(param1);
         for each(_loc6_ in _loc4_)
         {
            _loc8_ = this.getRendererForDisplayObject(_loc6_);
            if(_loc8_)
            {
               if(_loc8_.owner)
               {
                  if(!(Boolean(param3) && !Zlab.objectTypeManager.doTypesOverlap(param3,_loc8_.objectMask)))
                  {
                     if(_loc8_.pointOccupied(_loc5_,param3))
                     {
                        param2.push(_loc8_);
                     }
                  }
               }
            }
         }
         _loc5_ = this.transformScreenToScene(param1);
         for each(_loc7_ in this._layers)
         {
            if(_loc7_ is ILayerMouseHandler)
            {
               (_loc7_ as ILayerMouseHandler).getRenderersUnderPoint(_loc5_,param3,param2);
            }
         }
         return param2.length > 0 ? true : false;
      }
      
      protected function getRendererForDisplayObject(param1:DisplayObject) : DisplayObjectRenderer
      {
         var _loc3_:DisplayObjectRenderer = null;
         var _loc2_:DisplayObject = param1;
         while(_loc2_)
         {
            _loc3_ = this._renderers[_loc2_] as DisplayObjectRenderer;
            if(_loc3_)
            {
               return _loc3_;
            }
            if(_loc3_ is DisplayObjectSceneLayer)
            {
               return null;
            }
            _loc2_ = _loc2_.parent;
         }
         return null;
      }
      
      public function updateTransform() : void
      {
         if(!this.sceneView)
         {
            return;
         }
         if(this._transformDirty == false)
         {
            return;
         }
         this._transformDirty = false;
         this._rootTransform.identity();
         this._rootTransform.translate(this._rootPosition.x,this._rootPosition.y);
         this._rootTransform.scale(this.zoom,this.zoom);
         this._rootTransform.rotate(this._rootRotation);
         SceneAlignment.calculate(this._tempPoint,this.sceneAlignment,this.sceneView.width,this.sceneView.height);
         this._rootTransform.translate(this._tempPoint.x,this._tempPoint.y);
         this._rootSprite.transform.matrix = this._rootTransform;
      }
      
      override public function onFrame(param1:Number) : void
      {
         var _loc2_:DisplayObjectSceneLayer = null;
         var _loc3_:Rectangle = null;
         if(!this.sceneView)
         {
            Logger.warn(this,"updateTransform","sceneView is null, so we aren\'t rendering.");
            return;
         }
         if(this.trackObject)
         {
            this.position = new Point(-(this.trackObject.position.x + this.trackOffset.x),-(this.trackObject.position.y + this.trackOffset.y));
         }
         if(this.trackLimitRectangle != null)
         {
            _loc3_ = new Rectangle(this.trackLimitRectangle.x + this.sceneView.width * 0.5,this.trackLimitRectangle.y + this.sceneView.height * 0.5,this.trackLimitRectangle.width - this.sceneView.width,this.trackLimitRectangle.height - this.sceneView.height);
            this.position = new Point(ZlabUtil.clamp(this.position.x,-_loc3_.right,-_loc3_.left),ZlabUtil.clamp(this.position.y,-_loc3_.bottom,-_loc3_.top));
         }
         this.updateTransform();
         for each(_loc2_ in this._layers)
         {
            _loc2_.onRender();
         }
      }
      
      public function setWorldCenter(param1:Point) : void
      {
         if(!this.sceneView)
         {
            throw new Error("sceneView not yet set. can\'t center the world.");
         }
         this.position = this.transformWorldToScreen(param1);
      }
      
      public function screenPan(param1:int, param2:int) : void
      {
         if(param1 == 0 && param2 == 0)
         {
            return;
         }
         this._rootPosition.x -= int(param1 / this._zoom);
         this._rootPosition.y -= int(param2 / this._zoom);
         this._transformDirty = true;
      }
      
      public function get rotation() : Number
      {
         return this._rootRotation;
      }
      
      public function set rotation(param1:Number) : void
      {
         this._rootRotation = param1;
         this._transformDirty = true;
      }
      
      public function get position() : Point
      {
         return this._rootPosition.clone();
      }
      
      public function set position(param1:Point) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:int = int(param1.x);
         var _loc3_:int = int(param1.y);
         if(this._rootPosition.x == _loc2_ && this._rootPosition.y == _loc3_)
         {
            return;
         }
         this._rootPosition.x = _loc2_;
         this._rootPosition.y = _loc3_;
         this._transformDirty = true;
      }
      
      public function get zoom() : Number
      {
         return this._zoom;
      }
      
      public function set zoom(param1:Number) : void
      {
         param1 = ZlabUtil.clamp(param1,this.minZoom,this.maxZoom);
         if(this._zoom == param1)
         {
            return;
         }
         this._zoom = param1;
         this._transformDirty = true;
      }
      
      public function sortSpatials(param1:Array) : void
      {
      }
   }
}

