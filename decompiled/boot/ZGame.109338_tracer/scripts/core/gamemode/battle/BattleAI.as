package core.gamemode.battle
{
   import core.ZGlobal;
   import core.gamemode.battle.combatchain.CombatChain;
   import core.gamemode.battle.combatchain.HitValue;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.Fleet;
   import core.managers.ExperimentsManager;
   import core.managers.WorldUpgradeManager;
   import utils.ZGameRandom;
   import zlabs.debug.Logger;
   import zlabs.utils.MathUtils;
   
   public class BattleAI
   {
      
      public static const STRENGTH_CURRENT:int = 0;
      
      public static const STRENGTH_MAX:int = 1;
      
      private var m_combatChain:CombatChain = null;
      
      private var m_defenders:Array = null;
      
      private var m_attackers:Array = null;
      
      private var m_switchRatio:Number = 0;
      
      private var m_switchPercent:Number = 0;
      
      private var m_glancingBlowMult:Number = 1;
      
      private var m_criticalHitMult:Number = 1;
      
      private var m_criticalHitPercent:Number = 1;
      
      private var m_AICanMiss:Boolean = false;
      
      private var m_AICanCritical:Boolean = false;
      
      private var m_allowMiss:Boolean = true;
      
      private var m_shouldFocusFire:Boolean = false;
      
      public function BattleAI(param1:Array, param2:Array)
      {
         super();
         this.m_combatChain = new CombatChain();
         this.m_defenders = param1;
         this.m_attackers = param2;
         this.m_switchRatio = ZGlobal.gameSettings.getNumber("combatAISwitchRatio",0.5);
         this.m_switchPercent = ZGlobal.gameSettings.getNumber("combatAISwitchPercent",0.2);
         this.m_glancingBlowMult = ZGlobal.gameSettings.getNumber("combatGlancingBlowMultiplier",1);
         this.m_criticalHitMult = ZGlobal.gameSettings.getNumber("combatCriticalHitMultiplier",1);
         this.m_criticalHitPercent = ZGlobal.gameSettings.getNumber("combatCriticalHitPercentage",1);
         this.m_AICanMiss = ZGlobal.gameSettings.getString("combatAICanMiss","false") == "true";
         this.m_AICanCritical = ZGlobal.player.level < 10 ? ZGlobal.gameSettings.getString("combatAICanCritical","false") == "true" : ExperimentsManager.instance.getExperimentVariant("empire_combataicancritical") == ExperimentsManager.COMBATAICANCRITICAL_VARIANT_ENABLED || ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_POWER_UP_PROMPT) == ExperimentsManager.VARIANT_VALUE_POWER_UP_PROMPT_DISABLED_WITH_CRITICAL_HIT || ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_POWER_UP_PROMPT) == ExperimentsManager.VARIANT_VALUE_POWER_UP_PROMPT_ENABLED_WITH_CRITICAL_HIT || ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_POWER_UP_PROMPT) == ExperimentsManager.VARIANT_VALUE_POWER_UP_PROMPT_ENABLED_WITH_CRITICAL_HIT_EVERY_OTHER_TURN;
         this.m_allowMiss = ZGlobal.gameSettings.getString("combatAllowMiss","true") == "true";
      }
      
      public function set attackers(param1:Array) : void
      {
         this.m_attackers = param1;
      }
      
      public function set shouldFocusFire(param1:Boolean) : void
      {
         this.m_shouldFocusFire = param1;
      }
      
      public function get glancingBlowMult() : Number
      {
         return this.m_glancingBlowMult;
      }
      
      public function get criticalHitMult() : Number
      {
         return this.m_criticalHitMult;
      }
      
      public function get criticalHitPercent() : Number
      {
         return this.m_criticalHitPercent;
      }
      
      public function get AICanMiss() : Boolean
      {
         return this.m_AICanMiss;
      }
      
      public function get AICanCritical() : Boolean
      {
         return this.m_AICanCritical;
      }
      
      public function get allowMiss() : Boolean
      {
         return this.m_allowMiss;
      }
      
      public function dispose() : void
      {
         this.m_combatChain.dispose();
         this.m_combatChain = null;
         this.m_defenders = null;
         this.m_attackers = null;
      }
      
      public function FindBestDefendingUnit() : Object
      {
         var _loc1_:Number = ZGameRandom.instance.float();
         var _loc2_:Object = this.FindBestDefendingUnitAgainstAttackers(_loc1_);
         if(this.m_shouldFocusFire && Boolean(_loc2_.defender))
         {
            return _loc2_;
         }
         var _loc3_:Object = this.FindBestDefendingUnitAgainstBestAttacker(_loc1_);
         var _loc4_:Number = 0;
         if(_loc2_.value > 0)
         {
            _loc4_ = _loc3_.value / _loc2_.value;
         }
         var _loc5_:Boolean = _loc4_ < this.m_switchRatio;
         var _loc6_:Number = ZGameRandom.instance.float();
         if(_loc6_ < this.m_switchPercent)
         {
            Logger.info(this,"FindBestDefendingUnit","Switching defender choice, m_switchPercent: " + this.m_switchPercent + " switchPercent: " + _loc6_ + ".");
            _loc5_ = !_loc5_;
         }
         if(_loc5_)
         {
            Logger.info(this,"FindBestDefendingUnit","Reverting to basic defender choice, : " + this.m_switchRatio + " ratio: " + _loc4_ + ".");
            return _loc2_;
         }
         return _loc3_;
      }
      
      public function FindBestAttacker() : Object
      {
         var _loc5_:BattleObject = null;
         var _loc6_:Object = null;
         var _loc1_:Number = 0;
         var _loc2_:Boolean = true;
         var _loc3_:Number = -1;
         var _loc4_:BattleObject = null;
         for each(_loc5_ in this.m_defenders)
         {
            if(!_loc5_.unit.dead)
            {
               _loc6_ = this.findBestUnit(this.m_attackers,_loc5_,_loc2_,_loc1_);
               if(_loc6_.value > _loc3_)
               {
                  _loc3_ = Number(_loc6_.value);
                  _loc4_ = _loc6_.obj;
               }
            }
         }
         return {
            "attacker":_loc4_,
            "value":_loc3_
         };
      }
      
      private function FindBestDefendingUnitAgainstBestAttacker(param1:Number) : Object
      {
         var _loc5_:BattleObject = null;
         var _loc6_:BattleObject = null;
         var _loc7_:Number = NaN;
         var _loc8_:Object = null;
         var _loc9_:Object = null;
         var _loc2_:Boolean = true;
         var _loc3_:Number = -1;
         var _loc4_:BattleObject = null;
         for each(_loc5_ in this.m_defenders)
         {
            if(!_loc5_.unit.dead)
            {
               _loc8_ = this.findBestUnit(this.m_attackers,_loc5_,_loc2_,param1);
               if(_loc8_.value > _loc3_)
               {
                  _loc3_ = Number(_loc8_.value);
                  _loc4_ = _loc8_.obj;
               }
            }
         }
         _loc6_ = null;
         _loc7_ = 0;
         if(null != _loc4_)
         {
            param1 = ZGameRandom.instance.float();
            _loc9_ = this.findBestUnit(this.m_defenders,_loc4_,_loc2_,param1);
            _loc6_ = _loc9_.obj;
            _loc7_ = Number(_loc9_.value);
         }
         return {
            "defender":_loc6_,
            "attacker":_loc4_,
            "value":_loc7_
         };
      }
      
      private function pickBestFocusFireAttacker(param1:Array) : BattleObject
      {
         var _loc2_:BattleObject = null;
         var _loc3_:BattleObject = null;
         for each(_loc3_ in param1)
         {
            if(!_loc2_ || _loc3_.unit.strength < _loc2_.unit.strength)
            {
               _loc2_ = _loc3_;
            }
         }
         if(_loc2_)
         {
            Logger.print(this,"victim " + _loc2_.unit.code + " found at id " + _loc2_.unit.id);
         }
         else
         {
            Logger.print(this,"no ff victim found");
         }
         return _loc2_;
      }
      
      private function FindBestDefendingUnitAgainstAttackers(param1:Number) : Object
      {
         var _loc6_:BattleObject = null;
         var _loc7_:BattleObject = null;
         var _loc8_:Object = null;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc2_:Array = null;
         var _loc3_:Boolean = true;
         var _loc4_:Number = -1;
         var _loc5_:BattleObject = null;
         for each(_loc6_ in this.m_attackers)
         {
            if(!_loc6_.unit.dead)
            {
               _loc8_ = this.findBestUnit(this.m_defenders,_loc6_,_loc3_,param1);
               if(_loc8_.value > _loc4_)
               {
                  _loc4_ = Number(_loc8_.value);
                  _loc5_ = _loc8_.obj;
                  _loc2_ = [_loc6_];
               }
               else if(_loc8_.value >= 0 && _loc8_.value == _loc4_)
               {
                  _loc2_.push(_loc6_);
               }
            }
         }
         _loc7_ = null;
         if(_loc2_)
         {
            if(this.m_shouldFocusFire)
            {
               _loc7_ = this.pickBestFocusFireAttacker(_loc2_);
            }
            if(!_loc7_)
            {
               _loc9_ = 0;
               _loc10_ = _loc2_.length;
               if(_loc10_ > 1)
               {
                  _loc11_ = ZGameRandom.instance.float();
                  _loc9_ = int(Math.round(_loc11_ * (_loc10_ - 1)));
               }
               _loc7_ = _loc2_[_loc9_];
            }
         }
         return {
            "defender":_loc5_,
            "attacker":_loc7_,
            "value":_loc4_
         };
      }
      
      private function firstGoodUnit(param1:Array) : BattleObject
      {
         var _loc2_:BattleObject = null;
         for each(_loc2_ in param1)
         {
            if(!_loc2_.unit.dead)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function pickBestFocusFireDefender(param1:Array) : BattleObject
      {
         var _loc2_:BattleObject = null;
         var _loc4_:BattleObject = null;
         var _loc3_:int = ZGlobal.gameSettings.getInt("combatAIFocusFireVictimMaxStrength",50);
         for each(_loc4_ in param1)
         {
            if(_loc4_.unit.strength < _loc3_)
            {
               if(!_loc2_ || _loc4_.unit.strength > _loc2_.unit.strength)
               {
                  _loc2_ = _loc4_;
               }
            }
         }
         if(_loc2_)
         {
            Logger.print(this,"FF picked " + _loc2_.unit.code + " at index " + _loc2_.unit.id);
         }
         else
         {
            Logger.print(this,"no best FF target, picking randomly");
         }
         return _loc2_;
      }
      
      private function findBestUnit(param1:Array, param2:BattleObject, param3:Boolean, param4:Number) : Object
      {
         var _loc7_:BattleObject = null;
         var _loc8_:BattleObject = null;
         var _loc9_:Number = NaN;
         var _loc10_:uint = 0;
         var _loc11_:int = 0;
         var _loc5_:Array = new Array();
         var _loc6_:int = -1;
         for each(_loc7_ in param1)
         {
            if(!_loc7_.unit.dead && !_loc7_.stunned)
            {
               _loc10_ = this.GetAttackingHitChance(_loc7_,param2);
               if(_loc10_ > _loc6_)
               {
                  _loc5_ = [_loc7_];
                  _loc6_ = int(_loc10_);
               }
               else if(_loc10_ >= 0 && _loc10_ == _loc6_)
               {
                  _loc5_.push(_loc7_);
               }
            }
         }
         _loc8_ = null;
         _loc9_ = _loc5_.length;
         if(_loc9_ > 0)
         {
            if(this.m_shouldFocusFire)
            {
               _loc8_ = this.pickBestFocusFireDefender(_loc5_);
            }
            if(!_loc8_)
            {
               _loc11_ = 0;
               if(_loc9_ > 1)
               {
                  _loc11_ = int(Math.round(param4 * (_loc9_ - 1)));
               }
               _loc8_ = _loc5_[_loc11_];
            }
         }
         return {
            "obj":_loc8_,
            "value":_loc6_
         };
      }
      
      public function GetAttackingHitChance(param1:BattleObject, param2:BattleObject) : uint
      {
         return this.m_combatChain.GetAttackingHitChance(param1,param2);
      }
      
      public function GetAttackingHitValue(param1:BattleObject, param2:BattleObject, param3:int, param4:Boolean) : HitValue
      {
         var _loc5_:HitValue = this.m_combatChain.GetAttackingHitValue(param1,param2);
         var _loc6_:Number = this.getHitPercentModifier(param1,param2);
         if(_loc6_ == 0)
         {
            return _loc5_;
         }
         return new HitValue(_loc5_.critical - _loc6_,_loc5_.direct - _loc6_);
      }
      
      private function getMostDamagedUnit(param1:Array) : BattleObject
      {
         var _loc4_:BattleObject = null;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc2_:BattleObject = null;
         var _loc3_:Number = 1;
         for each(_loc4_ in param1)
         {
            if(!_loc4_.unit.dead)
            {
               _loc5_ = _loc4_.unitItem.getStrength(_loc4_.fleet);
               _loc6_ = _loc4_.unit.strength / _loc5_;
               if(_loc6_ < _loc3_)
               {
                  _loc2_ = _loc4_;
                  _loc3_ = _loc6_;
               }
            }
         }
         return _loc2_;
      }
      
      private function getBestUnitForAttackingPower(param1:Array, param2:String) : BattleObject
      {
         var _loc3_:BattleObject = null;
         for each(_loc3_ in param1)
         {
            if(!_loc3_.unit.dead)
            {
               if(!_loc3_.fleet.affectedByConsumable(param2,_loc3_.unit.id))
               {
                  return _loc3_;
               }
            }
         }
         return null;
      }
      
      private function getBestUnitForFriendlyPower(param1:Array, param2:String) : BattleObject
      {
         var _loc5_:BattleObject = null;
         var _loc6_:int = 0;
         var _loc3_:BattleObject = null;
         var _loc4_:int = 0;
         for each(_loc5_ in param1)
         {
            if(!_loc5_.unit.dead)
            {
               if(!_loc5_.fleet.affectedByConsumable(param2,_loc5_.unit.id))
               {
                  _loc6_ = _loc5_.unit.strength;
                  if(_loc6_ > _loc4_)
                  {
                     _loc4_ = _loc6_;
                     _loc3_ = _loc5_;
                  }
               }
            }
         }
         return _loc3_;
      }
      
      public function SecondaryAbilityHueristicsTarget(param1:ConsumableItem) : BattleObject
      {
         var _loc2_:Number = ZGameRandom.instance.float();
         var _loc3_:Number = param1.castPercent;
         if(_loc2_ < _loc3_)
         {
            if(!param1.targetsEnemy)
            {
               if(param1.di < 0)
               {
                  return this.getMostDamagedUnit(this.m_defenders);
               }
               return this.getBestUnitForFriendlyPower(this.m_defenders,param1.code);
            }
            return this.getBestUnitForAttackingPower(this.m_attackers,param1.code);
         }
         return null;
      }
      
      private function getHitPercentModifier(param1:BattleObject, param2:BattleObject) : Number
      {
         var _loc3_:Number = WorldUpgradeManager.instance.getModifiedAccuracy(param1.fleet.getUpgrades(param1.unit.code),0);
         var _loc4_:Number = WorldUpgradeManager.instance.getModifiedDodge(param2.fleet.getUpgrades(param2.unit.code));
         _loc3_ -= _loc4_;
         var _loc5_:Fleet = param1.fleet;
         var _loc6_:Fleet = param2.fleet;
         var _loc7_:Number = _loc5_.getToHitModifier(_loc6_,param2.unit.id,param1.unit.id);
         if(_loc7_ != 0)
         {
            _loc7_ *= 0.01;
            _loc3_ += _loc7_;
         }
         if(null != _loc5_.hitPercentageRecorder)
         {
            _loc7_ = _loc5_.hitPercentageRecorder.getModifier(param1.unit.id,param2.unit.id);
            if(_loc7_ != 0)
            {
               Logger.info(this,"GetAttackingHitPercentage","attacker " + param1.fleet.name + "," + param1.unit.id + " gets a " + _loc7_ + "% hit bonus from missing");
               _loc7_ *= 0.01;
               _loc3_ += _loc7_;
            }
         }
         return MathUtils.roundTo(_loc3_,ZGameRandom.ACCURACY);
      }
      
      private function GetDamageBase(param1:BattleObject, param2:BattleObject) : Number
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:Number = ZGlobal.gameSettings.getCombatDamageBase(25);
         var _loc4_:int = param1.unitItem.tier - param2.unitItem.tier;
         if(_loc4_ != 0)
         {
            _loc5_ = ZGlobal.gameSettings.getCombatDamageTierIncrement(0);
            _loc3_ += _loc4_ * _loc5_;
            _loc6_ = ZGlobal.gameSettings.getCombatDamageBaseMin(25);
            _loc3_ = Math.max(_loc6_,_loc3_);
         }
         return _loc3_;
      }
      
      public function GetAttackingDamage(param1:BattleObject, param2:BattleObject) : Object
      {
         var _loc3_:Number = this.GetAttackingStrengthAgainst(param1,param2,STRENGTH_MAX);
         var _loc4_:Number = this.GetAttackingStrengthAgainst(param2,param1,STRENGTH_CURRENT);
         var _loc5_:Number = this.GetDamageBase(param1,param2);
         var _loc6_:Number = _loc5_ * (3 * _loc3_ + _loc4_) / (3 * _loc4_ + _loc3_);
         var _loc7_:Number = param2.unitItem.getAttackStrength(param2.fleet);
         _loc6_ = _loc6_ / 100 * _loc7_;
         var _loc8_:Fleet = param1.fleet;
         var _loc9_:Fleet = param2.fleet;
         var _loc10_:Number = _loc8_.getDamageModifier(_loc9_,param2.unit.id,param1.unit.id);
         if(_loc10_ != 0)
         {
            _loc6_ = Math.max(_loc6_ + _loc10_,0);
         }
         var _loc11_:Number = _loc6_;
         _loc6_ = WorldUpgradeManager.instance.getModifiedDamage(param1.fleet.getUpgrades(param1.unit.code),_loc6_);
         var _loc12_:Number = _loc6_ - _loc11_;
         return {
            "damage":MathUtils.roundTo(_loc6_,ZGameRandom.ACCURACY),
            "upgradeDamage":MathUtils.roundTo(_loc12_,ZGameRandom.ACCURACY)
         };
      }
      
      public function GetAttackingDamageFromAbsoluteValue(param1:Number, param2:BattleObject) : int
      {
         var _loc3_:Number = param1;
         var _loc4_:Number = this.GetAttackingStrengthAgainstFromAbsoluteValue(param2);
         var _loc5_:Number = ZGlobal.gameSettings.getCombatDamageBase(25);
         var _loc6_:Number = _loc5_ * (3 * _loc3_ + _loc4_) / (3 * _loc4_ + _loc3_);
         return int(Math.ceil(MathUtils.roundTo(_loc6_,ZGameRandom.ACCURACY)));
      }
      
      public function GetAttackingStrengthAgainst(param1:BattleObject, param2:BattleObject, param3:int) : Number
      {
         var _loc4_:Number = 0;
         var _loc5_:Number = 0;
         if(param3 == STRENGTH_CURRENT)
         {
            _loc5_ = param1.unit.strength;
         }
         else
         {
            if(param3 != STRENGTH_MAX)
            {
               throw new Error("GetAttackingStrengthAgainst unknown strength type ");
            }
            _loc5_ = param1.unitItem.getAttackStrength(param1.fleet);
         }
         _loc4_ = param1.fleet.getStrengthModifier(param1.unit.id);
         if(_loc4_ != 0)
         {
            _loc5_ = Math.max(0,_loc5_ + _loc4_);
         }
         if(param2.unitItem.weaker)
         {
            _loc5_ = 10000;
         }
         else if(param1.unitItem.weaker)
         {
            _loc5_ = 0;
         }
         return MathUtils.roundTo(_loc5_,ZGameRandom.ACCURACY);
      }
      
      public function GetAttackingStrengthAgainstFromAbsoluteValue(param1:BattleObject) : Number
      {
         var _loc2_:Number = param1.unit.strength;
         return MathUtils.roundTo(_loc2_,ZGameRandom.ACCURACY);
      }
   }
}

