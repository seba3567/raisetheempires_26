package utils
{
   import core.ZGlobal;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   
   public class TileUtil
   {
      
      public function TileUtil()
      {
         super();
      }
      
      public static function worldDigitToTile(param1:Number) : int
      {
         return int(param1 * ZGlobal.cellSizeM);
      }
      
      public static function tileDigitToWorld(param1:int) : Number
      {
         return param1 * ZGlobal.cellSize;
      }
      
      public static function worldToTile(param1:Vector3D, param2:Boolean = true) : Vector3D
      {
         if(param2)
         {
            param1 = param1.clone();
         }
         param1.scaleBy(ZGlobal.cellSizeM);
         return param1;
      }
      
      public static function tileToWorld(param1:Vector3D, param2:Boolean = true) : Vector3D
      {
         if(param2)
         {
            param1 = param1.clone();
         }
         param1.scaleBy(ZGlobal.cellSize);
         return param1;
      }
      
      public static function tilePointToWorldPoint(param1:Point, param2:Boolean = false) : Point
      {
         if(param2)
         {
            param1 = param1.clone();
         }
         param1.x *= ZGlobal.cellSize;
         param1.y *= ZGlobal.cellSize;
         return param1;
      }
      
      public static function snapPointToGrid(param1:Point, param2:Boolean = true) : Point
      {
         param1.x = int(param1.x * ZGlobal.cellSizeM) * ZGlobal.cellSize;
         param1.y = int(param1.y * ZGlobal.cellSizeM) * ZGlobal.cellSize;
         return param1;
      }
      
      public static function snapToGrid(param1:Vector3D, param2:Boolean = true) : Vector3D
      {
         if(param2)
         {
            param1 = param1.clone();
         }
         param1.scaleBy(ZGlobal.cellSizeM);
         param1.scaleBy(ZGlobal.cellSize);
         return param1;
      }
      
      public static function worldPointToTilePoint(param1:Point, param2:Boolean = true) : Point
      {
         if(param2)
         {
            param1 = param1.clone();
         }
         param1.x *= ZGlobal.cellSizeM;
         param1.y *= ZGlobal.cellSizeM;
         return param1;
      }
      
      public static function tileOverlapCheck(param1:Object, param2:Object) : Boolean
      {
         var _loc3_:int = Math.max(param1.x,param2.x);
         var _loc4_:int = Math.max(param1.y,param2.y);
         var _loc5_:int = Math.min(param1.x + param1.xLength,param2.x + param2.xLength);
         var _loc6_:int = Math.min(param1.y + param1.yLength,param2.y + param2.yLength);
         return _loc5_ > _loc3_ && _loc6_ > _loc4_;
      }
   }
}

