package zlabs.utils.geom
{
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   
   public class Polygon2D
   {
      
      public var points:Array = null;
      
      private var _length:int;
      
      public function Polygon2D()
      {
         super();
      }
      
      public function rectToPoly(param1:Rectangle) : void
      {
         this.points = [new Vector3D(param1.topLeft.x,param1.topLeft.y),new Vector3D(param1.right,param1.y),new Vector3D(param1.bottomRight.x,param1.bottomRight.y),new Vector3D(param1.x,param1.bottom)];
         this.pointsUpdated();
      }
      
      public function addPoint(param1:Vector3D) : void
      {
         if(null == this.points)
         {
            this.points = new Array();
         }
         this.points.push(param1);
         this.pointsUpdated();
      }
      
      public function clear() : void
      {
         if(null != this.points)
         {
            this.points.length = 0;
            this._length = 0;
         }
      }
      
      public function scale(param1:Number) : void
      {
         var _loc3_:Vector3D = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._length)
         {
            _loc3_ = this.points[_loc2_];
            _loc3_.x = int(_loc3_.x * param1);
            _loc3_.y = int(_loc3_.y * param1);
            _loc2_++;
         }
      }
      
      public function intersects(param1:Polygon2D) : Boolean
      {
         if(this.points[2].x < param1.points[0].x)
         {
            return false;
         }
         if(this.points[3].x > param1.points[2].x)
         {
            return false;
         }
         if(this.points[3].y < param1.points[1].y)
         {
            return false;
         }
         if(this.points[0].y > param1.points[3].y)
         {
            return false;
         }
         if(this.goodXRatio(this.points[1],param1.points[0],param1.points[3],true))
         {
            return false;
         }
         if(this.goodXRatio(this.points[3],param1.points[1],param1.points[2],false))
         {
            return false;
         }
         if(this.goodYRatio(this.points[0],param1.points[2],param1.points[3],true))
         {
            return false;
         }
         if(this.goodYRatio(this.points[2],param1.points[1],param1.points[0],false))
         {
            return false;
         }
         return true;
      }
      
      private function goodXRatio(param1:Vector3D, param2:Vector3D, param3:Vector3D, param4:Boolean) : Boolean
      {
         var _loc5_:Number = param1.x - param2.x;
         var _loc6_:Number = param1.y - param2.y;
         if(param4)
         {
            return _loc5_ < _loc6_;
         }
         return _loc5_ > _loc6_;
      }
      
      private function goodYRatio(param1:Vector3D, param2:Vector3D, param3:Vector3D, param4:Boolean) : Boolean
      {
         var _loc5_:Number = param2.x - param3.x;
         var _loc6_:Number = _loc5_ - (param1.x - param3.x);
         var _loc7_:Number = param1.y - param2.y;
         if(param4)
         {
            return _loc6_ < _loc7_;
         }
         return _loc6_ > _loc7_;
      }
      
      private function pointsUpdated() : void
      {
         this._length = this.points.length;
      }
   }
}

