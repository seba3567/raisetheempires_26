package core.entities.components.states
{
   import flash.events.Event;
   import zlabs.core.OrderedArray;
   
   public class BasicState implements IState
   {
      
      public var transitions:OrderedArray = null;
      
      public var enterEvent:String = null;
      
      public function BasicState()
      {
         super();
      }
      
      public function addTransition(param1:ITransition) : void
      {
         if(null == this.transitions)
         {
            this.transitions = new OrderedArray();
         }
         this.transitions[this.transitions.length] = param1;
      }
      
      public function registerForTick() : Boolean
      {
         return null != this.transitions && this.transitions.length > 0;
      }
      
      public function tick(param1:IMachine) : void
      {
         var _loc2_:ITransition = null;
         for each(_loc2_ in this.transitions)
         {
            if(_loc2_.evaluate(param1) && param1.setCurrentState(_loc2_.getTargetState()))
            {
               return;
            }
         }
      }
      
      public function enter(param1:IMachine) : void
      {
         if(!this.enterEvent)
         {
            return;
         }
         var _loc2_:Event = new Event(this.enterEvent);
         param1.propertyBag.eventDispatcher.dispatchEvent(_loc2_);
      }
      
      public function exit(param1:IMachine) : void
      {
      }
      
      public function load(param1:IMachine, param2:IState) : void
      {
      }
      
      public function stop() : void
      {
      }
   }
}

