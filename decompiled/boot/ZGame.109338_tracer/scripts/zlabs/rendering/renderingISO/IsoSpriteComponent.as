package zlabs.rendering.renderingISO
{
   import as3isolib.bounds.IBounds;
   import as3isolib.display.IsoSprite;
   import as3isolib.display.primitive.IsoBox;
   import as3isolib.display.scene.IIsoScene;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.enum.RenderStyleType;
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import as3isolib.graphics.Stroke;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import zlabs.Zlab;
   import zlabs.components.AnimatedComponent;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.resource.Resource;
   
   public class IsoSpriteComponent extends AnimatedComponent
   {
      
      public static const COMPONENT_NAME:String = "temp";
      
      public static const FORCE_UPDATE_DISPLAY:String = "updatedisplay";
      
      public static const UPDATE_SPRITE:String = "updateSprite";
      
      public var autoAddToScene:Boolean = false;
      
      protected var _debugIsoBox:IsoBox;
      
      public var dirtyEvents:Array;
      
      public var isometricVolumeProperty:PropertyReference;
      
      public var isoSceneProperty:PropertyReference;
      
      public var isometricDepthPropRef:PropertyReference;
      
      public var spriteLayerProperty:PropertyReference;
      
      public var overlayLayerProperty:PropertyReference;
      
      public var secondOverlayLayerProperty:PropertyReference;
      
      public var photoOverlayLayerProperty:PropertyReference;
      
      public var progressBarLayerProperty:PropertyReference;
      
      public var pillageRewardProperty:PropertyReference;
      
      public var decorationFeedbackSpriteProperty:PropertyReference;
      
      public var protectableProperty:PropertyReference;
      
      public var protectorProperty:PropertyReference;
      
      public var areaImmuneProperty:PropertyReference;
      
      public var areaProtectorProperty:PropertyReference;
      
      public var xProperty:PropertyReference;
      
      public var yProperty:PropertyReference;
      
      public var zProperty:PropertyReference;
      
      protected var _debug:Boolean;
      
      protected var _dirtyEvents:Array;
      
      protected var _isometricVolume:Pt;
      
      protected var _isoSprite:IsoGameSprite = new IsoGameSprite();
      
      protected var _isoSceneComponent:IIsoScene;
      
      protected var _isoScene:IIsoScene = null;
      
      public function IsoSpriteComponent()
      {
         super();
      }
      
      public static function getFrom(param1:IEntity) : IsoSpriteComponent
      {
         return param1.lookupComponentByName(IsoSpriteComponent.COMPONENT_NAME) as IsoSpriteComponent;
      }
      
      public function get isIsoDisplay() : Boolean
      {
         return this._isoSceneComponent != null;
      }
      
      public function get isoSprite() : IsoSprite
      {
         return this._isoSprite;
      }
      
      public function get isometricVolume() : Pt
      {
         if(this.isometricVolumeProperty != null)
         {
            return owner.getProperty(this.isometricVolumeProperty) as Pt;
         }
         return this._isometricVolume;
      }
      
      public function set isometricVolume(param1:Pt) : void
      {
         if(this.isometricVolumeProperty != null)
         {
            owner.setProperty(this.isometricVolumeProperty,param1.clone());
         }
         else
         {
            this._isometricVolume = param1.clone() as Pt;
         }
         this._isoSprite.setSize(param1.x,param1.y,param1.z);
         if(Zlab.RENDER_DEBUG_MODE)
         {
            this._debugIsoBox.setSize(param1.x,param1.y,param1.z);
         }
      }
      
      public function displayDebugVolume() : void
      {
         if(Zlab.RENDER_DEBUG_MODE)
         {
            if(!this._debugIsoBox)
            {
               this.createIsoDebugVolume();
            }
            this._isoSprite.addChild(this._debugIsoBox);
         }
         else if(this._debugIsoBox)
         {
            this._isoSprite.removeChild(this._debugIsoBox);
            this._debugIsoBox = null;
         }
      }
      
      public function createIsoDebugVolume() : void
      {
         this._debugIsoBox = new IsoBox();
         var _loc1_:Pt = this.isometricVolume;
         this._debugIsoBox.setSize(_loc1_.x,_loc1_.y,_loc1_.z);
         this._debugIsoBox.x = 0;
         this._debugIsoBox.y = 0;
         this._debugIsoBox.styleType = RenderStyleType.WIREFRAME;
         this._debugIsoBox.stroke = new Stroke(1,16711680,1);
      }
      
      public function set asset(param1:Resource) : void
      {
      }
      
      public function get asset() : Resource
      {
         return null;
      }
      
      protected function get x() : Number
      {
         return this._isoSprite.x;
      }
      
      protected function set x(param1:Number) : void
      {
         this._isoSprite.x = param1;
      }
      
      protected function get y() : Number
      {
         return this._isoSprite.y;
      }
      
      protected function set y(param1:Number) : void
      {
         this._isoSprite.y = param1;
      }
      
      protected function get z() : Number
      {
         return this._isoSprite.z;
      }
      
      protected function set z(param1:Number) : void
      {
         this._isoSprite.z = param1;
      }
      
      public function screenToIso(param1:Point, param2:IBounds = null, param3:Pt = null) : Pt
      {
         var _loc4_:IsoScene = IsoScene(this._isoSprite.parent);
         if(!_loc4_)
         {
            return null;
         }
         var _loc5_:Point = _loc4_.container.globalToLocal(param1);
         if(param3)
         {
            param3.x = _loc5_.x;
            param3.y = _loc5_.y;
            param3.z = 1;
         }
         else
         {
            param3 = new Pt(_loc5_.x,_loc5_.y,1);
         }
         var _loc6_:Pt = IsoMath.screenToIso(param3);
         if(_loc6_.x < 0)
         {
            _loc6_.x = 0;
         }
         if(_loc6_.y < 0)
         {
            _loc6_.y = 0;
         }
         var _loc7_:Number = 10000;
         var _loc8_:Number = 10000;
         if(param2)
         {
            if(_loc6_.x + param2.width > _loc7_)
            {
               _loc6_.x = _loc7_ - param2.width;
            }
            if(_loc6_.y + param2.length > _loc8_)
            {
               _loc6_.y = _loc7_ - param2.length;
            }
         }
         return _loc6_;
      }
      
      public function setMask(param1:DisplayObject) : Boolean
      {
         if(this._isoSprite.container.mask !== param1)
         {
            if(param1)
            {
               this._isoSprite.container.addChild(param1);
               if(!this._isoSprite.container.getRect(this._isoSprite.container.parent).intersects(param1.getRect(this._isoSprite.container.parent)))
               {
                  return false;
               }
               param1.cacheAsBitmap = true;
            }
            this._isoSprite.container.cacheAsBitmap = param1 != null;
            this._isoSprite.container.mask = param1;
            registerForUpdates = param1 != null;
            return true;
         }
         return false;
      }
      
      public function addToIsoScene(param1:IIsoScene, param2:Pt, param3:Number, param4:Number, param5:Number) : void
      {
         if(param1 == null)
         {
            Logger.error(this,"addToIsoScene","scene == null");
            throw new Error("addToIsoScene" + ", scene=" + param1);
         }
         this.removeFromIsoScene();
         this.addComponentSprites();
         this._isoSceneComponent = param1;
         if(this._isoSceneComponent != null)
         {
            this._isoSceneComponent.addChild(this._isoSprite);
            if(Zlab.RENDER_DEBUG_MODE)
            {
               this.createIsoDebugVolume();
            }
         }
         this.init(param2,param3,param4,param5);
      }
      
      public function get canvas() : Graphics
      {
         return this._isoSprite.container.graphics;
      }
      
      private function init(param1:Pt, param2:Number, param3:Number, param4:Number) : void
      {
         this._isoSprite.setSize(param1.x,param1.y,param1.z);
         this.x = param2;
         this.y = param3;
         this.z = param4;
         this._isoSprite.invalidatePosition();
      }
      
      private function addComponentSprites() : void
      {
         var _loc1_:Sprite = null;
         var _loc2_:Sprite = null;
         var _loc3_:Sprite = null;
         var _loc4_:Sprite = null;
         var _loc5_:Sprite = null;
         var _loc6_:Sprite = null;
         var _loc7_:Sprite = null;
         var _loc8_:Sprite = null;
         var _loc9_:Sprite = null;
         var _loc10_:Sprite = null;
         this._isoSprite.sprites = [];
         if(this.overlayLayerProperty)
         {
            _loc1_ = owner.getProperty(this.overlayLayerProperty) as Sprite;
            this._isoSprite.sprites.push(_loc1_);
         }
         if(this.secondOverlayLayerProperty)
         {
            _loc2_ = owner.getProperty(this.secondOverlayLayerProperty) as Sprite;
            this._isoSprite.sprites.push(_loc2_);
         }
         if(this.progressBarLayerProperty)
         {
            _loc3_ = owner.getProperty(this.progressBarLayerProperty) as Sprite;
            this._isoSprite.sprites.push(_loc3_);
         }
         if(this.pillageRewardProperty)
         {
            _loc4_ = owner.getProperty(this.pillageRewardProperty) as Sprite;
            this._isoSprite.sprites.push(_loc4_);
         }
         if(this.decorationFeedbackSpriteProperty)
         {
            _loc5_ = owner.getProperty(this.decorationFeedbackSpriteProperty) as Sprite;
            this._isoSprite.sprites.push(_loc5_);
         }
         if(this.protectableProperty)
         {
            _loc6_ = owner.getProperty(this.protectableProperty) as Sprite;
            this._isoSprite.sprites.push(_loc6_);
         }
         if(this.protectorProperty)
         {
            _loc7_ = owner.getProperty(this.protectorProperty) as Sprite;
            this._isoSprite.sprites.push(_loc7_);
         }
         if(this.areaImmuneProperty)
         {
            _loc8_ = owner.getProperty(this.areaImmuneProperty) as Sprite;
            this._isoSprite.sprites.push(_loc8_);
         }
         if(this.areaProtectorProperty)
         {
            _loc9_ = owner.getProperty(this.areaProtectorProperty) as Sprite;
            this._isoSprite.sprites.push(_loc9_);
         }
         if(this.photoOverlayLayerProperty)
         {
            _loc10_ = owner.getProperty(this.photoOverlayLayerProperty) as Sprite;
            this._isoSprite.sprites.push(_loc10_);
         }
      }
      
      public function removeFromIsoScene() : void
      {
         if(this._isoSceneComponent != null)
         {
            this._isoSceneComponent.removeChild(this._isoSprite);
            this._isoSceneComponent = null;
            this._isoScene = null;
         }
      }
      
      public function setLoc(param1:Pt) : void
      {
         this.x = param1.x;
         this.y = param1.y;
         this.z = param1.z;
         this.update();
      }
      
      public function update(... rest) : void
      {
         if(owner == null)
         {
            return;
         }
         var _loc2_:Pt = this.isometricVolume;
         if(_loc2_ != null)
         {
            this._isoSprite.setSize(_loc2_.x,_loc2_.y,_loc2_.z);
         }
         if(this.xProperty != null)
         {
            this.x = owner.getProperty(this.xProperty) as Number;
         }
         if(this.yProperty != null)
         {
            this.y = owner.getProperty(this.yProperty) as Number;
         }
         if(this.zProperty != null)
         {
            this.z = owner.getProperty(this.zProperty) as Number;
         }
         this._isoSprite.invalidatePosition();
      }
      
      override protected function onAdd() : void
      {
         var _loc1_:String = null;
         registerForUpdates = false;
         this._dirtyEvents = this.dirtyEvents;
         for each(_loc1_ in this._dirtyEvents)
         {
            owner.eventDispatcher.addEventListener(_loc1_,this.update);
         }
         owner.eventDispatcher.addEventListener(UPDATE_SPRITE,this.onUpdate,false,0,true);
         owner.eventDispatcher.addEventListener(IsoSpatialComponent.ACTIVE_DISPLAY,this.onShow,false,0,true);
         owner.eventDispatcher.addEventListener(IsoSpatialComponent.INACTIVE_NON_DISPLAY,this.onHide,false,0,true);
      }
      
      protected function onUpdate(param1:Event) : void
      {
         this.update();
      }
      
      protected function onShow(param1:Event) : void
      {
         this._isoSprite.container.visible = true;
         this._isoSprite.invalidateVisibility();
      }
      
      protected function onHide(param1:Event) : void
      {
         this._isoSprite.container.visible = false;
         this._isoSprite.invalidateVisibility();
      }
      
      override protected function onRemove() : void
      {
         var _loc1_:String = null;
         for each(_loc1_ in this._dirtyEvents)
         {
            owner.eventDispatcher.removeEventListener(_loc1_,this.update);
         }
         this.removeFromIsoScene();
         registerForUpdates = false;
      }
      
      override protected function onReset() : void
      {
         if(this.autoAddToScene && this._isoSceneComponent == null)
         {
         }
      }
      
      override public function onFrame(param1:Number) : void
      {
         super.onFrame(param1);
         if(registerForUpdates)
         {
            owner.eventDispatcher.dispatchEvent(new Event(FORCE_UPDATE_DISPLAY));
         }
      }
   }
}

