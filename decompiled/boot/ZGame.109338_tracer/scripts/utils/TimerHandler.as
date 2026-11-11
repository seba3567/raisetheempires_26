package utils
{
   import flash.events.EventDispatcher;
   import zlabs.Zlab;
   
   public class TimerHandler extends EventDispatcher
   {
      
      private var m_parent:Object;
      
      private var m_duration:Number;
      
      private var m_callback:Function;
      
      private var m_userData:Object;
      
      public function TimerHandler(param1:Number, param2:Object, param3:Function, param4:Object = null)
      {
         super();
         this.m_parent = param2;
         this.m_duration = param1;
         this.m_callback = param3;
         this.m_userData = param4;
      }
      
      public function dispose() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         this.m_parent = null;
         this.m_callback = null;
      }
      
      public function start() : void
      {
         Zlab.processManager.removeScheduledObject(this);
         Zlab.processManager.schedule(this.m_duration,this,this.onExpired);
      }
      
      private function onExpired() : void
      {
         this.m_callback.apply(this.m_parent,[this.m_userData]);
      }
   }
}

