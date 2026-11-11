package utils
{
   public class BitArray
   {
      
      private static const BITS_PER_INDEX:uint = 32;
      
      private static const SHIFTS_PER_INDEX:uint = 5;
      
      private static const DEFAULT_BITS:uint = 64;
      
      private var m_data:Array = null;
      
      public function BitArray(param1:Object, param2:int = 64)
      {
         var _loc5_:int = 0;
         super();
         var _loc3_:int = Math.max(param1.length,(param2 >> SHIFTS_PER_INDEX) + 1);
         this.m_data = new Array(_loc3_);
         var _loc4_:int = 0;
         for each(_loc5_ in param1)
         {
            this.m_data[_loc4_] = _loc5_;
            _loc4_++;
         }
         while(_loc4_ < _loc3_)
         {
            this.m_data[_loc4_] = 0;
            _loc4_++;
         }
      }
      
      public function setBit(param1:int) : void
      {
         var _loc2_:int = param1 >> SHIFTS_PER_INDEX;
         param1 -= _loc2_ << SHIFTS_PER_INDEX;
         this.m_data[_loc2_] |= 1 << param1;
      }
      
      public function resetBit(param1:int) : void
      {
         var _loc2_:int = param1 >> SHIFTS_PER_INDEX;
         param1 -= _loc2_ << SHIFTS_PER_INDEX;
         this.m_data[_loc2_] &= ~(1 << param1);
      }
      
      public function isBitSet(param1:int) : Boolean
      {
         var _loc2_:int = param1 >> SHIFTS_PER_INDEX;
         if(_loc2_ >= 0)
         {
            param1 -= _loc2_ << SHIFTS_PER_INDEX;
            return (this.m_data[_loc2_] & 1 << param1) != 0;
         }
         return false;
      }
      
      public function iterate(param1:Function) : void
      {
         var _loc2_:uint = this.m_data.length * BITS_PER_INDEX;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this.isBitSet(_loc3_))
            {
               param1(_loc3_);
            }
            _loc3_++;
         }
      }
      
      public function anyBitSet() : Boolean
      {
         var _loc1_:uint = this.m_data.length * BITS_PER_INDEX;
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            if(this.isBitSet(_loc2_))
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function numBitsSet() : uint
      {
         var _loc1_:uint = 0;
         var _loc2_:uint = this.m_data.length * BITS_PER_INDEX;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this.isBitSet(_loc3_))
            {
               _loc1_++;
            }
            _loc3_++;
         }
         return _loc1_;
      }
   }
}

