package core.gamemode.selectionMasker
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gamemode.GridPointer;
   import core.managers.BuildManager;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   
   public class GridSelectionMasker implements ISelectionMaskerTarget
   {
      
      private var m_gridPos:Point = null;
      
      public function GridSelectionMasker(param1:Point)
      {
         super();
         this.m_gridPos = param1;
         this.m_gridPos.x *= ZGlobal.cellSize;
         this.m_gridPos.y *= ZGlobal.cellSize;
      }
      
      public function get parentPosition() : Point
      {
         var _loc1_:Point = GridPointer.instance.position;
         _loc1_.x += ZGlobal.cellSize;
         _loc1_.y += ZGlobal.cellSize * 0.5;
         return _loc1_;
      }
      
      public function get position() : Vector3D
      {
         return new Vector3D(this.m_gridPos.x,this.m_gridPos.y);
      }
      
      public function get volume() : Pt
      {
         return new Pt(ZGlobal.cellSize,ZGlobal.cellSize);
      }
      
      public function get terrainType() : String
      {
         return BuildManager.instance.PAVING_STR;
      }
      
      public function isEqual(param1:Object) : Boolean
      {
         var _loc2_:Point = param1 as Point;
         if(Boolean(_loc2_) && Boolean(_loc2_.x == this.m_gridPos.x) && _loc2_.y == this.m_gridPos.y)
         {
            return true;
         }
         return false;
      }
      
      public function release() : void
      {
      }
   }
}

