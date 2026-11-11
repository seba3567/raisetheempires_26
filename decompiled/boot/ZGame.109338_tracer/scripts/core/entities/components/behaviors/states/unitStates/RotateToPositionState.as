package core.entities.components.behaviors.states.unitStates
{
   import as3isolib.geom.Pt;
   import core.entities.components.BuildingSpatialComponent;
   import core.entities.components.UnitFSMComponent;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.behaviors.states.SimpleAutoState;
   import core.entities.components.states.IMachine;
   import core.gameobjects.GameItem;
   import entity.GameDataComponent;
   import flash.geom.Vector3D;
   import zlabs.entity.IEntity;
   
   public class RotateToPositionState extends SimpleAutoState
   {
      
      public function RotateToPositionState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      public static function rotateToPos(param1:IEntity, param2:Pt) : Boolean
      {
         var _loc3_:BuildingSpatialComponent = BuildingSpatialComponent(param1.lookupComponentByType(BuildingSpatialComponent));
         var _loc4_:Vector3D = _loc3_.position;
         var _loc5_:Number = param2.x - _loc4_.x;
         var _loc6_:Number = param2.y - _loc4_.y;
         var _loc7_:GameDataComponent = GameDataComponent(param1.lookupComponentByType(GameDataComponent));
         var _loc8_:int = GameItem.getDirectionFromAngle(Math.atan2(_loc6_,_loc5_) - Math.PI / 2);
         if(_loc8_ != _loc7_.direction)
         {
            _loc7_.direction = _loc8_;
            return true;
         }
         return false;
      }
      
      override public function enter(param1:IMachine) : void
      {
         var _loc2_:UnitFSMComponent = UnitFSMComponent(IEntity(param1.propertyBag).lookupComponentByType(UnitFSMComponent));
         rotateToPos(IEntity(param1.propertyBag),_loc2_.targetPosition);
         super.enter(param1);
      }
   }
}

