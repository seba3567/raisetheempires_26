package rendering.scroller
{
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.setTimeout;
   import zlabs.utils.bitmapDataUnlimited.BitmapDataUnlimited;
   import zlabs.utils.bitmapDataUnlimited.events.BitmapDataUnlimitedEvent;
   
   public class BackgroundScroller extends Sprite
   {
      
      private var panelPool:Array;
      
      private var panels:Array;
      
      private var panelSize:GridRect;
      
      public var blitWidth:Number;
      
      public var blitHeight:Number;
      
      public var divideBy:int;
      
      private var grid:Rectangle;
      
      private var fullMap:GridRect;
      
      private var totalPanels:int;
      
      private var blitImage:Sprite;
      
      private var color:int;
      
      public var isReady:Boolean = false;
      
      public function BackgroundScroller(param1:int, param2:int)
      {
         super();
         this.mouseEnabled = false;
         this.mouseChildren = false;
         this.color = param1;
         this.totalPanels = param2;
         this.blitImage = new Sprite();
      }
      
      public function init(param1:Number, param2:Number, param3:Number) : void
      {
         this.blitWidth = param1;
         this.blitHeight = param2;
         this.divideBy = param3;
         this.panelSize = new GridRect();
         this.panelSize.width = this.blitWidth / this.divideBy;
         this.panelSize.height = this.blitHeight / this.divideBy;
         this.panelPool = new Array();
         this.panels = new Array();
         this.buildGrid();
         this.generatePanels();
      }
      
      public function reset() : void
      {
         var _loc1_:GridRect = null;
         var _loc2_:ScrollPanel = null;
         for each(_loc1_ in this.panels)
         {
            this.removePanel(_loc1_);
         }
         for each(_loc2_ in this.panelPool)
         {
            _loc2_.reset();
         }
      }
      
      public function onScrollRect(param1:Rectangle, param2:Boolean = false) : void
      {
         var _loc6_:GridRect = null;
         var _loc3_:Point = param1.topLeft;
         var _loc4_:Point = this.globalToLocal(_loc3_);
         param1.x = _loc4_.x;
         param1.y = _loc4_.y;
         var _loc5_:int = 0;
         for each(_loc6_ in this.panels)
         {
            if(_loc6_.intersects(param1))
            {
               if(_loc6_.isRendererd && !param2)
               {
                  continue;
               }
               this.renderPanel(_loc6_);
            }
            else if(_loc6_.isRendererd)
            {
               this.removePanel(_loc6_);
            }
            _loc5_++;
         }
      }
      
      public function renderPanel(param1:GridRect) : void
      {
         var _loc2_:ScrollPanel = null;
         if(param1.bitmap)
         {
            _loc2_ = param1.bitmap;
            _loc2_.ID = "";
         }
         else
         {
            _loc2_ = this.getBitmapPanel(param1.ID);
         }
         if(!_loc2_)
         {
            return;
         }
         _loc2_.x = param1.x;
         _loc2_.y = param1.y;
         if(_loc2_.ID != param1.ID)
         {
            _loc2_.ID = param1.ID;
            _loc2_.draw(this.blitImage,param1);
         }
         _loc2_.visible = true;
         param1.isRendererd = true;
         param1.bitmap = _loc2_;
      }
      
      public function removePanel(param1:GridRect) : void
      {
         var _loc2_:ScrollPanel = param1.bitmap;
         if(_loc2_)
         {
            _loc2_.x = 0;
            _loc2_.y = 0;
            _loc2_.visible = false;
            this.returnBitmapPanel(_loc2_);
         }
         param1.bitmap = null;
         param1.isRendererd = false;
      }
      
      public function buildGrid() : void
      {
         var _loc5_:GridRect = null;
         this.fullMap = new GridRect(0,0,width,height);
         this.panels = new Array();
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = this.divideBy * this.divideBy;
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = this.panelSize.clone() as GridRect;
            _loc5_.ID = _loc2_ + "." + _loc1_;
            _loc5_.x = _loc5_.width * _loc2_;
            _loc5_.y = _loc5_.height * _loc1_;
            this.panels.push(_loc5_);
            if(++_loc2_ >= this.divideBy)
            {
               _loc2_ = 0;
               _loc1_++;
            }
            _loc4_++;
         }
      }
      
      public function generatePanels() : void
      {
         var _loc1_:BitmapDataUnlimited = new BitmapDataUnlimited();
         _loc1_.addEventListener(BitmapDataUnlimitedEvent.COMPLETE,this.onBmpReady);
         _loc1_.addEventListener(BitmapDataUnlimitedEvent.ERROR,this.onBmpError);
         _loc1_.create(this.panelSize.width,this.panelSize.height,false,this.color);
      }
      
      private function onBmpReady(param1:BitmapDataUnlimitedEvent) : void
      {
         var _loc2_:BitmapDataUnlimited = param1.target as BitmapDataUnlimited;
         var _loc3_:BitmapData = _loc2_.bitmapData;
         var _loc4_:ScrollPanel = new ScrollPanel(_loc2_);
         this.panelPool.push(_loc4_);
         if(this.panelPool.length < this.totalPanels)
         {
            setTimeout(this.generatePanels,100);
         }
         else
         {
            this.isReady = true;
            dispatchEvent(new Event(Event.COMPLETE));
         }
         _loc4_.visible = false;
         addChild(_loc4_);
      }
      
      public function returnBitmapPanel(param1:ScrollPanel) : void
      {
         this.panelPool.push(param1);
      }
      
      public function getBitmapPanel(param1:String, param2:Boolean = false) : ScrollPanel
      {
         var _loc3_:ScrollPanel = null;
         var _loc4_:int = 0;
         while(_loc4_ < this.panelPool.length)
         {
            if(this.panelPool[_loc4_].ID == param1)
            {
               _loc3_ = this.panelPool.splice(_loc4_,1)[0];
               break;
            }
            _loc4_++;
         }
         if(!_loc3_)
         {
            _loc3_ = this.panelPool.pop();
         }
         if(param2)
         {
            _loc3_.bitmapData.fillRect(_loc3_.bitmapData.rect,0);
         }
         return _loc3_;
      }
      
      public function imageToRender(param1:DisplayObject) : void
      {
         param1.x = this.blitWidth / 2;
         this.blitImage.addChild(param1);
      }
      
      private function onBmpError(param1:BitmapDataUnlimitedEvent) : void
      {
      }
      
      public function drawDebugRects(param1:Array) : void
      {
         var _loc4_:Rectangle = null;
         var _loc2_:Graphics = this.graphics;
         _loc2_.clear();
         _loc2_.lineStyle(1,6710886);
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1[_loc3_];
            _loc2_.drawRect(_loc4_.x,_loc4_.y,_loc4_.width,_loc4_.height);
            _loc3_++;
         }
         _loc2_.endFill();
      }
      
      public function dispose() : void
      {
         var _loc1_:GridRect = null;
         var _loc2_:ScrollPanel = null;
         for each(_loc1_ in this.panels)
         {
            _loc1_.dispose();
         }
         for each(_loc2_ in this.panelPool)
         {
            _loc2_.dispose();
         }
         this.panelPool.length = 0;
         this.panels.length = 0;
         this.panelPool = null;
         this.panels = null;
         this.panelSize = null;
      }
   }
}

