package core.entities.components.behaviors.states.unitStates
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.behaviors.states.SimpleClickState;
   import core.entities.components.states.IMachine;
   import events.UnitEvent;
   
   public class IdleState extends SimpleClickState
   {
      
      public function IdleState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override public function enter(param1:IMachine) : void
      {
         super.enter(param1);
         stateMachine.propertyBag.eventDispatcher.addEventListener(UnitEvent.TERRAIN_AS_TARGET,this.onTerrainClicked);
         stateMachine.propertyBag.eventDispatcher.addEventListener(UnitEvent.TERRAIN_AS_TARGET_CLIENT_ONLY,this.onTerrainClicked);
      }
      
      override public function exit(param1:IMachine) : void
      {
         super.exit(param1);
         this.removeListeners();
      }
      
      override protected function removeListeners() : void
      {
         stateMachine.propertyBag.eventDispatcher.removeEventListener(UnitEvent.TERRAIN_AS_TARGET,this.onTerrainClicked);
         stateMachine.propertyBag.eventDispatcher.removeEventListener(UnitEvent.TERRAIN_AS_TARGET_CLIENT_ONLY,this.onTerrainClicked);
      }
      
      private function onTerrainClicked(param1:UnitEvent) : void
      {
         super.onClick(param1);
      }
   }
}

