package zlabs.entity
{
   import flash.events.IEventDispatcher;
   
   public interface IPropertyBag
   {
      
      function get eventDispatcher() : IEventDispatcher;
      
      function doesPropertyExist(param1:PropertyReference) : Boolean;
      
      function getProperty(param1:PropertyReference, param2:* = null) : *;
      
      function setProperty(param1:PropertyReference, param2:*) : void;
   }
}

