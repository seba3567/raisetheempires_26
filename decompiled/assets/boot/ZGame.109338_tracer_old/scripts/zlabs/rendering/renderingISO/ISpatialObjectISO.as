package zlabs.rendering.renderingISO
{
   import as3isolib.bounds.IBounds;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import zlabs.rendering.rendering2D.ISpatialObject2D;
   
   public interface ISpatialObjectISO extends ISpatialObject2D
   {
      
      function get isoBounds() : IBounds;
      
      function get bounds() : Rectangle;
      
      function set position(param1:Vector3D) : void;
      
      function get position() : Vector3D;
   }
}

