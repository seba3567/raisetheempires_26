package displays.popups
{
   import flash.display.MovieClip;
   import utils.ZGameTimeUtil;
   
   public class MOTDCountdownClock extends CountdownClock
   {
      
      private var m_xml:XML = null;
      
      private var m_useUTC:Boolean;
      
      private var m_delta:int = 0;
      
      public function MOTDCountdownClock(param1:MovieClip, param2:XML, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false, param6:int = 0, param7:Function = null)
      {
         this.m_xml = param2;
         this.m_useUTC = param3;
         this.m_delta = param6;
         super(param1,param7,param4,param5);
      }
      
      override protected function get isValid() : Boolean
      {
         return this.m_xml != null;
      }
      
      override protected function get timeObject() : Object
      {
         var _loc3_:Object = null;
         var _loc1_:Object = new Object();
         var _loc2_:int = ZGameTimeUtil.instance.getDateStatus(_loc1_,this.m_xml,this.m_useUTC);
         if(_loc2_ == ZGameTimeUtil.DATE_STATUS_ACTIVE)
         {
            return ZGameTimeUtil.instance.getTimeObject(_loc1_.delta + this.m_delta);
         }
         return null;
      }
   }
}

