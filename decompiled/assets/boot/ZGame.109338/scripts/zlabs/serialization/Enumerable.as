package zlabs.serialization
{
   import flash.utils.Dictionary;
   import zlabs.debug.Logger;
   
   public class Enumerable implements ISerializable
   {
      
      public function Enumerable()
      {
         super();
      }
      
      public function get typeMap() : Dictionary
      {
         throw new Error("Derived classes must implement this!");
      }
      
      public function get defaultType() : Enumerable
      {
         throw new Error("Derived classes must implement this!");
      }
      
      public function serialize(param1:XML) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in this.typeMap)
         {
            if(this.typeMap[_loc2_] == this)
            {
               param1.appendChild(_loc2_);
               break;
            }
         }
      }
      
      public function deserialize(param1:XML) : *
      {
         var _loc2_:String = param1.toString();
         if(!this.typeMap[_loc2_])
         {
            Logger.error(this,"deserialize",_loc2_ + " is not a valid value for this enumeration.");
            return this.defaultType;
         }
         return this.typeMap[_loc2_];
      }
   }
}

