package core.managers
{
   public class TierSurfacingManager
   {
      
      public static var instance:TierSurfacingManager = new TierSurfacingManager();
      
      private var m_tierSurfacingEnabled:Boolean;
      
      private var m_tierSurfacing2Enabled:Boolean;
      
      public function TierSurfacingManager()
      {
         super();
      }
      
      public function initExperimentVars() : void
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant("empire_tier_surfacing");
         this.m_tierSurfacingEnabled = _loc1_ > 0;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_TIER_SURFACING_2) == ExperimentsManager.EXPERIMENT_TIER_SURFACING_2_ENABLED_VARIANT)
         {
            this.m_tierSurfacing2Enabled = true;
         }
         else
         {
            this.m_tierSurfacing2Enabled = false;
         }
      }
      
      public function get tierSurfacingEnabled() : Boolean
      {
         return this.m_tierSurfacingEnabled;
      }
      
      public function get tierSurfacing2Enabled() : Boolean
      {
         return this.m_tierSurfacing2Enabled;
      }
   }
}

