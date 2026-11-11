package zlabs.entity
{
   import zlabs.debug.Logger;
   import zlabs.serialization.ISerializable;
   
   public class PropertyReference implements ISerializable
   {
      
      private var _property:String = null;
      
      public var cachedLookup:Array;
      
      public function PropertyReference(param1:String = null)
      {
         super();
         this._property = param1;
      }
      
      public function get property() : String
      {
         return this._property;
      }
      
      public function set property(param1:String) : void
      {
         if(this._property != param1)
         {
            this.cachedLookup = null;
         }
         this._property = param1;
      }
      
      public function serialize(param1:XML) : void
      {
         param1.appendChild(new XML(this._property));
      }
      
      public function deserialize(param1:XML) : *
      {
         if(this._property)
         {
            Logger.warn(this,"deserialize","Overwriting property; was \'" + this._property + "\', new value is \'" + param1.toString() + "\'");
         }
         this._property = param1.toString();
         return this;
      }
      
      public function toString() : String
      {
         return this._property;
      }
   }
}

