package core.managers
{
   public class FlamingUnitManager
   {
      
      public static var instance:FlamingUnitManager = new FlamingUnitManager();
      
      private static var m_flamingDamage:int = 0;
      
      public static const EXPERIMENT_YELLOWUNITS_FLAMEDAMAGE_EXISTING:int = 1;
      
      public static const EXPERIMENT_YELLOWUNITS_FLAMEDAMAGE_OFF:int = 2;
      
      public static const EXPERIMENT_YELLOWUNITS_FLAMEDAMAGE_VARIANT3:int = 3;
      
      public static const EXPERIMENT_YELLOWUNITS_FLAMEDAMAGE_VARIANT4:int = 4;
      
      public static const EXPERIMENT_YELLOWUNITS_FLAMEDAMAGE_VARIANT5:int = 5;
      
      public static const EXPERIMENT_YELLOWUNITS_FLAMEDAMAGE_VARIANT6:int = 6;
      
      private static const DAMAGE_VARIANT1:int = 5;
      
      private static const DAMAGE_VARIANT2:int = 10;
      
      private static const DAMAGE_VARIANT3:int = 15;
      
      private static const DAMAGE_VARIANT4:int = 20;
      
      private var m_flamingEnabled:Boolean;
      
      private var m_flamingVariant:int;
      
      private var m_currentDamageVariant:int;
      
      public function FlamingUnitManager()
      {
         super();
      }
      
      public function initExperimentVars() : void
      {
         this.m_flamingVariant = ExperimentsManager.instance.getExperimentVariant("empires_yellow_units_flame_damage");
         this.m_flamingEnabled = this.m_flamingVariant > 0 && this.m_flamingVariant != EXPERIMENT_YELLOWUNITS_FLAMEDAMAGE_OFF;
         this.m_currentDamageVariant = DAMAGE_VARIANT1;
      }
      
      public function getFlamingDamageVariant() : int
      {
         switch(this.m_flamingVariant)
         {
            case EXPERIMENT_YELLOWUNITS_FLAMEDAMAGE_VARIANT3:
               this.m_currentDamageVariant = DAMAGE_VARIANT1;
               break;
            case EXPERIMENT_YELLOWUNITS_FLAMEDAMAGE_VARIANT4:
               this.m_currentDamageVariant = DAMAGE_VARIANT2;
               break;
            case EXPERIMENT_YELLOWUNITS_FLAMEDAMAGE_VARIANT5:
               this.m_currentDamageVariant = DAMAGE_VARIANT3;
               break;
            case EXPERIMENT_YELLOWUNITS_FLAMEDAMAGE_VARIANT6:
               this.m_currentDamageVariant = DAMAGE_VARIANT4;
               break;
            default:
               return this.m_currentDamageVariant;
         }
         return this.m_currentDamageVariant;
      }
      
      public function get flamingUnitsEnabled() : Boolean
      {
         return this.m_flamingEnabled;
      }
      
      public function get flamingUnitsDamageVariant() : int
      {
         return this.m_flamingVariant;
      }
      
      public function set flamingDamage(param1:int) : void
      {
         m_flamingDamage = param1;
      }
      
      public function get flamingDamage() : int
      {
         return m_flamingDamage;
      }
   }
}

