package zlabs.utils.quadTree
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import zlabs.ZGameBase;
   import zlabs.utils.MathUtils;
   import zlabs.utils.geom.Polygon2D;
   
   public class QuadTree
   {
      
      public static const RENDER_QUAD_TREE:Boolean = false;
      
      protected var headNode:QuadTreeNode;
      
      protected var maxItems:int;
      
      private var curRect:Rectangle;
      
      public function QuadTree(param1:Rectangle, param2:int)
      {
         super();
         this.curRect = param1;
         this.maxItems = param2;
         this.headNode = new QuadTreeNode(null,this.curRect,this.maxItems);
         this.maxItems = this.maxItems;
      }
      
      public function insert(param1:QuadTreePositionItem) : Boolean
      {
         var _loc2_:Point = MathUtils.convertVectorToPoint(param1);
         if(!this.curRect.containsPoint(_loc2_))
         {
            throw Error("Doesnt fit extents of world");
         }
         if(this.headNode.insert(param1))
         {
            return true;
         }
         return false;
      }
      
      public function get worldRect() : Rectangle
      {
         return this.headNode.rect;
      }
      
      public function resize(param1:Rectangle) : void
      {
         var _loc3_:QuadTreePositionItem = null;
         var _loc2_:Array = new Array();
         this.getAllItems(_loc2_);
         this.headNode.destroy();
         this.headNode = null;
         this.headNode = new QuadTreeNode(null,param1,this.maxItems);
         for each(_loc3_ in _loc2_)
         {
            this.headNode.insert(_loc3_);
         }
      }
      
      public function removeFromQuadTree(param1:QuadTreePositionItem) : Boolean
      {
         return this.headNode.removeFromQuadTree(param1);
      }
      
      public function setItemState(param1:Polygon2D, param2:Array = null) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         if(RENDER_QUAD_TREE)
         {
            ZGameBase.layerPopUp.graphics.clear();
            ZGameBase.layerPopUp.graphics.lineStyle(1,0);
         }
         this.headNode.setItemState(param1,true,param2);
         if(RENDER_QUAD_TREE)
         {
            _loc3_ = 4.6;
            ZGameBase.layerPopUp.graphics.beginFill(3355647,0.3);
            ZGameBase.layerPopUp.graphics.moveTo(param1.points[0].x * _loc3_,param1.points[0].y * _loc3_);
            _loc4_ = 0;
            while(_loc4_ < 4)
            {
               ZGameBase.layerPopUp.graphics.lineTo(param1.points[_loc4_].x * _loc3_,param1.points[_loc4_].y * _loc3_);
               _loc4_++;
            }
            ZGameBase.layerPopUp.graphics.endFill();
         }
      }
      
      public function getItems(param1:Rectangle, param2:Array) : void
      {
         this.headNode.getItems(param1,param2);
      }
      
      public function getAllItems(param1:Array) : void
      {
         if(param1 != null)
         {
            this.headNode.getAllItems(param1);
         }
      }
      
      public function getAllRects(param1:Array) : void
      {
         if(param1 != null)
         {
            this.headNode.getAllRects(param1);
         }
      }
      
      public function reset() : void
      {
         this.destroy();
         this.headNode = new QuadTreeNode(null,this.curRect,this.maxItems);
      }
      
      public function destroy() : void
      {
         this.headNode.destroy();
      }
   }
}

