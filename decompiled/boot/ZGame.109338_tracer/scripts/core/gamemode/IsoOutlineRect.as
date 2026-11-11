package core.gamemode
{
   import as3isolib.display.IsoView;
   import as3isolib.display.primitive.IsoRectangle;
   import as3isolib.graphics.SolidColorFill;
   import as3isolib.graphics.Stroke;
   import core.ZGlobal;
   import flash.geom.Point;
   import utils.TileUtil;
   
   public class IsoOutlineRect extends IsoRectangle
   {
      
      private static var m_isoView:IsoView;
      
      public function IsoOutlineRect(param1:int, param2:int)
      {
         super();
         renderAsOrphan = true;
         width = ZGlobal.cellSize * param1;
         length = ZGlobal.cellSize * param2;
         container.visible = true;
         m_isoView.backgroundContainer.addChild(container);
      }
      
      public static function init(param1:IsoView) : void
      {
         m_isoView = param1;
      }
      
      public function dispose() : void
      {
         if(container.parent)
         {
            container.parent.removeChild(container);
         }
      }
      
      public function setPosition(param1:Point) : void
      {
         var _loc2_:Point = TileUtil.tilePointToWorldPoint(param1,true);
         moveTo(_loc2_.x,_loc2_.y,0);
         render();
      }
      
      public function setColor(param1:uint, param2:Boolean) : void
      {
         var _loc3_:SolidColorFill = new SolidColorFill(param1,0.25);
         fill = _loc3_;
         var _loc4_:Stroke = new Stroke(4,param1,param2 ? 0.5 : 0);
         stroke = _loc4_;
         render();
      }
   }
}

