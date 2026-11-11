package zlabs.rendering.rendering2D
{
   import flash.display.BlendMode;
   import flash.display.DisplayObject;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import zlabs.Zlab;
   import zlabs.ZlabUtil;
   import zlabs.components.AnimatedComponent;
   import zlabs.core.ObjectType;
   import zlabs.debug.Logger;
   import zlabs.entity.PropertyReference;
   
   public class DisplayObjectRenderer extends AnimatedComponent
   {
      
      public var renderKey:int = 0;
      
      public var positionProperty:PropertyReference;
      
      public var snapToNearestPixels:Boolean = true;
      
      public var scaleProperty:PropertyReference;
      
      public var sizeProperty:PropertyReference;
      
      public var rotationProperty:PropertyReference;
      
      public var alphaProperty:PropertyReference;
      
      public var blendModeProperty:PropertyReference;
      
      public var layerIndexProperty:PropertyReference;
      
      public var zIndexProperty:PropertyReference;
      
      public var registrationPointProperty:PropertyReference;
      
      public var objectMask:ObjectType;
      
      protected var _displayObject:DisplayObject;
      
      protected var _scene:IScene2D;
      
      protected var _layerIndex:int = 0;
      
      protected var _lastLayerIndex:int = -1;
      
      protected var _zIndex:int = 0;
      
      protected var _rotationOffset:Number = 0;
      
      protected var _registrationPoint:Point = new Point();
      
      protected var _scale:Point = new Point(1,1);
      
      protected var _rotation:Number = 0;
      
      protected var _alpha:Number = 1;
      
      protected var _blendMode:String = "normal";
      
      protected var _position:Point = new Point();
      
      protected var _positionOffset:Point = new Point();
      
      protected var _size:Point;
      
      protected var _transformMatrix:Matrix = new Matrix();
      
      protected var _transformDirty:Boolean = true;
      
      protected var _layerIndexDirty:Boolean = true;
      
      protected var _zIndexDirty:Boolean = true;
      
      protected var _hitTestDirty:Boolean = true;
      
      protected var _inScene:Boolean = false;
      
      public function DisplayObjectRenderer()
      {
         super();
         this._scene = Zlab.scene;
      }
      
      public function get layerIndex() : int
      {
         return this._layerIndex;
      }
      
      public function set layerIndex(param1:int) : void
      {
         if(this._layerIndex == param1)
         {
            return;
         }
         this._layerIndex = param1;
         this._layerIndexDirty = true;
      }
      
      public function get zIndex() : int
      {
         return this._zIndex;
      }
      
      public function set zIndex(param1:int) : void
      {
         if(this._zIndex == param1)
         {
            return;
         }
         this._zIndex = param1;
         this._zIndexDirty = true;
      }
      
      public function get registrationPoint() : Point
      {
         return this._registrationPoint.clone();
      }
      
      public function set registrationPoint(param1:Point) : void
      {
         var _loc2_:int = int(param1.x);
         var _loc3_:int = int(param1.y);
         if(_loc2_ == this._registrationPoint.x && _loc3_ == this._registrationPoint.y)
         {
            return;
         }
         this._registrationPoint.x = _loc2_;
         this._registrationPoint.y = _loc3_;
         this._transformDirty = true;
      }
      
      public function get scale() : Point
      {
         return this._scale.clone();
      }
      
      public function set scale(param1:Point) : void
      {
         if(param1.x == this._scale.x && param1.y == this._scale.y)
         {
            return;
         }
         this._scale.x = param1.x;
         this._scale.y = param1.y;
         this._transformDirty = true;
      }
      
      public function set size(param1:Point) : void
      {
         if(!param1)
         {
            this._size = null;
            return;
         }
         if(!this._size)
         {
            this._size = new Point();
         }
         this._size.x = param1.x;
         this._size.y = param1.y;
         this._transformDirty = true;
      }
      
      public function get size() : Point
      {
         if(!this._size)
         {
            return this._size;
         }
         return this._size.clone();
      }
      
      public function get rotation() : Number
      {
         return this._rotation;
      }
      
      public function set rotation(param1:Number) : void
      {
         if(param1 == this._rotation)
         {
            return;
         }
         this._rotation = param1;
         this._transformDirty = true;
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function set alpha(param1:Number) : void
      {
         if(param1 == this._alpha)
         {
            return;
         }
         this._alpha = param1;
         this._transformDirty = true;
      }
      
      public function get blendMode() : String
      {
         return this._blendMode;
      }
      
      public function set blendMode(param1:String) : void
      {
         if(param1 == this._blendMode)
         {
            return;
         }
         param1 = param1.toLowerCase();
         if(param1 != BlendMode.ADD && param1 != BlendMode.ALPHA && param1 != BlendMode.DARKEN && param1 != BlendMode.DIFFERENCE && param1 != BlendMode.ERASE && param1 != BlendMode.HARDLIGHT && param1 != BlendMode.INVERT && param1 != BlendMode.LAYER && param1 != BlendMode.LIGHTEN && param1 != BlendMode.MULTIPLY && param1 != BlendMode.NORMAL && param1 != BlendMode.OVERLAY && param1 != BlendMode.SCREEN && param1 != "shader" && param1 != BlendMode.SUBTRACT)
         {
            Logger.warn(this,"set blendMode","Could not set the blend mode to \'" + param1 + "\', because it is not a valid BlendMode");
            return;
         }
         this._blendMode = param1;
         this._transformDirty = true;
      }
      
      public function get positionOffset() : Point
      {
         return this._positionOffset.clone();
      }
      
      public function set positionOffset(param1:Point) : void
      {
         if(param1.x == this._positionOffset.x && param1.y == this._positionOffset.y)
         {
            return;
         }
         this._positionOffset.x = param1.x;
         this._positionOffset.y = param1.y;
         this._transformDirty = true;
      }
      
      public function get position() : Point
      {
         return this._position.clone();
      }
      
      public function set position(param1:Point) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this.snapToNearestPixels)
         {
            _loc2_ = int(param1.x);
            _loc3_ = int(param1.y);
         }
         else
         {
            _loc2_ = param1.x;
            _loc3_ = param1.y;
         }
         if(_loc2_ == this._position.x && _loc3_ == this._position.y)
         {
            return;
         }
         this._position.x = _loc2_;
         this._position.y = _loc3_;
         this._transformDirty = true;
      }
      
      public function get x() : Number
      {
         return this._position.x;
      }
      
      public function set x(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(this.snapToNearestPixels)
         {
            _loc2_ = int(param1);
         }
         else
         {
            _loc2_ = param1;
         }
         if(_loc2_ == this._position.x)
         {
            return;
         }
         this._position.x = _loc2_;
         this._transformDirty = true;
      }
      
      public function get y() : Number
      {
         return this._position.y;
      }
      
      public function set y(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(this.snapToNearestPixels)
         {
            _loc2_ = int(param1);
         }
         else
         {
            _loc2_ = param1;
         }
         if(_loc2_ == this._position.y)
         {
            return;
         }
         this._position.y = _loc2_;
         this._transformDirty = true;
      }
      
      public function set worldPosition(param1:Point) : void
      {
         this.removeFromScene();
         if(!this.scene)
         {
            throw new Error("Not attached to a scene, so cannot transform from world space.");
         }
         this.position = this.scene.transformWorldToScene(param1);
         this.updateTransform();
         this.addToScene();
      }
      
      public function get worldPosition() : Point
      {
         if(!this.scene)
         {
            throw new Error("Not attached to a scene, so cannot transform from world space.");
         }
         return this.scene.transformSceneToWorld(this.position);
      }
      
      public function get sceneBounds() : Rectangle
      {
         if(!this.displayObject)
         {
            return null;
         }
         var _loc1_:Rectangle = this.displayObject.getBounds(this.displayObject);
         _loc1_.x += this.displayObject.x;
         _loc1_.y += this.displayObject.y;
         return _loc1_;
      }
      
      public function get localBounds() : Rectangle
      {
         if(!this.displayObject)
         {
            return null;
         }
         return this.displayObject.getBounds(this.displayObject);
      }
      
      public function get scene() : IScene2D
      {
         return this._scene;
      }
      
      public function set scene(param1:IScene2D) : void
      {
         this.removeFromScene();
         this._scene = param1;
         this.addToScene();
      }
      
      public function get displayObject() : DisplayObject
      {
         return this._displayObject;
      }
      
      public function set displayObject(param1:DisplayObject) : void
      {
         this.removeFromScene();
         this._displayObject = param1;
         this.addToScene();
      }
      
      public function get renderPosition() : Point
      {
         return new Point(this.displayObject.x,this.displayObject.y);
      }
      
      public function get rotationOffset() : Number
      {
         return ZlabUtil.getDegreesFromRadians(this._rotationOffset);
      }
      
      public function set rotationOffset(param1:Number) : void
      {
         this._rotationOffset = ZlabUtil.unwrapRadian(ZlabUtil.getRadiansFromDegrees(param1));
      }
      
      public function transformWorldToObject(param1:Point) : Point
      {
         var _loc2_:Matrix = this._transformMatrix.clone();
         _loc2_.invert();
         return _loc2_.transformPoint(param1);
      }
      
      public function transformObjectToWorld(param1:Point) : Point
      {
         return this._transformMatrix.transformPoint(param1);
      }
      
      public function pointOccupied(param1:Point, param2:ObjectType) : Boolean
      {
         if(!this.displayObject || !this.scene)
         {
            return false;
         }
         if(this.displayObject.stage == null)
         {
            Logger.warn(this,"pointOccupied","DisplayObject is not on stage, so hitTestPoint will probably not work right.");
         }
         param1 = this.scene.transformWorldToScreen(param1);
         return this.displayObject.hitTestPoint(param1.x,param1.y,true);
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         this.updateTransform(true);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         this.removeFromScene();
      }
      
      protected function removeFromScene() : void
      {
         if(Boolean(this._scene) && Boolean(this._displayObject) && this._inScene)
         {
            this._scene.remove(this);
            this._inScene = false;
         }
      }
      
      protected function addToScene() : void
      {
         if(Boolean(this._scene) && Boolean(this._displayObject) && !this._inScene)
         {
            this._scene.add(this);
            this._inScene = true;
            this._lastLayerIndex = this._layerIndex;
            this._layerIndexDirty = this._zIndexDirty = false;
         }
      }
      
      override public function onFrame(param1:Number) : void
      {
         if(!this.displayObject)
         {
            return;
         }
         this.updateProperties();
         if(this._transformDirty)
         {
            this.updateTransform();
         }
      }
      
      protected function updateProperties() : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         if(!owner)
         {
            return;
         }
         if(this.zIndexProperty)
         {
            this.zIndex = owner.getProperty(this.zIndexProperty,this.zIndex);
         }
         if(this.layerIndexProperty)
         {
            this.layerIndex = owner.getProperty(this.layerIndexProperty,this.layerIndex);
         }
         if(this._zIndexDirty && Boolean(this._scene))
         {
            this._scene.getLayer(this._layerIndex).markDirty();
            this._zIndexDirty = false;
         }
         var _loc1_:Point = owner.getProperty(this.positionProperty) as Point;
         if(_loc1_)
         {
            if(this.scene)
            {
               this.position = this.scene.transformWorldToScene(_loc1_);
            }
            else
            {
               this.position = _loc1_;
            }
         }
         var _loc2_:Point = owner.getProperty(this.scaleProperty) as Point;
         if(_loc2_)
         {
            this.scale = _loc2_;
         }
         var _loc3_:Point = owner.getProperty(this.sizeProperty) as Point;
         if(_loc3_)
         {
            this.size = _loc3_;
         }
         if(this.rotationProperty)
         {
            _loc5_ = owner.getProperty(this.rotationProperty) as Number;
            this.rotation = _loc5_;
         }
         if(this.alphaProperty)
         {
            _loc6_ = owner.getProperty(this.alphaProperty) as Number;
            this.alpha = _loc6_;
         }
         if(this.blendModeProperty)
         {
            _loc7_ = owner.getProperty(this.blendModeProperty) as String;
            this.blendMode = _loc7_;
         }
         var _loc4_:Point = owner.getProperty(this.registrationPointProperty) as Point;
         if(_loc4_)
         {
            this.registrationPoint = _loc4_;
         }
         if(this._layerIndexDirty && Boolean(this._scene))
         {
            _loc8_ = this._layerIndex;
            this._layerIndex = this._lastLayerIndex;
            if(this._lastLayerIndex != -1)
            {
               this.removeFromScene();
            }
            this._layerIndex = _loc8_;
            this.addToScene();
            this._lastLayerIndex = this._layerIndex;
            this._layerIndexDirty = false;
         }
      }
      
      public function updateTransform(param1:Boolean = false) : void
      {
         var _loc4_:Rectangle = null;
         if(!this.displayObject)
         {
            return;
         }
         if(param1)
         {
            this.updateProperties();
         }
         var _loc2_:Number = this._scale.x;
         var _loc3_:Number = this._scale.y;
         if(this._size)
         {
            _loc4_ = this.displayObject.getBounds(this.displayObject);
            _loc2_ = this._scale.x * (this._size.x / _loc4_.width);
            _loc3_ = this._scale.y * (this._size.y / _loc4_.height);
         }
         this._transformMatrix.identity();
         this._transformMatrix.scale(_loc2_,_loc3_);
         this._transformMatrix.translate(-this._registrationPoint.x * _loc2_,-this._registrationPoint.y * _loc3_);
         this._transformMatrix.rotate(ZlabUtil.getRadiansFromDegrees(this._rotation) + this._rotationOffset);
         this._transformMatrix.translate(this._position.x + this._positionOffset.x,this._position.y + this._positionOffset.y);
         this.displayObject.transform.matrix = this._transformMatrix;
         this.displayObject.alpha = this._alpha;
         this.displayObject.blendMode = this._blendMode;
         this.displayObject.visible = this.alpha > 0;
         this._transformDirty = false;
      }
   }
}

