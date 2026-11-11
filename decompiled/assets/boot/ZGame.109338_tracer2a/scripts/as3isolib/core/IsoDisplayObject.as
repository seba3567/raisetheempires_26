package as3isolib.core
{
   import as3isolib.bounds.IBounds;
   import as3isolib.bounds.PrimitiveBounds;
   import as3isolib.data.RenderData;
   import as3isolib.events.IsoEvent;
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   use namespace as3isolib_internal;
   
   public class IsoDisplayObject extends IsoContainer implements IIsoDisplayObject
   {
      
      private var cachedRenderData:RenderData;
      
      private var _isAnimated:Boolean = false;
      
      protected var isoBoundsObject:IBounds;
      
      public var usePreciseValues:Boolean = false;
      
      protected var isoX:Number = 0;
      
      protected var oldX:Number;
      
      protected var isoY:Number = 0;
      
      protected var oldY:Number;
      
      protected var isoZ:Number = 0;
      
      protected var oldZ:Number;
      
      private var dist:Number;
      
      protected var isoWidth:Number = 0;
      
      protected var oldWidth:Number;
      
      protected var isoLength:Number = 0;
      
      protected var oldLength:Number;
      
      protected var isoHeight:Number = 0;
      
      protected var oldHeight:Number;
      
      private var bRenderAsOrphan:Boolean = false;
      
      public var autoUpdate:Boolean = false;
      
      as3isolib_internal var bInvalidateEventDispatched:Boolean = false;
      
      as3isolib_internal var bPositionInvalidated:Boolean = false;
      
      as3isolib_internal var bSizeInvalidated:Boolean = false;
      
      as3isolib_internal var bVisibilityInvalidated:Boolean = false;
      
      public function IsoDisplayObject(param1:Object = null)
      {
         super();
         if(param1)
         {
            this.createObjectFromDescriptor(param1);
         }
      }
      
      public function getRenderData() : RenderData
      {
         var _loc2_:Boolean = false;
         var _loc3_:BitmapData = null;
         var _loc4_:RenderData = null;
         var _loc1_:Rectangle = mainContainer.getBounds(mainContainer);
         if(this.isInvalidated || !this.cachedRenderData)
         {
            _loc2_ = this.bRenderAsOrphan;
            this.bRenderAsOrphan = true;
            render(true);
            _loc3_ = new BitmapData(_loc1_.width + 1,_loc1_.height + 1,true,0);
            _loc3_.draw(mainContainer,new Matrix(1,0,0,1,-_loc1_.left,-_loc1_.top));
            _loc4_ = new RenderData();
            _loc4_.x = mainContainer.x + _loc1_.left;
            _loc4_.y = mainContainer.y + _loc1_.top;
            _loc4_.bitmapData = _loc3_;
            this.cachedRenderData = _loc4_;
            this.bRenderAsOrphan = _loc2_;
         }
         else
         {
            this.cachedRenderData.x = mainContainer.x + _loc1_.left;
            this.cachedRenderData.y = mainContainer.y + _loc1_.top;
         }
         return this.cachedRenderData;
      }
      
      public function get isAnimated() : Boolean
      {
         return this._isAnimated;
      }
      
      public function set isAnimated(param1:Boolean) : void
      {
         this._isAnimated = param1;
      }
      
      public function get isoBounds() : IBounds
      {
         if(!this.isoBoundsObject || this.isInvalidated)
         {
            this.isoBoundsObject = new PrimitiveBounds(this);
         }
         return this.isoBoundsObject;
      }
      
      public function get screenBounds() : Rectangle
      {
         var _loc1_:Rectangle = mainContainer.getBounds(mainContainer);
         _loc1_.x += mainContainer.x;
         _loc1_.y += mainContainer.y;
         return _loc1_;
      }
      
      public function getBounds(param1:DisplayObject) : Rectangle
      {
         var _loc2_:Rectangle = this.screenBounds;
         var _loc3_:Point = new Point(_loc2_.x,_loc2_.y);
         _loc3_ = IIsoContainer(parent).container.localToGlobal(_loc3_);
         _loc3_ = param1.globalToLocal(_loc3_);
         _loc2_.x = _loc3_.x;
         _loc2_.y = _loc3_.y;
         return _loc2_;
      }
      
      public function get inverseOriginX() : Number
      {
         return IsoMath.isoToScreen(new Pt(this.x + this.width,this.y + this.length,this.z)).x;
      }
      
      public function get inverseOriginY() : Number
      {
         return IsoMath.isoToScreen(new Pt(this.x + this.width,this.y + this.length,this.z)).y;
      }
      
      public function moveTo(param1:Number, param2:Number, param3:Number) : void
      {
         this.x = param1;
         this.y = param2;
         this.z = param3;
      }
      
      public function moveBy(param1:Number, param2:Number, param3:Number) : void
      {
         this.x += param1;
         this.y += param2;
         this.z += param3;
      }
      
      public function get x() : Number
      {
         return this.isoX;
      }
      
      public function set x(param1:Number) : void
      {
         if(!this.usePreciseValues)
         {
            param1 = Math.round(param1);
         }
         if(this.isoX != param1)
         {
            this.oldX = this.isoX;
            this.isoX = param1;
            this.invalidatePosition();
            if(this.autoUpdate)
            {
               render();
            }
         }
      }
      
      public function get screenX() : Number
      {
         return IsoMath.isoToScreen(new Pt(this.x,this.y,this.z)).x;
      }
      
      public function get y() : Number
      {
         return this.isoY;
      }
      
      public function set y(param1:Number) : void
      {
         if(!this.usePreciseValues)
         {
            param1 = Math.round(param1);
         }
         if(this.isoY != param1)
         {
            this.oldY = this.isoY;
            this.isoY = param1;
            this.invalidatePosition();
            if(this.autoUpdate)
            {
               render();
            }
         }
      }
      
      public function get screenY() : Number
      {
         return IsoMath.isoToScreen(new Pt(this.x,this.y,this.z)).y;
      }
      
      public function get z() : Number
      {
         return this.isoZ;
      }
      
      public function set z(param1:Number) : void
      {
         if(!this.usePreciseValues)
         {
            param1 = Math.round(param1);
         }
         if(this.isoZ != param1)
         {
            this.oldZ = this.isoZ;
            this.isoZ = param1;
            this.invalidatePosition();
            if(this.autoUpdate)
            {
               render();
            }
         }
      }
      
      public function get distance() : Number
      {
         return this.dist;
      }
      
      public function set distance(param1:Number) : void
      {
         this.dist = param1;
      }
      
      public function setSize(param1:Number, param2:Number, param3:Number) : void
      {
         this.width = param1;
         this.length = param2;
         this.height = param3;
      }
      
      public function get width() : Number
      {
         return this.isoWidth;
      }
      
      public function set width(param1:Number) : void
      {
         if(!this.usePreciseValues)
         {
            param1 = Math.round(param1);
         }
         param1 = Math.abs(param1);
         if(this.isoWidth != param1)
         {
            this.oldWidth = this.isoWidth;
            this.isoWidth = param1;
            this.invalidateSize();
            if(this.autoUpdate)
            {
               render();
            }
         }
      }
      
      public function get length() : Number
      {
         return this.isoLength;
      }
      
      public function set length(param1:Number) : void
      {
         if(!this.usePreciseValues)
         {
            param1 = Math.round(param1);
         }
         param1 = Math.abs(param1);
         if(this.isoLength != param1)
         {
            this.oldLength = this.isoLength;
            this.isoLength = param1;
            this.invalidateSize();
            if(this.autoUpdate)
            {
               render();
            }
         }
      }
      
      public function get height() : Number
      {
         return this.isoHeight;
      }
      
      public function set height(param1:Number) : void
      {
         if(!this.usePreciseValues)
         {
            param1 = Math.round(param1);
         }
         param1 = Math.abs(param1);
         if(this.isoHeight != param1)
         {
            this.oldHeight = this.isoHeight;
            this.isoHeight = param1;
            this.invalidateSize();
            if(this.autoUpdate)
            {
               render();
            }
         }
      }
      
      public function get renderAsOrphan() : Boolean
      {
         return this.bRenderAsOrphan;
      }
      
      public function set renderAsOrphan(param1:Boolean) : void
      {
         this.bRenderAsOrphan = param1;
      }
      
      override protected function renderLogic(param1:Boolean = true) : void
      {
         if(!hasParent && !this.renderAsOrphan)
         {
            return;
         }
         if(this.bPositionInvalidated)
         {
            this.validatePosition();
            this.bPositionInvalidated = false;
         }
         if(this.bSizeInvalidated)
         {
            this.validateSize();
            this.bSizeInvalidated = false;
         }
         this.bVisibilityInvalidated = false;
         this.bInvalidateEventDispatched = false;
         super.renderLogic(param1);
      }
      
      protected function validatePosition() : void
      {
         var _loc1_:Pt = new Pt(this.x,this.y,this.z);
         IsoMath.isoToScreen(_loc1_);
         mainContainer.x = _loc1_.x;
         mainContainer.y = _loc1_.y;
      }
      
      protected function validateSize() : void
      {
         var _loc1_:IsoEvent = new IsoEvent(IsoEvent.RESIZE,true);
         _loc1_.propName = "size";
         _loc1_.oldValue = {
            "width":this.oldWidth,
            "length":this.oldLength,
            "height":this.oldHeight
         };
         _loc1_.newValue = {
            "width":this.isoWidth,
            "length":this.isoLength,
            "height":this.isoHeight
         };
         dispatchEvent(_loc1_);
      }
      
      public function invalidatePosition() : void
      {
         this.bPositionInvalidated = true;
         if(!this.bInvalidateEventDispatched)
         {
            dispatchEvent(new IsoEvent(IsoEvent.INVALIDATE));
            this.bInvalidateEventDispatched = true;
         }
      }
      
      public function invalidateVisibility() : void
      {
         this.bVisibilityInvalidated = true;
         if(!this.bInvalidateEventDispatched)
         {
            dispatchEvent(new IsoEvent(IsoEvent.INVALIDATE));
            this.bInvalidateEventDispatched = true;
         }
      }
      
      public function invalidateSize() : void
      {
         this.bSizeInvalidated = true;
         if(!this.bInvalidateEventDispatched)
         {
            dispatchEvent(new IsoEvent(IsoEvent.INVALIDATE));
            this.bInvalidateEventDispatched = true;
         }
      }
      
      override public function get isInvalidated() : Boolean
      {
         return this.bPositionInvalidated || this.bSizeInvalidated || this.bVisibilityInvalidated;
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         mainContainer.cacheAsBitmap = this._isAnimated;
      }
      
      public function clone() : *
      {
         var _loc1_:Class = getDefinitionByName(getQualifiedClassName(this)) as Class;
         var _loc2_:IIsoDisplayObject = new _loc1_();
         _loc2_.setSize(this.isoWidth,this.isoLength,this.isoHeight);
         return _loc2_;
      }
      
      private function createObjectFromDescriptor(param1:Object) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in param1)
         {
            if(this.hasOwnProperty(_loc2_))
            {
               this[_loc2_] = param1[_loc2_];
            }
         }
      }
   }
}

