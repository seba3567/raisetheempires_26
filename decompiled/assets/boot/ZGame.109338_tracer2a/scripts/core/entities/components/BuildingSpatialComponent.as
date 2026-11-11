package core.entities.components
{
   import core.gameobjects.GameItem;
   import rendering.renderingIso.QuadSpatialComponent;
   import zlabs.core.InputMap;
   import zlabs.core.ObjectType;
   import zlabs.managers.IAreaMapManager;
   
   public class BuildingSpatialComponent extends QuadSpatialComponent
   {
      
      private var _InputMap:InputMap;
      
      public function BuildingSpatialComponent(param1:IAreaMapManager, param2:GameItem)
      {
         var _loc3_:Number = param2.sizeX;
         var _loc4_:Number = param2.sizeY;
         var _loc5_:Number = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
         _loc5_ = _loc5_ * 0.5;
         super(param1,_loc5_,false);
         var _loc6_:String = param2.terrainType;
         if(_loc6_.length > 0)
         {
            objectMask = new ObjectType(_loc6_);
         }
      }
   }
}

