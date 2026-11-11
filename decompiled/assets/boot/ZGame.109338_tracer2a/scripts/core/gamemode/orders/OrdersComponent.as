package core.gamemode.orders
{
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.BuildingSpatialComponent;
   import core.entities.components.UnitFSMComponent;
   import core.gamemode.GameModeManager;
   import core.gamemode.GridPointer;
   import core.gameobjects.Fleet;
   import core.managers.visitorManager.VisitorManager;
   import dispatchers.MessageDispatcher;
   import entity.GameDataComponent;
   import flash.events.Event;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.EntityComponent;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.utils.MathUtils;
   
   public class OrdersComponent extends EntityComponent
   {
      
      private static const PRIORITY_ACTIVE_TARGET_MOVE:int = 20;
      
      private static const PRIORITY_ACTIVE_STANDARD_MOVE:int = 30;
      
      private static const PRIORITY_NEW_TARGET_MOVE:int = 40;
      
      private static const PRIORITY_NEW_STANDARD_MOVE:int = 50;
      
      private var m_orders:Array = null;
      
      public function OrdersComponent()
      {
         super();
      }
      
      public static function getOrdersComponent(param1:IEntity) : OrdersComponent
      {
         return OrdersComponent(param1.lookupComponentByType(OrdersComponent));
      }
      
      public function get snapToDestination() : Boolean
      {
         return true;
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         this.m_orders = new Array();
         MessageDispatcher.instance.addEventListener(MessageDispatcher.SET_DESTINATION,this.onSetDestination,false,0,true);
         VisitorManager.instance.addEventListener(VisitorManager.VISITOR_TARGET_HELPED,this.onEntityHelped,false,0,true);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         this.clearExistingOrders();
         this.m_orders.length = 0;
         this.m_orders = null;
         MessageDispatcher.instance.removeEventListener(MessageDispatcher.SET_DESTINATION,this.onSetDestination);
         VisitorManager.instance.removeEventListener(VisitorManager.VISITOR_TARGET_HELPED,this.onEntityHelped);
      }
      
      public function getTargetCentre(param1:IEntity, param2:Pt) : Pt
      {
         var _loc3_:BuildingSpatialComponent = BuildingSpatialComponent(param1.lookupComponentByType(BuildingSpatialComponent));
         var _loc4_:Pt = Pt.toPt(_loc3_.position);
         param2.x = _loc3_.volume.x;
         param2.y = _loc3_.volume.y;
         _loc4_.x += param2.x * 0.5;
         _loc4_.y += param2.y * 0.5;
         return _loc4_;
      }
      
      private function getTargetPosition(param1:IEntity) : Pt
      {
         var _loc2_:Pt = this.destinationOfFinalOrder();
         if(null == _loc2_)
         {
            _loc2_ = this.getPosition(owner);
         }
         var _loc3_:Pt = new Pt();
         var _loc4_:Pt = this.getTargetCentre(param1,_loc3_);
         var _loc5_:Number = Pt.distance(_loc2_,_loc4_);
         return Pt.interpolate(_loc4_,_loc2_,(_loc3_.x + ZGlobal.cellSize) * 0.5 / _loc5_);
      }
      
      private function getPosition(param1:IEntity) : Pt
      {
         var _loc2_:BuildingSpatialComponent = BuildingSpatialComponent(param1.lookupComponentByType(BuildingSpatialComponent));
         return Pt.toPt(_loc2_.position);
      }
      
      public function setDestination(param1:Pt) : void
      {
         var _loc3_:Fleet = null;
         var _loc2_:MoveOrder = null;
         if(owner.owningGroup.name)
         {
            _loc3_ = ZGlobal.hostPlayer.fleets.getFleetByName(owner.owningGroup.name);
         }
         if(_loc3_)
         {
            if(_loc3_.hasStatus(Fleet.IN_COMBAT))
            {
               Logger.print(OrdersComponent,"OrdersComponent: Cannot move fleet: " + owner.owningGroup.name + " is currently in combat.");
               return;
            }
            _loc2_ = new MoveOrderClientOnly(param1,PRIORITY_ACTIVE_STANDARD_MOVE);
         }
         else
         {
            _loc2_ = new MoveOrder(param1,PRIORITY_ACTIVE_STANDARD_MOVE);
         }
         var _loc4_:Pt = this.destinationOfFinalOrder();
         if(null == _loc4_)
         {
            _loc4_ = this.getPosition(owner);
         }
         if(_loc2_.isValid(_loc4_))
         {
            this.insertOrders([_loc2_],PRIORITY_NEW_STANDARD_MOVE);
            GridPointer.instance.dispatchEvent(new Event(GridPointer.SET_DESTINATION));
         }
         else
         {
            _loc2_ = null;
         }
      }
      
      public function setTarget(param1:IEntity) : void
      {
         var _loc2_:Pt = null;
         if(param1 != owner)
         {
            if(!this.alreadyInList(param1))
            {
               _loc2_ = this.getTargetPosition(param1);
               this.insertOrders([new MoveOrder(_loc2_,PRIORITY_ACTIVE_TARGET_MOVE),new ClickOrder(param1)],PRIORITY_NEW_TARGET_MOVE);
            }
         }
      }
      
      private function alreadyInList(param1:IEntity) : Boolean
      {
         var _loc2_:Order = null;
         for each(_loc2_ in this.m_orders)
         {
            if(_loc2_.target == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      private function getAttackingOffset(param1:Pt, param2:Pt) : Pt
      {
         var _loc3_:Pt = new Pt(0,0);
         if(param2.x > param1.x)
         {
            _loc3_.x = 1;
         }
         else if(param2.x < param1.x)
         {
            _loc3_.x = -1;
         }
         if(param2.y > param1.y)
         {
            _loc3_.y = 1;
         }
         else if(param2.y < param1.y)
         {
            _loc3_.y = -1;
         }
         return _loc3_;
      }
      
      public function setTargetToBattle(param1:IEntity) : void
      {
         var _loc2_:Fleet = null;
         var _loc3_:Number = NaN;
         var _loc4_:Pt = null;
         var _loc5_:Pt = null;
         var _loc6_:Array = null;
         if(param1 != owner)
         {
            if(owner.owningGroup.name)
            {
               _loc2_ = ZGlobal.hostPlayer.fleets.getFleetByName(owner.owningGroup.name);
            }
            if(_loc2_)
            {
               if(_loc2_.hasStatus(Fleet.IN_COMBAT))
               {
                  Logger.print(OrdersComponent,"OrdersComponent: Cannot attack with fleet: " + owner.owningGroup.name + " is currently in combat.");
                  return;
               }
            }
            _loc3_ = GameModeManager.instance.getTopGameMode().gridScale;
            _loc4_ = this.getPosition(param1);
            _loc4_ = MathUtils.snapToGrid(_loc4_,ZGlobal.cellSize * _loc3_);
            _loc5_ = this.getPosition(owner);
            _loc5_ = MathUtils.snapToGrid(_loc5_,ZGlobal.cellSize * _loc3_);
            _loc6_ = new Array();
            _loc6_.push(new BattleOrder(param1));
            this.insertOrders(_loc6_,PRIORITY_NEW_TARGET_MOVE);
         }
      }
      
      public function setCombatField(param1:IEntity) : void
      {
      }
      
      public function destinationOfFinalOrder() : Pt
      {
         if(this.m_orders.length > 0)
         {
            return this.m_orders[this.m_orders.length - 1].destination;
         }
         return null;
      }
      
      public function get orderCount() : int
      {
         return int(this.m_orders.length) || 0;
      }
      
      private function canBeInterruptedBy(param1:int, param2:int) : Boolean
      {
         if(param1 >= 0)
         {
            switch(param1)
            {
               case PRIORITY_ACTIVE_STANDARD_MOVE:
                  switch(param2)
                  {
                     case PRIORITY_NEW_STANDARD_MOVE:
                        return true;
                     case PRIORITY_NEW_TARGET_MOVE:
                        return true;
                  }
                  break;
               case PRIORITY_ACTIVE_TARGET_MOVE:
                  switch(param2)
                  {
                     case PRIORITY_NEW_STANDARD_MOVE:
                        return false;
                     case PRIORITY_NEW_TARGET_MOVE:
                        return false;
                  }
            }
         }
         return false;
      }
      
      protected function get canInterrupt() : Boolean
      {
         return false;
      }
      
      private function insertOrders(param1:Array, param2:int) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Order = null;
         var _loc6_:int = 0;
         var _loc3_:Boolean = true;
         if(this.canInterrupt)
         {
            if(this.m_orders.length > 0)
            {
               _loc3_ = false;
               _loc4_ = 0;
               for each(_loc5_ in this.m_orders)
               {
                  if(this.canBeInterruptedBy(_loc5_.priority,param2))
                  {
                     _loc6_ = _loc4_;
                     while(_loc6_ < this.m_orders.length)
                     {
                        this.stopOrder(this.m_orders[_loc6_]);
                        _loc6_++;
                     }
                     this.m_orders.splice(_loc4_);
                     _loc3_ = this.m_orders.length == 0;
                     if(_loc3_)
                     {
                        this.resetStates();
                     }
                     break;
                  }
                  _loc4_++;
               }
            }
         }
         else
         {
            _loc3_ = this.m_orders.length == 0;
         }
         this.m_orders = this.m_orders.concat(param1);
         if(_loc3_)
         {
            this.startOrder(this.m_orders[0]);
         }
      }
      
      protected function clearExistingOrders() : void
      {
         var _loc1_:Order = null;
         for each(_loc1_ in this.m_orders)
         {
            this.stopOrder(_loc1_);
         }
         this.m_orders = new Array();
      }
      
      protected function resetStates() : void
      {
         var _loc1_:UnitFSMComponent = null;
         if(this.m_orders.length == 0)
         {
            _loc1_ = UnitFSMComponent(owner.lookupComponentByType(UnitFSMComponent));
            _loc1_.firstState = "go";
         }
      }
      
      private function startOrder(param1:Order) : void
      {
         param1.addEventListener(Event.COMPLETE,this.onOrderComplete);
         param1.addEventListener(Event.CANCEL,this.onOrderCanceled);
         param1.execute(owner);
      }
      
      private function stopOrder(param1:Order) : void
      {
         param1.removeEventListener(Event.COMPLETE,this.onOrderComplete);
         param1.removeEventListener(Event.CANCEL,this.onOrderCanceled);
         param1.dispose(owner);
      }
      
      private function onOrderComplete(param1:Event) : void
      {
         var _loc2_:Order = null;
         if(this.m_orders.length > 0)
         {
            _loc2_ = this.m_orders.shift();
            this.stopOrder(_loc2_);
            if(this.m_orders.length > 0)
            {
               Zlab.processManager.schedule(1,this,this.onFrameDelay);
            }
         }
      }
      
      private function onOrderCanceled(param1:Event) : void
      {
         this.clearExistingOrders();
      }
      
      private function onFrameDelay() : void
      {
         if(this.m_orders.length > 0)
         {
            this.startOrder(this.m_orders[0]);
         }
      }
      
      private function onSetDestination(param1:WorldEvent) : void
      {
         var _loc2_:Pt = null;
         if(owner.owningGroup.name == param1.eventData.name)
         {
            _loc2_ = MathUtils.tileToWorld(param1.eventData.locX,param1.eventData.locY,0,ZGlobal.cellSize);
            this.setDestination(_loc2_);
         }
      }
      
      private function onEntityHelped(param1:WorldEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Order = null;
         var _loc4_:IEntity = null;
         var _loc5_:GameDataComponent = null;
         var _loc6_:int = 0;
         if(Boolean(this.m_orders) && Boolean(this.m_orders.length))
         {
            while(_loc2_ < this.m_orders.length)
            {
               _loc3_ = this.m_orders[_loc2_];
               _loc4_ = _loc3_.target;
               if(_loc4_)
               {
                  _loc5_ = GameDataComponent.getGameDataComponent(_loc4_);
                  if(_loc5_)
                  {
                     _loc6_ = int(param1.eventData.id);
                     if(_loc5_.id == _loc6_)
                     {
                        this.stopOrder(_loc3_);
                        this.m_orders.splice(_loc2_,1);
                        return;
                     }
                  }
               }
               _loc2_++;
            }
         }
      }
   }
}

