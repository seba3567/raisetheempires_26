package core.gamemode.battle
{
   import Engine.Managers.TransactionManager;
   import ZQuest.Managers.QuestManager;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gamemode.battle.selectors.BattleSelector;
   import core.gamemode.battle.selectors.PlayerOrEnemySelector;
   import core.gamemode.battle.selectors.PlayerSelector;
   import core.gameobjects.ConsumableItem;
   import core.gameobjects.Fleet;
   import core.gameobjects.Unit;
   import core.gameobjects.UnitItem;
   import core.gameobjects.questPower.QuestPower;
   import core.managers.AllianceQuestManager;
   import core.managers.AlliancesManager;
   import core.managers.ChallengeModeManager;
   import core.managers.CommandoManager;
   import core.managers.ExperimentsManager;
   import core.managers.FlamingUnitManager;
   import core.managers.PVPManager;
   import core.managers.WorldUpgradeManager;
   import core.managers.ZRTManager;
   import core.managers.battleManager.BattleManager;
   import core.managers.questManager.ZGameQuestManager;
   import core.player.Player;
   import core.player.PlayerAmmo;
   import core.ui.FloatingText;
   import core.ui.feedbacktext.AmmoFeedbackText;
   import core.ui.feedbacktext.EnergyFeedbackText;
   import core.ui.feedbacktext.FeedbackText;
   import core.ui.feedbacktext.LibertyBondFeedbackText;
   import core.ui.feedbacktext.ManaFeedbackText;
   import core.ui.feedbacktext.QuantifiedFeedbackText;
   import core.ui.floatingtext.ImageFloatingText;
   import core.views.ViewManager;
   import core.worlds.battleWorld.BattleRendererComponent;
   import core.worlds.battleWorld.BattleUnit;
   import core.worlds.battleWorld.BattleWorld;
   import dispatchers.StrategicDispatcher;
   import displays.popups.GenericPopup;
   import displays.popups.GenericPopup2B;
   import displays.popups.buyAmmo.BuyAmmoPopup;
   import displays.popups.buyEnergy.BuyEnergyPopup;
   import displays.popups.buyMana.BuyManaPopup;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import transactions.TAssignConsumable;
   import transactions.TResolveBattle;
   import utils.ZGameRandom;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class BattleHost extends Battle implements ISelectionReceiver
   {
      
      private static const INVALID_OK:int = 0;
      
      private static const INVALID_ENERGY:int = 1;
      
      private static const INVALID_AMMO:int = 2;
      
      private static const INVALID_MANA:int = 3;
      
      private const WEAK_ROLL:Number = -2;
      
      private const STRONG_ROLL:Number = 2;
      
      private const EXPERIMENT_AI_FOCUSFIRE_MINVARIANT:int = 3;
      
      private var m_userExitBattle:Boolean = false;
      
      protected var m_battleResult:int = 0;
      
      private var m_selector:BattleSelector = null;
      
      private var m_selectedUnit:BattleObject = null;
      
      public var m_battleOver:Boolean = false;
      
      private var m_deferredConsumable:ConsumableItem = null;
      
      private var m_noEnergy:int = 0;
      
      private var m_turnEnded:Boolean = false;
      
      public function BattleHost(param1:Fleet, param2:Fleet)
      {
         super();
         this.m_userExitBattle = false;
         this.m_battleResult = BATTLE_RESULT_NONE;
         this.m_noEnergy = ZGlobal.player.combatSpecialBits & Fleet.NO_ENERGY;
         this.setupGroupsByFleets(param1,param2);
         this.initSetup();
      }
      
      public function get battleResult() : int
      {
         return this.m_battleResult;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.selector = null;
         this.m_selectedUnit = null;
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_RECREATE_PLAYER_GROUP,this.onRecreatePlayerGroup);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_TRIGGER_CONSUMABLE,this.onTriggerConsumable);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.UNIT_POWER_USED,this.onUnitPowerUsed);
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_UNIT_USED_CONSUMABLE_ENERGY,this.onUnitUsedConsumableEnergy);
      }
      
      override protected function initSetup() : void
      {
         super.initSetup();
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_RECREATE_PLAYER_GROUP,this.onRecreatePlayerGroup);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.UNIT_POWER_USED,this.onUnitPowerUsed);
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_UNIT_USED_CONSUMABLE_ENERGY,this.onUnitUsedConsumableEnergy);
         m_skippedPlayerStart = false;
         var _loc1_:int = 0;
         if(null != ZGlobal.player.fleets.battleStatus[m_playerFleetName])
         {
            _loc1_ = int(ZGlobal.player.fleets.battleStatus[m_playerFleetName]);
            if(_loc1_ == 1)
            {
               ZGlobal.player.fleets.battleStatus[m_playerFleetName] = 0;
               m_skippedPlayerStart = true;
               jumpTo(this.state_ChoosePlayerTarget);
            }
         }
      }
      
      private function onRecreatePlayerGroup(param1:WorldEvent) : void
      {
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_RECREATE_PLAYER_GROUP,this.onRecreatePlayerGroup);
         recreatePlayerGroup(param1.eventData as Fleet);
         if(m_battleUI)
         {
            m_battleUI.repopulateUI();
         }
      }
      
      override protected function setupStateMachine() : void
      {
         m_stateMachine = new Array();
         m_stateMachine.push({"state":this.state_ChoosePlayerAttacker});
         m_stateMachine.push({"state":this.state_ChooseEnemyTarget});
         addDefaultBattleResolveStates(false);
         m_stateMachine.push({"state":this.state_StartAISequence});
         m_stateMachine.push({"state":this.state_UseSecondaryAbility});
         m_stateMachine.push({"state":this.state_ChoosePlayerTarget});
         addDefaultBattleResolveStates(true);
         m_stateMachine.push({"state":this.state_SequenceComplete});
         m_stateMachine.push({"state":this.state_WaitForInput});
      }
      
      override protected function onContinueFromConsumable(param1:WorldEvent) : void
      {
         var _loc2_:ConsumableItem = param1.eventData as ConsumableItem;
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant("empire_consumable_energy");
         if(_loc2_.secondary || _loc3_ != 3 && (BattleManager.instance.powerUseRequiresTurn || _loc2_.useTurn))
         {
            super.onContinueFromConsumable(param1);
         }
         else
         {
            this.m_turnEnded = false;
            if(isBattleOver())
            {
               jumpTo(this.state_CheckResults);
            }
            else
            {
               jumpTo(this.state_SequenceComplete);
            }
            deselectConsumable();
            Zlab.processManager.schedule(500,this,this.restartSequenceFromConsumable);
         }
      }
      
      private function restartSequenceFromConsumable() : void
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant("empire_consumable_energy");
         if(_loc1_ == 3)
         {
            m_blocked = false;
         }
         processStatesUnBlocked();
      }
      
      private function allUnitsStunned(param1:Array) : Boolean
      {
         var _loc2_:BattleObject = null;
         for each(_loc2_ in param1)
         {
            if(!_loc2_.unit.dead && !_loc2_.stunned)
            {
               return false;
            }
         }
         return true;
      }
      
      override protected function initStateDictionary() : void
      {
         super.initStateDictionary();
         stateDictionary[this.state_ChoosePlayerAttacker] = {"name":"state_ChoosePlayerAttacker"};
         stateDictionary[this.state_ChooseEnemyTarget] = {"name":"state_ChooseEnemyTarget"};
         stateDictionary[state_UpdateConsumable] = {"name":"state_UpdateConsumable"};
         stateDictionary[this.state_StartAISequence] = {"name":"state_StartAISequence"};
         stateDictionary[this.state_UseSecondaryAbility] = {"name":"state_UseSecondaryAbility"};
         stateDictionary[this.state_ChoosePlayerTarget] = {"name":"state_ChoosePlayerTarget"};
         stateDictionary[this.state_SequenceComplete] = {"name":"state_SequenceComplete"};
         stateDictionary[this.state_WaitForInput] = {"name":"state_WaitForInput"};
      }
      
      override protected function onStartBattle(param1:Event) : void
      {
         if(!m_skippedPlayerStart)
         {
            if(this.allUnitsStunned(m_playerGroup))
            {
               this.stunnedSkipPlayerTurn();
               return;
            }
         }
         super.onStartBattle(param1);
      }
      
      override protected function startSequence() : void
      {
         var _loc1_:BattleObject = null;
         this.m_turnEnded = true;
         Zlab.processManager.schedule(500,this,this.startPlayer);
         this.selector = new PlayerSelector(this);
         if(null == this.m_selectedUnit)
         {
            _loc1_ = this.getBestObject();
            if(null != _loc1_)
            {
               this.player = _loc1_;
            }
         }
      }
      
      private function startPlayer() : void
      {
         BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_PLAYER_TURN));
      }
      
      private function getBestObject() : BattleObject
      {
         var _loc3_:BattleObject = null;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc1_:BattleObject = null;
         var _loc2_:ZGameQuestManager = QuestManager.getInstance(null) as ZGameQuestManager;
         if(_loc2_)
         {
            _loc4_ = _loc2_.getDefaultSelectionSlot(m_enemyFleetName);
            if(_loc4_ >= 0)
            {
               if(Boolean(m_playerGroup[_loc4_]) && !m_playerGroup[_loc4_].unit.dead)
               {
                  return m_playerGroup[_loc4_];
               }
            }
         }
         for each(_loc3_ in m_playerGroup)
         {
            if(_loc3_.unitItem.highlightByDefault)
            {
               _loc1_ = _loc3_;
               break;
            }
         }
         if(null == _loc1_)
         {
            _loc5_ = m_ai.FindBestAttacker();
            _loc1_ = _loc5_.attacker;
         }
         return _loc1_;
      }
      
      private function set selector(param1:BattleSelector) : void
      {
         if(null != this.m_selector)
         {
            this.m_selector.dispose();
         }
         this.m_selector = param1;
         if(null != this.m_selector)
         {
            this.m_selector.init();
         }
      }
      
      private function state_ChoosePlayerAttacker() : Boolean
      {
         if(m_targetObject)
         {
            m_sequenceFleetName = m_playerFleetName;
            m_playerUnit = m_targetObject;
            this.m_selectedUnit = m_targetObject;
            m_targetObject = null;
            m_battleUI.playerUnit = m_playerUnit;
            this.selector = new PlayerOrEnemySelector(this);
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_OBJECT_SELECTED,m_playerUnit));
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_PLAYER_OBJECT_CHOSEN,m_playerUnit));
            BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_UI_RECALCULATE_HIGHLIGHT));
            return true;
         }
         return false;
      }
      
      private function state_ChooseEnemyTarget() : Boolean
      {
         var _loc1_:int = 0;
         if(m_targetObject)
         {
            _loc1_ = m_targetObject.unitItem.attackCost;
            if(m_playerUnit.unitItem.attackCostType == UnitItem.ATTACK_COST_MANA && !m_playerUnit.unitItem.getEfficiency(m_playerUnit.fleet,m_playerUnit.unit.code))
            {
               ZGlobal.player.mana.spend(_loc1_);
               this.manaUI(_loc1_);
            }
            else if(PlayerAmmo.variantAmmoMasterOn())
            {
               ZGlobal.player.m_ammo.ammo -= _loc1_;
               this.ammoUI(_loc1_);
            }
            else
            {
               if(Boolean(this.m_noEnergy) && Boolean(ExperimentsManager.instance.getExperimentVariant("empire_combat_no_energy") > 1) && ZRTManager.instance.isZRTOn(ZGlobal.player.COMBAT_NO_ENERGY))
               {
                  _loc1_ = 0;
               }
               ZGlobal.player.m_energy.energy -= _loc1_;
               this.energyUI(_loc1_);
            }
            m_enemyUnit = m_targetObject;
            m_targetObject = null;
            m_battleUI.enemyUnit = m_enemyUnit;
            this.kickOffBattleSequence();
            return true;
         }
         return false;
      }
      
      private function onUnitPowerUsed(param1:WorldEvent) : void
      {
         var _loc2_:ConsumableItem = param1.eventData.consumableItem;
         var _loc3_:int = _loc2_.mana;
         if(_loc3_ > 0)
         {
            m_blocked = true;
            this.manaUI(_loc3_);
         }
      }
      
      private function playerUnitFloatingText(param1:int, param2:String, param3:QuantifiedFeedbackText, param4:BattleObject = null, param5:String = "-") : void
      {
         var _loc8_:FeedbackText = null;
         var _loc9_:DisplayObjectContainer = null;
         var _loc10_:FloatingText = null;
         var _loc6_:BattleRendererComponent = ViewManager.instance.getComponentFromView(BattleWorld.ID,BattleRendererComponent) as BattleRendererComponent;
         var _loc7_:BattleUnit = null;
         if(param4 != null)
         {
            _loc7_ = _loc6_.getBattleUnit(param4);
         }
         else
         {
            _loc7_ = _loc6_.getBattleUnit(m_playerUnit);
         }
         if(null != _loc7_)
         {
            _loc8_ = param3;
            _loc9_ = _loc6_.getSurface(_loc7_.side).parent.parent;
            _loc10_ = null;
            if(param2)
            {
               _loc10_ = new ImageFloatingText(_loc9_,ZGlobal.getAssetURL(param2));
            }
            else
            {
               _loc10_ = new FloatingText(_loc9_);
            }
            _loc10_.disposeOnComplete = true;
            _loc10_.useWorldZoom = false;
            _loc10_.position = new Pt(_loc7_.x,_loc7_.y);
            if(ZGlobal.localizer.localeCode == "ja_JP")
            {
               param5 = "";
            }
            _loc10_.text = param5 + _loc8_.friendlyName;
            _loc10_.scale = 1.5;
            _loc10_.color = _loc8_.color;
            _loc8_ = null;
         }
      }
      
      private function manaUI(param1:int) : void
      {
         this.playerUnitFloatingText(param1,null,new ManaFeedbackText(param1));
      }
      
      private function energyUI(param1:int) : void
      {
         if(param1 != 0)
         {
            if(ZGlobal.localizer.localeCode == "ja_JP")
            {
               param1 = param1 < 0 ? param1 : int(-param1);
            }
            this.playerUnitFloatingText(param1,EnergyFeedbackText.MEDIUM_ICON_URL,new EnergyFeedbackText(param1));
         }
      }
      
      private function ammoUI(param1:int) : void
      {
         this.playerUnitFloatingText(param1,AmmoFeedbackText.MEDIUM_ICON_URL,new AmmoFeedbackText(param1));
      }
      
      public function libertyBondUI(param1:int) : void
      {
         this.playerUnitFloatingText(param1,LibertyBondFeedbackText.ICON_URL,new LibertyBondFeedbackText(param1),this.getFirstAliveUnit(m_playerGroup),"+");
      }
      
      override protected function kickOffBattleSequence() : void
      {
         m_continue = false;
         m_targetObject = null;
         this.selector = null;
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_PLAYER_OBJECT_CHOSEN,m_playerUnit));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_ENEMY_OBJECT_CHOSEN,m_enemyUnit));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_PAIR_CHOSEN,{
            "player":m_playerUnit,
            "enemy":m_enemyUnit
         }));
         BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_SEQUENCE_STARTED));
      }
      
      private function state_StartAISequence() : Boolean
      {
         m_sequenceFleetName = m_enemyFleetName;
         return true;
      }
      
      private function state_UseSecondaryAbility() : Boolean
      {
         var _loc2_:Unit = null;
         var _loc3_:BattleObject = null;
         var _loc4_:UnitItem = null;
         var _loc5_:ConsumableItem = null;
         var _loc6_:BattleObject = null;
         var _loc1_:Fleet = Fleet.getFleet(m_enemyFleetName);
         for each(_loc2_ in _loc1_.units)
         {
            _loc3_ = _loc1_.getBattleObject(_loc2_.id,m_enemyGroup);
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc2_.code,UnitItem) as UnitItem;
            if(Boolean(_loc4_.secondaryAbility) && !_loc3_.stunned)
            {
               TransactionManager.addTransaction(new TAssignConsumable("AI",null,0,0,null));
               _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_.secondaryAbility,ConsumableItem) as ConsumableItem;
               _loc6_ = m_ai.SecondaryAbilityHueristicsTarget(_loc5_);
               if(_loc6_)
               {
                  m_enemyUnit = _loc3_;
                  Zlab.processManager.schedule(1250,this,this.onExecuteSecondaryAbility,{
                     "consumableItem":_loc5_,
                     "target":_loc6_
                  });
                  return false;
               }
            }
         }
         return true;
      }
      
      private function onExecuteSecondaryAbility(param1:Object) : void
      {
         param1.ai = true;
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_CONSUMABLE_SELECTED,param1));
         this.consumable = param1.consumableItem;
         if(param1.target.fleet.name == m_playerFleetName)
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.PLAYER_UNIT_CLICKED,param1.target));
         }
         else
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.ENEMY_UNIT_CLICKED,param1.target));
         }
      }
      
      private function get shouldAIFocusFire() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_AI_FOCUS_FIRE);
         if(_loc1_ < this.EXPERIMENT_AI_FOCUSFIRE_MINVARIANT)
         {
            return false;
         }
         var _loc2_:int = ZGlobal.gameSettings.getInt("combatAIFocusFireMinLevel",25);
         if(ZGlobal.player.level < _loc2_)
         {
            return false;
         }
         var _loc3_:String = ZGlobal.gameSettings.getString("combatAIFocusFireProbabilities","");
         if(_loc3_ == "")
         {
            return false;
         }
         var _loc4_:Array = _loc3_.split(",");
         if(_loc1_ >= _loc4_.length)
         {
            return false;
         }
         var _loc5_:Number = Number(_loc4_[_loc1_]);
         var _loc6_:Number = ZGameRandom.instance.float();
         return _loc6_ <= _loc5_;
      }
      
      private function state_ChoosePlayerTarget() : Boolean
      {
         m_ai.shouldFocusFire = this.shouldAIFocusFire;
         var _loc1_:Object = m_ai.FindBestDefendingUnit();
         m_ai.shouldFocusFire = false;
         if(_loc1_.attacker == null || _loc1_.defender == null)
         {
            this.updateConsumableSkipped(true);
            Zlab.processManager.schedule(250,this,this.skipToPlayer);
            return false;
         }
         m_playerUnit = _loc1_.attacker;
         m_enemyUnit = _loc1_.defender;
         m_battleUI.playerUnit = m_playerUnit;
         m_battleUI.enemyUnit = m_enemyUnit;
         m_aiAttack = true;
         m_blocked = true;
         BattleDispatcher.instance.dispatchEvent(new Event(BattleDispatcher.BATTLE_ENEMY_TURN));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_ENEMY_OBJECT_CHOSEN,m_enemyUnit));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_PLAYER_OBJECT_CHOSEN,m_playerUnit));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_PAIR_CHOSEN,{
            "player":m_playerUnit,
            "enemy":m_enemyUnit
         }));
         Zlab.processManager.schedule(500,this,continueAction);
         return false;
      }
      
      override protected function state_Resolve() : Boolean
      {
         var _loc1_:TResolveBattle = new TResolveBattle(m_playerUnit,m_enemyUnit,m_aiAttack);
         var _loc2_:BattleObject = null;
         var _loc3_:BattleObject = null;
         if(m_aiAttack)
         {
            m_enemyStats = this.resolveAttack(m_enemyUnit,m_playerUnit);
            _loc1_.setDebugInfo(m_enemyStats.hitValue,m_enemyStats.unitRoll);
            if(m_playerUnit.canCounter)
            {
               m_playerStats = this.resolveAttack(m_playerUnit,m_enemyUnit);
            }
            _loc3_ = damageUnit(m_enemyUnit,m_playerUnit,m_enemyStats.damage,0,m_enemyStats);
            if(m_playerUnit.canCounter)
            {
               damageUnit(m_playerUnit,m_enemyUnit,m_playerStats.damage,0,m_playerStats);
            }
         }
         else
         {
            m_playerStats = this.resolveAttack(m_playerUnit,m_enemyUnit);
            _loc1_.setDebugInfo(m_playerStats.hitValue,m_playerStats.unitRoll);
            if(m_enemyUnit.canCounter)
            {
               m_enemyStats = this.resolveAttack(m_enemyUnit,m_playerUnit);
            }
            _loc2_ = damageUnit(m_playerUnit,m_enemyUnit,m_playerStats.damage,0,m_playerStats);
            if(m_enemyUnit.canCounter)
            {
               damageUnit(m_enemyUnit,m_playerUnit,m_enemyStats.damage,0,m_enemyStats);
            }
            _loc1_.setCommandoAssaultFlag(m_playerStats.commandoAssaultBonus);
         }
         _loc1_.battleComplete(_loc2_,_loc3_);
         TransactionManager.addTransaction(_loc1_);
         _loc1_ = null;
         updateUnits();
         return true;
      }
      
      override protected function state_CheckResults() : Boolean
      {
         super.state_CheckResults();
         if(isBattleOver())
         {
            this.battleOver(BATTLE_RESULT_NONE);
            return false;
         }
         return true;
      }
      
      private function getFirstAliveUnit(param1:Array) : BattleObject
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
      
      private function updateConsumableSkipped(param1:Boolean) : void
      {
         var _loc2_:TResolveBattle = new TResolveBattle(this.getFirstAliveUnit(m_playerGroup),this.getFirstAliveUnit(m_enemyGroup),param1);
         _loc2_.battleComplete(null,null);
         TransactionManager.addTransaction(_loc2_);
         _loc2_ = null;
      }
      
      private function state_SequenceComplete() : Boolean
      {
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_SEQUENCE_COMPLETE,{"endTurn":this.m_turnEnded}));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UPDATE_POINTER_HOST));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_ENEMY_OBJECT_CHOSEN,null));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_PAIR_CHOSEN,null));
         m_aiAttack = false;
         m_blocked = false;
         if(this.m_userExitBattle)
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_COMPLETE_MANUAL_HOST));
            return false;
         }
         return true;
      }
      
      private function stunnedSkipPlayerTurn() : void
      {
         m_sequenceFleetName = m_playerFleetName;
         this.updateConsumableSkipped(false);
         Zlab.processManager.schedule(250,this,this.skipPlayerTurn);
      }
      
      private function skipPlayerTurn() : void
      {
         jumpTo(state_StartFleetConsumables);
         processStatesUnBlocked();
      }
      
      private function skipToPlayer() : void
      {
         jumpTo(state_StartFleetConsumables,false);
         m_blocked = false;
         processStatesUnBlocked();
      }
      
      private function state_WaitForInput() : Boolean
      {
         if(m_continue)
         {
            return true;
         }
         if(null != this.m_selectedUnit && !this.m_selectedUnit.unit.dead && !this.m_selectedUnit.stunned)
         {
            m_targetObject = this.m_selectedUnit;
            return true;
         }
         this.m_selectedUnit = this.getBestObject();
         if(null != this.m_selectedUnit)
         {
            m_targetObject = this.m_selectedUnit;
            return true;
         }
         if(this.allUnitsStunned(m_playerGroup))
         {
            this.stunnedSkipPlayerTurn();
            return false;
         }
         m_continue = true;
         return false;
      }
      
      public function checkExitBattle() : Boolean
      {
         this.m_userExitBattle = true;
         return !m_blocked;
      }
      
      private function getDiceRoll(param1:BattleObject, param2:BattleObject) : Number
      {
         if(param1.unitItem.weak)
         {
            return this.WEAK_ROLL;
         }
         if(param2.unitItem.weak)
         {
            return this.STRONG_ROLL;
         }
         return ZGameRandom.instance.randBetween(0,1);
      }
      
      private function resolveAttack(param1:BattleObject, param2:BattleObject) : Object
      {
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc3_:Object = new Object();
         _loc3_.hitValue = m_ai.GetAttackingHitValue(param1,param2,BattleAI.STRENGTH_CURRENT,false);
         _loc3_.unitRoll = Number(this.getDiceRoll(param1,param2));
         if(m_ai.allowMiss)
         {
            _loc3_.hit = Boolean(_loc3_.unitRoll >= _loc3_.hitValue.direct);
         }
         else
         {
            _loc3_.hit = true;
         }
         var _loc4_:Object = m_ai.GetAttackingDamage(param1,param2);
         _loc3_.damage = _loc4_.damage;
         _loc3_.upgradeDamage = _loc4_.upgradeDamage;
         _loc3_.critical = false;
         _loc3_.glancing = false;
         if(param1 == m_playerUnit && param1.unitItem.subType == UnitItem.ARMY && CommandoManager.instance.isActive())
         {
            _loc5_ = CommandoManager.instance.getDamageModifier();
            _loc3_.damage += _loc5_;
            _loc3_.commandoAssaultBonus = true;
         }
         else
         {
            _loc3_.commandoAssaultBonus = false;
         }
         Logger.info(this,"resolveAttack","att:" + param1.unitItem.code + " def:" + param2.unitItem.code + " hitPercent: direct " + _loc3_.hitValue.direct + " critical " + _loc3_.hitValue.critical + " unitRoll: " + _loc3_.unitRoll + " hit " + _loc3_.hit);
         if(null != param1.fleet.hitPercentageRecorder)
         {
            param1.fleet.hitPercentageRecorder.update(param1.unit.id,param2.unit.id,_loc3_.hit);
         }
         if(!_loc3_.hit)
         {
            if(!m_aiAttack || !m_ai.AICanMiss)
            {
               Logger.info(this,"resolveAttack","glancing");
               _loc3_.damage *= m_ai.glancingBlowMult;
               _loc3_.upgradeDamage *= m_ai.glancingBlowMult;
               _loc3_.hit = true;
               _loc3_.glancing = true;
            }
         }
         else if(_loc3_.unitRoll != this.STRONG_ROLL)
         {
            if(!m_aiAttack || m_ai.AICanCritical)
            {
               if(_loc3_.unitRoll >= _loc3_.hitValue.critical)
               {
                  Logger.info(this,"resolveAttack","critical");
                  _loc3_.damage *= m_ai.criticalHitMult;
                  _loc3_.upgradeDamage *= m_ai.criticalHitMult;
                  _loc3_.critical = true;
               }
            }
         }
         if(_loc3_.hit)
         {
            _loc3_.damage = int(Math.ceil(_loc3_.damage));
            _loc3_.upgradeDamage = int(Math.ceil(_loc3_.upgradeDamage));
            if(_loc3_.damage - _loc3_.upgradeDamage == 0)
            {
               _loc3_.damage += 1;
            }
            if(!m_aiAttack)
            {
               _loc6_ = param2.unit.strength - _loc3_.damage;
               if(_loc6_ > 0 && _loc6_ <= 1)
               {
                  Logger.info(this,"resolveAttack","Incing damage to prevent 1 strength.");
                  _loc3_.damage += 1;
               }
            }
         }
         else
         {
            _loc3_.damage = 0;
            _loc3_.upgradeDamage = 0;
         }
         if(param2.unitItem.weaker)
         {
            _loc3_.damage = param2.unit.strength;
         }
         _loc3_.kill = Boolean(param2.unit.strength <= _loc3_.damage);
         Logger.info(this,"resolveAttack","s:" + param2.unit.strength + " c: " + _loc3_.critical + " d:" + _loc3_.damage + " ud:" + _loc3_.upgradeDamage + " kill:" + _loc3_.kill);
         if(!ZGlobal.player.getSeenFlag(WorldUpgradeManager.FIRST_RESEARCH_DIALOG))
         {
            _loc3_.upgradeDamage = 0;
         }
         return _loc3_;
      }
      
      override protected function updateUnitHealth(param1:BattleObject, param2:Number, param3:BattleObject = null) : void
      {
         var _loc6_:int = 0;
         if(ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_RESEARCH_SHIELD_UPGRADE) == ExperimentsManager.VARIANT_RESEARCH_SHIELD_UPGRADE_ON)
         {
            if(param1.unit.shields > 0 && param2 > 0)
            {
               --param1.unit.shields;
               if(param1.unit.shields == 0)
               {
                  param1.unit.shieldHit = 1;
               }
               param2 = 0;
            }
         }
         var _loc4_:int = 0;
         if(FlamingUnitManager.instance.flamingUnitsEnabled && param3 != null && (param3.unitItem.isFlamingUnit || param3.fleet.hasFlameConsumable()))
         {
            _loc6_ = FlamingUnitManager.instance.getFlamingDamageVariant();
            _loc4_ = Math.ceil(_loc6_ / 100 * param2);
            if(_loc4_ > 0 && _loc4_ < 10)
            {
               _loc4_ = 10;
            }
            FlamingUnitManager.instance.flamingDamage = _loc4_;
            param2 += _loc4_;
         }
         var _loc5_:Number = param1.unitItem.getStrength(param1.fleet);
         param1.unit.strength = Math.min(_loc5_,Math.max(0,param1.unit.strength - param2));
         param1.unit.strength = int(Math.ceil(param1.unit.strength));
      }
      
      override protected function onCancelConsumable(param1:Event) : void
      {
         super.onCancelConsumable(param1);
         jumpTo(this.state_WaitForInput);
         processStatesUnBlocked();
      }
      
      private function setupGroupsByFleets(param1:Fleet, param2:Fleet) : void
      {
         m_playerFleetName = param1.name;
         m_enemyFleetName = param2.name;
         m_enemyGroup = buildGroupFromFleet(param2);
         m_playerGroup = buildGroupFromFleet(param1);
         setupGroups();
      }
      
      public function endBattleWithRetreat() : void
      {
         this.battleOver(BATTLE_RESULT_RETREAT);
      }
      
      public function endBattleWithCancel() : void
      {
         this.battleOver(BATTLE_RESULT_CANCEL);
      }
      
      protected function battleOver(param1:int) : void
      {
         if(this.m_battleOver)
         {
            return;
         }
         this.m_battleOver = true;
         var _loc2_:Fleet = Fleet.getFleet(m_playerFleetName);
         var _loc3_:Fleet = Fleet.getFleet(m_enemyFleetName);
         var _loc4_:String = _loc2_ ? _loc2_.uid : null;
         var _loc5_:String = _loc3_ ? _loc3_.uid : null;
         var _loc6_:Array = _loc2_.units;
         var _loc7_:Dictionary = _loc2_.lost;
         var _loc8_:Boolean = _loc2_.hasRevivedUnits;
         if(param1 != BATTLE_RESULT_NONE)
         {
            this.m_battleResult = param1;
         }
         else if(this.getFirstAliveUnit(m_playerGroup) != null)
         {
            this.m_battleResult = BATTLE_RESULT_WON;
         }
         else
         {
            this.m_battleResult = BATTLE_RESULT_LOST;
         }
         this.setBattleResult(this.m_battleResult);
         if(this.m_battleResult == BATTLE_RESULT_WON)
         {
            if(isDominationMode || isGlobalPVP || this.isAllianceBattle())
            {
               AllianceQuestManager.instance.grantItems();
            }
         }
         this.removeFleets();
         StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.BATTLE_COMPLETE,this.m_battleResult));
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_COMPLETE_HOST,{
            "remainingUnits":_loc6_,
            "lostUnits":_loc7_,
            "hasRevivedUnits":_loc8_,
            "result":this.m_battleResult,
            "playerUID":_loc4_,
            "enemyUID":_loc5_,
            "neighborAssist":ChallengeModeManager.instance.isNeighborAssist(),
            "pveRepel":this.isPVEChallenge(),
            "isStrikeTeamInvasion":PVPManager.instance.isStrikeTeamInvasion(_loc5_),
            "battle":this
         }));
      }
      
      protected function isPVEChallenge() : Boolean
      {
         return ChallengeModeManager.instance.isPVEChallenge();
      }
      
      public function isAllianceBattle() : Boolean
      {
         if(m_playerFleetName == AlliancesManager.ALLIANCE_PLAYER_FLEET)
         {
            return true;
         }
         return false;
      }
      
      protected function setBattleResult(param1:int) : void
      {
         var _loc2_:BattleObject = null;
         if(param1 == Battle.BATTLE_RESULT_WON || param1 == Battle.BATTLE_RESULT_LOST)
         {
            for each(_loc2_ in m_playerGroup)
            {
               if(_loc2_.unitItem.hasType(UnitItem.MEGA_UNIT))
               {
                  ZGlobal.player.setSeenFlag(Player.HAS_SEEN_TITAN_BATTLE);
                  ZGlobal.player.setSeenFlag(Player.HAS_SEEN_TITAN_BATTLE_QT057);
                  break;
               }
            }
         }
      }
      
      protected function removeFleets() : void
      {
         ZGlobal.player.fleets.battleOver(m_playerFleetName,m_enemyFleetName,this.m_battleResult);
      }
      
      private function canUseObject(param1:BattleObject) : int
      {
         var _loc2_:int = param1.unitItem.attackCost;
         if(param1.unitItem.attackCostType == UnitItem.ATTACK_COST_MANA)
         {
            if(!ZGlobal.player.mana.allow(_loc2_))
            {
               return INVALID_MANA;
            }
         }
         else if(PlayerAmmo.variantAmmoMasterOn())
         {
            if(!ZGlobal.player.m_ammo.checkAmmo(_loc2_))
            {
               return INVALID_AMMO;
            }
         }
         else if(!ZGlobal.player.m_energy.checkEnergy(_loc2_))
         {
            return INVALID_ENERGY;
         }
         return INVALID_OK;
      }
      
      public function set player(param1:BattleObject) : void
      {
         if(param1 != m_playerUnit)
         {
            this.selector = null;
            m_targetObject = param1;
            m_targetObject.playSelectionSound();
            if(null != m_playerUnit)
            {
               jumpTo(this.state_ChoosePlayerAttacker);
            }
            processStatesUnBlocked();
         }
      }
      
      public function set playerOver(param1:BattleObject) : void
      {
         if(null == param1 && Boolean(this.m_selectedUnit))
         {
            param1 = this.m_selectedUnit;
         }
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_PLAYER_OBJECT_CHOSEN,param1));
      }
      
      public function set enemy(param1:BattleObject) : void
      {
         var _loc2_:int = this.canUseObject(m_playerUnit);
         if(_loc2_ == INVALID_ENERGY)
         {
            BuyEnergyPopup.enableWatchToEarn();
            BuyEnergyPopup.show(this.onEnergyPopupClosed);
         }
         else if(_loc2_ == INVALID_AMMO)
         {
            PopupManager.instance.push(new BuyAmmoPopup(this.onEnergyPopupClosed));
         }
         else if(_loc2_ == INVALID_MANA)
         {
            PopupManager.instance.push(new BuyManaPopup(this.onEnergyPopupClosed));
         }
         else
         {
            this.selector = null;
            m_targetObject = param1;
            processStatesUnBlocked();
         }
      }
      
      public function set enemyOver(param1:BattleObject) : void
      {
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_ENEMY_OBJECT_CHOSEN,param1));
         if(Boolean(this.m_selectedUnit) && Boolean(param1))
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_PAIR_CHOSEN,{
               "player":this.m_selectedUnit,
               "enemy":param1
            }));
         }
         else
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_PAIR_CHOSEN,null));
         }
      }
      
      public function set consumable(param1:ConsumableItem) : void
      {
         if(null != param1)
         {
            this.selector = null;
         }
         currentConsumable = param1;
         if(null != m_currentConsumable)
         {
            if(!m_currentConsumable.secondary)
            {
               BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_OBJECT_SELECTED,null));
               BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UI_PLAYER_OBJECT_CHOSEN,null));
            }
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_GROUP_HIGHLIGHT,m_currentConsumable.affectsAll));
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_SUBGROUP_HIGHLIGHT,m_currentConsumable.hasChipDamage));
         }
      }
      
      private function activateConsumableFromMercOrAlly(param1:ConsumableItem, param2:String) : void
      {
         this.selector = null;
         var _loc3_:Fleet = Fleet.getFleet(m_playerFleetName);
         _loc3_.setAllyUsed(param2);
         if(ZGlobal.combatAllyGatingVarient == ZGlobal.EXPERIMENT_ALLY_GATING_START_TIMERS_WHEN_USED)
         {
            ZGlobal.player.allies.startAllyTimer(param2);
         }
         m_blocked = true;
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_CONSUMABLE_USED,{
            "item":param1,
            "id":param2
         }));
         this.m_deferredConsumable = param1;
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_TRIGGER_CONSUMABLE,this.onTriggerConsumable);
      }
      
      private function activateConsumableFromQuestPower(param1:ConsumableItem, param2:String) : void
      {
         this.selector = null;
         var _loc3_:Fleet = Fleet.getFleet(m_playerFleetName);
         _loc3_.setAllyUsed(param2);
         TransactionManager.addTransaction(new TAssignConsumable(m_enemyFleetName,param2,0,0,null),true);
         m_blocked = true;
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_CONSUMABLE_USED,{
            "item":param1,
            "id":param2
         }));
         setAllyConsumable(param1,param1.targetsEnemy ? m_enemyGroup : m_playerGroup);
      }
      
      private function onTriggerConsumable(param1:Event) : void
      {
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_TRIGGER_CONSUMABLE,this.onTriggerConsumable);
         setAllyConsumable(this.m_deferredConsumable,this.m_deferredConsumable.targetsEnemy ? m_enemyGroup : m_playerGroup);
         this.m_deferredConsumable = null;
      }
      
      public function set ally(param1:String) : void
      {
         var _loc2_:ConsumableItem = ConsumableItem.getRandomConsumableForPlayer(param1,m_enemyFleetName,m_playerFleetName);
         this.activateConsumableFromMercOrAlly(_loc2_,param1);
      }
      
      public function set merc(param1:String) : void
      {
         var _loc2_:ConsumableItem = ConsumableItem.getRandomConsumableForMercenary(param1,m_enemyFleetName,m_playerFleetName);
         this.activateConsumableFromMercOrAlly(_loc2_,param1);
      }
      
      public function set questPower(param1:String) : void
      {
         var _loc2_:String = QuestPower.getCodeFromId(param1);
         var _loc3_:ConsumableItem = ZGlobal.gameSettings.getItemByCode(_loc2_,ConsumableItem) as ConsumableItem;
         this.activateConsumableFromQuestPower(_loc3_,param1);
      }
      
      private function onEnergyPopupClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.NO)
         {
            PopupManager.instance.push(GenericPopup2B.NewYesNo(ZGameUtils.ZlocT("Dialogs","CombatContinueLater"),null,this.onContinueCheck));
         }
      }
      
      private function onContinueCheck(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.YES)
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_PAUSE,{"inPreBattle":false}));
         }
      }
      
      private function onUnitUsedConsumableEnergy(param1:WorldEvent) : void
      {
         var _loc2_:BattleObject = param1.eventData.target as BattleObject;
         var _loc3_:int = int(param1.eventData.energy);
         if(_loc3_ != 0)
         {
            if(PlayerAmmo.variantAmmoMasterOn())
            {
               this.playerUnitFloatingText(_loc3_,AmmoFeedbackText.MEDIUM_ICON_URL,new AmmoFeedbackText(_loc3_),_loc2_);
            }
            else
            {
               this.playerUnitFloatingText(_loc3_,EnergyFeedbackText.MEDIUM_ICON_URL,new EnergyFeedbackText(_loc3_),_loc2_);
            }
         }
      }
   }
}

