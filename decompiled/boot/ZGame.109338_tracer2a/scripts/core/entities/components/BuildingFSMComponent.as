package core.entities.components
{
   import core.ZGlobal;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.entities.components.states.FSMComponent;
   import core.entities.components.states.IInput;
   import core.managers.promoManager.PromoManager;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   
   public class BuildingFSMComponent extends FSMComponent
   {
      
      public var currentState:PropertyReference = null;
      
      public function BuildingFSMComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         var _loc1_:int = int(owner.getProperty(this.currentState));
         stateMachine.loadToState(_loc1_);
         owner.eventDispatcher.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUp,false,0,true);
         if(!this.isBuilt)
         {
            PromoManager.instance.addEventListener(PromoManager.EVENT_REQUEST_INCOMPLETE_BUILDABLES,this.onRequestIncompleteBuildables,false,0,true);
         }
      }
      
      private function onRequestIncompleteBuildables(param1:WorldEvent) : void
      {
         var _loc2_:GameDataComponent = null;
         if(param1.eventData.itemExists == false && !this.isBuilt)
         {
            _loc2_ = owner.lookupComponentByType(GameDataComponent) as GameDataComponent;
            if(param1.eventData.code == _loc2_.gameData.code)
            {
               param1.eventData.itemExists = true;
            }
         }
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         owner.eventDispatcher.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUp);
      }
      
      private function onMouseUp(param1:Event) : void
      {
         if(stateMachine.currentState is IInput)
         {
            (stateMachine.currentState as IInput).onClick(param1);
         }
      }
      
      public function set firstState(param1:String) : void
      {
         stateMachine.setCurrentToFirstState();
      }
      
      public function get isBuilt() : Boolean
      {
         var _loc1_:BehaviorState = stateMachine.getState(stateMachine.currentStateName) as BehaviorState;
         return _loc1_.isBuilt();
      }
      
      public function forceClick() : Boolean
      {
         if(stateMachine.currentState is IInput && !ZGlobal.isVisiting() || BehaviorState(stateMachine.currentState).isVisitable())
         {
            (stateMachine.currentState as IInput).onClick(null);
            return true;
         }
         return false;
      }
   }
}

