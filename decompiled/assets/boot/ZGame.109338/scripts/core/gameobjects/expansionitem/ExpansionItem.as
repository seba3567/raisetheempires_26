package core.gameobjects.expansionitem
{
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.managers.ExpansionPriceExperimentManager;
   import core.managers.ExperimentsManager;
   
   public class ExpansionItem extends GameItem
   {
      
      public static const CREWABLE_EXPANSION_ID:String = "x02";
      
      private var m_priceCurveEnabled:Boolean = false;
      
      private var m_resourceScalar:Number = 1;
      
      private var m_itemScalar:Number = 1;
      
      private var m_numStartingExpansions:uint = 0;
      
      public function ExpansionItem(param1:XML)
      {
         super(param1);
         var _loc2_:String = ZGlobal.gameSettings.getString("startingExpansionIndexes");
         var _loc3_:Array = _loc2_.split(",");
         this.m_numStartingExpansions = _loc3_.length;
         this.m_priceCurveEnabled = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_PRICECURVE_EXPANSION) == ExperimentsManager.VARIANT_VALUE_PRICECURVE_EXPANSION_ENABLED;
         this.m_resourceScalar = this.m_priceCurveEnabled ? ZGlobal.gameSettings.getNumber("expansionPriceCurveResourceScalar",0.5) : ZGlobal.gameSettings.getNumber("expansionResourceScalar",1.5);
         this.m_itemScalar = this.m_priceCurveEnabled ? ZGlobal.gameSettings.getNumber("expansionPriceCurveItemScalar",0.85) : ZGlobal.gameSettings.getNumber("expansionItemScalar",1.5);
      }
      
      override public function get cash() : int
      {
         var _loc2_:int = 0;
         var _loc1_:int = super.cash;
         if(_loc1_ > 0)
         {
            _loc2_ = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_EXPANSION_CREW_MASTER);
            if(_loc2_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED && this.isCashExpansion())
            {
               return ExpansionPriceExperimentManager.instance.getExpansionCashCost(this.getNumberOfExpansions());
            }
         }
         return _loc1_;
      }
      
      override public function get requiredWorkers() : uint
      {
         var _loc3_:int = 0;
         var _loc1_:uint = uint(m_xml.requiredWorkers);
         var _loc2_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_EXPANSION_CREW_MASTER);
         if(this.code == CREWABLE_EXPANSION_ID && _loc2_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED)
         {
            _loc3_ = int(ExpansionPriceExperimentManager.instance.getExpansionData(this.getNumberOfExpansions(),"populationRequired"));
            if(_loc3_ > 0)
            {
               _loc1_ = uint(_loc3_);
            }
         }
         return _loc1_;
      }
      
      public function get requiredCrew() : uint
      {
         var _loc3_:int = 0;
         var _loc1_:uint = 1;
         var _loc2_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_EXPANSION_CREW_MASTER);
         if(this.code == CREWABLE_EXPANSION_ID && _loc2_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED)
         {
            _loc3_ = int(ExpansionPriceExperimentManager.instance.getExpansionData(this.getNumberOfExpansions(),"crewRequired"));
            if(_loc3_ > 0)
            {
               _loc1_ = uint(_loc3_);
            }
         }
         return this.requiredWorkers;
      }
      
      public function get cashPerCrew() : uint
      {
         var _loc3_:int = 0;
         var _loc1_:uint = 1;
         var _loc2_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_EXPANSION_CREW_MASTER);
         if(this.code == CREWABLE_EXPANSION_ID && _loc2_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED)
         {
            _loc3_ = int(ExpansionPriceExperimentManager.instance.getExpansionData(this.getNumberOfExpansions(),"cashPerCrew"));
            if(_loc3_ > 0)
            {
               _loc1_ = uint(_loc3_);
            }
         }
         return _loc1_;
      }
      
      public function get totalCash() : uint
      {
         var _loc3_:int = 0;
         var _loc1_:uint = 1;
         var _loc2_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_EXPANSION_CREW_MASTER);
         if(_loc2_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED)
         {
            _loc3_ = int(ExpansionPriceExperimentManager.instance.getExpansionData(this.getNumberOfExpansions(),"totalCash"));
            if(_loc3_ > 0)
            {
               _loc1_ = uint(_loc3_);
            }
         }
         return _loc1_;
      }
      
      public function get cashCost() : uint
      {
         var _loc3_:int = 0;
         var _loc1_:uint = 1;
         var _loc2_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_EXPANSION_CREW_MASTER);
         if(_loc2_ == ZGlobal.EXPERIMENT_EXPANSION_CREW_ENABLED)
         {
            _loc3_ = int(ExpansionPriceExperimentManager.instance.getExpansionData(this.getNumberOfExpansions(),"totalCash"));
            if(_loc3_ > 0)
            {
               _loc1_ = uint(_loc3_);
            }
         }
         return _loc1_;
      }
      
      override protected function getResourceCostAmount(param1:int) : int
      {
         if(this.m_priceCurveEnabled)
         {
            return ExpansionPriceExperimentManager.instance.getTunedExpansionCost(this.getNumberOfExpansions(),"coins");
         }
         return this.getAmount(param1,this.m_resourceScalar);
      }
      
      override protected function getItemCostAmount(param1:int) : int
      {
         if(this.m_priceCurveEnabled)
         {
            return ExpansionPriceExperimentManager.instance.getTunedExpansionCost(this.getNumberOfExpansions(),"xk01");
         }
         return this.getAmount(param1,this.m_itemScalar);
      }
      
      private function getAmount(param1:int, param2:Number) : uint
      {
         var _loc3_:Number = 1;
         var _loc4_:uint = this.getNumberOfExpansions();
         while(_loc4_ > 0)
         {
            _loc3_ *= param2;
            _loc4_--;
         }
         return param1 * _loc3_;
      }
      
      private function getNumberOfExpansions() : uint
      {
         return ZGlobal.player.expansions.numBitsSet() - this.m_numStartingExpansions;
      }
      
      public function isCrewableExpansion() : Boolean
      {
         return m_xml.expansionType == "crew" ? true : false;
      }
      
      public function isCashExpansion() : Boolean
      {
         return m_xml.expansionType == "cash" ? true : false;
      }
   }
}

