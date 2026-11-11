package core.gamemode.orders
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.UnitFSMComponent;
   import core.gamemode.GMDefault;
   import core.gamemode.GameMode;
   import core.gamemode.GameModeManager;
   import events.UnitEvent;
   import flash.events.Event;
   import flash.geom.Point;
   import zlabs.core.IPBObject;
   import zlabs.entity.IEntity;
   import zlabs.utils.MathUtils;
   
   public class MoveOrder extends Order
   {
      
      private var m_position:Pt = null;
      
      private var m_failed:Boolean = false;
      
      public function MoveOrder(param1:Pt, param2:int)
      {
         super(param2);
         this.m_position = param1;
      }
      
      override public function get destination() : Pt
      {
         return this.m_position.clone() as Pt;
      }
      
      public function isValid(param1:Pt) : Boolean
      {
         var _loc2_:Pt = this.getGridPosition(param1);
         var _loc3_:Pt = this.getGridPosition(this.m_position);
         if(Pt.distance(_loc2_,_loc3_) > 0)
         {
            return true;
         }
         return false;
      }
      
      private function getGridPosition(param1:Pt) : Pt
      {
         var _loc2_:GameMode = GameModeManager.instance.getTopGameMode();
         var _loc3_:Number = _loc2_.gridScale;
         var _loc4_:Pt = new Pt(param1.x,param1.y);
         _loc4_ = MathUtils.snapToGrid(_loc4_,ZGlobal.cellSize * _loc3_);
         _loc4_.x += ZGlobal.cellSize * _loc3_ * 0.5;
         _loc4_.y += ZGlobal.cellSize * _loc3_ * 0.5;
         return _loc4_;
      }
      
      override public function execute(param1:IEntity) : void
      {
         super.execute(param1);
         var _loc2_:Pt = this.getGridPosition(this.m_position);
         if(!this.moveGroupIfAllowed(param1,_loc2_))
         {
            this.moveUnit(param1,_loc2_);
         }
      }
      
      protected function moveUnit(param1:IEntity, param2:Pt) : void
      {
         param1.eventDispatcher.addEventListener(UnitEvent.ACTION_FAILED,this.onActionFailed);
         var _loc3_:UnitFSMComponent = UnitFSMComponent(param1.lookupComponentByType(UnitFSMComponent));
         _loc3_.targetPosition = param2;
         this.dispatchUnitEvent(param1);
         param1.eventDispatcher.removeEventListener(UnitEvent.ACTION_FAILED,this.onActionFailed);
      }
      
      protected function dispatchUnitEvent(param1:IEntity) : void
      {
         param1.eventDispatcher.dispatchEvent(new UnitEvent(UnitEvent.TERRAIN_AS_TARGET));
      }
      
      protected function moveGroupIfAllowed(param1:IEntity, param2:Pt) : Boolean
      {
         if(GMDefault.isUnitOwnedByPlayer(param1))
         {
            this.moveGroup(param1,param2);
            return true;
         }
         return false;
      }
      
      protected function moveGroup(param1:IEntity, param2:Pt) : void
      {
         var _loc4_:IPBObject = null;
         var _loc5_:IEntity = null;
         var _loc6_:Pt = null;
         var _loc7_:Point = null;
         var _loc8_:Boolean = false;
         var _loc3_:int = 0;
         while(_loc3_ < param1.owningGroup.length)
         {
            _loc4_ = param1.owningGroup.getItem(_loc3_);
            _loc5_ = IEntity(_loc4_);
            _loc6_ = new Pt(param2.x,param2.y);
            _loc7_ = new Point(0,0);
            _loc8_ = _loc3_ > 0;
            if(_loc8_)
            {
            }
            _loc6_.x += _loc7_.x;
            _loc6_.y += _loc7_.y;
            this.moveUnit(_loc5_,_loc6_);
            if(_loc8_)
            {
               m_eventMonitor.addDispatcher(_loc5_.eventDispatcher,UnitEvent.ACTION_COMPLETE);
            }
            if(this.m_failed)
            {
               break;
            }
            _loc3_++;
         }
      }
      
      protected function onActionFailed(param1:UnitEvent) : void
      {
         this.m_failed = true;
         dispatchEvent(new Event(Event.CANCEL));
      }
   }
}

