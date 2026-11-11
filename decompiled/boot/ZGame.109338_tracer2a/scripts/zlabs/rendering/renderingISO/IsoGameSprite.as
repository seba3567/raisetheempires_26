package zlabs.rendering.renderingISO
{
   import as3isolib.display.IsoSprite;
   import flash.geom.Point;
   
   public class IsoGameSprite extends IsoSprite
   {
      
      public function IsoGameSprite()
      {
         super();
      }
      
      public function pickObject(param1:Point) : Boolean
      {
         return false;
      }
   }
}

