package zlabs.entity
{
   import zlabs.core.IPBObject;
   
   public interface IEntity extends IPropertyBag, IPBObject
   {
      
      function set deferring(param1:Boolean) : void;
      
      function get deferring() : Boolean;
      
      function addComponent(param1:IEntityComponent, param2:String) : Boolean;
      
      function removeComponent(param1:IEntityComponent) : void;
      
      function serialize(param1:XML) : void;
      
      function deserialize(param1:XML, param2:Boolean = true) : void;
      
      function lookupComponentByType(param1:Class) : IEntityComponent;
      
      function lookupComponentsByType(param1:Class) : Array;
      
      function lookupComponentByName(param1:String) : IEntityComponent;
   }
}

