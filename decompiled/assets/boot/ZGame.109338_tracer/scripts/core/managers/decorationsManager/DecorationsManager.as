package core.managers.decorationsManager
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.DecorationTargetComponent;
   import core.gameobjects.DecorationItem;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import transactions.TDecoCrewBuyOnce;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class DecorationsManager extends EventDispatcher
   {
      
      public static var instance:DecorationsManager = new DecorationsManager();
      
      public static var SOURCE_PLACED:String = "sourcePlaced";
      
      public static var SOURCE_REMOVED:String = "sourceRemoved";
      
      public static var TARGET_MOVED:String = "targetMoved";
      
      public static var TARGET_MILITARY:String = "military";
      
      public static var TARGET_PRODUCTION:String = "production";
      
      public static var TARGET_RESIDENTIAL:String = "residential";
      
      public static var TARGET_CIVIC:String = "civic";
      
      public static var TARGET_UNIT:String = "unit";
      
      public static var TARGET_ACCELERATED_MILITARY:String = "acceleratedMilitary";
      
      public static var TARGET_FARM_CAMP:String = "farmCampTarget";
      
      public static var TARGET_ACCELERATED_ARMY_RESEARCH:String = "acceleratedArmyResearch";
      
      public static var EFFECT_MATURING_YIELD:String = "maturationYield";
      
      public static var EFFECT_CONTRACT_YIELD:String = "contractYield";
      
      public static var EFFECT_REFERENCEITEM_COST:String = "referenceItemCost";
      
      public static var EFFECT_CREW_HARVEST_BUFF:String = "crewTendBuff";
      
      public static var EFFECT_CONTRACT_DURATION:String = "contractDuration";
      
      public static var EFFECT_FARM_CAMP_DURATION:String = "farmCampDuration";
      
      public static var EFFECT_ARMY_RESEARCH_ACCELERATION:String = "armyResearchAcceleration";
      
      private static var m_allowedTargets:Array = [TARGET_MILITARY,TARGET_PRODUCTION,TARGET_RESIDENTIAL,TARGET_ACCELERATED_MILITARY,TARGET_FARM_CAMP,TARGET_ACCELERATED_ARMY_RESEARCH,TARGET_CIVIC];
      
      private static var m_allowedEffects:Array = [EFFECT_MATURING_YIELD,EFFECT_CONTRACT_YIELD,EFFECT_REFERENCEITEM_COST,EFFECT_CREW_HARVEST_BUFF,EFFECT_FARM_CAMP_DURATION,EFFECT_CONTRACT_DURATION,EFFECT_ARMY_RESEARCH_ACCELERATION];
      
      public static var EFFECT_FEEDBACK_PREMIUM:int = 0;
      
      public static var EFFECT_FEEDBACK_CONTRACT_YIELD:int = 1;
      
      public static var EFFECT_FEEDBACK_REFERENCEITEM_COST:int = 2;
      
      public static var EFFECT_FEEDBACK_MATURING_YIELD:int = 3;
      
      public static var EFFECT_FEEDBACK_CREW_HARVEST_BUFF:int = 4;
      
      private static var m_decoStoreInventoryCardBackgrounds:Array = ["card_mc_premium","card_mc_production","card_mc_military","card_mc_residential","card_mc_civic"];
      
      private static var m_decoInventoryCountBackgrounds:Array = ["count_mc_premium","count_mc_industrial","count_mc_military","count_mc_residential","count_mc_government"];
      
      private static var m_decoFeedbackColors:Array = [136 << 16 | 5 << 8 | 0xF0,74 << 16 | 167 << 8 | 0xEC,0 << 16 | 234 << 8 | 0,167 << 16 | 35 << 8 | 0x68,255 << 16 | 205 << 8 | 0x37];
      
      private static var DEFAULT_CAP:int = 999999;
      
      public static var LABEL_AMOUNT_NORMAL:String = "amountNormal";
      
      public static var LABEL_AMOUNT_CREWED:String = "amountCrewed";
      
      private var m_targetInfoDict:Dictionary = new Dictionary();
      
      private var m_xml:XMLList;
      
      private var m_payoutVariant:int;
      
      private var m_crewDuration:int = 64800;
      
      private var m_fullCrewBonus:int = 0;
      
      private var m_buyOnceAmount:int = 0;
      
      private var m_repelPayoutSources:Dictionary = new Dictionary();
      
      public function DecorationsManager()
      {
         super();
      }
      
      public static function sortMeaningfulDecorations(param1:GameItem, param2:GameItem) : int
      {
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc3_:DecorationItem = ZGlobal.gameSettings.getItemByCode(param1.code,DecorationItem) as DecorationItem;
         var _loc4_:DecorationItem = ZGlobal.gameSettings.getItemByCode(param2.code,DecorationItem) as DecorationItem;
         var _loc5_:XMLList = _loc3_.effectsXML;
         var _loc6_:XMLList = _loc4_.effectsXML;
         if(_loc5_.length() > _loc6_.length())
         {
            return -1;
         }
         if(_loc5_.length() < _loc6_.length())
         {
            return 1;
         }
         if(Boolean(_loc5_.length()) && Boolean(_loc6_.length()))
         {
            _loc7_ = _loc5_[0].@effect.toString();
            _loc8_ = _loc6_[0].@effect.toString();
            _loc9_ = m_allowedEffects.indexOf(_loc7_);
            _loc10_ = m_allowedEffects.indexOf(_loc8_);
            if(_loc9_ < 0)
            {
               return 1;
            }
            if(_loc10_ < 0)
            {
               return -1;
            }
            if(_loc9_ < _loc10_)
            {
               return -1;
            }
            if(_loc9_ > _loc10_)
            {
               return 1;
            }
            _loc11_ = instance.getEffectVariantAmount(_loc5_[0].@amountNormal.toString(),_loc5_[0].@effect.toString());
            _loc12_ = instance.getEffectVariantAmount(_loc6_[0].@amountNormal.toString(),_loc6_[0].@effect.toString());
            if(_loc11_ > _loc12_)
            {
               return -1;
            }
            if(_loc11_ < _loc12_)
            {
               return 1;
            }
         }
         return 0;
      }
      
      public function onSourcePlaced(param1:WorldEvent) : void
      {
         var _loc2_:int = (param1.eventData.data.effectStrings as Array).indexOf("repelPayout");
         if(_loc2_ >= 0 && Boolean(param1.eventData.isBuilt))
         {
            this.m_repelPayoutSources[param1.eventData.id] = this.getEffectVariantAmount(param1.eventData.data.effectsXML[_loc2_].@amountNormal.toString(),"repelPayout");
         }
      }
      
      public function onSourceRemoved(param1:WorldEvent) : void
      {
         if(this.m_repelPayoutSources[param1.eventData.id])
         {
            delete this.m_repelPayoutSources[param1.eventData.id];
         }
      }
      
      public function init(param1:Object) : void
      {
         this.m_payoutVariant = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_DECORATIONS_PAYOUT);
         if(Boolean(param1) && Boolean(param1.decorationsInfo))
         {
            if(param1.decorationsInfo.crewDuration)
            {
               this.m_crewDuration = param1.decorationsInfo.crewDuration;
            }
            if(param1.decorationsInfo.fullCrewBonus)
            {
               this.m_fullCrewBonus = param1.decorationsInfo.fullCrewBonus;
            }
            if(param1.decorationsInfo.buyOnceAmount)
            {
               this.m_buyOnceAmount = param1.decorationsInfo.buyOnceAmount;
            }
         }
         this.addEventListener(DecorationsManager.SOURCE_PLACED,this.onSourcePlaced,false,0,true);
         this.addEventListener(DecorationsManager.SOURCE_REMOVED,this.onSourceRemoved,false,0,true);
      }
      
      public function getEffectVariantAmount(param1:String, param2:String) : int
      {
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         if(param1)
         {
            _loc3_ = param2 != EFFECT_CONTRACT_DURATION ? this.m_payoutVariant : ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_DECORATIONS_CONTRACT_DURATION);
            _loc4_ = param1.split(",");
            if(_loc3_ < _loc4_.length)
            {
               return _loc4_[_loc3_];
            }
         }
         return 0;
      }
      
      public function getAffectedResources(param1:String) : Array
      {
         var _loc2_:XML = null;
         for each(_loc2_ in this.m_xml)
         {
            if(_loc2_.@effect.toString() == param1)
            {
               if(_loc2_.@resources != undefined)
               {
                  return _loc2_.@resources.toString().split(",");
               }
            }
         }
         return [];
      }
      
      public function initFromSettings(param1:XMLList) : void
      {
         this.m_xml = param1;
      }
      
      public function getEffectsForGameItem(param1:GameItem) : Array
      {
         var _loc3_:XML = null;
         var _loc2_:Array = [];
         this.updateTargetInfoDict(param1);
         if(this.m_targetInfoDict[param1.code])
         {
            for each(_loc3_ in this.m_targetInfoDict[param1.code])
            {
               _loc2_.push(_loc3_.@effect.toString());
            }
         }
         return _loc2_;
      }
      
      public function getTargetTypesForGameItem(param1:GameItem) : Array
      {
         var _loc3_:XML = null;
         var _loc2_:Array = [];
         this.updateTargetInfoDict(param1);
         if(this.m_targetInfoDict[param1.code])
         {
            for each(_loc3_ in this.m_targetInfoDict[param1.code])
            {
               _loc2_.push(_loc3_.@name.toString());
            }
         }
         return _loc2_;
      }
      
      public function isDecorationEffect(param1:String) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         if(m_allowedEffects.indexOf(param1) < 0)
         {
            return false;
         }
         return true;
      }
      
      public function isDecorationTarget(param1:GameItem) : Boolean
      {
         return this.getTargetTypesForGameItem(param1).length > 0;
      }
      
      private function getTargetInfos(param1:GameItem) : Array
      {
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:Array = null;
         var _loc2_:Array = [];
         for each(_loc3_ in this.m_xml)
         {
            if(_loc3_.@forbiddenItems != undefined)
            {
               _loc5_ = _loc3_.@forbiddenItems.toString().split(",");
               if(_loc5_.indexOf(param1.code) >= 0)
               {
                  continue;
               }
            }
            for each(_loc4_ in _loc3_.info)
            {
               if(_loc4_.@stateMachines != undefined)
               {
                  _loc7_ = param1.getStateMachineName(null);
                  if(!_loc7_)
                  {
                     continue;
                  }
                  _loc8_ = _loc4_.@stateMachines.toString().split(",");
                  if(_loc8_.indexOf(_loc7_) < 0)
                  {
                     continue;
                  }
               }
               if(_loc4_.@type != undefined)
               {
                  if(_loc4_.@type != param1.type)
                  {
                     continue;
                  }
               }
               if(_loc4_.@subtype != undefined)
               {
                  if(_loc4_.@subtype != param1.subType)
                  {
                     continue;
                  }
               }
               _loc6_ = _loc3_.@name.toString();
               if(m_allowedTargets.indexOf(_loc6_) >= 0)
               {
                  _loc2_.push(_loc3_);
               }
            }
         }
         return _loc2_;
      }
      
      private function updateTargetInfoDict(param1:GameItem) : void
      {
         if(Boolean(param1) && this.m_targetInfoDict[param1.code] == undefined)
         {
            this.m_targetInfoDict[param1.code] = this.getTargetInfos(param1);
         }
      }
      
      private function initDecoUI(param1:DecorationItem, param2:MovieClip, param3:Array) : void
      {
         var _loc6_:String = null;
         var _loc7_:Boolean = false;
         var _loc4_:int = param1.effectFeedbackType;
         var _loc5_:int = 0;
         for each(_loc6_ in param3)
         {
            _loc7_ = _loc5_ == _loc4_;
            param2[_loc6_].visible = _loc7_;
            _loc5_++;
         }
      }
      
      public function initDecoUICardBackground(param1:DecorationItem, param2:MovieClip) : void
      {
         this.initDecoUI(param1,param2,m_decoStoreInventoryCardBackgrounds);
      }
      
      public function initDecoUICardCountBackground(param1:DecorationItem, param2:MovieClip) : void
      {
         this.initDecoUI(param1,param2,m_decoInventoryCountBackgrounds);
      }
      
      public function get enabled() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_DECORATIONS_MASTER);
         return _loc1_ == 2;
      }
      
      public function get fullCrewBonusAmount() : int
      {
         return this.m_fullCrewBonus;
      }
      
      public function getFeedbackColor(param1:DecorationItem) : int
      {
         var _loc2_:int = param1.effectFeedbackType;
         return m_decoFeedbackColors[_loc2_];
      }
      
      public function getEffectCap(param1:String) : int
      {
         var _loc2_:XML = null;
         for each(_loc2_ in this.m_xml)
         {
            if(_loc2_.@effect.toString() == param1)
            {
               if(_loc2_.@cap != undefined)
               {
                  return _loc2_.@cap;
               }
            }
         }
         return DEFAULT_CAP;
      }
      
      public function get crewDurationBonusString() : String
      {
         var _loc1_:String = ZGameTimeUtil.instance.getTimeString(this.crewRemoveDuration,false);
         return ZGameUtils.ZlocT("Dialogs","CrewedDecorationsTimeBonus",{"durationString":_loc1_});
      }
      
      public function get crewRemoveDuration() : int
      {
         return this.m_crewDuration;
      }
      
      public function get buyOnceAmount() : int
      {
         return this.m_buyOnceAmount;
      }
      
      public function crewBuyOnce(param1:IEntity) : void
      {
         ZGlobal.player.cash -= this.buyOnceAmount;
         var _loc2_:TDecoCrewBuyOnce = new TDecoCrewBuyOnce(param1);
         TransactionManager.addTransaction(_loc2_);
      }
      
      public function getStoreTooltipAOELabel(param1:DecorationItem) : String
      {
         var _loc2_:int = param1.aoe;
         if(_loc2_ < 2)
         {
            return "DecorationsTooltipAOESmall";
         }
         if(_loc2_ < 3)
         {
            return "DecorationsTooltipAOEMedium";
         }
         return "DecorationsTooltipAOELarge";
      }
      
      public function applyResourceDiscount(param1:int, param2:int) : int
      {
         var _loc3_:Number = (100 - param2) / 100;
         var _loc4_:int = Math.floor(param1 * _loc3_);
         return int(Math.min(0,_loc4_));
      }
      
      public function applyContractDurationDecoEffect(param1:Number, param2:IEntity) : Number
      {
         var _loc3_:DecorationTargetComponent = DecorationTargetComponent.getDecorationTargetComponent(param2);
         var _loc4_:int = 0;
         if(_loc3_)
         {
            _loc4_ = _loc3_.getContractDurationPercentage();
         }
         return Math.floor(param1 - param1 * (_loc4_ / 100));
      }
      
      public function applyFarmCampDurationEffect(param1:Number, param2:IEntity) : Number
      {
         var _loc3_:DecorationTargetComponent = DecorationTargetComponent.getDecorationTargetComponent(param2);
         var _loc4_:int = 0;
         if(_loc3_)
         {
            _loc4_ = _loc3_.getFarmCampDurationPercentage();
         }
         return Math.floor(param1 - param1 * (_loc4_ / 100));
      }
      
      public function applyResearchAccelerationDecoEffect(param1:Number, param2:IEntity) : Number
      {
         var _loc3_:DecorationTargetComponent = DecorationTargetComponent.getDecorationTargetComponent(param2);
         var _loc4_:int = 0;
         if(_loc3_)
         {
            _loc4_ = _loc3_.getResearchAccelerationPercentage();
         }
         return Math.floor(param1 - param1 * (_loc4_ / 100));
      }
      
      public function getRepelMultiplier() : int
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         for each(_loc2_ in this.m_repelPayoutSources)
         {
            _loc1_ += _loc2_ - 1;
         }
         return ++_loc1_;
      }
   }
}

