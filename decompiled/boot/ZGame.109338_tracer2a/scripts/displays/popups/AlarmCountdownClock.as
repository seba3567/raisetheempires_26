package displays.popups
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class AlarmCountdownClock extends GenericCountdownClock
   {
      
      public static const TIMER_EXPIRED:String = "timer_expired";
      
      private var m_handler:EventDispatcher = new EventDispatcher();
      
      private var m_triggeredAlarm:Boolean = false;
      
      public function AlarmCountdownClock(param1:MovieClip, param2:int)
      {
         super(param1,param2);
      }
      
      public function get alarm() : EventDispatcher
      {
         return this.m_handler;
      }
      
      override protected function onUpdateClock() : void
      {
         super.onUpdateClock();
         if(!this.m_triggeredAlarm && !isValid)
         {
            this.m_handler.dispatchEvent(new Event(TIMER_EXPIRED));
            this.m_triggeredAlarm = true;
         }
      }
   }
}

