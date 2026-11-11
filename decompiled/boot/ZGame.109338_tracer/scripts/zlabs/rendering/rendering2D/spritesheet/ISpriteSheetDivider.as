package zlabs.rendering.rendering2D.spritesheet
{
   import flash.geom.Rectangle;
   
   public interface ISpriteSheetDivider
   {
      
      function get frameCount() : int;
      
      function set owningSheet(param1:SpriteSheetComponent) : void;
      
      function getFrameArea(param1:int) : Rectangle;
      
      function clone() : ISpriteSheetDivider;
   }
}

