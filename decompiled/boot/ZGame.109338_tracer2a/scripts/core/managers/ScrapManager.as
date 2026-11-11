package core.managers
{
   public class ScrapManager
   {
      
      public static var instance:ScrapManager = new ScrapManager();
      
      public static const EXPERIMENT_SCRAP_OFF:int = 1;
      
      public static const EXPERIMENT_SCRAP_CONTROL:int = 2;
      
      public static const EXPERIMENT_SCRAP_VARIANT3:int = 3;
      
      public static const EXPERIMENT_SCRAP_VARIANT4:int = 4;
      
      public static const EXPERIMENT_SCRAP_VARIANT5:int = 5;
      
      public static const EXPERIMENT_SCRAP_VARIANT6:int = 6;
      
      private static const SCRAP_PROB_VARIANT1:int = 0;
      
      private static const SCRAP_PROB_VARIANT2:int = 0;
      
      private static const SCRAP_PROB_VARIANT3:int = 20;
      
      private static const SCRAP_PROB_VARIANT4:int = 40;
      
      private static const SCRAP_PROB_VARIANT5:int = 60;
      
      private static const SCRAP_PROB_VARIANT6:int = 100;
      
      private var m_scrapEnabled:Boolean;
      
      private var m_scrapVariant:int;
      
      private var m_currentScrapProb:int;
      
      public function ScrapManager()
      {
         super();
      }
      
      public function initExperimentVars() : void
      {
         this.m_scrapVariant = ExperimentsManager.instance.getExperimentVariant("empire_scrap_doober");
         this.m_scrapEnabled = this.m_scrapVariant > 0 && this.m_scrapVariant != EXPERIMENT_SCRAP_OFF && this.m_scrapVariant != EXPERIMENT_SCRAP_CONTROL;
         this.m_currentScrapProb = this.getScrapProbVariant();
      }
      
      private function getScrapProbVariant() : int
      {
         switch(this.m_scrapVariant)
         {
            case EXPERIMENT_SCRAP_OFF:
            case EXPERIMENT_SCRAP_CONTROL:
               this.m_currentScrapProb = SCRAP_PROB_VARIANT1;
               break;
            case EXPERIMENT_SCRAP_VARIANT3:
               this.m_currentScrapProb = SCRAP_PROB_VARIANT3;
               break;
            case EXPERIMENT_SCRAP_VARIANT4:
               this.m_currentScrapProb = SCRAP_PROB_VARIANT4;
               break;
            case EXPERIMENT_SCRAP_VARIANT5:
               this.m_currentScrapProb = SCRAP_PROB_VARIANT5;
               break;
            case EXPERIMENT_SCRAP_VARIANT6:
               this.m_currentScrapProb = SCRAP_PROB_VARIANT6;
         }
         return this.m_currentScrapProb;
      }
      
      public function get scrapEnabled() : Boolean
      {
         return this.m_scrapEnabled;
      }
      
      public function get scrapProb() : int
      {
         return this.m_currentScrapProb;
      }
   }
}

