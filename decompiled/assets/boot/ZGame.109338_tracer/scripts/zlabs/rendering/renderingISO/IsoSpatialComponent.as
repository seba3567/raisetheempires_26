package zlabs.rendering.renderingISO
{
   import as3isolib.bounds.IBounds;
   import as3isolib.core.IIsoDisplayObject;
   import as3isolib.geom.Pt;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import zlabs.Zlab;
   import zlabs.core.ObjectType;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.rendering.rendering2D.DisplayObjectRenderer;
   import zlabs.rendering.rendering2D.IScene2D;
   import zlabs.rendering.rendering2D.RayHitInfo;
   
   public class IsoSpatialComponent extends EntityComponent implements ISpatialObjectISO
   {
      
      public static const START:String = "isoSpatialMoveStart";
      
      public static const STOP:String = "isoSpatialMoveStop";
      
      public static var INACTIVE_NON_DISPLAY:String = "inactiveNonDisplay";
      
      public static var ACTIVE_DISPLAY:String = "activeDisplay";
      
      private var _spatialManager:ISpatialManagerISO;
      
      public var isoDisplayObjectReference:PropertyReference = null;
      
      private var _isoSprite:IIsoDisplayObject;
      
      private var _visible:Boolean = true;
      
      private var _addedToManager:Boolean = false;
      
      private var _position:Vector3D = new Vector3D();
      
      private var _volume:Pt;
      
      public var spriteForPointChecks:DisplayObjectRenderer;
      
      private var _rotation:Number = 0;
      
      public var angularVelocity:Number = 0;
      
      private var _objectMask:ObjectType;
      
      public function IsoSpatialComponent()
      {
         super();
      }
      
      public function visible(param1:Boolean) : Boolean
      {
         if(param1 != this._visible)
         {
            if(param1 && Boolean(owner))
            {
               owner.eventDispatcher.dispatchEvent(new Event(ACTIVE_DISPLAY));
            }
            else if(owner)
            {
               owner.eventDispatcher.dispatchEvent(new Event(INACTIVE_NON_DISPLAY));
            }
            this._visible = param1;
         }
         return this._visible;
      }
      
      public function get isoSprite() : IIsoDisplayObject
      {
         return this._isoSprite;
      }
      
      public function set isoSprite(param1:IIsoDisplayObject) : void
      {
         this._isoSprite = param1;
      }
      
      public function getIsoSprite() : IIsoDisplayObject
      {
         return this._isoSprite;
      }
      
      public function setIndex(param1:int) : void
      {
         this._isoSprite.container.parent.setChildIndex(this._isoSprite.container,param1);
      }
      
      public function get isoBounds() : IBounds
      {
         return this._isoSprite.isoBounds;
      }
      
      public function get bounds() : Rectangle
      {
         return this._isoSprite.getBounds(Zlab.mainStage);
      }
      
      public function get position() : Vector3D
      {
         return this._position.clone();
      }
      
      public function set position(param1:Vector3D) : void
      {
         this.x = param1.x;
         this.y = param1.y;
         this.z = param1.z;
         if(owner)
         {
            owner.eventDispatcher.dispatchEvent(new Event(IsoSpriteComponent.UPDATE_SPRITE));
         }
      }
      
      public function get volume() : Pt
      {
         return this._volume;
      }
      
      public function set volume(param1:Pt) : void
      {
         this._volume = param1;
         if(owner)
         {
            owner.eventDispatcher.dispatchEvent(new Event(IsoSpriteComponent.UPDATE_SPRITE));
         }
      }
      
      public function set x(param1:Number) : void
      {
         this._position.x = param1;
         if(this._isoSprite)
         {
            this._isoSprite.x = param1;
         }
      }
      
      public function get x() : Number
      {
         return this._position.x;
      }
      
      public function set y(param1:Number) : void
      {
         this._position.y = param1;
         if(this._isoSprite)
         {
            this._isoSprite.y = param1;
         }
      }
      
      public function get y() : Number
      {
         return this._position.y;
      }
      
      public function set z(param1:Number) : void
      {
         this._position.z = param1;
         if(this._isoSprite)
         {
            this._isoSprite.z = param1;
         }
      }
      
      public function get z() : Number
      {
         return this._position.z;
      }
      
      public function get length() : Number
      {
         return this._position.length;
      }
      
      public function get rotation() : Number
      {
         return this._rotation;
      }
      
      public function set rotation(param1:Number) : void
      {
         this._rotation = param1;
      }
      
      public function removeSpatialObject() : void
      {
         if(this._addedToManager && Boolean(this._spatialManager))
         {
            this._spatialManager.removeSpatialObject(this);
            this._addedToManager = false;
         }
      }
      
      override protected function onRemove() : void
      {
         this.removeSpatialObject();
         this._spatialManager = null;
         this._isoSprite = null;
         super.onRemove();
      }
      
      public function get spatialManager() : ISpatialManagerISO
      {
         return this._spatialManager;
      }
      
      public function set spatialManager(param1:ISpatialManagerISO) : void
      {
         if(!isRegistered)
         {
            this._spatialManager = param1;
            return;
         }
         if(this._spatialManager)
         {
            this._spatialManager.removeSpatialObject(this);
            this._addedToManager = false;
         }
         this._spatialManager = param1;
         if(this._spatialManager)
         {
            this._spatialManager.addSpatialObject(this);
            this._addedToManager = true;
         }
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         if(!this._isoSprite && Boolean(this.isoDisplayObjectReference))
         {
            this._isoSprite = owner.getProperty(this.isoDisplayObjectReference);
         }
      }
      
      protected function collisionFunction(param1:Object, param2:Object) : int
      {
         var _loc3_:IIsoDisplayObject = param1 as IIsoDisplayObject;
         var _loc4_:IIsoDisplayObject = param2 as IIsoDisplayObject;
         if(_loc3_ != null && _loc4_ != null)
         {
            return _loc3_.z + _loc3_.height > _loc4_.z + _loc4_.height ? -1 : 1;
         }
         return 0;
      }
      
      public function update() : void
      {
         if(owner)
         {
            owner.eventDispatcher.dispatchEvent(new Event(IsoSpriteComponent.UPDATE_SPRITE));
         }
      }
      
      public function get objectMask() : ObjectType
      {
         return this._objectMask;
      }
      
      public function set objectMask(param1:ObjectType) : void
      {
         this._objectMask = param1;
      }
      
      public function get worldExtents() : Rectangle
      {
         return null;
      }
      
      public function castRay(param1:Point, param2:Point, param3:ObjectType, param4:RayHitInfo) : Boolean
      {
         return false;
      }
      
      public function pointOccupied(param1:Point, param2:ObjectType, param3:IScene2D) : Boolean
      {
         if(!this.spriteForPointChecks || !param3)
         {
            return this.worldExtents.containsPoint(param1);
         }
         return this.spriteForPointChecks.pointOccupied(param3.transformWorldToScreen(param1),param2);
      }
   }
}

