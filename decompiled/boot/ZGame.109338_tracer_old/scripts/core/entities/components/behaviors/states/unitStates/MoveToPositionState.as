package core.entities.components.behaviors.states.unitStates
{
   import Engine.Managers.TransactionManager;
   import as3isolib.geom.Pt;
   import com.greensock.TweenLite;
   import com.greensock.easing.Linear;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.entities.components.UnitFSMComponent;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.behaviors.states.SimpleAutoState;
   import core.entities.components.states.IMachine;
   import core.gamemode.orders.OrdersComponent;
   import core.gameobjects.Fleet;
   import flash.events.Event;
   import flash.geom.Vector3D;
   import transactions.TMove;
   import utils.ZGameTime;
   import zlabs.core.PBGroup;
   import zlabs.entity.IEntity;
   import zlabs.entity.PropertyReference;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   
   public class MoveToPositionState extends SimpleAutoState
   {
      
      private var m_positionReference:PropertyReference = null;
      
      private var m_start:Vector3D = null;
      
      private var m_end:Pt = null;
      
      private var m_distance:Number = 0;
      
      private var m_speed:Number = 1;
      
      private var m_entity:IEntity;
      
      public function MoveToPositionState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override public function enter(param1:IMachine) : void
      {
         this.m_positionReference = new PropertyReference("@IsoSpatial.position");
         param1.propertyBag.eventDispatcher.dispatchEvent(new Event(IsoSpatialComponent.START));
         this.m_speed = ZGlobal.gameSettings.getNumber("walkSpeed");
         this.m_speed = 1 / this.m_speed;
         this.startMoving(param1);
         super.enter(param1);
      }
      
      override protected function updateOverrides(param1:XML) : void
      {
         super.updateOverrides(param1);
         m_durationSeconds = new ZGameTime(this.m_distance * this.m_speed);
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         TweenLite.killTweensOf(this);
         var _loc2_:OrdersComponent = OrdersComponent.getOrdersComponent(this.m_entity);
         if(null != _loc2_ && _loc2_.snapToDestination)
         {
            this.progress = 1;
         }
         this.m_entity = null;
         this.m_positionReference = null;
         if(param1)
         {
            param1.propertyBag.eventDispatcher.dispatchEvent(new Event(IsoSpatialComponent.STOP));
            super.performExitActions(param1);
         }
      }
      
      override public function stop() : void
      {
         super.stop();
         this.performExitActions(stateMachine);
      }
      
      private function startMoving(param1:IMachine) : void
      {
         var _loc5_:Fleet = null;
         this.m_entity = IEntity(param1.propertyBag);
         var _loc2_:UnitFSMComponent = UnitFSMComponent(this.m_entity.lookupComponentByType(UnitFSMComponent));
         this.m_start = IEntity(param1.propertyBag).getProperty(this.m_positionReference);
         this.m_end = _loc2_.targetPosition;
         var _loc3_:Number = this.m_end.x - this.m_start.x;
         var _loc4_:Number = this.m_end.y - this.m_start.y;
         this.m_distance = Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_) / ZGlobal.cellSize;
         var _loc6_:PBGroup = IEntity(stateMachine.propertyBag).owningGroup;
         if((Boolean(_loc6_)) && Boolean(_loc6_.name))
         {
            _loc5_ = ZGlobal.hostPlayer.fleets.getFleetByName(_loc6_.name);
         }
         var _loc7_:Boolean = false;
         if(Boolean(_loc5_) && Boolean(_loc5_.uid) && _loc5_.uid != ZGlobal.player.uid)
         {
            _loc7_ = true;
         }
         if(yieldHelper.usesEnergy(this.m_entity) && !_loc7_)
         {
            TransactionManager.addTransaction(new TMove(stateMachine.propertyBag as IEntity,this.m_end),true);
         }
         TweenLite.to(this,this.m_distance * this.m_speed,{
            "progress":1,
            "ease":Linear.easeNone
         });
         _loc2_.targetPosition = null;
      }
      
      public function get progress() : Number
      {
         return 0;
      }
      
      public function set progress(param1:Number) : void
      {
         var _loc2_:Pt = Pt.interpolate(Pt.toPt(this.m_start),this.m_end,param1);
         var _loc3_:BuildingSpatialComponent = BuildingSpatialComponent(this.m_entity.lookupComponentByType(BuildingSpatialComponent));
         var _loc4_:Vector3D = new Vector3D(_loc2_.x,_loc2_.y,_loc2_.z);
         _loc3_.position = _loc4_;
         this.positionUpdated(param1,_loc4_);
      }
      
      protected function positionUpdated(param1:Number, param2:Vector3D) : void
      {
      }
   }
}

