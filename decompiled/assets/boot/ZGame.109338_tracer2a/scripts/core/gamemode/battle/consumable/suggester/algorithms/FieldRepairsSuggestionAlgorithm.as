package core.gamemode.battle.consumable.suggester.algorithms
{
   import core.ZGlobal;
   import core.gamemode.battle.consumable.suggester.AbstractConsumableSuggestionAlgorithm;
   import core.gamemode.battle.consumable.suggester.ConsumableSuggesterUtils;
   import core.gamemode.battle.consumable.suggester.IConsumableSuggestion;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.Fleet;
   import core.managers.ConsumableSuggestionManager;
   
   public class FieldRepairsSuggestionAlgorithm extends AbstractConsumableSuggestionAlgorithm implements IConsumableSuggestion
   {
      
      public static const ALGORITHM_FIELD_REPAIRS:String = "fieldRepairsAlgorithm";
      
      protected var m_suggestionPercent:Number;
      
      private var m_revenuePercent:Number;
      
      private var m_suggestionWeight:Number;
      
      private var m_revenueWeight:Number;
      
      private var m_fieldRepairsThresholdMin:Number;
      
      private var m_fieldRepairsThresholdTier1:Number;
      
      private var m_fieldRepairsThresholdTier2:Number;
      
      private var m_fieldRepairsThresholdTier3:Number;
      
      private var m_fieldRepairsForceOnFleetHealthThreshold:Number;
      
      private var m_fieldRepairsMinimumPlayerFleetSize:Number;
      
      public var m_suggestedHealthTierCode:String;
      
      private var m_fieldRepairCode:String;
      
      private var m_fieldRepairMessage:String;
      
      public function FieldRepairsSuggestionAlgorithm(param1:Fleet)
      {
         super(false);
         m_playerFleet = param1;
         this.initVars();
      }
      
      override public function get algorithmName() : String
      {
         return ALGORITHM_FIELD_REPAIRS;
      }
      
      override public function get consumableCode() : String
      {
         var _loc2_:Array = null;
         var _loc3_:ConsumableItem = null;
         var _loc4_:ConsumableItem = null;
         var _loc5_:String = null;
         var _loc1_:String = AbstractConsumableSuggestionAlgorithm.NO_CONSUMABLE_SUGGESTABLE;
         if(this.m_fieldRepairCode != null)
         {
            _loc2_ = this.m_fieldRepairCode.split(",");
            for each(_loc5_ in _loc2_)
            {
               _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc5_,ConsumableItem) as ConsumableItem;
               if(_loc3_ != null)
               {
                  if((_loc4_ == null || _loc3_.requiredLevel > _loc4_.requiredLevel) && _loc3_.requiredLevel <= ZGlobal.player.level)
                  {
                     _loc4_ = _loc3_;
                     _loc1_ = _loc4_.code;
                  }
               }
            }
         }
         return _loc1_;
      }
      
      override public function get consumableMessage() : String
      {
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc1_:String = AbstractConsumableSuggestionAlgorithm.NO_CONSUMABLE_SUGGESTABLE;
         if(this.m_fieldRepairMessage != null)
         {
            _loc2_ = this.m_fieldRepairMessage.split(",");
            if(_loc2_.length > 1)
            {
               _loc3_ = this.m_fieldRepairCode.split(",");
               _loc4_ = _loc3_.indexOf(this.consumableCode);
               if(_loc4_ >= _loc2_.length)
               {
                  throw Error("There is no consumable messages suggestion for: " + this.consumableCode);
               }
               _loc1_ = _loc2_[_loc4_];
            }
            else
            {
               _loc1_ = this.m_fieldRepairMessage;
            }
         }
         return _loc1_;
      }
      
      override public function calculateSuggestionWeight() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Array = null;
         var _loc3_:Array = null;
         m_weight = 0;
         if(ConsumableSuggesterUtils.getfleetDamagedUnitsQuantity(m_playerFleet) >= this.m_fieldRepairsMinimumPlayerFleetSize)
         {
            _loc1_ = ConsumableSuggesterUtils.getAverageStrengthLost(m_playerFleet,false);
            _loc2_ = m_consumableCode.split(",");
            _loc3_ = m_consumableMessage.split(",");
            if(ConsumableSuggesterUtils.getFleetCurrentStrength(m_playerFleet) / ConsumableSuggesterUtils.getFleetStartingStrength(m_playerFleet) > this.m_fieldRepairsForceOnFleetHealthThreshold)
            {
               m_forceIfSuggested = false;
            }
            else
            {
               m_forceIfSuggested = true;
            }
            if(_loc2_.length < 3)
            {
               throw Error("Field Repair codes length should be 3");
            }
            if(_loc1_ > this.m_fieldRepairsThresholdMin && _loc1_ < this.m_fieldRepairsThresholdTier1)
            {
               this.m_fieldRepairCode = _loc2_[2];
               this.m_fieldRepairMessage = _loc3_[2];
               this.computeWeight();
            }
            else if(_loc2_.length == 2 && _loc1_ < this.m_fieldRepairsThresholdTier2)
            {
               this.m_fieldRepairCode = _loc2_[1] + "," + _loc2_[2];
               this.m_fieldRepairMessage = _loc3_[1] + "," + _loc3_[2];
               this.computeWeight();
            }
            else if(_loc1_ > this.m_fieldRepairsThresholdTier3)
            {
               this.m_fieldRepairCode = m_consumableCode;
               this.m_fieldRepairMessage = m_consumableMessage;
               this.computeWeight();
            }
         }
      }
      
      private function computeWeight() : void
      {
         m_weight = ConsumableSuggesterUtils.calculateTotalWeight(this.m_suggestionPercent,this.m_suggestionWeight,this.m_revenuePercent,this.m_revenueWeight);
      }
      
      private function initVars() : void
      {
         cycleThroughAttributesAndSetMemberVars(ConsumableSuggestionManager.instance.getConsumableSuggestionDataXML(this.algorithmName));
      }
      
      override protected function setMemberVar(param1:String, param2:Object) : void
      {
         this[param1] = param2;
      }
   }
}

