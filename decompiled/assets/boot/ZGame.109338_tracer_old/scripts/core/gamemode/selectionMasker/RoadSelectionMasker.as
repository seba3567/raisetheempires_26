package core.gamemode.selectionMasker
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gamemode.GridPointer;
   import core.gamemode.helpers.RoadPlacementProxy;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   
   public class RoadSelectionMasker implements ISelectionMaskerTarget
   {
      
      private var m_road:RoadPlacementProxy = null;
      
      public function RoadSelectionMasker(param1:RoadPlacementProxy)
      {
         super();
         this.m_road = param1;
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
         var _loc1_:Point = null;
         if(this.m_road.placementList.length > 0)
         {
            _loc1_ = this.m_road.placementList[0];
            return new Vector3D(_loc1_.x / ZGlobal.cellSize,_loc1_.y / ZGlobal.cellSize);
         }
         return new Vector3D();
      }
      
      public function get volume() : Pt
      {
         return new Pt(ZGlobal.cellSize,ZGlobal.cellSize);
      }
      
      public function get terrainType() : String
      {
         return "";
      }
      
      public function isEqual(param1:Object) : Boolean
      {
         return false;
      }
      
      public function release() : void
      {
         this.m_road = null;
      }
   }
}

