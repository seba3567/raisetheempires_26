package rendering.road
{
   import flash.geom.Point;
   import utils.TileUtil;
   import zlabs.debug.Logger;
   
   public class Road
   {
      
      private var m_startCell:Point;
      
      private var m_endCell:Point;
      
      private var m_startPos:Point;
      
      private var m_endPos:Point;
      
      private var m_lineArray:Array;
      
      public function Road(param1:Point, param2:Point)
      {
         super();
         if(null != param1 && null != param2)
         {
            this.m_startCell = param1;
            this.m_endCell = param2;
            this.m_startPos = this.m_startCell.clone();
            this.m_endPos = this.m_endCell.clone();
            this.m_lineArray = new Array();
            if(this.m_startCell.x != this.m_endCell.x && this.m_startCell.y != this.m_endCell.y)
            {
               Logger.error(this,"Road","this is a non straight line we cant use it!");
            }
            this.endpointsUpdated();
         }
      }
      
      public function get startCell() : Point
      {
         return this.m_startCell;
      }
      
      public function set startCell(param1:Point) : void
      {
         this.m_startCell = param1;
         this.m_startPos = this.m_startCell.clone();
      }
      
      public function get endCell() : Point
      {
         return this.m_endCell;
      }
      
      public function set endCell(param1:Point) : void
      {
         this.m_endCell = param1;
         this.m_endPos = this.m_endCell.clone();
      }
      
      public function get startPos() : Point
      {
         return TileUtil.tilePointToWorldPoint(this.m_startPos,true);
      }
      
      public function get endPos() : Point
      {
         return TileUtil.tilePointToWorldPoint(this.m_endPos,true);
      }
      
      public function breakLineAtPoint(param1:int, param2:int) : Array
      {
         var _loc11_:Road = null;
         var _loc3_:Array = new Array();
         var _loc4_:Point = new Point(param1,param2);
         var _loc5_:Point = this.m_startCell.length < this.m_endCell.length ? this.m_startCell : this.m_endCell;
         var _loc6_:Point = this.m_startCell.length < this.m_endCell.length ? this.m_endCell : this.m_startCell;
         var _loc7_:Point = _loc5_.x == _loc6_.x ? new Point(0,1) : new Point(1,0);
         var _loc8_:Point = _loc4_.subtract(_loc7_);
         var _loc9_:Point = _loc4_.add(_loc7_);
         var _loc10_:int = _loc5_.subtract(_loc6_).length;
         if(_loc8_.subtract(_loc5_).length >= 0 && this.containsPoint(_loc8_.x,_loc8_.y) && !_loc8_.equals(_loc4_))
         {
            if(_loc8_.x != _loc5_.x && _loc8_.y != _loc5_.y)
            {
               throw new Error("something broke with this code that Eddie wrote");
            }
            _loc11_ = new Road(_loc5_.clone(),_loc8_);
            _loc3_.push(_loc11_);
         }
         if(_loc6_.subtract(_loc9_).length >= 0 && this.containsPoint(_loc9_.x,_loc9_.y) && !_loc9_.equals(_loc4_))
         {
            if(_loc9_.x != _loc6_.x && _loc9_.y != _loc6_.y)
            {
               throw new Error("something broke with this code that Eddie wrote");
            }
            _loc11_ = new Road(_loc9_,_loc6_.clone());
            _loc3_.push(_loc11_);
         }
         return _loc3_;
      }
      
      public function containsPoint(param1:int, param2:int) : Boolean
      {
         if(this.m_startCell.length < this.m_endCell.length)
         {
            if(param1 >= this.m_startCell.x && param1 <= this.m_endCell.x && param2 >= this.m_startCell.y && param2 <= this.m_endCell.y)
            {
               return true;
            }
         }
         else if(param1 >= this.m_endCell.x && param1 <= this.m_startCell.x && param2 >= this.m_endCell.y && param2 <= this.m_startCell.y)
         {
            return true;
         }
         return false;
      }
      
      public function serialize() : String
      {
         var _loc1_:String = this.m_startCell.x + "," + this.m_startCell.y;
         return _loc1_ + ("|" + this.m_endCell.x + "," + this.m_endCell.y);
      }
      
      public function deSerialize(param1:String) : void
      {
         var _loc2_:Array = param1.split("|");
         var _loc3_:Array = _loc2_[0].split(",");
         this.m_startCell = new Point(_loc3_[0],_loc3_[1]);
         var _loc4_:Array = _loc2_[1].split(",");
         this.m_endCell = new Point(_loc4_[0],_loc4_[1]);
         this.m_startPos = this.m_startCell.clone();
         this.m_endPos = this.m_endCell.clone();
         this.m_lineArray = new Array();
         this.endpointsUpdated();
      }
      
      public function getLine() : Array
      {
         return this.m_lineArray;
      }
      
      public function endpointsUpdated() : void
      {
         RoadTileSetManager.drawStraightLine(this.m_startCell,this.m_endCell,this.m_lineArray);
      }
      
      public function get direction() : Number
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         if(this.m_startCell.x < this.m_endCell.x)
         {
            _loc1_ = Math.abs(this.m_endCell.x) - Math.abs(this.m_startCell.x);
            _loc2_ = Math.abs(this.m_endCell.y) - Math.abs(this.m_startCell.y);
         }
         else
         {
            _loc1_ = Math.abs(this.m_startCell.x) - Math.abs(this.m_endCell.x);
            _loc2_ = Math.abs(this.m_startCell.y) - Math.abs(this.m_endCell.y);
         }
         return Math.abs(Math.atan2(_loc2_,_loc1_) * (180 / Math.PI));
      }
      
      public function dispose() : void
      {
         this.m_lineArray = null;
         this.m_endPos = null;
         this.m_startPos = null;
         this.m_endCell = null;
         this.m_startCell = null;
      }
      
      public function length(param1:Point, param2:Point) : Number
      {
         var _loc3_:Number = param1.x - param2.x;
         var _loc4_:Number = param1.y - param2.y;
         return Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
      }
      
      public function scalar(param1:Point, param2:Point, param3:Point) : Number
      {
         var _loc4_:Number = this.length(param1,param2);
         var _loc5_:Number = this.length(param1,param3);
         return _loc5_ / _loc4_;
      }
      
      public function angle(param1:Point, param2:Point) : Number
      {
         return Math.atan2(param2.y - param1.y,param2.x - param1.x);
      }
      
      public function degree(param1:Point, param2:Point) : Number
      {
         return this.angle(param1,param2) * 180 / Math.PI;
      }
      
      public function isParallel(param1:Point, param2:Point, param3:Point, param4:Point) : Boolean
      {
         return this.angle(param1,param2) == this.angle(param3,param4);
      }
      
      public function isPointOnLine(param1:Point, param2:Point, param3:Point) : Boolean
      {
         return Math.abs(this.degree(param1,param2) - this.degree(param1,param3)) < 0.25 && this.length(param1,param3) <= this.length(param1,param2);
      }
      
      public function projectOnLine(param1:Point, param2:Point, param3:Number) : Object
      {
         var _loc4_:Number = this.angle(param1,param2);
         return {
            "x":param1.x + Math.cos(_loc4_) * param3,
            "y":param1.y + Math.sin(_loc4_) * param3
         };
      }
      
      public function isPointColinear(param1:Point) : Boolean
      {
         var _loc2_:Boolean = param1.x == this.m_startCell.x && param1.x == this.m_endCell.x;
         var _loc3_:Boolean = param1.y == this.m_startCell.y && param1.y == this.m_endCell.y;
         return _loc2_ || _loc3_;
      }
   }
}

