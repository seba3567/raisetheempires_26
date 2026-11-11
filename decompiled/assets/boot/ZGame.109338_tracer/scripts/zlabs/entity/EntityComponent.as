package zlabs.entity
{
   public class EntityComponent implements IEntityComponent
   {
      
      private var _isRegistered:Boolean = false;
      
      private var _owner:IEntity = null;
      
      private var _name:String = null;
      
      public function EntityComponent()
      {
         super();
      }
      
      public function get owner() : IEntity
      {
         return this._owner;
      }
      
      public function set owner(param1:IEntity) : void
      {
         this._owner = param1;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get isRegistered() : Boolean
      {
         return this._isRegistered;
      }
      
      public function register(param1:IEntity, param2:String) : void
      {
         if(this.isRegistered)
         {
            throw new Error("Trying to register an already-registered component!");
         }
         this._name = param2;
         this._owner = param1;
         this.onAdd();
         this._isRegistered = true;
      }
      
      public function unregister() : void
      {
         if(!this.isRegistered)
         {
            throw new Error("Trying to unregister an unregistered component!");
         }
         this._isRegistered = false;
         this.onRemove();
         this._owner = null;
         this._name = null;
      }
      
      public function reset() : void
      {
         this.onReset();
      }
      
      protected function onAdd() : void
      {
      }
      
      protected function onRemove() : void
      {
      }
      
      protected function onReset() : void
      {
      }
   }
}

