package zlabs.rendering.rendering2D
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import zlabs.core.ObjectType;
   
   public interface ISpatialManager2D
   {
      
      function addSpatialObject(param1:ISpatialObject2D) : void;
      
      function removeSpatialObject(param1:ISpatialObject2D) : void;
      
      function queryRectangle(param1:Rectangle, param2:ObjectType, param3:Array) : Boolean;
      
      function queryCircle(param1:Point, param2:Number, param3:ObjectType, param4:Array) : Boolean;
      
      function castRay(param1:Point, param2:Point, param3:ObjectType, param4:RayHitInfo) : Boolean;
      
      function getObjectsUnderPoint(param1:Point, param2:Array, param3:ObjectType = null) : Boolean;
   }
}

