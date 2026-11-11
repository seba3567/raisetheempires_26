package zlabs.utils
{
   import as3isolib.geom.Pt;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   
   public class MathUtils
   {
      
      public static var EXPANSION_CELL_NUMTILES:uint = 8;
      
      public static var EXPANSION_NUM_CELLS:uint = 14;
      
      private static var m_idCounter:Number = 0;
      
      public function MathUtils()
      {
         super();
      }
      
      public static function randBetween(param1:Number, param2:Number) : Number
      {
         return Math.random() * (param2 - param1) + param1;
      }
      
      public static function roundTo(param1:Number, param2:int) : Number
      {
         var _loc3_:int = 1;
         while(param2 > 0)
         {
            _loc3_ *= 10;
            param2--;
         }
         var _loc4_:int = int(param1 * _loc3_);
         return Number(_loc4_) / _loc3_;
      }
      
      public static function generateUniqueId() : Object
      {
         return "local:" + m_idCounter++;
      }
      
      public static function convertPtToPoint(param1:Pt) : Point
      {
         return new Point(param1.x,param1.y);
      }
      
      public static function convertPointToPt(param1:Point) : Pt
      {
         return new Pt(param1.x,param1.y,0);
      }
      
      public static function convertVectorToPoint(param1:Vector3D) : Point
      {
         return new Point(param1.x,param1.y);
      }
      
      public static function convertPointToVector3D(param1:Point) : Vector3D
      {
         return new Vector3D(param1.x,param1.y);
      }
      
      public static function convertVector3DtoPt(param1:Vector3D) : Pt
      {
         return new Pt(param1.x,param1.y,param1.z);
      }
      
      public static function convertPtToVector3D(param1:Pt) : Vector3D
      {
         return new Vector3D(param1.x,param1.y,param1.z);
      }
      
      public static function worldToTile(param1:Pt, param2:int) : Pt
      {
         return new Pt(param1.x / param2,param1.y / param2,param1.z);
      }
      
      public static function tileToWorld(param1:Number, param2:Number, param3:Number, param4:Number) : Pt
      {
         return new Pt(param1 * param4,param2 * param4,param3 * param4);
      }
      
      public static function snapToGrid(param1:Pt, param2:Number) : Pt
      {
         param1.x = int(param1.x / param2) * param2;
         param1.y = int(param1.y / param2) * param2;
         return param1;
      }
      
      public static function isoToExpansionIndex(param1:uint, param2:uint, param3:uint) : uint
      {
         param1 /= EXPANSION_CELL_NUMTILES;
         param2 /= EXPANSION_CELL_NUMTILES;
         var _loc4_:uint = param3 / EXPANSION_CELL_NUMTILES;
         return param1 + param2 * _loc4_;
      }
      
      public static function expansionIndexToIso(param1:uint, param2:uint, param3:Point) : void
      {
         var _loc4_:uint = param1 % EXPANSION_NUM_CELLS;
         var _loc5_:uint = param1 / EXPANSION_NUM_CELLS;
         param3.x = _loc4_ * EXPANSION_CELL_NUMTILES;
         param3.y = _loc5_ * EXPANSION_CELL_NUMTILES;
      }
      
      public static function gridToExpansionIndex(param1:uint, param2:uint, param3:uint) : uint
      {
         var _loc4_:uint = 4;
         var _loc5_:uint = EXPANSION_CELL_NUMTILES / _loc4_;
         var _loc6_:uint = param3 / EXPANSION_CELL_NUMTILES;
         var _loc7_:uint = param2 - param2 % _loc5_;
         var _loc8_:uint = _loc7_ * _loc6_ / _loc5_;
         return uint(_loc8_ + param1 / _loc5_);
      }
      
      public static function expansionIndexToGrid(param1:uint, param2:uint) : Pt
      {
         var _loc3_:uint = param2 / EXPANSION_CELL_NUMTILES;
         return new Pt(uint(param1 % _loc3_),uint(param1 / _loc3_));
      }
      
      public static function degreeToRadians(param1:Number) : Number
      {
         return param1 * (Math.PI / 180);
      }
      
      public static function radiansToDegrees(param1:Number) : Number
      {
         return param1 * 180 / Math.PI;
      }
   }
}

