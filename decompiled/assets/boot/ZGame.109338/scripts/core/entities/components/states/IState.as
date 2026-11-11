package core.entities.components.states
{
   public interface IState
   {
      
      function enter(param1:IMachine) : void;
      
      function tick(param1:IMachine) : void;
      
      function registerForTick() : Boolean;
      
      function exit(param1:IMachine) : void;
      
      function load(param1:IMachine, param2:IState) : void;
      
      function stop() : void;
   }
}

