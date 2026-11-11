package Engine.Classes
{
   import Engine.Helpers.Vector2;
   import Engine.Managers.InputManager;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.utils.*;
   
   public class Viewport extends Sprite
   {
      
      protected var m_position:Vector2 = new Vector2();
      
      protected var m_zoom:Number = 1;
      
      protected var m_bitmap:Bitmap = new Bitmap();
      
      protected var m_bitmapData:BitmapData;
      
      protected var m_transformStack:Array = [];
      
      protected var m_absoluteTransformMatrix:Matrix = new Matrix();
      
      protected var m_layers:Vector.<ViewportLayer> = new Vector.<ViewportLayer>();
      
      protected var m_bitmapDirty:Boolean = true;
      
      public function Viewport()
      {
         super();
         addEventListener(Event.RESIZE,this.onResize);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this.initialize();
         InputManager.initializeHandlers(this);
      }
      
      protected function initialize() : void
      {
         this.addLayer(new ViewportLayer("overlay",-1));
         this.addLayer(new ViewportLayer("object",0));
         this.addLayer(new ViewportLayer("ui",1));
         this.addLayer(new ViewportLayer("hud",2));
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.stage.addEventListener(Event.RESIZE,this.onResize);
         this.onResize(null);
      }
      
      public function getTransformMatrix() : Matrix
      {
         return this.m_absoluteTransformMatrix;
      }
      
      public function getScrollPosition() : Vector2
      {
         return this.m_position.cloneVec2();
      }
      
      public function setScrollPosition(param1:Vector2) : void
      {
         this.m_position = param1.cloneVec2();
         this.m_bitmapDirty = true;
      }
      
      public function setZoom(param1:Number) : void
      {
         if(this.m_zoom != param1)
         {
            this.m_zoom = param1;
            this.m_bitmapDirty = true;
         }
      }
      
      public function setDirty() : void
      {
         this.m_bitmapDirty = true;
      }
      
      public function regenerateBitmapData() : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:ViewportLayer = null;
         var _loc1_:Boolean = false;
         if(this.stage != null && this.stage.stageWidth > 0 && this.stage.stageHeight > 0)
         {
            if(this.m_bitmapData == null || this.m_bitmapData.width != this.stage.stageWidth || this.m_bitmapData.height != this.stage.stageHeight)
            {
               if(this.m_bitmap.parent)
               {
                  this.m_bitmap.parent.removeChild(this.m_bitmap);
               }
               if(this.m_bitmapData)
               {
                  this.m_bitmapData.dispose();
                  this.m_bitmapData = null;
               }
               _loc2_ = 0;
               this.m_bitmapData = new BitmapData(this.stage.stageWidth,this.stage.stageHeight);
               this.m_bitmap.bitmapData = this.m_bitmapData;
               addChildAt(this.m_bitmap,_loc2_);
               _loc2_++;
               _loc3_ = 0;
               while(_loc3_ < this.m_layers.length)
               {
                  _loc4_ = this.m_layers[_loc3_];
                  if(_loc4_.parent)
                  {
                     _loc4_.parent.removeChild(_loc4_);
                  }
                  addChildAt(_loc4_,_loc2_);
                  _loc2_++;
                  _loc3_++;
               }
            }
         }
         return _loc1_;
      }
      
      protected function addLayer(param1:ViewportLayer) : void
      {
         this.m_layers.push(param1);
         this.m_layers.sort(this.sortLayer);
      }
      
      private function sortLayer(param1:ViewportLayer, param2:ViewportLayer) : Number
      {
         if(param1.priority > param2.priority)
         {
            return 1;
         }
         if(param1.priority < param2.priority)
         {
            return -1;
         }
         return 0;
      }
      
      public function getLayer(param1:String) : Sprite
      {
         var _loc2_:Sprite = null;
         var _loc3_:int = 0;
         while(_loc3_ < this.m_layers.length)
         {
            if(this.m_layers[_loc3_].name == param1)
            {
               _loc2_ = this.m_layers[_loc3_] as Sprite;
               break;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      protected function render(param1:Boolean = false) : Boolean
      {
         var _loc3_:Matrix = null;
         var _loc2_:Boolean = false;
         if(Boolean(this.m_bitmapData) && (this.m_bitmapDirty || param1))
         {
            this.regenerateBitmapData();
            this.m_absoluteTransformMatrix.identity();
            this.m_absoluteTransformMatrix.translate(this.m_position.x,this.m_position.y);
            this.m_absoluteTransformMatrix.translate(-this.stage.stageWidth / 2,-this.stage.stageHeight / 2);
            this.m_absoluteTransformMatrix.scale(this.m_zoom,this.m_zoom);
            this.m_absoluteTransformMatrix.translate(this.stage.stageWidth / 2,this.stage.stageHeight / 2);
            this.m_bitmapData.lock();
            this.drawBackground(this.m_bitmapData);
            this.m_bitmapData.unlock();
            _loc3_ = this.m_absoluteTransformMatrix.clone();
            this.getLayer("object").transform.matrix = _loc3_;
            this.getLayer("ui").transform.matrix = _loc3_;
            this.getLayer("overlay").transform.matrix = _loc3_;
            this.m_bitmapDirty = false;
            _loc2_ = true;
         }
         return _loc2_;
      }
      
      protected function drawBackground(param1:BitmapData) : void
      {
         param1.fillRect(param1.rect,Config.VIEWPORT_CLEAR_COLOR);
      }
      
      public function centerViewport() : void
      {
      }
      
      public function getBitmapData() : BitmapData
      {
         return this.m_bitmapData;
      }
      
      public function clearBitmapData() : void
      {
         if(this.m_bitmapData != null)
         {
            this.m_bitmapData.dispose();
            this.m_bitmapData = null;
            this.m_bitmapDirty = true;
         }
      }
      
      public function getZoom() : Number
      {
         return this.m_zoom;
      }
      
      protected function onResize(param1:Event) : void
      {
         this.regenerateBitmapData();
         this.m_bitmapDirty = true;
      }
      
      protected function onEnterFrame(param1:Event) : void
      {
         if(this.stage != null)
         {
            this.render();
         }
      }
      
      public function copyPixels(param1:BitmapData, param2:Rectangle, param3:Point, param4:BitmapData, param5:Point, param6:Boolean) : void
      {
         var _loc7_:Point = this.m_absoluteTransformMatrix.transformPoint(param3);
         this.m_bitmapData.copyPixels(param1,param2,_loc7_,param4,param5,param6);
      }
      
      public function get uiBase() : Sprite
      {
         return this.getLayer("ui");
      }
      
      public function get overlayBase() : Sprite
      {
         return this.getLayer("overlay");
      }
      
      public function get objectBase() : Sprite
      {
         return this.getLayer("object");
      }
      
      public function get hudBase() : Sprite
      {
         return this.getLayer("hud");
      }
   }
}

