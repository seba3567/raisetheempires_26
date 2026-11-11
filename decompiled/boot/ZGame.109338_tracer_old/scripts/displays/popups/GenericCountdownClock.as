package displays.popups
{
   import flash.display.MovieClip;
   import utils.ZGameTimeUtil;
   
   public class GenericCountdownClock extends CountdownClock
   {
      
      private var m_endTime:int;
      
      public function GenericCountdownClock(param1:MovieClip, param2:int, param3:Function = null, param4:Boolean = false, param5:Boolean = false)
      {
         this.m_endTime = param2;
         super(param1,param3,param4,param5);
      }
      
      private function get currentTime() : int
      {
         return GlobalEngine.serverTime / 1000;
      }
      
      override protected function get isValid() : Boolean
      {
         return this.currentTime <= this.m_endTime;
      }
      
      override protected function get timeObject() : Object
      {
         var _loc1_:Object = null;
         if(this.isValid)
         {
            return ZGameTimeUtil.instance.getTimeObject(this.m_endTime - this.currentTime);
         }
         return null;
      }
   }
}

