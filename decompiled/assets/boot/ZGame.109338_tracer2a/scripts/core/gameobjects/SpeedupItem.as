package core.gameobjects
{
   import core.ZGlobal;
   import core.managers.PriceTestManager;
   
   public class SpeedupItem extends GameItem
   {
      
      private var m_elapsedTime:Number = 100;
      
      private var m_duration:Number = 0;
      
      public function SpeedupItem(param1:XML)
      {
         if(null != param1)
         {
            super(param1);
         }
         else
         {
            m_xml = null;
         }
      }
      
      public function set elapsedTime(param1:Number) : void
      {
         this.m_elapsedTime = param1;
      }
      
      public function get elapsedTime() : Number
      {
         return this.m_elapsedTime;
      }
      
      public function set duration(param1:Number) : void
      {
         this.m_duration = param1;
      }
      
      public function get duration() : Number
      {
         return this.m_duration;
      }
      
      override public function get cash() : int
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc1_:Number = PriceTestManager.instance.costMultiplierByType("speedup");
         if(null != m_xml)
         {
            _loc2_ = this.m_elapsedTime / this.m_duration;
            if(_loc2_ >= 0 && _loc2_ < 0.25)
            {
               _loc3_ = Math.ceil(_loc1_ * parseInt(m_xml.cost.@cash));
            }
            else if(_loc2_ >= 0.25 && _loc2_ < 0.5)
            {
               _loc3_ = Math.ceil(_loc1_ * parseInt(m_xml.cost.@cash) * 0.75);
            }
            else if(_loc2_ >= 0.5 && _loc2_ < 0.75)
            {
               _loc3_ = Math.ceil(_loc1_ * parseInt(m_xml.cost.@cash) * 0.5);
            }
            else if(_loc2_ >= 0.75 && _loc2_ < 1)
            {
               _loc3_ = Math.ceil(_loc1_ * parseInt(m_xml.cost.@cash) * 0.25);
            }
            return Math.ceil(_loc3_);
         }
         return Math.ceil(_loc1_ * ZGlobal.gameSettings.getCashAmountFromDurationMilliseconds(this.m_duration - this.m_elapsedTime));
      }
   }
}

