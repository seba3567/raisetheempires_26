package zlabs.core
{
   import flash.utils.Dictionary;
   import zlabs.debug.Logger;
   
   public class ObjectTypeManager
   {
      
      private var _typeCount:uint = 0;
      
      private var _typeList:Dictionary = new Dictionary();
      
      private var _bitList:Array = new Array();
      
      public function ObjectTypeManager()
      {
         super();
      }
      
      public function get typeCount() : uint
      {
         return this._typeCount;
      }
      
      public function getType(param1:String) : uint
      {
         if(!this._typeList.hasOwnProperty(param1))
         {
            if(this._typeCount == 64)
            {
               Logger.warn(this,"GetObjectType","Only 64 unique object types can be created.");
               return 0;
            }
            this._typeList[param1] = this._typeCount;
            this._bitList[1 << this._typeCount] = param1;
            ++this._typeCount;
         }
         return 1 << this._typeList[param1];
      }
      
      public function getTypeName(param1:uint) : String
      {
         return this._bitList[param1];
      }
      
      public function doesTypeMatch(param1:ObjectType, param2:String) : Boolean
      {
         var _loc3_:* = this._typeList[param2];
         return _loc3_ != null && param1.bits == 1 << _loc3_;
      }
      
      public function doesTypeOverlap(param1:ObjectType, param2:String) : Boolean
      {
         var _loc3_:* = this._typeList[param2];
         return _loc3_ != null && (param1.bits & 1 << _loc3_) != 0;
      }
      
      public function doTypesMatch(param1:ObjectType, param2:ObjectType) : Boolean
      {
         return param1.bits == param2.bits;
      }
      
      public function doTypesOverlap(param1:ObjectType, param2:ObjectType) : Boolean
      {
         if(!param1 || !param2)
         {
            return false;
         }
         return (param1.bits & param2.bits) != 0;
      }
      
      public function registerFlag(param1:int, param2:String) : void
      {
         if(this.getTypeName(param1) != null)
         {
            throw new Error("Bit already in use!");
         }
         if(this._typeList[param2])
         {
            throw new Error("Name already assigned to another bit!");
         }
         if(param1 >= this._typeCount)
         {
            this._typeCount = param1 + 1;
         }
         this._typeList[param2] = param1;
         this._bitList[param1] = param2;
      }
   }
}

