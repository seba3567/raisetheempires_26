package com.zynga.ads.w2e
{
   import com.zynga.ads.zac_internal;
   
   use namespace zac_internal;
   
   internal final class Reward implements IReward
   {
      
      zac_internal static const VERSION:String = "#{VERSION}";
      
      private var _type:String;
      
      private var _value:* = null;
      
      public function Reward(param1:Object)
      {
         super();
         this._type = param1.type || "unknown";
         this._value = param1.value || null;
      }
      
      public function get type() : String
      {
         return this._type;
      }
      
      public function get value() : *
      {
         return this._value;
      }
      
      public function toString() : String
      {
         var _loc1_:Array = ["[Reward ","type: ",this.type,", ","value: ",this.value || "null","]"];
         return _loc1_.join("");
      }
   }
}

