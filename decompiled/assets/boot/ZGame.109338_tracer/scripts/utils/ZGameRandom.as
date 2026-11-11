package utils
{
   import zlabs.utils.MathUtils;
   
   public class ZGameRandom
   {
      
      public static var ACCURACY:int = 3;
      
      public static var instance:ZGameRandom = new ZGameRandom();
      
      public static var rewardInstance:ZGameRandom = new ZGameRandom();
      
      public static var ransomInstance:ZGameRandom = new ZGameRandom();
      
      public static var scrapInstance:ZGameRandom = new ZGameRandom();
      
      private var m_w:uint = 1;
      
      private var m_z:uint = 1;
      
      public function ZGameRandom()
      {
         super();
      }
      
      public function init(param1:uint, param2:uint) : void
      {
         this.m_w = param1;
         this.m_z = param2;
      }
      
      private function random() : uint
      {
         var _loc1_:uint = 36969 * (this.m_z & 0xFFFF);
         var _loc2_:uint = uint(this.m_z >> 16 & 0xFFFF);
         this.m_z = 36969 * (this.m_z & 0xFFFF) + (this.m_z >> 16 & 0xFFFF) & 0xFFFFFFFF;
         this.m_w = 18000 * (this.m_w & 0xFFFF) + (this.m_w >> 16 & 0xFFFF) & 0xFFFFFFFF;
         return (this.m_z << 16) + this.m_w & 0xFFFFFFFF;
      }
      
      public function get initialisers() : Object
      {
         return {
            "w":this.m_w,
            "z":this.m_z
         };
      }
      
      public function float() : Number
      {
         var _loc1_:Number = Number(this.random());
         _loc1_ /= uint.MAX_VALUE;
         return MathUtils.roundTo(_loc1_,ACCURACY);
      }
      
      public function randBetween(param1:Number, param2:Number) : Number
      {
         return this.float() * (param2 - param1) + param1;
      }
   }
}

