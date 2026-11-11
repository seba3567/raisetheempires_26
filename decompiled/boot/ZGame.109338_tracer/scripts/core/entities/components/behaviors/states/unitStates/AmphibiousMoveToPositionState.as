package core.entities.components.behaviors.states.unitStates
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.managers.BuildManager;
   import entity.GameDataComponent;
   import flash.geom.Vector3D;
   import zlabs.entity.IEntity;
   
   public class AmphibiousMoveToPositionState extends MoveToPositionState
   {
      
      private var m_gameData:GameDataComponent = null;
      
      public function AmphibiousMoveToPositionState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override public function enter(param1:IMachine) : void
      {
         this.m_gameData = IEntity(param1.propertyBag).lookupComponentByType(GameDataComponent) as GameDataComponent;
         super.enter(param1);
      }
      
      override public function exit(param1:IMachine) : void
      {
         super.exit(param1);
         this.m_gameData = null;
      }
      
      override protected function positionUpdated(param1:Number, param2:Vector3D) : void
      {
         var _loc4_:int = 0;
         super.positionUpdated(param1,param2);
         var _loc3_:Boolean = BuildManager.instance.getBuildType(param2.x / ZGlobal.cellSize,param2.y / ZGlobal.cellSize,BuildManager.instance.WATER_STR);
         if(this.m_gameData.inWater != _loc3_)
         {
            this.m_gameData.inWater = _loc3_;
            _loc4_ = stateMachine.propertyBag.getProperty(directionProperty,null) as int;
            direction = _loc4_;
         }
      }
      
      override protected function get imageName() : String
      {
         return AmphibiousIdleState.getImageName(this.m_gameData,m_imageName);
      }
   }
}

