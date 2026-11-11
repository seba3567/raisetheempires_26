package events
{
   import core.entities.components.states.IState;
   import flash.events.Event;
   
   public class TransitionEvent extends Event
   {
      
      public static const TRANSITION:String = "fsmStateTransition";
      
      public var oldState:IState;
      
      public var oldStateName:String;
      
      public var newState:IState;
      
      public var newStateName:String;
      
      public function TransitionEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

