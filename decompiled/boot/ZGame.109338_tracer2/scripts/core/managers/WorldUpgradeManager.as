package core.managers
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.gameobjects.GameItem;
   import core.gameobjects.UnitItem;
   import core.gameobjects.UpgradeItem;
   import dispatchers.ResearchDispatcher;
   import events.ResearchUpdatedEvent;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import transactions.TUpgradeResearchBuilding;
   import utils.ZGameRandom;
   import zlabs.utils.MathUtils;
   
   public class WorldUpgradeManager extends EventDispatcher
   {
      
      public static var instance:WorldUpgradeManager = new WorldUpgradeManager();
      
      public static var FIRST_RESEARCH_DIALOG:String = "firstResearchDialog";
      
      private var m_upgrades:Dictionary = new Dictionary();
      
      private var m_templateCache:Dictionary = new Dictionary();
      
      private var m_upgradeTrees:Dictionary = new Dictionary();
      
      private var m_buildingsTypesUpgraded:Object;
      
      private var m_treesUnlocked:Object;
      
      public function WorldUpgradeManager()
      {
         super();
      }
      
      public static function getResearchBuildingCodeOfType(param1:String) : String
      {
         var researchBuildingTypes:XMLList = null;
         var type:String = param1;
         researchBuildingTypes = ZGlobal.gameSettings.getXML().researchBuildingTypes.building.(@type == type);
         if(researchBuildingTypes)
         {
            return researchBuildingTypes.@code.toString();
         }
         return null;
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         var _loc2_:XML = null;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         if(param1)
         {
            for each(_loc2_ in param1)
            {
               _loc3_ = _loc2_.@name.toString() + _loc2_.@tree.toString();
               _loc4_ = _loc2_.@upgrades.toString().split(",");
               for each(_loc5_ in _loc4_)
               {
                  this.m_upgradeTrees[_loc5_] = _loc3_;
               }
            }
         }
      }
      
      public function loadUpgrades(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         for(_loc2_ in param1)
         {
            for each(_loc3_ in param1[_loc2_])
            {
               this.addUpgrade(_loc2_,_loc3_);
            }
         }
      }
      
      public function loadResearch2(param1:Object) : void
      {
         if(param1)
         {
            this.m_buildingsTypesUpgraded = param1.buildingTypesUpgraded;
            this.m_treesUnlocked = param1.treesUnlocked;
         }
      }
      
      public function addUpgrade(param1:String, param2:String) : void
      {
         if(!(this.m_upgrades[param1] is Array))
         {
            this.m_upgrades[param1] = new Array();
         }
         if(this.m_upgrades[param1].indexOf(param2) < 0)
         {
            this.m_upgrades[param1].push(param2);
         }
         var _loc3_:UpgradeItem = UpgradeItem(ZGlobal.gameSettings.getItemByCode(param2,UpgradeItem));
         if(_loc3_.modifiesDuration())
         {
            ResearchDispatcher.instance.dispatchEvent(new ResearchUpdatedEvent(ResearchUpdatedEvent.DURATION_UPGRADE_ADDED,param1,param2));
         }
         ResearchDispatcher.instance.dispatchEvent(new ResearchUpdatedEvent(ResearchUpdatedEvent.UPGRADE_ADDED,param1,param2));
      }
      
      public function getModifiedShields(param1:Array, param2:int) : int
      {
         var _loc4_:String = null;
         var _loc5_:UpgradeItem = null;
         var _loc3_:Number = 0;
         if(param1 as Array)
         {
            for each(_loc4_ in param1)
            {
               _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_,UpgradeItem) as UpgradeItem;
               if(_loc5_.modifiesShields())
               {
                  _loc3_ = _loc5_.shieldModifier;
               }
            }
         }
         return _loc3_;
      }
      
      public function getModifiedStrength(param1:Array, param2:Number) : int
      {
         var _loc3_:String = null;
         var _loc4_:UpgradeItem = null;
         for each(_loc3_ in param1)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,UpgradeItem) as UpgradeItem;
            if(_loc4_.modifiesStrength())
            {
               if(_loc4_.isPercentageModifier())
               {
                  param2 += param2 * _loc4_.strengthModifier / 100;
               }
               else
               {
                  param2 += _loc4_.strengthModifier;
               }
               param2 = Math.round(param2);
            }
         }
         return param2;
      }
      
      public function getModifiedCost(param1:Array, param2:int) : int
      {
         var _loc4_:String = null;
         var _loc5_:UpgradeItem = null;
         var _loc6_:Number = NaN;
         var _loc3_:Number = param2;
         for each(_loc4_ in param1)
         {
            _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_,UpgradeItem) as UpgradeItem;
            if(_loc5_.modifiesCost())
            {
               if(_loc5_.isPercentageModifier())
               {
                  _loc6_ = _loc3_ * _loc5_.costModifier / 100;
                  if(_loc6_ < 1)
                  {
                     _loc6_ = 1;
                  }
                  _loc3_ -= _loc6_;
                  _loc3_ = Math.max(_loc3_,0);
               }
               else
               {
                  _loc3_ -= _loc5_.costModifier;
                  _loc3_ = Math.max(_loc3_,0);
               }
            }
         }
         return Math.round(_loc3_);
      }
      
      public function getModifiedDuration(param1:Array, param2:int) : int
      {
         var _loc3_:String = null;
         var _loc4_:UpgradeItem = null;
         for each(_loc3_ in param1)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,UpgradeItem) as UpgradeItem;
            if(_loc4_.modifiesDuration())
            {
               if(_loc4_.isPercentageModifier())
               {
                  param2 -= param2 * _loc4_.durationModifier / 100;
                  param2 = Math.max(param2,0);
               }
               else
               {
                  param2 -= _loc4_.durationModifier;
                  param2 = Math.max(param2,0);
               }
            }
         }
         return param2;
      }
      
      public function getModifiedDodge(param1:Array) : Number
      {
         var _loc3_:String = null;
         var _loc4_:UpgradeItem = null;
         var _loc2_:Number = 0;
         for each(_loc3_ in param1)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,UpgradeItem) as UpgradeItem;
            if(_loc4_.modifiesDodge())
            {
               _loc2_ += MathUtils.roundTo(_loc4_.dodgeModifier * 0.01,ZGameRandom.ACCURACY);
            }
         }
         return _loc2_;
      }
      
      public function getModifiedAccuracy(param1:Array, param2:Number) : Number
      {
         var _loc3_:String = null;
         var _loc4_:UpgradeItem = null;
         for each(_loc3_ in param1)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,UpgradeItem) as UpgradeItem;
            if(_loc4_.modifiesAccuracy())
            {
               param2 += _loc4_.accuracyModifier * 0.01;
               param2 = MathUtils.roundTo(param2,ZGameRandom.ACCURACY);
            }
         }
         return param2;
      }
      
      public function getModifiedDamage(param1:Array, param2:Number) : Number
      {
         var _loc3_:String = null;
         var _loc4_:UpgradeItem = null;
         for each(_loc3_ in param1)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,UpgradeItem) as UpgradeItem;
            if(_loc4_.modifiesDamage())
            {
               if(_loc4_.isPercentageModifier())
               {
                  param2 += param2 * _loc4_.damageModifier / 100;
                  param2 = MathUtils.roundTo(param2,ZGameRandom.ACCURACY);
               }
               else
               {
                  param2 += _loc4_.damageModifier;
               }
            }
         }
         return param2;
      }
      
      public function hasUpgrade(param1:String, param2:String) : Boolean
      {
         var _loc3_:Array = null;
         if(this.m_upgrades[param1] is Array)
         {
            _loc3_ = this.m_upgrades[param1];
            if(_loc3_.indexOf(param2) >= 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public function getUpgradesByCode(param1:String) : Array
      {
         var _loc2_:Array = new Array();
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1,UnitItem) as UnitItem;
         if(Boolean(_loc3_) && Boolean(_loc3_.hasType(UnitItem.MEGA_UNIT)) && Boolean(_loc3_.megaTemplate))
         {
            param1 = _loc3_.megaTemplate;
         }
         if(this.m_upgrades[param1] is Array)
         {
            _loc2_ = this.m_upgrades[param1];
         }
         return _loc2_;
      }
      
      public function getNumRemainingUpgrades(param1:String) : int
      {
         var _loc2_:int = this.getTotalUpgrades(param1);
         if(this.m_upgrades[param1] is Array)
         {
            _loc2_ -= this.getNumCompletedUpgrades(param1);
         }
         return _loc2_;
      }
      
      public function getNumCompletedUpgrades(param1:String) : int
      {
         var _loc2_:* = 0;
         if(this.m_upgrades[param1] is Array)
         {
            _loc2_ = int(this.m_upgrades[param1].length);
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RESEARCH_SHIELD_UPGRADE) != ExperimentsManager.VARIANT_RESEARCH_SHIELD_UPGRADE_ON)
            {
               if(this.isShieldUpgraded(param1))
               {
                  _loc2_--;
               }
            }
            return _loc2_;
         }
         return 0;
      }
      
      public function getTotalUpgrades(param1:String) : int
      {
         var _loc2_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1,UnitItem) as UnitItem;
         var _loc3_:String = _loc2_.researchTemplate;
         var _loc4_:XMLList = this.getResearchTemplate(_loc3_);
         var _loc5_:* = 0;
         if(_loc4_)
         {
            _loc5_ = int(_loc4_.upgrade.length());
            if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RESEARCH_SHIELD_UPGRADE) != ExperimentsManager.VARIANT_RESEARCH_SHIELD_UPGRADE_ON)
            {
               if(this.isTechResearch(_loc3_))
               {
                  _loc5_--;
               }
            }
         }
         return _loc5_;
      }
      
      public function isStrengthUpgraded(param1:String) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:UpgradeItem = null;
         var _loc2_:Array = this.m_upgrades[param1];
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,UpgradeItem) as UpgradeItem;
            if(_loc4_.modifiesStrength())
            {
               return true;
            }
         }
         return false;
      }
      
      public function isShieldUpgraded(param1:String) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:UpgradeItem = null;
         var _loc2_:Array = this.m_upgrades[param1];
         for each(_loc3_ in _loc2_)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,UpgradeItem) as UpgradeItem;
            if(_loc4_.modifiesShields())
            {
               return true;
            }
         }
         return false;
      }
      
      public function getResearchTemplate(param1:String) : XMLList
      {
         var templateCode:String = param1;
         if(this.m_templateCache[templateCode] == null)
         {
            this.m_templateCache[templateCode] = ZGlobal.gameSettings.getXML().researchTemplates.researchTemplate.(@code == templateCode);
         }
         return this.m_templateCache[templateCode];
      }
      
      public function isTechResearch(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:XMLList = this.getResearchTemplate(param1);
         if(_loc3_.@type == "techUpgrade")
         {
            _loc2_ = true;
         }
         return _loc2_;
      }
      
      public function get research2Enabled() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant("empire_research2_master");
         return _loc1_ == 2;
      }
      
      public function researchBuildingUpgradeAvailable(param1:String) : Boolean
      {
         if(!this.research2Enabled)
         {
            return false;
         }
         var _loc2_:String = "empire_research2_" + param1;
         _loc2_.toLowerCase();
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant(_loc2_);
         return _loc3_ >= 3;
      }
      
      public function isResearchBuildingUpgraded(param1:String) : Boolean
      {
         if(!this.researchBuildingUpgradeAvailable(param1))
         {
            return false;
         }
         if(!this.m_buildingsTypesUpgraded || this.m_buildingsTypesUpgraded.indexOf(param1) < 0)
         {
            return false;
         }
         return true;
      }
      
      public function upgradeResearchBuilding(param1:String) : void
      {
         var _loc2_:TUpgradeResearchBuilding = new TUpgradeResearchBuilding(param1);
         TransactionManager.addTransaction(_loc2_);
         if(!this.m_buildingsTypesUpgraded)
         {
            this.m_buildingsTypesUpgraded = [param1];
         }
         else
         {
            this.m_buildingsTypesUpgraded.push(param1);
         }
         this.unlockTreesForExistingUpgrades(param1);
      }
      
      public function isAutoUpgradeItem(param1:String) : Boolean
      {
         var _loc2_:String = ZGlobal.gameSettings.getString("autoUpgradeUnits","");
         var _loc3_:Array = _loc2_.split(",");
         return _loc3_.indexOf(param1) >= 0;
      }
      
      private function unlockTree(param1:String, param2:String) : void
      {
         if(!this.m_treesUnlocked)
         {
            this.m_treesUnlocked = new Object();
         }
         if(!(this.m_treesUnlocked[param1] as Array))
         {
            this.m_treesUnlocked[param1] = [];
         }
         this.m_treesUnlocked[param1].push(param2);
      }
      
      private function getResearchTreeForUpgrade(param1:String) : String
      {
         return this.m_upgradeTrees[param1];
      }
      
      private function unlockTreesForExistingUpgrades(param1:String) : void
      {
         var _loc2_:String = null;
         var _loc3_:GameItem = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         for(_loc2_ in this.m_upgrades)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_,GameItem) as GameItem;
            if(Boolean(_loc3_) && _loc3_.subType == param1)
            {
               for each(_loc4_ in this.m_upgrades[_loc2_])
               {
                  _loc5_ = this.getResearchTreeForUpgrade(_loc4_);
                  if(_loc5_)
                  {
                     this.unlockTree(_loc2_,_loc5_);
                  }
               }
            }
         }
      }
      
      public function getModifiedEfficiency(param1:Array, param2:Number) : Number
      {
         var _loc3_:String = null;
         var _loc4_:UpgradeItem = null;
         for each(_loc3_ in param1)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_,UpgradeItem) as UpgradeItem;
            if(_loc4_.modifiesEfficiency())
            {
               param2 = 100 / _loc4_.efficiencyModifier;
               param2 = MathUtils.roundTo(param2,ZGameRandom.ACCURACY);
            }
         }
         return param2;
      }
   }
}

