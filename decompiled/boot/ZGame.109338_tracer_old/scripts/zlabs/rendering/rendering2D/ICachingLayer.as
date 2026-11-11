package zlabs.rendering.rendering2D
{
   import flash.geom.Rectangle;
   
   public interface ICachingLayer
   {
      
      function invalidate(param1:DisplayObjectRenderer) : void;
      
      function invalidateRectangle(param1:Rectangle) : void;
   }
}

