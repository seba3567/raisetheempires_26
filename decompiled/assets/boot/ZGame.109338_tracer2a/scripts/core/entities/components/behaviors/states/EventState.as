package core.entities.components.behaviors.states
{
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import zlabs.events.WorldEvent;
   
   public class EventState extends BehaviorState
   {
      
      public static var ADVANCE:String = "advance";
      
      private var m_paramString:String = null;
      
      public function EventState(param1:BehaviorStateInit)
      {
         super(param1);
         if(m_data.@clickEventParam.toString().length > 0)
         {
            this.m_paramString = m_data.@clickEventParam.toString();
         }
      }
      
      override public function enter(param1:IMachine) : void
      {
         super.enter(param1);
         stateMachine.propertyBag.eventDispatcher.addEventListener(ADVANCE,this.onAdvance,false,0,true);
      }
      
      override public function exit(param1:IMachine) : void
      {
         super.exit(param1);
         this.removeListeners();
      }
      
      private function onAdvance(param1:WorldEvent) : void
      {
         if(param1.eventData as String == this.m_paramString)
         {
            clickNextState();
         }
      }
      
      override protected function removeListeners() : void
      {
         stateMachine.propertyBag.eventDispatcher.removeEventListener(ADVANCE,this.onAdvance);
      }
   }
}

