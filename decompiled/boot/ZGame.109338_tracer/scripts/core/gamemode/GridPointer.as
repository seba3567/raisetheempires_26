package core.gamemode
{
   import as3isolib.display.IsoView;
   import as3isolib.display.scene.IsoScene;
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.managers.BuildManager;
   import events.IsoViewEvent;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import zlabs.Constants;
   import zlabs.Zlab;
   import zlabs.utils.MathUtils;
   
   public class GridPointer extends EventDispatcher
   {
      
      public static var instance:GridPointer = new GridPointer();
      
      public static const SET_DESTINATION:String = "setdest";
      
      private var m_cursorClass:Class = GridPointer_m_cursorClass;
      
      private var m_expandCursorClass:Class = GridPointer_m_expandCursorClass;
      
      private var m_isoScene:IsoScene = null;
      
      private var m_isoView:IsoView = null;
      
      private var m_sprite:Sprite = null;
      
      private var m_displayObject:DisplayObject = null;
      
      private var m_scale:Number = 1;
      
      private var m_imageOffset:Number = 0;
      
      private var m_attachment:IPointerAttachment = null;
      
      private var m_visibilityLocked:Boolean = false;
      
      private var m_reposition:Boolean = true;
      
      public function GridPointer()
      {
         super();
      }
      
      public function init(param1:IsoView, param2:IsoScene) : void
      {
         this.m_isoView = param1;
         this.m_isoScene = param2;
      }
      
      public function addToWorld() : void
      {
         this.m_sprite = new Sprite();
         this.useLargeCursor = false;
         this.m_isoView.backgroundContainer.addChild(this.m_sprite);
         Zlab.inputManager.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove,false,1,true);
         GameModeManager.instance.addEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom,false,0,true);
      }
      
      public function update() : void
      {
         this.onMouseMove(null);
      }
      
      public function set valid(param1:Boolean) : void
      {
         var _loc2_:ColorTransform = null;
         if(this.m_displayObject)
         {
            _loc2_ = new ColorTransform();
            if(false == param1)
            {
               _loc2_.color = 16711680;
            }
            this.m_displayObject.transform.colorTransform = _loc2_;
         }
      }
      
      public function removeFromWorld() : void
      {
         if(this.m_sprite)
         {
            this.m_isoView.backgroundContainer.removeChild(this.m_sprite);
            this.m_displayObject = null;
            this.m_sprite = null;
            Zlab.inputManager.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
            GameModeManager.instance.removeEventListener(IsoViewEvent.ISOVIEW_ZOOM,this.onZoom);
         }
      }
      
      public function deInit() : void
      {
         this.m_isoView = null;
         this.m_isoScene = null;
      }
      
      public function set reposition(param1:Boolean) : void
      {
         this.m_reposition = param1;
      }
      
      public function set visibilityLocked(param1:Boolean) : void
      {
         this.m_visibilityLocked = param1;
      }
      
      public function set highlight(param1:Boolean) : void
      {
         if(this.m_displayObject)
         {
            if(param1)
            {
               this.m_displayObject.filters = [new GlowFilter(Constants.COLOR_HIGHLIGHT,1,8,8,20)];
            }
            else
            {
               this.m_displayObject.filters = [];
            }
         }
      }
      
      public function set hide(param1:Boolean) : void
      {
         var _loc2_:Boolean = false;
         if(!this.m_visibilityLocked && Boolean(this.m_displayObject))
         {
            _loc2_ = param1 == false;
            if(_loc2_ != this.m_displayObject.visible)
            {
               this.m_displayObject.visible = _loc2_;
               if(this.m_displayObject.filters.length)
               {
                  this.m_displayObject.filters = [];
               }
               if(param1)
               {
                  this.update();
               }
            }
         }
      }
      
      public function set useLargeCursor(param1:Boolean) : void
      {
         var _loc2_:Number = 1;
         if(param1)
         {
            this.setCursor(new this.m_expandCursorClass());
            this.m_imageOffset = ZGlobal.cellSize * 4;
            _loc2_ = 2;
         }
         else
         {
            this.setCursor(new this.m_cursorClass());
            this.m_imageOffset = 0;
         }
         this.m_sprite.scaleX = _loc2_;
         this.m_sprite.scaleY = _loc2_;
         Bitmap(this.m_displayObject).smoothing = param1;
      }
      
      private function setCursor(param1:DisplayObject) : void
      {
         if(this.m_displayObject)
         {
            this.m_sprite.removeChild(this.m_displayObject);
         }
         this.m_displayObject = param1;
         this.m_sprite.addChild(this.m_displayObject);
      }
      
      public function set snapScale(param1:Number) : void
      {
         if(this.m_sprite)
         {
            if(this.m_scale != param1)
            {
               this.m_scale = param1;
               this.update();
            }
         }
      }
      
      public function addAttachment(param1:IPointerAttachment) : void
      {
         var _loc2_:DisplayObject = null;
         if(null == this.m_sprite)
         {
            return;
         }
         param1.init(this.m_cursorClass);
         for each(_loc2_ in param1.displayObjects)
         {
            this.m_sprite.addChild(_loc2_);
         }
      }
      
      public function removeAttachments() : void
      {
         if(null == this.m_sprite)
         {
            return;
         }
         while(this.m_sprite.numChildren > 0)
         {
            this.m_sprite.removeChildAt(0);
         }
         this.m_sprite.addChild(this.m_displayObject);
      }
      
      public function convertScreenCoordsToGrid(param1:Number, param2:Number) : Pt
      {
         var _loc3_:Point = new Point(param1,param2);
         var _loc4_:Point = this.m_isoScene.container.globalToLocal(_loc3_);
         var _loc5_:Pt = IsoMath.screenToIso(new Pt(_loc4_.x,_loc4_.y,0));
         _loc5_ = MathUtils.snapToGrid(_loc5_,ZGlobal.cellSize * this.m_scale);
         BuildManager.instance.clamp(_loc5_);
         return _loc5_;
      }
      
      public function get position() : Point
      {
         return new Point(this.m_sprite.x,this.m_sprite.y);
      }
      
      public function setPosition(param1:Number, param2:Number) : void
      {
         var _loc3_:Pt = null;
         if(null != this.m_sprite)
         {
            _loc3_ = IsoMath.isoToScreen(new Pt(param1,param2));
            this.m_sprite.x = _loc3_.x - this.m_displayObject.width * 0.5 - this.m_imageOffset;
            this.m_sprite.y = _loc3_.y;
         }
      }
      
      private function pushToTop() : void
      {
         var _loc1_:int = this.m_isoView.backgroundContainer.getChildIndex(this.m_sprite);
         if(_loc1_ < this.m_isoView.backgroundContainer.numChildren - 1)
         {
            this.m_isoView.backgroundContainer.setChildIndex(this.m_sprite,this.m_isoView.backgroundContainer.numChildren - 1);
         }
      }
      
      private function onZoom(param1:IsoViewEvent) : void
      {
         this.onMouseMove(null);
      }
      
      private function onMouseMove(param1:MouseEvent) : void
      {
         var _loc2_:Pt = null;
         this.pushToTop();
         if(this.m_reposition)
         {
            _loc2_ = this.convertScreenCoordsToGrid(Zlab.mainStage.mouseX,Zlab.mainStage.mouseY);
            this.setPosition(_loc2_.x,_loc2_.y);
         }
      }
   }
}

