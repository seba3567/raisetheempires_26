package core.gamemode.orders
{
   import as3isolib.geom.Pt;
   import core.entities.components.UIControllerComponent;
   import core.entities.components.UnitFSMComponent;
   import core.entities.components.behaviors.states.unitStates.RotateToPositionState;
   import events.UnitEvent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   import zlabs.rendering.renderingISO.IsoSpatialComponent;
   
   public class ClickOrder extends Order
   {
      
      private var m_target:IEntity = null;
      
      public function ClickOrder(param1:IEntity)
      {
         super(-1);
         this.m_target = param1;
         this.m_target.eventDispatcher.dispatchEvent(new WorldEvent(UIControllerComponent.EVENT_SPRITE_EFFECT,UIControllerComponent.SPRITE_EFFECT_SELECTED_ON));
         this.m_target.eventDispatcher.addEventListener("EntityDestroyed",this.onEntityInvalidated);
         this.m_target.eventDispatcher.addEventListener(IsoSpatialComponent.START,this.onEntityInvalidated);
         this.m_target.eventDispatcher.dispatchEvent(new Event(UnitEvent.ACTION_STARTED));
      }
      
      override public function dispose(param1:IEntity) : void
      {
         super.dispose(param1);
         if(this.m_target)
         {
            this.m_target.eventDispatcher.removeEventListener(UnitEvent.ACTION_COMPLETE,this.onTargetActionComplete);
            this.m_target.eventDispatcher.removeEventListener(UnitEvent.ACTION_FAILED,this.onTargetActionFailed);
            this.m_target.eventDispatcher.dispatchEvent(new Event(UnitEvent.ACTION_ENDED));
            this.removeTint();
            this.removeListeners();
         }
         this.m_target = null;
      }
      
      override public function execute(param1:IEntity) : void
      {
         var _loc2_:OrdersComponent = null;
         var _loc3_:Pt = null;
         var _loc4_:UnitFSMComponent = null;
         super.execute(param1);
         if(this.m_target)
         {
            this.m_target.eventDispatcher.addEventListener(UnitEvent.ACTION_COMPLETE,this.onTargetActionComplete);
            this.m_target.eventDispatcher.addEventListener(UnitEvent.ACTION_FAILED,this.onTargetActionFailed);
            _loc2_ = OrdersComponent.getOrdersComponent(param1);
            _loc3_ = _loc2_.getTargetCentre(this.m_target,new Pt());
            if(RotateToPositionState.rotateToPos(param1,_loc3_))
            {
               _loc4_ = UnitFSMComponent(param1.lookupComponentByType(UnitFSMComponent));
               _loc4_.firstState = "go";
            }
            this.m_target.eventDispatcher.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
         }
         else
         {
            this.onTargetActionComplete(null);
         }
      }
      
      override public function get target() : IEntity
      {
         return this.m_target;
      }
      
      private function removeTint() : void
      {
         this.m_target.eventDispatcher.dispatchEvent(new WorldEvent(UIControllerComponent.EVENT_SPRITE_EFFECT,UIControllerComponent.SPRITE_EFFECT_SELECTED_OFF));
      }
      
      private function removeListeners() : void
      {
         this.m_target.eventDispatcher.removeEventListener("EntityDestroyed",this.onEntityInvalidated);
         this.m_target.eventDispatcher.removeEventListener(IsoSpatialComponent.START,this.onEntityInvalidated);
      }
      
      private function onTargetActionComplete(param1:UnitEvent) : void
      {
         onActionComplete(param1);
      }
      
      private function onTargetActionFailed(param1:UnitEvent) : void
      {
         dispatchEvent(new Event(Event.CANCEL));
      }
      
      private function onEntityInvalidated(param1:Event) : void
      {
         if(this.m_target)
         {
            this.removeTint();
            this.removeListeners();
         }
         this.m_target = null;
      }
   }
}

