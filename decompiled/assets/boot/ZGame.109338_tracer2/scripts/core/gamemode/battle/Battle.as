package core.gamemode.battle
{
   import core.ZGlobal;
   import core.gamemode.battle.consumable.BattleAllyConsumable;
   import core.gamemode.battle.consumable.BattleConsumable;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.Fleet;
   import core.gameobjects.Unit;
   import core.gameobjects.UnitItem;
   import core.managers.DebugManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.views.ViewManager;
   import core.worlds.battleWorld.BattleRendererComponent;
   import core.worlds.battleWorld.BattleUnit;
   import core.worlds.battleWorld.BattleWorld;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class Battle
   {
      
      public static const UNIT_DESTROYED:String = "unitdestroyed";
      
      public static const BATTLE_RESULT_NONE:int = 0;
      
      public static const BATTLE_RESULT_WON:int = 1;
      
      public static const BATTLE_RESULT_LOST:int = 2;
      
      public static const BATTLE_RESULT_RETREAT:int = 3;
      
      public static const BATTLE_RESULT_CANCEL:int = 4;
      
      public static var BATTLE_STATE_NONE:int = 0;
      
      public static var BATTLE_STATE_SETUP:int = 1;
      
      public static var BATTLE_STATE_ACTIVE:int = 2;
      
      protected var m_playerGroup:Array = null;
      
      protected var m_enemyGroup:Array = null;
      
      protected var m_stateMachine:Array = null;
      
      protected var m_statePointer:int = 0;
      
      protected var m_continue:Boolean = false;
      
      protected var m_playerUnit:BattleObject = null;
      
      protected var m_enemyUnit:BattleObject = null;
      
      protected var m_playerStats:Object = null;
      
      protected var m_enemyStats:Object = null;
      
      protected var m_firstUnit:BattleSequenceObject = null;
      
      protected var m_secondUnit:BattleSequenceObject = null;
      
      protected var m_ai:BattleAI = null;
      
      protected var m_battleUI:BattleUI = null;
      
      protected var m_blocked:Boolean = false;
      
      protected var m_aiAttack:Boolean = false;
      
      protected var m_skippedPlayerStart:Boolean = false;
      
      protected var m_targetObject:BattleObject = null;
      
      protected var m_currentConsumable:ConsumableItem = null;
      
      protected var m_battleConsumable:BattleConsumable = null;
      
      protected var m_playerFleetName:String = null;
      
      protected var m_enemyFleetName:String = null;
      
      protected var m_sequenceFleetName:String = null;
      
      private var m_combatActive:Boolean = false;
      
      protected var m_stateDictionary:Dictionary = new Dictionary();
      
      public function Battle()
      {
         super();
         this.initStateDictionary();
      }
      
      public function get isQuest() : Boolean
      {
         return false;
      }
      
      public function get isChallenge() : Boolean
      {
         return false;
      }
      
      public function get isGlobalPVP() : Boolean
      {
         return false;
      }
      
      public function get isQuestTreeBattle() : Boolean
      {
         return false;
      }
      
      public function get getQuestId() : String
      {
         return "";
      }
      
      public function get isQuestSurvival() : Boolean
      {
         return false;
      }
      
      public function get isSurvivalMode() : Boolean
      {
         return false;
      }
      
      public function get isMechLab() : Boolean
      {
         return false;
      }
      
      public function get isDefenseForceEditMode() : Boolean
      {
         return false;
      }
      
      public function get isDominationMode() : Boolean
      {
         return false;
      }
      
      public function get isDeathMatchBattle() : Boolean
      {
         return false;
      }
      
      public function playerUnitTally(param1:Boolean = false) : Object
      {
         var _loc3_:BattleObject = null;
         var _loc2_:Object = new Object();
         var _loc4_:int = 0;
         while(_loc4_ < this.m_playerGroup.length)
         {
            _loc3_ = this.m_playerGroup[_loc4_];
            if(!_loc2_.hasOwnProperty(_loc3_.unit.code))
            {
               _loc2_[_loc3_.unit.code] = 0;
            }
            if(param1 || !_loc3_.unit.dead)
            {
               ++_loc2_[_loc3_.unit.code];
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function get playerGroup() : Array
      {
         return this.m_playerGroup;
      }
      
      public function get playerFleet() : Fleet
      {
         var _loc1_:BattleObject = null;
         if(this.m_playerGroup)
         {
            for each(_loc1_ in this.m_playerGroup)
            {
               if(_loc1_.fleet)
               {
                  return _loc1_.fleet;
               }
            }
         }
         return null;
      }
      
      public function rematch() : void
      {
      }
      
      public function showWonPopup(param1:Array, param2:Array, param3:Dictionary, param4:Function) : void
      {
      }
      
      public function showLosePopup(param1:Array, param2:Dictionary, param3:Function) : void
      {
      }
      
      protected function initStateDictionary() : void
      {
         this.stateDictionary[this.state_StartAttack] = {"name":"state_StartAttack"};
         this.stateDictionary[this.state_Resolve] = {"name":"state_Resolve"};
         this.stateDictionary[this.state_FirstAttack] = {"name":"state_FirstAttack"};
         this.stateDictionary[this.state_FirstResult] = {"name":"state_FirstResult"};
         this.stateDictionary[this.state_SecondAttack] = {"name":"state_SecondAttack"};
         this.stateDictionary[this.state_SecondResult] = {"name":"state_SecondResult"};
         this.stateDictionary[this.state_StartFleetConsumables] = {"name":"state_StartFleetConsumables"};
         this.stateDictionary[this.state_UpdateFleetConsumables] = {"name":"state_UpdateFleetConsumables"};
         this.stateDictionary[this.state_CheckResults] = {"name":"state_CheckResults"};
      }
      
      protected function get stateDictionary() : Dictionary
      {
         return this.m_stateDictionary;
      }
      
      protected function initSetup() : void
      {
         var _loc1_:Fleet = null;
         var _loc2_:Fleet = null;
         this.setupStateMachine();
         _loc1_ = ZGlobal.hostPlayer.fleets.getFleetByName(this.m_playerFleetName);
         if(_loc1_)
         {
            _loc1_.setStatus(Fleet.IN_COMBAT);
            _loc1_.setStatus(Fleet.IS_ATTACKING);
         }
         _loc2_ = ZGlobal.hostPlayer.fleets.getFleetByName(this.m_enemyFleetName);
         if(_loc2_)
         {
            _loc2_.setStatus(Fleet.IN_COMBAT);
            _loc2_.clearStatus(Fleet.IS_ATTACKING);
         }
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_CONTINUE_FROM_CONSUMABLE,this.onContinueFromConsumable);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_DAMAGE_FROM_CONSUMABLE,this.onUnitDamageFromConsumable);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_CANCEL_CONSUMABLE,this.onCancelConsumable);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_START,this.onStartBattle);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.REVIVE_UNITS,this.addRevivedUnitsToPlayerGroup);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.REREGISTER_TITAN_PARTS,this.reregisterTitanParts);
      }
      
      public function dispose() : void
      {
         this.m_playerFleetName = null;
         this.m_enemyFleetName = null;
         this.m_firstUnit = null;
         this.m_secondUnit = null;
         this.m_playerUnit = null;
         this.m_enemyUnit = null;
         this.m_playerStats = null;
         this.m_enemyStats = null;
         this.m_stateMachine = null;
         Zlab.processManager.removeScheduledObject(this);
         this.m_battleUI.dispose();
         this.m_battleUI = null;
         this.m_ai.dispose();
         this.m_ai = null;
         this.disposeGroup(this.m_playerGroup);
         this.m_playerGroup = null;
         this.disposeGroup(this.m_enemyGroup);
         this.m_enemyGroup = null;
         this.m_targetObject = null;
         this.m_currentConsumable = null;
         this.disposeBattleConsumable();
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_CONTINUE_FROM_CONSUMABLE,this.onContinueFromConsumable);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.UNIT_DAMAGE_FROM_CONSUMABLE,this.onUnitDamageFromConsumable);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_CANCEL_CONSUMABLE,this.onCancelConsumable);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_START,this.onStartBattle);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.REVIVE_UNITS,this.addRevivedUnitsToPlayerGroup);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.REVIVE_UNITS,this.reregisterTitanParts);
      }
      
      protected function setupStateMachine() : void
      {
      }
      
      protected function addDefaultBattleResolveStates(param1:Boolean) : void
      {
         this.m_stateMachine.push({"state":this.state_StartAttack});
         this.m_stateMachine.push({"state":this.state_Resolve});
         this.m_stateMachine.push({"state":this.state_FirstAttack});
         this.m_stateMachine.push({"state":this.state_FirstResult});
         this.m_stateMachine.push({"state":this.state_SecondAttack});
         this.m_stateMachine.push({"state":this.state_SecondResult});
         this.m_stateMachine.push({"state":this.state_StartFleetConsumables});
         this.m_stateMachine.push({"state":this.state_UpdateFleetConsumables});
         this.m_stateMachine.push({"state":this.state_CheckResults});
      }
      
      protected function state_StartAttack() : Boolean
      {
         this.m_blocked = true;
         this.m_combatActive = true;
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_OBJECT_SELECTED,null));
         return true;
      }
      
      protected function state_Resolve() : Boolean
      {
         return true;
      }
      
      protected function state_FirstAttack() : Boolean
      {
         this.playMuzzleFlashFX(this.m_firstUnit.attacker,this.m_firstUnit.defender,0);
         var _loc1_:Number = ZGlobal.gameSettings.getSeconds("combatFirstAttackPostDelay",1);
         Zlab.processManager.schedule(_loc1_ * 1000,this,this.continueAction);
         return false;
      }
      
      protected function state_FirstResult() : Boolean
      {
         var _loc2_:Boolean = false;
         if(this.m_firstUnit.attacker == this.m_playerUnit)
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_RESULT,this.m_firstUnit.attackerStats));
         }
         if(this.m_firstUnit.attackerStats.hit)
         {
            _loc2_ = this.m_firstUnit.attackerStats.commandoAssaultBonus ? Boolean(this.m_firstUnit.attackerStats.commandoAssaultBonus) : false;
            this.playHitFX(this.m_firstUnit.attacker,this.m_firstUnit.defender,this.m_firstUnit.attackerStats.damage,this.m_firstUnit.attackerStats.upgradeDamage,this.m_firstUnit.attackerStats.glancing,this.m_firstUnit.attackerStats.critical,_loc2_);
            if(this.m_firstUnit.defender.unit.dead)
            {
               this.killUnit(this.m_firstUnit.attacker,this.m_firstUnit.defender,null,this.m_firstUnit.attacker == this.m_playerUnit);
            }
         }
         else
         {
            this.playMissFX(this.m_firstUnit.attacker,this.m_firstUnit.defender,0);
         }
         var _loc1_:Number = ZGlobal.gameSettings.getSeconds("combatFirstSequencePostDelay",1);
         Zlab.processManager.schedule(_loc1_ * 1000,this,this.continueAction);
         return false;
      }
      
      protected function state_SecondAttack() : Boolean
      {
         var _loc1_:Number = NaN;
         if(!this.m_secondUnit.attacker.canCounter)
         {
            return true;
         }
         this.playMuzzleFlashFX(this.m_secondUnit.attacker,this.m_secondUnit.defender,0);
         _loc1_ = ZGlobal.gameSettings.getSeconds("combatSecondAttackPostDelay",1);
         Zlab.processManager.schedule(_loc1_ * 1000,this,this.continueAction);
         return false;
      }
      
      protected function state_SecondResult() : Boolean
      {
         var _loc1_:Number = NaN;
         var _loc2_:Boolean = false;
         if(!this.m_secondUnit.attacker.canCounter)
         {
            return true;
         }
         if(this.m_secondUnit.attacker == this.m_playerUnit)
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_RESULT,this.m_secondUnit.attackerStats));
         }
         if(this.m_secondUnit.attackerStats.hit)
         {
            _loc2_ = this.m_secondUnit.attackerStats.commandoAssaultBonus ? Boolean(this.m_secondUnit.attackerStats.commandoAssaultBonus) : false;
            this.playHitFX(this.m_secondUnit.attacker,this.m_secondUnit.defender,this.m_secondUnit.attackerStats.damage,this.m_secondUnit.attackerStats.upgradeDamage,this.m_secondUnit.attackerStats.glancing,this.m_secondUnit.attackerStats.critical,_loc2_);
            if(this.m_secondUnit.defender.unit.dead)
            {
               this.killUnit(this.m_secondUnit.attacker,this.m_secondUnit.defender,null,this.m_secondUnit.attacker == this.m_playerUnit);
            }
         }
         else
         {
            this.playMissFX(this.m_secondUnit.attacker,this.m_secondUnit.defender,0);
         }
         _loc1_ = ZGlobal.gameSettings.getSeconds("combatSecondSequencePostDelay",1);
         Zlab.processManager.schedule(_loc1_ * 1000,this,this.continueAction);
         return false;
      }
      
      protected function state_CheckResults() : Boolean
      {
         this.m_firstUnit = null;
         this.m_secondUnit = null;
         this.m_playerUnit = null;
         this.m_enemyUnit = null;
         this.m_combatActive = false;
         TutorialManager.instance.dispatchEvent(new Event(TutorialManager.COMBAT_SEQUENCE_CONTINUE));
         BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_PAIR_COMPLETE));
         return true;
      }
      
      protected function state_UpdateConsumable() : Boolean
      {
         if(null == this.m_currentConsumable)
         {
            return true;
         }
         return false;
      }
      
      private function targetFleetName() : String
      {
         if(this.m_sequenceFleetName == this.m_playerFleetName)
         {
            return this.m_playerFleetName;
         }
         return this.m_enemyFleetName;
      }
      
      private function targetGroup() : Array
      {
         if(this.m_sequenceFleetName == this.m_playerFleetName)
         {
            return this.m_playerGroup;
         }
         return this.m_enemyGroup;
      }
      
      protected function state_StartFleetConsumables() : Boolean
      {
         var _loc1_:String = this.targetFleetName();
         var _loc2_:Fleet = Fleet.getFleet(_loc1_);
         if(null != _loc2_)
         {
            _loc2_.startConsumables();
         }
         return true;
      }
      
      protected function state_UpdateFleetConsumables() : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc1_:String = this.targetFleetName();
         var _loc2_:Fleet = Fleet.getFleet(_loc1_);
         if(null != _loc2_)
         {
            _loc3_ = _loc2_.triggerDOTConsumables(this.targetGroup(),_loc1_ == this.m_enemyFleetName ? this.m_playerUnit : this.m_enemyUnit);
            if(_loc3_ > 0)
            {
               this.m_blocked = true;
               Zlab.processManager.schedule(_loc3_ * 1000,this,this.repeatAction);
               return false;
            }
         }
         return true;
      }
      
      protected function set currentConsumable(param1:ConsumableItem) : void
      {
         var _loc2_:Boolean = false;
         this.m_currentConsumable = param1;
         if(null != param1)
         {
            _loc2_ = this.m_sequenceFleetName == this.m_playerFleetName;
            this.m_battleConsumable = new BattleConsumable(param1,_loc2_ ? this.m_playerUnit : this.m_enemyUnit,_loc2_);
         }
      }
      
      protected function setAllyConsumable(param1:ConsumableItem, param2:Array) : void
      {
         var _loc3_:Boolean = false;
         this.m_currentConsumable = param1;
         if(null != param1)
         {
            _loc3_ = this.m_sequenceFleetName == this.m_playerFleetName;
            this.m_battleConsumable = new BattleAllyConsumable(param1,_loc3_ ? this.m_playerUnit : this.m_enemyUnit,_loc3_,param2);
         }
      }
      
      public function get returnToPreviousView() : Boolean
      {
         return true;
      }
      
      public function get showWinLosePopup() : Boolean
      {
         return true;
      }
      
      protected function onStartBattle(param1:Event) : void
      {
         if(this.enemyFleetDead())
         {
            this.jumpTo(this.state_CheckResults);
            this.processStates();
         }
         else if(this.m_skippedPlayerStart)
         {
            this.m_skippedPlayerStart = false;
            this.processStates();
         }
         else
         {
            this.startSequence();
         }
      }
      
      private function enemyFleetDead() : Boolean
      {
         var _loc1_:Fleet = Fleet.getFleet(this.m_enemyFleetName);
         if(!_loc1_ || !_loc1_.units || _loc1_.units.length == 0)
         {
            return true;
         }
         return false;
      }
      
      private function disposeBattleConsumable() : void
      {
         if(null != this.m_battleConsumable)
         {
            this.m_battleConsumable.dispose();
            this.m_battleConsumable = null;
         }
      }
      
      protected function deselectConsumable() : void
      {
         this.disposeBattleConsumable();
         this.currentConsumable = null;
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,{"consumableItem":null}));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_GROUP_HIGHLIGHT,false));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_SUBGROUP_HIGHLIGHT,false));
      }
      
      protected function kickOffBattleSequence() : void
      {
      }
      
      protected function updateUnits() : void
      {
         var _loc1_:Boolean = true;
         if(this.m_aiAttack)
         {
            _loc1_ = false;
         }
         this.m_firstUnit = new BattleSequenceObject();
         this.m_secondUnit = new BattleSequenceObject();
         if(_loc1_)
         {
            this.m_firstUnit.attackerStats = this.m_playerStats;
            this.m_firstUnit.defenderStats = this.m_enemyStats;
            this.m_firstUnit.attacker = this.m_playerUnit;
            this.m_firstUnit.defender = this.m_enemyUnit;
            this.m_secondUnit.attackerStats = this.m_enemyStats;
            this.m_secondUnit.defenderStats = this.m_playerStats;
            this.m_secondUnit.attacker = this.m_enemyUnit;
            this.m_secondUnit.defender = this.m_playerUnit;
         }
         else
         {
            this.m_firstUnit.attackerStats = this.m_enemyStats;
            this.m_firstUnit.defenderStats = this.m_playerStats;
            this.m_firstUnit.attacker = this.m_enemyUnit;
            this.m_firstUnit.defender = this.m_playerUnit;
            this.m_secondUnit.attackerStats = this.m_playerStats;
            this.m_secondUnit.defenderStats = this.m_enemyStats;
            this.m_secondUnit.attacker = this.m_playerUnit;
            this.m_secondUnit.defender = this.m_enemyUnit;
         }
         this.m_battleUI.playerUnit = this.m_playerUnit;
         this.m_battleUI.enemyUnit = this.m_enemyUnit;
      }
      
      protected function exitBattle() : void
      {
      }
      
      private function processState(param1:Object) : Boolean
      {
         return param1.state();
      }
      
      private function processStates() : void
      {
         while(this.processState(this.m_stateMachine[this.m_statePointer]))
         {
            ++this.m_statePointer;
            if(this.m_statePointer > this.m_stateMachine.length - 1)
            {
               this.startSequence();
            }
            this.m_statePointer %= this.m_stateMachine.length;
         }
      }
      
      protected function startSequence() : void
      {
      }
      
      protected function repeatAction() : void
      {
         this.processStates();
      }
      
      protected function continueAction() : void
      {
         ++this.m_statePointer;
         this.processStates();
      }
      
      protected function setupGroups(param1:Boolean = false) : void
      {
         this.m_ai = new BattleAI(this.m_enemyGroup,this.m_playerGroup);
         this.m_battleUI = new BattleUI(this.m_ai,param1);
         var _loc2_:IEntity = ViewManager.instance.goToView(BattleWorld.ID);
         var _loc3_:BattleObject = null;
         for each(_loc3_ in this.m_enemyGroup)
         {
            _loc2_.eventDispatcher.dispatchEvent(new WorldEvent(BattleWorld.REGISTER_ENEMY_UNIT,_loc3_));
         }
         for each(_loc3_ in this.m_playerGroup)
         {
            _loc2_.eventDispatcher.dispatchEvent(new WorldEvent(BattleWorld.REGISTER_PLAYER_UNIT,_loc3_));
         }
         _loc2_.eventDispatcher.dispatchEvent(new WorldEvent(BattleWorld.REGISTER_FLEETS,{
            "player":this.m_playerFleetName,
            "enemy":this.m_enemyFleetName
         }));
         this.m_battleUI.init(this.m_playerFleetName,this.m_enemyFleetName);
      }
      
      protected function recreatePlayerGroup(param1:Fleet) : void
      {
         var _loc3_:BattleObject = null;
         this.m_playerGroup = this.buildGroupFromFleet(param1);
         this.m_ai.attackers = this.m_playerGroup;
         var _loc2_:IEntity = ViewManager.instance.getView(BattleWorld.ID);
         for each(_loc3_ in this.m_playerGroup)
         {
            _loc2_.eventDispatcher.dispatchEvent(new WorldEvent(BattleWorld.REGISTER_PLAYER_UNIT,_loc3_));
         }
      }
      
      private function addRevivedUnitsToPlayerGroup(param1:WorldEvent) : void
      {
         var _loc2_:BattleObject = null;
         var _loc3_:BattleObject = null;
         var _loc4_:BattleObject = null;
         var _loc5_:Array = null;
         if(param1.eventData)
         {
            _loc2_ = param1.eventData as BattleObject;
            if(_loc2_.unitItem.hasType(UnitItem.MEGA_UNIT))
            {
               return;
            }
            for each(_loc4_ in this.m_playerGroup)
            {
               if(_loc4_.fleet.name == _loc2_.fleet.name)
               {
                  _loc3_ = _loc4_;
                  break;
               }
            }
            _loc5_ = _loc3_.group;
            _loc2_.group = _loc5_;
            this.m_playerGroup.splice(_loc2_.fleet.units.indexOf(_loc2_.unit),1,_loc2_);
         }
         this.m_ai.attackers = this.m_playerGroup;
      }
      
      private function reregisterTitanParts(param1:WorldEvent) : void
      {
         var _loc2_:Fleet = null;
         if(param1.eventData)
         {
            _loc2_ = param1.eventData as Fleet;
            this.recreatePlayerGroup(_loc2_);
         }
      }
      
      protected function buildGroupFromFleet(param1:Fleet) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:BattleObject = null;
         var _loc2_:Array = new Array();
         if(param1.units)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.units.length)
            {
               _loc4_ = this.createBattleObject(param1.units[_loc3_],param1,_loc2_);
               if(null != _loc4_)
               {
                  _loc2_.push(_loc4_);
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      private function createBattleObject(param1:Unit, param2:Fleet, param3:Array) : BattleObject
      {
         var _loc4_:BattleObject = null;
         return new BattleObject(param1,param2,param3);
      }
      
      private function disposeGroup(param1:Array) : void
      {
         var _loc2_:BattleObject = null;
         for each(_loc2_ in param1)
         {
            _loc2_.dispose();
         }
      }
      
      protected function anyUnitsAlive(param1:Array) : Boolean
      {
         var _loc2_:BattleObject = null;
         for each(_loc2_ in param1)
         {
            if(!_loc2_.dead)
            {
               return true;
            }
         }
         return false;
      }
      
      protected function damageUnit(param1:BattleObject, param2:BattleObject, param3:Number, param4:int, param5:Object) : BattleObject
      {
         if(param3 > 0)
         {
            this.updateUnitHealth(param2,param3,param1);
         }
         return param2;
      }
      
      protected function updateUnitHealth(param1:BattleObject, param2:Number, param3:BattleObject = null) : void
      {
      }
      
      protected function killUnit(param1:BattleObject, param2:BattleObject, param3:Object, param4:Boolean) : void
      {
         param2.unit.strength = 0;
         param2.fleet.lastUnitLost = param2.unit.code;
         param2.fleet.lastIndexLost = param2.fleet.units.indexOf(param2.unit);
         if(!param2.unitItem.hasType(UnitItem.MEGA_UNIT_CONTROLLER))
         {
            ZGlobal.player.fleets.removeUnit(param2.fleet.name,param2.unit);
         }
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_KILLED,{
            "attacker":param1,
            "target":param2,
            "weapon":param3,
            "enemy":param4
         }));
      }
      
      private function playMuzzleFlashFX(param1:BattleObject, param2:BattleObject, param3:int) : void
      {
         if(DebugManager.instance.abCombatActive)
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_FIRE,{
               "attacker":param1,
               "target":param2
            }));
         }
      }
      
      private function playMissFX(param1:BattleObject, param2:BattleObject, param3:int) : void
      {
         if(DebugManager.instance.abCombatActive)
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_MISS,{
               "attacker":param1,
               "target":param2
            }));
         }
      }
      
      private function playHitFX(param1:BattleObject, param2:BattleObject, param3:Number, param4:Number, param5:Boolean, param6:Boolean, param7:Boolean) : void
      {
         if(DebugManager.instance.abCombatActive)
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_DAMAGED,{
               "attacker":param1,
               "target":param2,
               "damage":param3,
               "upgradeDamage":param4,
               "glancing":param5,
               "critical":param6,
               "commandoAssaultBonus":param7
            }));
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_HIT,{
               "attacker":param1,
               "target":param2,
               "damage":param3,
               "glancing":param5,
               "critical":param6
            }));
         }
      }
      
      public function isBattleOver() : Boolean
      {
         return !this.anyUnitsAlive(this.m_enemyGroup) || this.checkForRetreat(this.m_enemyFleetName) || !this.anyUnitsAlive(this.m_playerGroup);
      }
      
      public function processStatesUnBlocked() : void
      {
         if(!this.m_blocked)
         {
            this.processStates();
         }
      }
      
      protected function jumpTo(param1:Function, param2:Boolean = true) : void
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         if(param2)
         {
            this.m_statePointer = 0;
            for each(_loc3_ in this.m_stateMachine)
            {
               if(_loc3_.state == param1)
               {
                  break;
               }
               ++this.m_statePointer;
            }
         }
         else
         {
            _loc4_ = int(this.m_stateMachine.length);
            while(this.m_statePointer < _loc4_)
            {
               if(this.m_stateMachine[this.m_statePointer].state == param1)
               {
                  break;
               }
               ++this.m_statePointer;
            }
         }
      }
      
      protected function onContinueFromConsumable(param1:WorldEvent) : void
      {
         if(this.m_sequenceFleetName == this.m_playerFleetName)
         {
            this.jumpTo(this.state_StartFleetConsumables);
            this.deselectConsumable();
            this.kickOffBattleSequence();
         }
         else
         {
            this.jumpTo(this.state_StartFleetConsumables,false);
            this.deselectConsumable();
         }
         this.processStates();
      }
      
      protected function onCancelConsumable(param1:Event) : void
      {
         this.deselectConsumable();
      }
      
      private function getWeaponNameFromConsumableEvent(param1:Object, param2:ConsumableItem, param3:Boolean) : String
      {
         var _loc4_:String = param2[param1.type + "Weapon"];
         if(param2.appendWeaponDirection)
         {
            _loc4_ += param3 ? "NE" : "SW";
         }
         return _loc4_;
      }
      
      private function onUnitDamageFromConsumable(param1:WorldEvent) : void
      {
         var _loc11_:BattleRendererComponent = null;
         var _loc12_:BattleUnit = null;
         var _loc13_:Number = NaN;
         var _loc2_:Object = param1.eventData;
         var _loc3_:ConsumableItem = _loc2_.consumable;
         var _loc4_:BattleObject = _loc2_.target;
         var _loc5_:Boolean = !_loc4_.fleet.isOwnedByPlayer(ZGlobal.player.uid);
         var _loc6_:String = this.getWeaponNameFromConsumableEvent(_loc2_,_loc3_,_loc5_);
         var _loc7_:Object = {
            "id":_loc6_,
            "delay":_loc2_.delay
         };
         var _loc8_:Number = 0;
         if(_loc3_.givesShield)
         {
            if(_loc4_.unit.shields == 0)
            {
               _loc4_.unit.code;
               _loc11_ = BattleRendererComponent(ViewManager.instance.getComponentFromView(BattleWorld.ID,BattleRendererComponent));
               _loc12_ = _loc11_.getBattleUnit(_loc4_);
               _loc12_.shieldAnimation();
            }
            _loc4_.unit.shields = 1;
         }
         _loc2_.chipDamage;
         var _loc9_:Number = _loc3_.str;
         if(_loc9_ != 0)
         {
            _loc8_ = this.m_ai.GetAttackingDamageFromAbsoluteValue(_loc9_,_loc4_);
         }
         else if(_loc2_.chipDamage)
         {
            _loc8_ = Number(_loc2_.chipDamage);
         }
         else
         {
            _loc8_ = Number(_loc3_[_loc2_.type]);
         }
         if(_loc3_.damageIsPercent)
         {
            _loc8_ *= _loc4_.unitItem.getStrength(_loc4_.fleet);
         }
         var _loc10_:Number = UnitItem.getModifier(_loc3_.againstList,_loc4_.unitItem);
         if(_loc10_ != 1)
         {
            _loc8_ *= _loc10_;
         }
         if(_loc5_)
         {
            _loc13_ = _loc4_.unit.strength - _loc8_;
            if(_loc13_ > 0 && _loc13_ <= 1)
            {
               Logger.info(this,"onUnitDamageFromConsumable","Incing damage to prevent 1 strength.");
               _loc8_ += 1;
            }
         }
         this.updateUnitHealth(_loc4_,_loc8_,null);
         if(_loc4_.unit.dead)
         {
            this.killUnit(null,_loc4_,_loc7_,_loc5_);
         }
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_DAMAGED,{
            "weapon":_loc7_,
            "target":_loc4_,
            "damage":_loc8_,
            "consumable":true,
            "enemyFleet":_loc5_
         }));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_HIT,{
            "weapon":_loc7_,
            "target":_loc4_,
            "consumable":true,
            "consumableItem":_loc3_,
            "chipDamage":_loc2_.chipDamage,
            "damage":(_loc4_.unit.dead ? _loc8_ : false)
         }));
      }
      
      public function getPlayerFleetName() : String
      {
         return this.m_playerFleetName;
      }
      
      public function getEnemyFleetName() : String
      {
         return this.m_enemyFleetName;
      }
      
      protected function checkForRetreat(param1:String) : Boolean
      {
         return false;
      }
   }
}

