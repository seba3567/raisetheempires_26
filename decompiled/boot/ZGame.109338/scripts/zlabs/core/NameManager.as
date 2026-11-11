package zlabs.core
{
   import flash.utils.Dictionary;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.entity.IEntityComponent;
   
   public class NameManager
   {
      
      private var _objects:Dictionary = new Dictionary();
      
      public function NameManager()
      {
         super();
      }
      
      public function get objectList() : Dictionary
      {
         return this._objects;
      }
      
      public function add(param1:IPBObject) : void
      {
         var _loc2_:Boolean = param1.name != null && param1.name != "";
         var _loc3_:Boolean = param1.alias != null && param1.alias != "";
         if(_loc2_ && Boolean(this._objects[param1.name]))
         {
            Logger.warn(this,"add","A PBObject with the name " + param1.name + " (alias: " + param1.alias + ") already exists. Future lookups by this name will return the newest object. Did you mean to make an entity a template?");
         }
         if(TemplateManager.VERBOSE_LOGGING)
         {
            Logger.print(this,"Registering PBObject \'" + param1.name + "\', alias \'" + param1.alias + "\'");
         }
         if(_loc2_)
         {
            this._objects[param1.name] = param1;
         }
         if(_loc3_)
         {
            this._objects[param1.alias] = param1;
         }
      }
      
      public function remove(param1:IPBObject) : void
      {
         if(param1.alias != null && param1.alias != "" && this._objects[param1.alias] == param1)
         {
            this._objects[param1.alias] = null;
            delete this._objects[param1.alias];
         }
         if(param1.name != null && param1.name != "" && this._objects[param1.name] == param1)
         {
            this._objects[param1.name] = null;
            delete this._objects[param1.name];
         }
      }
      
      public function lookup(param1:String) : *
      {
         return this._objects[param1];
      }
      
      public function validateName(param1:String) : String
      {
         if(!this._objects[param1])
         {
            return param1;
         }
         var _loc2_:* = 1;
         var _loc3_:String = param1 + _loc2_;
         while(this._objects[_loc3_])
         {
            _loc3_ = param1 + _loc2_++;
         }
         return _loc3_;
      }
      
      public function lookupComponentByType(param1:String, param2:Class) : IEntityComponent
      {
         var _loc3_:IEntity = this.lookup(param1);
         if(!_loc3_)
         {
            return null;
         }
         return _loc3_.lookupComponentByType(param2);
      }
      
      public function lookupComponentsByType(param1:String, param2:Class) : Array
      {
         var _loc3_:IEntity = this.lookup(param1);
         if(!_loc3_)
         {
            return null;
         }
         return _loc3_.lookupComponentsByType(param2);
      }
      
      public function lookupComponentByName(param1:String, param2:String) : IEntityComponent
      {
         var _loc3_:IEntity = this.lookup(param1);
         if(!_loc3_)
         {
            return null;
         }
         return _loc3_.lookupComponentByName(param2);
      }
   }
}

