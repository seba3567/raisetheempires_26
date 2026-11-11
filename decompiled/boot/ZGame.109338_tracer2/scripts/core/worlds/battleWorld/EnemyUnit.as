package core.worlds.battleWorld
{
   import core.ZGlobal;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.Fleet;
   import core.gameobjects.GameItem;
   import core.managers.ExperimentsManager;
   import core.managers.ScrapManager;
   import core.managers.WhiteUnitManager;
   import core.managers.ZRTManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.dooberManager.DooberManager;
   import core.managers.rewardPickupManager.RewardPickup;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import sound.SoundEvent;
   import utils.ZGameRandom;
   import zlabs.events.WorldEvent;
   
   public class EnemyUnit extends BattleUnit
   {
      
      private static const EXPERIMENT_SUPPORT_UNITS_DOOBER_DROP:String = "empires_support_units_doober_drop";
      
      protected var m_battleCompleteData:Object = null;
      
      public function EnemyUnit(param1:int, param2:BattleObject)
      {
         super(param1,param2);
      }
      
      override public function init(param1:Sprite, param2:BattleObject, param3:int, param4:int) : void
      {
         super.init(param1,param2,param3,param4);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_WAITING_FOR_ENEMY_CLICK,this.onWaitForEnemyClick);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onBattleComplete);
      }
      
      public function onBattleComplete(param1:WorldEvent) : void
      {
         this.m_battleCompleteData = param1.eventData;
      }
      
      override public function dispose(param1:Sprite) : void
      {
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_WAITING_FOR_ENEMY_CLICK,this.onWaitForEnemyClick);
         super.dispose(param1);
      }
      
      override public function die(param1:BattleObject, param2:BattleObject, param3:Object) : void
      {
         super.die(param1,param2,param3);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_WAITING_FOR_ENEMY_CLICK,this.onWaitForEnemyClick);
      }
      
      override protected function onMouseClick(param1:MouseEvent) : void
      {
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.ENEMY_UNIT_CLICKED,battleObject));
         super.onMouseClick(param1);
      }
      
      override protected function onMouseOver(param1:MouseEvent) : void
      {
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.ENEMY_UNIT_HIGHLIGHTED,battleObject));
         super.onMouseOver(param1);
      }
      
      override protected function doMouseOut() : void
      {
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.ENEMY_UNIT_HIGHLIGHTED,null));
         super.doMouseOut();
      }
      
      private function onWaitForEnemyClick(param1:WorldEvent) : void
      {
         if(param1.eventData == true)
         {
            addMouseEvents();
         }
         else
         {
            removeMouseEvents(true);
         }
      }
      
      override protected function get hoverColor() : int
      {
         return 16724787;
      }
      
      override protected function get colorIndex() : int
      {
         return PLAYER;
      }
      
      override protected function dispatchHighlightedEvent() : void
      {
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_SET_ENEMY_HIGHLIGHTED_UNIT,battleObject));
      }
      
      override protected function playDamageXPReward(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:BattleObject = null;
         var _loc8_:int = 0;
         var _loc9_:BattleObject = null;
         var _loc10_:int = 0;
         var _loc11_:XML = null;
         var _loc12_:int = 0;
         var _loc13_:Number = NaN;
         var _loc14_:Array = null;
         var _loc15_:GameItem = null;
         var _loc16_:Object = null;
         var _loc17_:int = 0;
         var _loc18_:XML = null;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:Number = NaN;
         var _loc22_:int = 0;
         if(param1.damage)
         {
            _loc2_ = {
               "flags":RewardPickup.FLAG_LEFT_ONLY,
               "delay":250,
               "x":x,
               "y":y,
               "energyAmount":1
            };
            _loc3_ = battleObject.unitItem.getAttackStrength(battleObject.fleet);
            _loc4_ = "";
            _loc5_ = 0;
            if(param1.glancing)
            {
               _loc4_ = battleObject.unit.dead ? "kill" : "glancinghit";
            }
            else if(param1.critical)
            {
               SoundEvent.getSoundEvent("CriticalHit").play();
               _loc2_.flags |= RewardPickup.FLAG_HIGH_BOUNCE;
               _loc2_.coinAmount = getCoinAmount(_loc3_,param1.damage);
               _loc2_.rareType = getRareType(param1.attackerStrength);
               _loc2_.rareAmount = getRareAmount(_loc3_,param1.damage);
               if(this.allowManaLootDrops())
               {
                  _loc5_ = 1;
               }
               if(battleObject.unit.dead)
               {
                  _loc4_ = "criticalkill";
                  _loc2_.numCoinLoot = 3;
                  _loc2_.numRareLoot = 3;
                  _loc2_.delay = 50;
               }
               else
               {
                  _loc4_ = "criticalhit";
                  _loc2_.numCoinLoot = 1;
                  _loc2_.numRareLoot = 1;
               }
            }
            else if(param1.hit)
            {
               _loc2_.numCoinLoot = 1;
               _loc2_.coinAmount = getCoinAmount(_loc3_,param1.damage);
               _loc4_ = battleObject.unit.dead ? "kill" : "directhit";
            }
            _loc6_ = 1;
            _loc7_ = param1.attacker as BattleObject;
            _loc8_ = _loc7_ ? _loc7_.unitItem.tier : 99;
            _loc9_ = param1.target as BattleObject;
            _loc10_ = _loc9_ ? _loc9_.unitItem.tier : 1;
            _loc12_ = 0;
            while(_loc12_ < ZGlobal.gameSettings.getXML().dooberCombatTable.playerTier.length())
            {
               _loc11_ = ZGlobal.gameSettings.getXML().dooberCombatTable.playerTier[_loc12_];
               if(_loc11_.@value == _loc8_)
               {
                  break;
               }
               _loc12_++;
            }
            if(_loc11_)
            {
               _loc12_ = 0;
               while(_loc12_ < _loc11_.enemyTier.length())
               {
                  _loc18_ = _loc11_.enemyTier[_loc12_];
                  if(_loc18_.@value == _loc10_)
                  {
                     break;
                  }
                  _loc12_++;
               }
               if(_loc18_)
               {
                  _loc6_ = parseFloat(_loc18_.@percent);
               }
            }
            _loc13_ = ZGameRandom.rewardInstance.float();
            _loc14_ = DooberManager.instance.getRandomRewards(_loc13_,DooberManager.COMBAT_ACTION_TYPE,"default",_loc6_);
            _loc14_ = new Array();
            this.addFixedRewards(_loc14_,battleObject.unit.dead);
            _loc2_.itemLoot = new Array();
            _loc2_.numItemLoot = 0;
            _loc2_.scrap = 0;
            for each(_loc16_ in _loc14_)
            {
               _loc15_ = ZGlobal.gameSettings.getItemByCode(_loc16_.item,GameItem) as GameItem;
               _loc2_.itemLoot.push(_loc16_.item);
               ++_loc2_.numItemLoot;
            }
            if(_loc5_ > 0)
            {
               _loc5_ = this.getManaLootDrop(_loc5_);
               if(_loc5_ > 0)
               {
                  _loc2_.numManaLoot = _loc5_;
                  _loc2_.manaAmount = _loc5_;
               }
            }
            if(battleObject.unit.dead)
            {
               if(ScrapManager.instance.scrapEnabled)
               {
                  _loc13_ = Math.ceil(ZGameRandom.scrapInstance.randBetween(0,100));
                  if(_loc13_ <= ScrapManager.instance.scrapProb)
                  {
                     _loc2_.scrap = 1;
                  }
               }
            }
            _loc17_ = 1;
            if(param1.attacker != null)
            {
               if(param1.attacker.unitItem.isBlueDevil == true)
               {
                  _loc17_ = ZGlobal.gameSettings.getInt("bluedevilXPMultiplier",1);
               }
            }
            if(ExperimentsManager.instance.getExperimentVariant("empire_combat_double_xp") > 1 && ZRTManager.instance.isZRTOn(ZGlobal.player.COMBAT_DOUBLE_XP))
            {
               _loc19_ = 0;
               _loc19_ = ZGlobal.player.combatSpecialBits;
               _loc20_ = _loc19_ & Fleet.DOUBLE_XP;
               if(_loc20_)
               {
                  _loc17_ = 2 * _loc17_;
               }
            }
            addRewards(_loc4_,_loc2_,_loc17_);
            if(param1.attacker != null)
            {
               if(WhiteUnitManager.instance.whiteUnitsEnabled)
               {
                  if(param1.attacker.unitItem.isWhiteUnit == true && !param1.critical)
                  {
                     _loc21_ = Math.ceil(ZGameRandom.rewardInstance.randBetween(0,100));
                     if(_loc21_ <= WhiteUnitManager.instance.whiteUnitProbabilityVariant)
                     {
                        _loc22_ = 1;
                        if(_loc2_.numEnergyLoot != null)
                        {
                           _loc2_.numEnergyLoot += _loc22_;
                        }
                        else
                        {
                           _loc2_.numEnergyLoot = _loc22_;
                        }
                     }
                  }
               }
            }
            spawnLoot(_loc2_,true);
            super.playDamageXPReward(param1);
         }
      }
      
      private function addFixedRewards(param1:Array, param2:Boolean) : void
      {
         if(param2 && this.m_battleCompleteData != null)
         {
            if(DooberManager.instance.isMysterDooberResultsSet && (ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_DOMINATION_WARCHEST) == ExperimentsManager.EXPERIMENT_DOMINATION_WARCHEST_ENABLED && DominationModeManager.instance.isInDominationBattle()))
            {
               param1.push({
                  "item":DooberManager.MYSTERY_DOOBER_ITEM,
                  "count":1
               });
            }
         }
      }
      
      private function allowManaLootDrops() : Boolean
      {
         var _loc1_:int = 0;
         if(ExperimentsManager.instance.getExperimentVariant(ZGlobal.EXPERIMENT_SUPPORT_UNITS) >= ZGlobal.EXPERIMENT_SUPPORT_UNITS_ACTIVE)
         {
            _loc1_ = ZGlobal.gameSettings.getInt("manaStartingLevel");
            if(ZGlobal.player.level >= _loc1_)
            {
               return true;
            }
         }
         return false;
      }
      
      private function getManaLootDrop(param1:int) : int
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(ZGlobal.player.mana.allowGive(param1))
         {
            _loc2_ = ExperimentsManager.instance.getExperimentValue(EXPERIMENT_SUPPORT_UNITS_DOOBER_DROP,ZGlobal.gameSettings.getManaExperimentValues("exp_su_mana_doober"),0);
            if(_loc2_ > 0)
            {
               _loc2_ *= 0.01;
               _loc3_ = ZGameRandom.rewardInstance.float();
               if(_loc3_ < _loc2_)
               {
                  return 1;
               }
            }
         }
         return 0;
      }
   }
}

