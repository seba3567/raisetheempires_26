package core.ui.UIDirector
{
   import flash.events.Event;
   
   public class UIDirector
   {
      
      public static const EVENT_SCRIPT_END:String = "EVENT_SCRIPT_END";
      
      private static var m_instance:UIDirector = null;
      
      private var m_script:UIDirectorScript = null;
      
      private var m_callback:Function = null;
      
      public function UIDirector()
      {
         super();
      }
      
      public static function get instance() : UIDirector
      {
         if(!m_instance)
         {
            m_instance = new UIDirector();
         }
         return m_instance;
      }
      
      public function runScript(param1:UIDirectorScript, param2:Function = null) : void
      {
         this.m_script = param1;
         this.m_script.addEventListener(EVENT_SCRIPT_END,this.onScriptEnd,false,0,true);
         this.m_script.begin();
      }
      
      private function onScriptEnd(param1:Event) : void
      {
         this.m_script = null;
         if(this.m_callback != null)
         {
            this.m_callback();
         }
      }
   }
}

