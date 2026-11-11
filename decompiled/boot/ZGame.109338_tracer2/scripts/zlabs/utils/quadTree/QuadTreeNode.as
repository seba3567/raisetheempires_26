package zlabs.utils.quadTree
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import zlabs.ZGameBase;
   import zlabs.debug.Logger;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   import zlabs.utils.MathUtils;
   import zlabs.utils.geom.Polygon2D;
   
   public class QuadTreeNode
   {
      
      private const STATUS_INVALID:int = 0;
      
      private const STATUS_VISIBLE:int = 1;
      
      private const STATUS_INVISIBLE:int = 2;
      
      private var _rect:Rectangle;
      
      protected var _maxItems:int;
      
      protected var isPartitioned:Boolean;
      
      protected var parentNode:QuadTreeNode;
      
      protected var topLeftNode:QuadTreeNode;
      
      protected var topRightNode:QuadTreeNode;
      
      protected var bottomLeftNode:QuadTreeNode;
      
      protected var bottomRightNode:QuadTreeNode;
      
      private var items:Array;
      
      private var numItems:int = 0;
      
      private var _poly:Polygon2D;
      
      private var isAnyChildVisible:int = 1;
      
      private var visibleStatus:int = 0;
      
      public function QuadTreeNode(param1:QuadTreeNode, param2:Rectangle, param3:int)
      {
         super();
         this.parentNode = param1;
         this._maxItems = param3;
         this._rect = param2;
         this._poly = new Polygon2D();
         this._poly.rectToPoly(this._rect);
         this.isPartitioned = false;
         this.items = new Array();
      }
      
      public function insert(param1:QuadTreePositionItem) : Boolean
      {
         if(!this.insertInChild(param1))
         {
            if(this._rect.width < 1)
            {
               Logger.error(this,"insert","cannot place item: " + param1.parent);
               return false;
            }
            this.items.push(param1);
            this.numItems = this.items.length;
            if(this.visibleStatus == this.STATUS_INVISIBLE)
            {
               IsoSpatialComponent(param1.parent).visible(false);
            }
            else if(this.visibleStatus == this.STATUS_VISIBLE)
            {
               IsoSpatialComponent(param1.parent).visible(true);
            }
            this.isAnyChildVisible = 1;
            if(!this.isPartitioned && this.numItems >= this._maxItems)
            {
               this.partition();
               return true;
            }
         }
         return true;
      }
      
      public function insertInChild(param1:QuadTreePositionItem) : Boolean
      {
         if(!this.isPartitioned)
         {
            return false;
         }
         if(this.topLeftNode.containsPoint(param1))
         {
            this.topLeftNode.insert(param1);
            return true;
         }
         if(this.topRightNode.containsPoint(param1))
         {
            this.topRightNode.insert(param1);
            return true;
         }
         if(this.bottomLeftNode.containsPoint(param1))
         {
            this.bottomLeftNode.insert(param1);
            return true;
         }
         if(this.bottomRightNode.containsPoint(param1))
         {
            this.bottomRightNode.insert(param1);
            return true;
         }
         return false;
      }
      
      public function partition() : void
      {
         var _loc1_:int = this.rect.width * 0.5;
         var _loc2_:int = this.rect.height * 0.5;
         var _loc3_:Rectangle = new Rectangle(this.rect.x,this.rect.y,_loc1_,_loc2_);
         this.topLeftNode = new QuadTreeNode(this,_loc3_,this._maxItems);
         _loc3_ = new Rectangle(this.rect.x + _loc1_,this.rect.y,_loc1_,_loc2_);
         this.topRightNode = new QuadTreeNode(this,_loc3_,this._maxItems);
         _loc3_ = new Rectangle(this.rect.x,this.rect.y + _loc2_,_loc1_,_loc2_);
         this.bottomLeftNode = new QuadTreeNode(this,_loc3_,this._maxItems);
         _loc3_ = new Rectangle(this.rect.x + _loc1_,this.rect.y + _loc2_,_loc1_,_loc2_);
         this.bottomRightNode = new QuadTreeNode(this,_loc3_,this._maxItems);
         this.isPartitioned = true;
         while(this.numItems > 0)
         {
            if(!this.pushItemDown(0))
            {
               Logger.error(this,"partition","unable to push item down, bailing.");
               break;
            }
         }
      }
      
      public function pushItemDown(param1:int) : Boolean
      {
         if(this.insertInChild(this.items[param1]))
         {
            this.removeItem(param1);
            return true;
         }
         return false;
      }
      
      public function pushItemUp(param1:int) : void
      {
         var _loc2_:QuadTreePositionItem = this.items[param1];
         this.removeItem(param1);
         this.parentNode.insert(_loc2_);
      }
      
      protected function removeItem(param1:int) : void
      {
         if(this.items[param1])
         {
            this.items.splice(param1,1);
            this.numItems = this.items.length;
         }
      }
      
      public function removeByItem(param1:QuadTreePositionItem) : void
      {
         var _loc2_:int = this.items.indexOf(param1);
         if(_loc2_ > -1)
         {
            this.items.splice(_loc2_,1);
            this.numItems = this.items.length;
         }
      }
      
      public function itemMove(param1:QuadTreePositionItem) : void
      {
         var _loc2_:int = this.items.indexOf(param1);
         if(_loc2_ > -1)
         {
            if(!this.pushItemDown(_loc2_))
            {
               if(this.parentNode != null)
               {
                  this.pushItemUp(_loc2_);
               }
               else if(this.containsPoint(param1))
               {
               }
            }
         }
      }
      
      public function removeFromQuadTree(param1:QuadTreePositionItem) : Boolean
      {
         var _loc2_:int = this.items.indexOf(param1);
         if(_loc2_ > -1)
         {
            this.items.splice(_loc2_,1);
            this.numItems = this.items.length;
            return true;
         }
         if(this.isPartitioned)
         {
            if(this.topLeftNode.removeFromQuadTree(param1) || this.topRightNode.removeFromQuadTree(param1) || this.bottomLeftNode.removeFromQuadTree(param1) || this.bottomRightNode.removeFromQuadTree(param1))
            {
               return true;
            }
         }
         return false;
      }
      
      public function worldResize(param1:Rectangle) : void
      {
         this.parentNode = null;
         this.rect = param1;
         this.isPartitioned = false;
         this.items = new Array();
      }
      
      public function findItemNode(param1:QuadTreePositionItem) : QuadTreeNode
      {
         var _loc3_:QuadTreeNode = null;
         var _loc2_:int = this.items.indexOf(param1);
         if(_loc2_ > -1)
         {
            return this;
         }
         if(this.isPartitioned)
         {
            _loc3_ = null;
            if(this.topLeftNode.containsPoint(param1))
            {
               _loc3_ = this.topLeftNode.findItemNode(param1);
            }
            if(_loc3_ == null && this.topRightNode.containsPoint(param1))
            {
               _loc3_ = this.topRightNode.findItemNode(param1);
            }
            if(_loc3_ == null && this.bottomLeftNode.containsPoint(param1))
            {
               _loc3_ = this.bottomLeftNode.findItemNode(param1);
            }
            if(_loc3_ == null && this.bottomRightNode.containsPoint(param1))
            {
               _loc3_ = this.bottomRightNode.findItemNode(param1);
            }
            return _loc3_;
         }
         return null;
      }
      
      public function destroy() : void
      {
         this.parentNode = null;
         if(this.isPartitioned)
         {
            this.topLeftNode.destroy();
            this.topRightNode.destroy();
            this.bottomLeftNode.destroy();
            this.bottomRightNode.destroy();
            this.topLeftNode = null;
            this.topRightNode = null;
            this.bottomLeftNode = null;
            this.bottomRightNode = null;
         }
         while(this.numItems > 0)
         {
            this.removeItem(0);
         }
         this.isPartitioned = false;
         this._poly = null;
         this.numItems = 0;
         this.items.length = 0;
         this.items = null;
      }
      
      public function setItemState(param1:Polygon2D, param2:Boolean, param3:Array = null) : int
      {
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc7_:QuadTreePositionItem = null;
         if(!this.isPartitioned && this.numItems == 0)
         {
            return 0;
         }
         var _loc4_:Boolean = param2;
         if(param2)
         {
            _loc4_ = this._poly.intersects(param1);
         }
         if(!_loc4_ && this.isAnyChildVisible == 0)
         {
            return 0;
         }
         if(QuadTree.RENDER_QUAD_TREE)
         {
            _loc5_ = 4.6;
            if(!this.isPartitioned)
            {
               ZGameBase.layerPopUp.graphics.beginFill(_loc4_ ? 3407667 : 16724787,0.6);
               ZGameBase.layerPopUp.graphics.drawRect(this._poly.points[0].x * _loc5_,this._poly.points[0].y * _loc5_,(this._poly.points[1].x - this._poly.points[0].x) * _loc5_,(this._poly.points[3].y - this._poly.points[0].y) * _loc5_);
               ZGameBase.layerPopUp.graphics.endFill();
            }
         }
         this.isAnyChildVisible = 0;
         this.visibleStatus = this.STATUS_INVALID;
         if(this.isPartitioned)
         {
            _loc6_ = 0;
            _loc6_ = this.topLeftNode.setItemState(param1,_loc4_,param3);
            this.isAnyChildVisible |= _loc6_;
            _loc6_ = this.topRightNode.setItemState(param1,_loc4_,param3);
            this.isAnyChildVisible |= _loc6_;
            _loc6_ = this.bottomLeftNode.setItemState(param1,_loc4_,param3);
            this.isAnyChildVisible |= _loc6_;
            _loc6_ = this.bottomRightNode.setItemState(param1,_loc4_,param3);
            this.isAnyChildVisible |= _loc6_;
         }
         else
         {
            _loc7_ = null;
            for each(_loc7_ in this.items)
            {
               if(QuadTree.RENDER_QUAD_TREE)
               {
                  ZGameBase.layerPopUp.graphics.beginFill(_loc4_ ? 3407667 : 16724787);
                  ZGameBase.layerPopUp.graphics.drawRect(_loc7_.x * _loc5_,_loc7_.y * _loc5_,2,2);
                  ZGameBase.layerPopUp.graphics.endFill();
               }
               if(_loc4_)
               {
                  this.visibleStatus = this.STATUS_VISIBLE;
                  IsoSpatialComponent(_loc7_.parent).visible(true);
                  if(param3)
                  {
                     param3.push(_loc7_);
                  }
                  this.isAnyChildVisible = 1;
               }
               else
               {
                  this.visibleStatus = this.STATUS_INVISIBLE;
                  IsoSpatialComponent(_loc7_.parent).visible(false);
               }
            }
         }
         return this.isAnyChildVisible;
      }
      
      public function getItems(param1:Rectangle, param2:Array) : void
      {
         var _loc3_:QuadTreePositionItem = null;
         var _loc4_:Point = null;
         if(this.rect.intersects(param1))
         {
            _loc3_ = null;
            for each(_loc3_ in this.items)
            {
               _loc4_ = MathUtils.convertVectorToPoint(_loc3_);
               if(param1.containsPoint(_loc4_))
               {
                  param2.push(_loc3_);
               }
            }
            if(this.isPartitioned)
            {
               this.topLeftNode.getItems(param1,param2);
               this.topRightNode.getItems(param1,param2);
               this.bottomLeftNode.getItems(param1,param2);
               this.bottomRightNode.getItems(param1,param2);
            }
         }
      }
      
      public function getAllItems(param1:Array) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.numItems)
         {
            param1.push(this.items[_loc2_]);
            _loc2_++;
         }
         if(this.isPartitioned)
         {
            this.topLeftNode.getAllItems(param1);
            this.topRightNode.getAllItems(param1);
            this.bottomLeftNode.getAllItems(param1);
            this.bottomRightNode.getAllItems(param1);
         }
      }
      
      public function getAllRects(param1:Array) : void
      {
         param1.push(this.rect);
         if(this.isPartitioned)
         {
            this.topLeftNode.getAllRects(param1);
            this.topRightNode.getAllRects(param1);
            this.bottomLeftNode.getAllRects(param1);
            this.bottomRightNode.getAllRects(param1);
         }
      }
      
      public function containsPoint(param1:Vector3D) : Boolean
      {
         var _loc2_:Point = MathUtils.convertVectorToPoint(param1);
         return this._rect.containsPoint(_loc2_);
      }
      
      public function containsRect(param1:Rectangle) : Boolean
      {
         return this._rect.containsRect(param1);
      }
      
      public function get rect() : Rectangle
      {
         return this._rect;
      }
      
      public function set rect(param1:Rectangle) : void
      {
         this._rect = param1;
      }
   }
}

