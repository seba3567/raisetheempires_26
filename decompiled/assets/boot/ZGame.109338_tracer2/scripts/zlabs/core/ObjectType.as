package zlabs.core
{
   import zlabs.Zlab;
   import zlabs.serialization.ISerializable;
   
   public class ObjectType implements ISerializable
   {
      
      private static var _wildcard:ObjectType;
      
      private var _bits:int = 0;
      
      public function ObjectType(... rest)
      {
         super();
         if(rest.length == 1)
         {
            if(rest[0] is Array)
            {
               this.typeNames = rest[0];
            }
            else
            {
               this.typeName = rest[0];
            }
         }
         else if(rest.length > 1)
         {
            this.typeNames = rest;
         }
      }
      
      public static function get wildcard() : ObjectType
      {
         if(!_wildcard)
         {
            _wildcard = new ObjectType();
         }
         _wildcard._bits = 4294967295;
         return _wildcard;
      }
      
      public function get bits() : int
      {
         return this._bits;
      }
      
      public function get typeName() : String
      {
         var _loc1_:int = 0;
         while(_loc1_ < Zlab.objectTypeManager.typeCount)
         {
            if(this._bits & 1 << _loc1_)
            {
               return Zlab.objectTypeManager.getTypeName(1 << _loc1_);
            }
            _loc1_++;
         }
         return "";
      }
      
      public function set typeName(param1:String) : void
      {
         this._bits = Zlab.objectTypeManager.getType(param1);
      }
      
      public function get typeNames() : Array
      {
         var _loc1_:Array = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < Zlab.objectTypeManager.typeCount)
         {
            if(this._bits & 1 << _loc2_)
            {
               _loc1_.push(Zlab.objectTypeManager.getTypeName(1 << _loc2_));
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function set typeNames(param1:Array) : void
      {
         var _loc2_:String = null;
         this._bits = 0;
         for each(_loc2_ in param1)
         {
            this._bits |= Zlab.objectTypeManager.getType(_loc2_);
         }
      }
      
      public function add(param1:String) : void
      {
         this._bits |= Zlab.objectTypeManager.getType(param1);
      }
      
      public function remove(param1:String) : void
      {
         this._bits &= wildcard.bits - Zlab.objectTypeManager.getType(param1);
      }
      
      public function and(param1:ObjectType) : Boolean
      {
         if((param1.bits & this.bits) != 0)
         {
            return true;
         }
         return false;
      }
      
      public function serialize(param1:XML) : void
      {
         var _loc3_:String = null;
         var _loc2_:Array = this.typeNames;
         if(_loc2_.length == 1)
         {
            param1.appendChild(_loc2_[0]);
            return;
         }
         for each(_loc3_ in _loc2_)
         {
            param1.appendChild(<type>{_loc3_}</type>);
         }
      }
      
      public function deserialize(param1:XML) : *
      {
         var _loc2_:XML = null;
         if(param1.hasSimpleContent())
         {
            this.typeName = param1.toString();
            return this;
         }
         this._bits = 0;
         for each(_loc2_ in param1.*)
         {
            this._bits |= Zlab.objectTypeManager.getType(_loc2_.toString());
         }
         return this;
      }
   }
}

