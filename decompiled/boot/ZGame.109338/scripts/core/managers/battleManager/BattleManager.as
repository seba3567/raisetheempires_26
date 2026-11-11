package core.managers.battleManager
{
   import core.ZGlobal;
   import core.gameobjects.ConsumableItem;
   import core.managers.ExperimentsManager;
   
   public class BattleManager
   {
      
      public static var instance:BattleManager = new BattleManager();
      
      private static const EXPERIMENT_COMBAT_UNIT_HEAL_CONTROL:uint = 0;
      
      private static const EXPERIMENT_COMBAT_UNIT_HEAL_VARIANT_1:uint = 1;
      
      private static const EXPERIMENT_COMBAT_UNIT_HEAL_VARIANT_2:uint = 2;
      
      private static const EXPERIMENT_COMBAT_UNIT_HEAL_VARIANT_3:uint = 3;
      
      private static const EXPERIMENT_COMBAT_UNIT_HEAL_VARIANT_4:uint = 4;
      
      private const EXPERIMENT_COMBAT_UNIT_HEAL_TURN_CONTROL:int = 0;
      
      private const EXPERIMENT_COMBAT_UNIT_HEAL_TURN_VARIANT_1:int = 1;
      
      private const EXPERIMENT_COMBAT_UNIT_HEAL_TURN_VARIANT_2:int = 2;
      
      public function BattleManager()
      {
         super();
      }
      
      public function get powerUseRequiresTurn() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_COMBAT_UNIT_HEAL_TURN);
         return _loc1_ != this.EXPERIMENT_COMBAT_UNIT_HEAL_TURN_VARIANT_2;
      }
      
      public function get unitCombatHealLoseTurnVariant() : int
      {
         return ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_COMBAT_UNIT_HEAL);
      }
      
      public function get unitCombatHealKeepTurnVariant() : int
      {
         return ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_COMBAT_UNIT_HEAL_KEEPTURN);
      }
      
      public function get powerButtonHealPercent() : Number
      {
         var _loc1_:int = 0;
         if(BattleManager.instance.powerUseRequiresTurn)
         {
            _loc1_ = this.unitCombatHealLoseTurnVariant;
            if(_loc1_ == BattleManager.EXPERIMENT_COMBAT_UNIT_HEAL_VARIANT_3 || _loc1_ == BattleManager.EXPERIMENT_COMBAT_UNIT_HEAL_VARIANT_4)
            {
               return 0.9999;
            }
            return ZGlobal.gameSettings.getNumber("combatPowerButtonHealthPercent",0);
         }
         return 0.9999;
      }
      
      private function get powerItemCode() : String
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         if(BattleManager.instance.powerUseRequiresTurn)
         {
            _loc1_ = this.unitCombatHealLoseTurnVariant;
            if(_loc1_ == EXPERIMENT_COMBAT_UNIT_HEAL_VARIANT_2 || _loc1_ == EXPERIMENT_COMBAT_UNIT_HEAL_VARIANT_3)
            {
               return "N41";
            }
            return "N40";
         }
         _loc2_ = this.unitCombatHealKeepTurnVariant;
         _loc3_ = ZGlobal.gameSettings.getString("combatPowerButtonKeepTurnItems","");
         _loc4_ = _loc3_.split(",");
         if(_loc2_ < _loc4_.length)
         {
            return _loc4_[_loc2_];
         }
         return "N40";
      }
      
      public function get powerItem() : ConsumableItem
      {
         var _loc1_:String = this.powerItemCode;
         if(_loc1_)
         {
            return ZGlobal.gameSettings.getItemByCode(_loc1_,ConsumableItem) as ConsumableItem;
         }
         return null;
      }
      
      public function reviveUnitMultiplier() : Number
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_COMBAT_REVIVE_UNIT);
         switch(_loc1_)
         {
            case 3:
               return 1;
            case 4:
               return 1.2;
            case 5:
               return 1.5;
            default:
               return 100;
         }
      }
   }
}

