package core.gameobjects.fleet
{
   import zlabs.debug.Logger;
   
   public class HitPercentageRecorder
   {
      
      private var m_attackerId:int = -1;
      
      private var m_targetId:int = -1;
      
      private var m_missCount:int = 0;
      
      public function HitPercentageRecorder(param1:Object)
      {
         super();
         if(null != param1)
         {
            this.m_attackerId = param1.a;
            this.m_targetId = param1.t;
            this.m_missCount = param1.m;
         }
      }
      
      public function update(param1:int, param2:int, param3:Boolean) : void
      {
         if(param3 == false)
         {
            if(param1 == this.m_attackerId && param2 == this.m_targetId)
            {
               this.m_missCount += 1;
            }
            else
            {
               this.m_attackerId = param1;
               this.m_targetId = param2;
               this.m_missCount = 1;
            }
         }
         else
         {
            this.m_attackerId = -1;
            this.m_targetId = -1;
            this.m_missCount = 0;
         }
      }
      
      public function getModifier(param1:int, param2:int) : Number
      {
         var _loc3_:Number = NaN;
         var _loc4_:* = 0;
         if(param1 == this.m_attackerId && param2 == this.m_targetId)
         {
            _loc3_ = 0;
            _loc4_ = this.m_missCount;
            while(_loc4_ > 0)
            {
               _loc3_ += 10 * _loc4_;
               _loc4_--;
            }
            Logger.info(this,"getModifier","value: " + _loc3_);
            return _loc3_;
         }
         return 0;
      }
   }
}

