package zlabs.entity
{
   public interface IEntityComponent
   {
      
      function get owner() : IEntity;
      
      function set owner(param1:IEntity) : void;
      
      function get name() : String;
      
      function get isRegistered() : Boolean;
      
      function register(param1:IEntity, param2:String) : void;
      
      function unregister() : void;
      
      function reset() : void;
   }
}

