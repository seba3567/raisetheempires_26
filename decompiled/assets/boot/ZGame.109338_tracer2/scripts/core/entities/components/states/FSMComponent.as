package core.entities.components.states
{
   import zlabs.components.TickedComponent;
   import zlabs.events.WorldEvent;
   
   public class FSMComponent extends TickedComponent
   {
      
      public var stateMachine:Machine;
      
      public var paused:Boolean = false;
      
      public function FSMComponent()
      {
         super();
      }
      
      override protected function onAdd() : void
      {
         super.onAdd();
         if(this.stateMachine)
         {
            this.stateMachine.propertyBag = owner;
         }
         owner.eventDispatcher.addEventListener(Machine.ENABLE_TICK,this.onEnableTick,false,0,true);
      }
      
      override protected function onRemove() : void
      {
         super.onRemove();
         if(this.stateMachine)
         {
            this.stateMachine.destroy();
         }
         owner.eventDispatcher.removeEventListener(Machine.ENABLE_TICK,this.onEnableTick);
      }
      
      private function onEnableTick(param1:WorldEvent) : void
      {
         registerForTicks = param1.eventData;
      }
      
      override public function onTick(param1:Number) : void
      {
         if(this.paused)
         {
            return;
         }
         if(this.stateMachine)
         {
            this.stateMachine.tick();
         }
      }
   }
}

