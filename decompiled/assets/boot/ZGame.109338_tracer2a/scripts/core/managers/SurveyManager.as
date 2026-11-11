package core.managers
{
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   import zlabs.managers.WindowManager;
   
   public class SurveyManager extends EventDispatcher
   {
      
      public static const SHOW_SCREEN:String = "ShowScreen";
      
      private static var m_instance:SurveyManager = null;
      
      private static const SURVEY_STATS_COUNTER:String = "survey";
      
      private var m_overlaySurveyURL:String;
      
      public function SurveyManager()
      {
         super();
      }
      
      public static function getInstance() : SurveyManager
      {
         if(null == m_instance)
         {
            m_instance = new SurveyManager();
         }
         return m_instance;
      }
      
      public function initializeSurveyOverlay(param1:String) : void
      {
         if(param1)
         {
            this.m_overlaySurveyURL = param1;
         }
      }
      
      public function displaySurveyOverlay() : void
      {
         if(Boolean(this.m_overlaySurveyURL) && ExternalInterface.available)
         {
            WindowManager.setFullScreen(false);
            Logger.info(this,"displaySurveyOverlay","calling theFarmOverlay.showSurveyOverlay with: " + this.m_overlaySurveyURL);
            ExternalInterface.call("theFarmOverlay.showSurveyOverlay",this.m_overlaySurveyURL);
            dispatchEvent(new WorldEvent(SHOW_SCREEN,this));
         }
      }
   }
}

