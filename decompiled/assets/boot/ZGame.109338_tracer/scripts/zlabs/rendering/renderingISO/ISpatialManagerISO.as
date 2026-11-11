package zlabs.rendering.renderingISO
{
   import flash.geom.Point;
   import zlabs.core.ObjectType;
   import zlabs.rendering.rendering2D.ISpatialManager2D;
   
   public interface ISpatialManagerISO extends ISpatialManager2D
   {
      
      function getIsoObjectsUnderPoint(param1:Point, param2:Array, param3:ObjectType = null) : Boolean;
   }
}

