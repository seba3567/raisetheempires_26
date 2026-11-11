package core.managers
{
   public class WhiteUnitManager
   {
      
      public static var m_instance:WhiteUnitManager;
      
      public static const EXPERIMENT_WHITEUNIT_ENERGY_DOOBER_OFF:int = 1;
      
      public static const EXPERIMENT_WHITEUNIT_ENERGY_DOOBER_CONTROL:int = 2;
      
      public static const EXPERIMENT_WHITEUNIT_ENERGY_DOOBER_VARIANT3:int = 3;
      
      public static const EXPERIMENT_WHITEUNIT_ENERGY_DOOBER_VARIANT4:int = 4;
      
      public static const EXPERIMENT_WHITEUNIT_ENERGY_DOOBER_VARIANT5:int = 5;
      
      public static const EXPERIMENT_WHITEUNIT_ENERGY_DOOBER_VARIANT6:int = 6;
      
      public static const EXPERIMENT_WHITEUNIT_ENERGY_DOOBER_VARIANT7:int = 7;
      
      private static const PROBABILITY_VARIANT1:int = 10;
      
      private static const PROBABILITY_VARIANT2:int = 25;
      
      private static const PROBABILITY_VARIANT3:int = 50;
      
      private static const PROBABILITY_VARIANT4:int = 75;
      
      private static const PROBABILITY_VARIANT5:int = 100;
      
      private var m_whiteUnitsEnabled:Boolean;
      
      private var m_whiteUnitsVariant:int;
      
      private var m_currentProbabilityVariant:int;
      
      public function WhiteUnitManager()
      {
         super();
         this.initExperimentVars();
      }
      
      public static function get instance() : WhiteUnitManager
      {
         if(m_instance == null)
         {
            m_instance = new WhiteUnitManager();
         }
         return m_instance;
      }
      
      public function initExperimentVars() : void
      {
         this.m_whiteUnitsVariant = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_WHITEUNIT_ENERGY_DOOBER);
         this.m_whiteUnitsEnabled = this.m_whiteUnitsVariant > 0 && this.m_whiteUnitsVariant != EXPERIMENT_WHITEUNIT_ENERGY_DOOBER_OFF && this.m_whiteUnitsVariant != EXPERIMENT_WHITEUNIT_ENERGY_DOOBER_CONTROL;
         this.m_currentProbabilityVariant = PROBABILITY_VARIANT1;
         this.m_currentProbabilityVariant = this.getWhiteUnitProbabilityVariant();
      }
      
      public function getWhiteUnitProbabilityVariant() : int
      {
         switch(this.m_whiteUnitsVariant)
         {
            case EXPERIMENT_WHITEUNIT_ENERGY_DOOBER_VARIANT3:
               this.m_currentProbabilityVariant = PROBABILITY_VARIANT1;
               break;
            case EXPERIMENT_WHITEUNIT_ENERGY_DOOBER_VARIANT4:
               this.m_currentProbabilityVariant = PROBABILITY_VARIANT2;
               break;
            case EXPERIMENT_WHITEUNIT_ENERGY_DOOBER_VARIANT5:
               this.m_currentProbabilityVariant = PROBABILITY_VARIANT3;
               break;
            case EXPERIMENT_WHITEUNIT_ENERGY_DOOBER_VARIANT6:
               this.m_currentProbabilityVariant = PROBABILITY_VARIANT4;
               break;
            case EXPERIMENT_WHITEUNIT_ENERGY_DOOBER_VARIANT7:
               this.m_currentProbabilityVariant = PROBABILITY_VARIANT5;
               break;
            default:
               return this.m_currentProbabilityVariant;
         }
         return this.m_currentProbabilityVariant;
      }
      
      public function get whiteUnitsEnabled() : Boolean
      {
         return this.m_whiteUnitsEnabled;
      }
      
      public function get whiteUnitProbabilityVariant() : int
      {
         return this.m_currentProbabilityVariant;
      }
   }
}

