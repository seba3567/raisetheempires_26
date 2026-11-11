package core.managers
{
   import core.ZGlobal;
   import entity.GameDataComponent;
   import flash.utils.Dictionary;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   
   public class ExpansionPriceExperimentManager
   {
      
      public static const MAX_EXPANSIONS:uint = 190;
      
      public static var instance:ExpansionPriceExperimentManager = new ExpansionPriceExperimentManager();
      
      private var m_dataCache:Array = null;
      
      private var m_cashCache:Array = null;
      
      private var m_tunedCostCache:Array = null;
      
      public function ExpansionPriceExperimentManager()
      {
         super();
      }
      
      public function getExpansionData(param1:uint, param2:String) : String
      {
         var _loc6_:int = 0;
         var _loc3_:String = "";
         var _loc4_:uint = 0;
         var _loc5_:int = this.dataCache.length - 1;
         if(param1 <= _loc5_)
         {
            if(!this.dataCache[param1])
            {
               Logger.error(this,"getExpansionData","Expansion data not found for expansionCount - " + param1);
               return "";
            }
            _loc4_ = param1;
         }
         else
         {
            _loc4_ = uint(_loc5_);
         }
         if(param2 == "populationRequired")
         {
            _loc3_ = this.dataCache[_loc4_].@populationRequired;
         }
         else if(param2 == "crewRequired")
         {
            _loc3_ = this.dataCache[_loc4_].@crewRequired;
         }
         else if(param2 == "cashPerCrew")
         {
            _loc6_ = int(this.dataCache[_loc4_].@cashPerCrew);
            _loc3_ = this.getExperimentAdjustedPrice(_loc6_).toString();
         }
         else if(param2 == "totalCash")
         {
            _loc3_ = this.dataCache[_loc4_].@totalCash;
         }
         else
         {
            Logger.error(this,"getExpansionData","Expansion data not found for dataKey" + param2);
         }
         return _loc3_;
      }
      
      public function getExpansionCashCost(param1:uint) : int
      {
         var _loc2_:uint = 0;
         var _loc3_:int = this.cashCache.length - 1;
         if(param1 <= _loc3_)
         {
            if(!this.cashCache[param1])
            {
               Logger.error(this,"getExpansionCashCost","expansion data not found for expansionCount" + param1);
               return 1;
            }
            _loc2_ = param1;
         }
         else
         {
            _loc2_ = uint(_loc3_);
         }
         return this.getExperimentAdjustedPrice(int(this.cashCache[_loc2_].@cashCost));
      }
      
      private function getExperimentAdjustedPrice(param1:int) : int
      {
         var _loc2_:int = -1;
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_EXPANSION_CREW_COST);
         if(_loc3_ == 3)
         {
            _loc2_ = Math.ceil(param1 * 0.5);
         }
         else if(_loc3_ == 4)
         {
            _loc2_ = Math.ceil(param1 * 0.8);
         }
         else if(_loc3_ == 5)
         {
            _loc2_ = Math.ceil(param1 * 1.2);
         }
         else if(_loc3_ == 6)
         {
            _loc2_ = Math.ceil(param1 * 1.5);
         }
         else
         {
            _loc2_ = param1;
         }
         return _loc2_;
      }
      
      private function get dataCache() : Array
      {
         var _loc1_:XMLList = null;
         var _loc2_:uint = 0;
         var _loc3_:XML = null;
         if(!this.m_dataCache)
         {
            this.m_dataCache = new Array();
            _loc1_ = ZGlobal.gameSettings.getXML().expansionData.expansionCosts.expansionCost;
            _loc2_ = 0;
            for each(_loc3_ in _loc1_)
            {
               this.m_dataCache[_loc2_] = _loc3_;
               _loc2_++;
            }
         }
         return this.m_dataCache;
      }
      
      private function get cashCache() : Array
      {
         var _loc1_:XMLList = null;
         var _loc2_:uint = 0;
         var _loc3_:XML = null;
         if(!this.m_cashCache)
         {
            this.m_cashCache = new Array();
            _loc1_ = ZGlobal.gameSettings.getXML().expansionData.expansionCashCosts.expansionCashCost;
            _loc2_ = 0;
            for each(_loc3_ in _loc1_)
            {
               this.m_cashCache[_loc2_] = _loc3_;
               _loc2_++;
            }
         }
         return this.m_cashCache;
      }
      
      public function getFilledCrewExpansionCount() : int
      {
         var _loc3_:IEntity = null;
         var _loc4_:GameDataComponent = null;
         var _loc1_:int = 0;
         var _loc2_:Dictionary = WorldObjectManager.instance.getObjectsBySubType("expansion","crewExpansion");
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_)
            {
               _loc4_ = GameDataComponent.getGameDataComponent(_loc3_);
               _loc1_ = _loc4_.filledCrewCount;
            }
         }
         return _loc1_;
      }
      
      public function getTunedExpansionCost(param1:uint, param2:String) : int
      {
         var _loc3_:int = 0;
         var _loc4_:uint = 0;
         var _loc5_:int = this.tunedCostCache.length - 1;
         if(param1 <= _loc5_)
         {
            if(this.tunedCostCache[param1])
            {
               _loc4_ = param1;
            }
            else
            {
               Logger.error(this,"getTunedExpansionCost","Expansion data not found for expansionCount - " + param1);
            }
         }
         else
         {
            _loc4_ = uint(_loc5_);
         }
         var _loc6_:XMLList = XML(this.tunedCostCache[_loc4_]).attribute(param2);
         if(_loc6_.length())
         {
            _loc3_ = int(_loc6_[0]);
         }
         else
         {
            Logger.error(this,"getTunedExpansionCost","Expansion data not found for dataKey: " + param2);
         }
         return _loc3_;
      }
      
      private function get tunedCostCache() : Array
      {
         var _loc1_:XMLList = null;
         var _loc2_:XML = null;
         if(!this.m_tunedCostCache)
         {
            this.m_tunedCostCache = new Array();
            _loc1_ = ZGlobal.gameSettings.getXML().expansionData.expansionTunedResourceCosts.expansionTunedResourceCost;
            for each(_loc2_ in _loc1_)
            {
               if(_loc2_.@expansionCount != null)
               {
                  this.m_tunedCostCache[int(_loc2_.@expansionCount)] = _loc2_;
               }
            }
         }
         return this.m_tunedCostCache;
      }
   }
}

