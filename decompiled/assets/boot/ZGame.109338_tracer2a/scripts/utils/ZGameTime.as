package utils
{
   public class ZGameTime
   {
      
      private var m_absolute:Number = 0;
      
      private var m_adjusted:Number = 0;
      
      public function ZGameTime(param1:Number)
      {
         super();
         this.m_absolute = param1;
         this.m_adjusted = this.m_absolute;
         if(this.m_adjusted > 5)
         {
            this.m_adjusted *= ZGameTimeUtil.instance.devMultiplier;
         }
      }
      
      public function get absolute() : Number
      {
         return this.m_absolute;
      }
      
      public function get adjusted() : Number
      {
         return this.m_adjusted;
      }
   }
}

