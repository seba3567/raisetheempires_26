package zlabs.rendering.rendering2D
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import zlabs.core.ObjectType;
   
   public interface ISpatialObject2D
   {
      
      function get worldExtents() : Rectangle;
      
      function get objectMask() : ObjectType;
      
      function castRay(param1:Point, param2:Point, param3:ObjectType, param4:RayHitInfo) : Boolean;
      
      function pointOccupied(param1:Point, param2:ObjectType, param3:IScene2D) : Boolean;
   }
}

