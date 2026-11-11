package core.entities.components.states
{
   import zlabs.entity.IPropertyBag;
   
   public interface IMachine
   {
      
      function tick() : void;
      
      function addState(param1:String, param2:IState) : void;
      
      function getCurrentState() : IState;
      
      function getPreviousState() : IState;
      
      function getState(param1:String) : IState;
      
      function getStateName(param1:IState) : String;
      
      function setCurrentState(param1:String) : Boolean;
      
      function get currentStateName() : String;
      
      function get propertyBag() : IPropertyBag;
      
      function set propertyBag(param1:IPropertyBag) : void;
   }
}

