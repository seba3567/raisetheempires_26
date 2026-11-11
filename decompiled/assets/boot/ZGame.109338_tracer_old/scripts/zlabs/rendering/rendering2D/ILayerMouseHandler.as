package zlabs.rendering.rendering2D
{
   import flash.geom.Point;
   import zlabs.core.ObjectType;
   
   public interface ILayerMouseHandler
   {
      
      function getRenderersUnderPoint(param1:Point, param2:ObjectType, param3:Array) : void;
   }
}

