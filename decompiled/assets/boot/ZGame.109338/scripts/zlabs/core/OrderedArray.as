package zlabs.core
{
   import flash.utils.Proxy;
   import flash.utils.flash_proxy;
   
   use namespace flash_proxy;
   
   public dynamic class OrderedArray extends Proxy
   {
      
      private var memberValueHash:Object = {};
      
      private var memberIndexHash:Object = {};
      
      private var memberNameArray:Array = [];
      
      public function OrderedArray()
      {
         super();
      }
      
      public function get length() : uint
      {
         return this.memberNameArray.length;
      }
      
      override flash_proxy function setProperty(param1:*, param2:*) : void
      {
         var _loc3_:uint = 0;
         if(param1 in this.memberValueHash == false)
         {
            _loc3_ = this.memberNameArray.length;
            this.memberIndexHash[param1] = _loc3_;
            this.memberNameArray[_loc3_] = param1;
         }
         this.memberValueHash[param1] = param2;
      }
      
      override flash_proxy function getProperty(param1:*) : *
      {
         return this.memberValueHash[param1];
      }
      
      override flash_proxy function callProperty(param1:*, ... rest) : *
      {
         if(this.memberValueHash[param1] is Function)
         {
            return this.memberValueHash[param1].apply(null,rest);
         }
         return null;
      }
      
      override flash_proxy function hasProperty(param1:*) : Boolean
      {
         return param1 in this.memberValueHash;
      }
      
      override flash_proxy function deleteProperty(param1:*) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:uint = 0;
         if(param1 in this.memberValueHash)
         {
            _loc2_ = int(this.memberIndexHash[param1]);
            this.memberNameArray.splice(_loc2_,1);
            _loc3_ = this.memberNameArray.length;
            while(_loc2_ < _loc3_)
            {
               --this.memberIndexHash[this.memberNameArray[_loc2_]];
               _loc2_++;
            }
            delete this.memberValueHash[param1];
            delete this.memberIndexHash[param1];
            return true;
         }
         return false;
      }
      
      override flash_proxy function nextNameIndex(param1:int) : int
      {
         return param1 < this.memberNameArray.length ? int(param1 + 1) : 0;
      }
      
      override flash_proxy function nextName(param1:int) : String
      {
         return this.memberNameArray[param1 - 1];
      }
      
      override flash_proxy function nextValue(param1:int) : *
      {
         return this.memberValueHash[this.memberNameArray[param1 - 1]];
      }
      
      override flash_proxy function getDescendants(param1:*) : *
      {
         return null;
      }
      
      override flash_proxy function isAttribute(param1:*) : Boolean
      {
         return false;
      }
   }
}

