package core.gamemode.selectionMasker
{
   import as3isolib.geom.Pt;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   
   public interface ISelectionMaskerTarget
   {
      
      function get parentPosition() : Point;
      
      function get position() : Vector3D;
      
      function get volume() : Pt;
      
      function get terrainType() : String;
      
      function isEqual(param1:Object) : Boolean;
      
      function release() : void;
   }
}

