package core.entities.components.states
{
   public interface ITransition
   {
      
      function getTargetState() : String;
      
      function evaluate(param1:IMachine) : Boolean;
   }
}

