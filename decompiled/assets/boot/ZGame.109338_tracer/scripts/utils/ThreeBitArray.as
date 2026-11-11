package utils
{
   public class ThreeBitArray
   {
      
      private static const BITS_PER_VALUE:uint = 2;
      
      private static const ALL_BITS:uint = 3;
      
      private var m_data:uint = 0;
      
      public function ThreeBitArray(param1:uint)
      {
         super();
         this.m_data = param1;
      }
      
      public function get asArray() : Array
      {
         var _loc1_:int = 32 / BITS_PER_VALUE;
         var _loc2_:Array = new Array(_loc1_);
         var _loc3_:int = 0;
         while(_loc3_ < _loc1_)
         {
            _loc2_[_loc3_] = this.getValueAt(_loc3_);
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function getValueAt(param1:int) : int
      {
         var _loc2_:int = param1 * BITS_PER_VALUE;
         var _loc3_:int = ALL_BITS << _loc2_;
         return (this.m_data & _loc3_) >> _loc2_;
      }
   }
}

