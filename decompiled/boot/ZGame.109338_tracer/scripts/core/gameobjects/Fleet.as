package core.gameobjects
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleObject;
   import core.gameobjects.fleet.HitPercentageRecorder;
   import core.managers.AlliancesManager;
   import core.managers.ChipDamageManager;
   import core.managers.ExperimentsManager;
   import core.managers.domination.DominationModeManager;
   import core.managers.tutorialManager.TutorialManager;
   import core.managers.warehouseManager.WarehouseUnitManager;
   import core.managers.worldUnitManager.WorldUnitManager;
   import core.player.PlayerAmmo;
   import core.ui.menuitem.ContextualBarUIItem;
   import core.views.ViewManager;
   import core.worlds.battleWorld.BattleRendererComponent;
   import core.worlds.battleWorld.BattleUnit;
   import core.worlds.battleWorld.BattleWorld;
   import dispatchers.FleetDispatcher;
   import dispatchers.StrategicDispatcher;
   import displays.popups.buyAmmo.BuyAmmoPopup;
   import displays.popups.buyEnergy.BuyEnergyPopup;
   import displays.popups.buyMana.BuyManaPopup;
   import flash.utils.Dictionary;
   import transactions.TAssignConsumable;
   import utils.MegaUnitUtils;
   import utils.ZGameRandom;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class Fleet
   {
      
      public static const ARRIVED:String = "arrived";
      
      public static const TARGET_CHANGED:String = "targetChanged";
      
      public static const DEPLOY:String = "fleetdeploy";
      
      public static const ADD_TO_INVENTORY:Boolean = true;
      
      public static const REMOVE_FROM_INVENTORY:Boolean = false;
      
      public static const MAX_UNITS:int = 5;
      
      public static const QUEST:int = 1 << 0;
      
      public static const CAMPAIGN:int = 1 << 1;
      
      public static const CHALLENGE:int = 1 << 2;
      
      public static const DEPLOYED:int = 1 << 3;
      
      public static const VISITING:int = 1 << 4;
      
      public static const IN_COMBAT:int = 1 << 5;
      
      public static const IS_ATTACKING:int = 1 << 6;
      
      public static const FREE:int = 1 << 7;
      
      public static const PERSISTS:int = 1 << 8;
      
      public static const GLOBAL_PVP:int = 1 << 9;
      
      public static const QUESTTREE:int = 1 << 10;
      
      public static const SURVIVAL_PLAYER:int = 1 << 11;
      
      public static const SURVIVAL_ENEMY:int = 1 << 12;
      
      public static const RESTORE_ON_RETREAT:int = 1 << 13;
      
      public static const MECHLAB:int = 1 << 14;
      
      public static const DOMINATION_DEFENSE:int = 1 << 15;
      
      public static const DOMINATION_PLAYER:int = 1 << 16;
      
      public static const DOMINATION_ENEMY:int = 1 << 17;
      
      public static const DOMINATION_RETAL:int = 1 << 18;
      
      public static const QUEST_SURVIVAL:int = 1 << 19;
      
      public static const DEATHMATCH_PLAYER:int = 1 << 20;
      
      public static const DEATHMATCH_ENEMY:int = 1 << 21;
      
      public static const NO_ENERGY:int = 1 << 0;
      
      public static const DOUBLE_XP:int = 1 << 1;
      
      public static const HALF_RANSOM:int = 1 << 2;
      
      private static const FLEET_UNIT_IN_WORLD:int = 0;
      
      private static const FLEET_UNIT_IN_INVENTORY:int = 1;
      
      private static const FLEET_UNIT_IN_WAREHOUSE:int = 2;
      
      private static const FLEET_ALLY_UNUSED:int = 0;
      
      private static const FLEET_ALLY_USED:int = 1;
      
      private var m_name:String;
      
      private var m_type:String = null;
      
      private var m_units:Array = new Array();
      
      private var m_store:Array = null;
      
      private var m_allies:Dictionary = null;
      
      private var m_orderedAllies:Array = null;
      
      private var m_consumables:Array = null;
      
      private var m_doubleShot:Object = null;
      
      private var m_inventory:Array = null;
      
      private var m_lost:Dictionary = null;
      
      private var m_lastUnitLost:String = null;
      
      private var m_lastIndexLost:int = -1;
      
      private var m_fleetHasRevivedUnits:Boolean = false;
      
      private var m_status:int = 0;
      
      private var m_uid:String = null;
      
      private var m_hitPercentageRecorder:HitPercentageRecorder = null;
      
      private var m_playerLevel:int = 0;
      
      private var m_battleTimestamp:Number;
      
      private var m_battleTarget:String = null;
      
      private var m_ransomRandom:Number = 0;
      
      private var m_ransomResource:String = null;
      
      private var m_ransomAmount:int = 0;
      
      private var m_targetID:String = null;
      
      private var m_battleConsumableIndex:int = 0;
      
      private var m_upgrades:Dictionary = new Dictionary();
      
      private var m_specialBits:int = 0;
      
      public function Fleet(param1:Object, param2:String, param3:String)
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:Object = null;
         var _loc9_:Unit = null;
         var _loc10_:String = null;
         var _loc11_:Array = null;
         var _loc12_:Array = null;
         var _loc13_:String = null;
         var _loc14_:UnitItem = null;
         super();
         this.m_type = param2;
         if(param1 == null)
         {
            this.m_name = "Fleet_" + GlobalEngine.getTimer();
            this.m_uid = param3;
            this.m_playerLevel = ZGlobal.player.level;
         }
         else
         {
            this.m_name = param1.name;
            this.m_status = param1.status;
            this.m_targetID = param1.target;
            this.m_consumables = param1.consumables;
            this.m_inventory = param1.inventory;
            this.m_playerLevel = param1.playerLevel;
            if(null != param1.specialBits)
            {
               this.m_specialBits = param1.specialBits;
            }
            if(null != param1.lost)
            {
               this.m_lost = new Dictionary();
               for(_loc6_ in param1.lost)
               {
                  this.m_lost[_loc6_] = param1.lost[_loc6_];
               }
            }
            if(param1.lastUnitLost)
            {
               this.m_lastUnitLost = param1.lastUnitLost;
            }
            if(param1.lastIndexLost)
            {
               this.m_lastIndexLost = param1.lastIndexLost as int;
            }
            if(null != param1.allies)
            {
               this.m_allies = new Dictionary();
               this.m_orderedAllies = new Array();
               for(_loc7_ in param1.allies)
               {
                  _loc8_ = param1.allies[_loc7_];
                  this.m_allies[_loc8_.uid as String] = _loc8_.s;
                  this.m_orderedAllies.push(_loc8_.uid as String);
               }
            }
            if(param1.battleTarget)
            {
               this.m_battleTarget = param1.battleTarget;
            }
            if(param1.battleTimestamp)
            {
               this.m_battleTimestamp = param1.battleTimestamp;
            }
            if(param1.uid)
            {
               this.m_uid = param1.uid;
            }
            else
            {
               this.m_uid = param3;
            }
            if(param1.ransomRandom)
            {
               this.m_ransomRandom = param1.ransomRandom;
            }
            if(param1.ransomResource)
            {
               this.m_ransomResource = param1.ransomResource;
            }
            if(param1.ransomAmount)
            {
               this.m_ransomAmount = param1.ransomAmount;
            }
            this.cleanupFleetUnits(param1);
            _loc4_ = 0;
            for each(_loc5_ in param1.units)
            {
               _loc9_ = this.addUnit(_loc5_);
               if(!this.isOwnedByAI() && !this.hasStatus(FREE))
               {
                  _loc9_.source = param1.store[_loc4_];
                  if(_loc9_.source == FLEET_UNIT_IN_WAREHOUSE)
                  {
                     WarehouseUnitManager.instance.holdUnit(_loc9_.code,true);
                  }
               }
               _loc4_++;
            }
            if(param1.fleets)
            {
               for each(param1 in param1.fleets)
               {
                  this.addFleet(param1);
               }
            }
            if(param1.upgrades)
            {
               this.m_upgrades = new Dictionary();
               for(_loc10_ in param1.upgrades)
               {
                  _loc11_ = param1.upgrades[_loc10_].split(",");
                  _loc12_ = new Array();
                  for each(_loc13_ in _loc11_)
                  {
                     _loc12_.push(_loc13_);
                  }
                  this.m_upgrades[_loc10_] = _loc12_;
                  _loc14_ = ZGlobal.gameSettings.getItemByCode(_loc10_,UnitItem) as UnitItem;
                  if((Boolean(_loc14_)) && _loc14_.hasType(UnitItem.MEGA_UNIT))
                  {
                     this.m_upgrades[_loc14_.megaTemplate] = _loc12_;
                  }
               }
            }
            if(null != param1.hp)
            {
               this.createHitPercentageRecorder(param1.hp);
            }
         }
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_SEQUENCE_COMPLETE,this.onBattleSequenceComplete);
      }
      
      public static function linkFleets(param1:Fleet, param2:Fleet) : void
      {
         param1.battleTarget = param2.name;
         param2.battleTarget = param1.name;
      }
      
      public static function getFleet(param1:String) : Fleet
      {
         var _loc2_:Fleet = ZGlobal.player.fleets.getFleetByName(param1);
         if(null == _loc2_ && ZGlobal.hostPlayer != ZGlobal.player)
         {
            _loc2_ = ZGlobal.hostPlayer.fleets.getFleetByName(param1);
         }
         return _loc2_;
      }
      
      public static function getDeployableCount(param1:String) : int
      {
         var _loc2_:int = 0;
         var _loc3_:Dictionary = WorldUnitManager.instance.availableUnits;
         if(_loc3_[param1] != undefined)
         {
            _loc2_ = int(_loc3_[param1]);
         }
         return int(_loc2_ + ZGlobal.player.getNumberOfInventoryItems(param1));
      }
      
      private static function getAvailableCount(param1:String) : int
      {
         return int(WorldUnitManager.instance.numUnits(param1) + ZGlobal.player.getNumberOfInventoryItems(param1));
      }
      
      public function get specialBits() : int
      {
         return this.m_specialBits;
      }
      
      public function cleanupFleetUnits(param1:Object) : void
      {
         var _loc8_:String = null;
         var _loc9_:UnitItem = null;
         var _loc2_:Array = new Array();
         var _loc3_:int = -1;
         var _loc4_:int = -1;
         var _loc5_:Array = new Array();
         var _loc6_:String = "";
         var _loc7_:int = 0;
         var _loc10_:* = 0;
         for each(_loc8_ in param1.units)
         {
            _loc5_ = _loc8_.split(",");
            _loc6_ = _loc5_[0];
            _loc7_ = _loc5_[1] * 1;
            _loc9_ = ZGlobal.gameSettings.getItemByCode(_loc6_,UnitItem) as UnitItem;
            if((Boolean(_loc9_)) && _loc9_.hasType(UnitItem.MEGA_UNIT_CONTROLLER))
            {
               _loc2_.push({
                  "index":_loc10_,
                  "strength":_loc7_
               });
               if(_loc7_ > _loc3_)
               {
                  _loc3_ = _loc7_;
                  _loc4_ = _loc2_.length - 1;
               }
            }
            _loc10_++;
         }
         if(_loc2_.length > 1)
         {
            _loc10_ = 0;
            _loc9_ = ZGlobal.gameSettings.getItemByCode(param1.lastUnitLost,UnitItem) as UnitItem;
            if((Boolean(_loc9_)) && _loc9_.hasType(UnitItem.MEGA_UNIT_CONTROLLER))
            {
               if(_loc3_ > 0)
               {
                  this.m_lastUnitLost = null;
               }
               else
               {
                  this.m_lastIndexLost = _loc2_[0].index;
               }
            }
            if(_loc2_[0].strength != _loc3_)
            {
               param1.units.splice(_loc2_[0].index,0,param1.units[_loc2_[_loc4_].index]);
               param1.units.splice(_loc2_[0].index + 1,1);
            }
            _loc10_ = int(_loc2_.length - 1);
            while(_loc10_ >= 1)
            {
               param1.units.splice(_loc2_[_loc10_].index,1);
               _loc10_--;
            }
         }
      }
      
      public function clearWarehouseHoldings() : void
      {
         var _loc1_:Unit = null;
         for each(_loc1_ in this.m_units)
         {
            if(_loc1_.source == FLEET_UNIT_IN_WAREHOUSE)
            {
               WarehouseUnitManager.instance.releaseUnit(_loc1_.code);
            }
         }
      }
      
      public function dispose() : void
      {
         BattleDispatcher.instance.removeEventListener(BattleDispatcher.BATTLE_SEQUENCE_COMPLETE,this.onBattleSequenceComplete);
         this.m_status = 0;
         this.m_units = null;
         this.m_targetID = null;
      }
      
      public function clearUnits() : void
      {
         this.m_units = new Array();
      }
      
      public function get name() : String
      {
         return this.m_name;
      }
      
      public function set name(param1:String) : void
      {
         this.m_name = param1;
      }
      
      public function get type() : String
      {
         return this.m_type;
      }
      
      public function get damaged() : Boolean
      {
         var _loc1_:Unit = null;
         var _loc2_:UnitItem = null;
         var _loc3_:Number = NaN;
         for each(_loc1_ in this.m_units)
         {
            if(!_loc1_.dead)
            {
               _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_.code,UnitItem) as UnitItem;
               _loc3_ = _loc2_.getStrength(this);
               if(_loc1_.strength < _loc3_)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function get playerLevel() : int
      {
         return this.m_playerLevel;
      }
      
      public function getStrengthPercentage() : Number
      {
         var _loc3_:Unit = null;
         var _loc4_:UnitItem = null;
         var _loc1_:Number = 0;
         var _loc2_:Number = 0;
         for each(_loc3_ in this.m_units)
         {
            _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_.code,UnitItem) as UnitItem;
            _loc2_ += _loc4_.getStrength(this);
            _loc1_ += _loc3_.strength;
         }
         return _loc2_ > 0 ? _loc1_ / _loc2_ : 0;
      }
      
      public function set type(param1:String) : void
      {
         this.m_type = param1;
      }
      
      public function get units() : Array
      {
         return this.m_units;
      }
      
      public function get upgrades() : Dictionary
      {
         return this.m_upgrades;
      }
      
      public function get lost() : Dictionary
      {
         return this.m_lost;
      }
      
      public function get lastUnitLost() : String
      {
         return this.m_lastUnitLost;
      }
      
      public function set lastUnitLost(param1:String) : void
      {
         this.m_lastUnitLost = param1;
      }
      
      public function get lastIndexLost() : int
      {
         return this.m_lastIndexLost;
      }
      
      public function set lastIndexLost(param1:int) : void
      {
         this.m_lastIndexLost = param1;
      }
      
      public function get allies() : Dictionary
      {
         return this.m_allies;
      }
      
      public function get orderedAllies() : Array
      {
         return this.m_orderedAllies;
      }
      
      public function get inventory() : Array
      {
         return this.m_inventory;
      }
      
      public function set inventory(param1:Array) : void
      {
         this.m_inventory = param1;
      }
      
      public function getUpgrades(param1:String) : Array
      {
         var _loc2_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1,UnitItem) as UnitItem;
         if(null != this.m_upgrades && !_loc2_.hasType(UnitItem.MEGA_UNIT))
         {
            return this.m_upgrades[param1];
         }
         if(null != this.m_upgrades && _loc2_.hasType(UnitItem.MEGA_UNIT))
         {
            return this.m_upgrades[_loc2_.megaTemplate];
         }
         return null;
      }
      
      public function set targetID(param1:String) : void
      {
         this.m_targetID = param1;
         FleetDispatcher.instance.dispatchEvent(new WorldEvent(Fleet.TARGET_CHANGED,this));
      }
      
      public function get targetID() : String
      {
         return this.m_targetID;
      }
      
      public function get hitPercentageRecorder() : HitPercentageRecorder
      {
         return this.m_hitPercentageRecorder;
      }
      
      public function createHitPercentageRecorder(param1:Object) : void
      {
         if(ZGlobal.gameSettings.getString("combatEnableMissBonus","false") == "true")
         {
            this.m_hitPercentageRecorder = new HitPercentageRecorder(param1);
         }
      }
      
      public function restore() : void
      {
         var _loc1_:Unit = null;
         var _loc2_:UnitItem = null;
         if(this.hasStatus(Fleet.RESTORE_ON_RETREAT))
         {
            this.removeConsumables();
            for each(_loc1_ in this.m_units)
            {
               _loc2_ = ZGlobal.gameSettings.getItemByCode(_loc1_.code,UnitItem) as UnitItem;
               _loc1_.strength = _loc2_.getStrength(this);
            }
         }
      }
      
      public function removeConsumables() : void
      {
         this.m_consumables = null;
      }
      
      public function setStatus(param1:int) : void
      {
         this.m_status |= param1;
      }
      
      public function clearStatus(param1:int) : void
      {
         this.m_status &= ~param1;
      }
      
      public function hasStatus(param1:int) : Boolean
      {
         return (this.m_status & param1) != 0;
      }
      
      public function get uid() : String
      {
         return this.m_uid;
      }
      
      public function set uid(param1:String) : void
      {
         this.m_uid = param1;
      }
      
      public function get battleTarget() : String
      {
         return this.m_battleTarget;
      }
      
      public function set battleTarget(param1:String) : void
      {
         this.m_battleTarget = param1;
      }
      
      public function get battleTimestamp() : Number
      {
         return this.m_battleTimestamp;
      }
      
      public function set battleTimestamp(param1:Number) : void
      {
         this.m_battleTimestamp = param1;
      }
      
      public function setOutOfCombat() : void
      {
         this.clearStatus(IN_COMBAT);
         this.m_battleTarget = null;
      }
      
      private function spendConsumable(param1:ConsumableItem, param2:Boolean, param3:Boolean, param4:BattleObject = null) : Boolean
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:Unit = null;
         var _loc11_:BattleRendererComponent = null;
         var _loc12_:BattleUnit = null;
         var _loc13_:Object = null;
         var _loc14_:Object = null;
         if(!param3)
         {
            return true;
         }
         if(param1.givesShield && param1.affectsAll)
         {
            _loc9_ = true;
            for each(_loc10_ in this.m_units)
            {
               if(_loc10_.shields == 0)
               {
                  _loc9_ = false;
               }
            }
            if(_loc9_ == true)
            {
               ContextualBarUIItem(ContextualBarUIItem.getContextualBar()).getCombatBar().allowSpecialPowerSelection2(true);
               _loc11_ = BattleRendererComponent(ViewManager.instance.getComponentFromView(BattleWorld.ID,BattleRendererComponent));
               _loc12_ = _loc11_.getBattleUnit(param4);
               _loc13_ = new Object();
               _loc13_["float"] = true;
               _loc13_["text"] = ZGameUtils.ZlocT("Items","shieldExists");
               _loc13_["autoSize"] = true;
               _loc12_.floatingText(0,_loc12_.x,_loc12_.y,_loc13_);
               return false;
            }
         }
         _loc5_ = param2 ? 0 : param1.energy;
         _loc6_ = ExperimentsManager.instance.getExperimentVariant("empire_consumable_energy");
         if(_loc6_ > 2 && param1.secondary == false)
         {
            _loc5_ = 1;
         }
         _loc7_ = false;
         _loc8_ = ZGlobal.player.m_energy.checkEnergy(_loc5_);
         if(PlayerAmmo.variantAmmoMasterOn())
         {
            _loc7_ = true;
            _loc8_ = ZGlobal.player.m_ammo.checkAmmo(_loc5_);
         }
         if(_loc8_)
         {
            if(ZGlobal.player.mana.allow(param1.mana))
            {
               if(this.useConsumable(param1,param2))
               {
                  if(_loc7_)
                  {
                     ZGlobal.player.m_ammo.ammo -= _loc5_;
                  }
                  else
                  {
                     ZGlobal.player.m_energy.energy -= _loc5_;
                  }
                  if(param4 != null)
                  {
                     _loc14_ = new Object();
                     _loc14_.target = param4;
                     _loc14_.energy = _loc5_;
                     BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_UNIT_USED_CONSUMABLE_ENERGY,_loc14_));
                  }
                  ZGlobal.player.mana.spend(param1.mana);
                  return true;
               }
            }
            else
            {
               PopupManager.instance.push(new BuyManaPopup());
            }
         }
         else if(_loc7_)
         {
            PopupManager.instance.push(new BuyAmmoPopup(null,true));
         }
         else
         {
            BuyEnergyPopup.enableWatchToEarn();
            BuyEnergyPopup.show();
         }
         return false;
      }
      
      public function affectedByConsumable(param1:String, param2:int) : Boolean
      {
         var _loc3_:ConsumableItem = null;
         var _loc4_:Object = null;
         if(this.m_consumables)
         {
            _loc3_ = ZGlobal.gameSettings.getItemByCode(param1,ConsumableItem) as ConsumableItem;
            for each(_loc4_ in this.m_consumables)
            {
               if(_loc4_.code == param1)
               {
                  if(_loc3_.affectsAll || _loc4_.id == param2)
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      public function addConsumable(param1:String, param2:int, param3:Boolean, param4:Boolean, param5:BattleObject = null) : Boolean
      {
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         var _loc9_:String = null;
         var _loc10_:Object = null;
         var _loc6_:ConsumableItem = ZGlobal.gameSettings.getItemByCode(param1,ConsumableItem) as ConsumableItem;
         if(this.spendConsumable(_loc6_,param3,param4,param5))
         {
            if(null == this.m_consumables)
            {
               this.m_consumables = new Array();
            }
            _loc7_ = new Object();
            _loc7_.code = param1;
            _loc7_.duration = _loc6_.duration;
            _loc7_.originalDuration = _loc6_.duration;
            _loc7_.id = param2;
            this.m_consumables.push(_loc7_);
            if(!param3)
            {
               TransactionManager.addTransaction(new TAssignConsumable(this.m_name,param1,param2,0,null),true);
               if(TutorialManager.instance.active)
               {
                  TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.COMBAT_CONSUMABLE_USED));
               }
               _loc8_ = {"item":_loc6_};
               if(AlliancesManager.instance.allianceBattle)
               {
                  _loc8_ = new Object();
                  _loc8_.item = _loc6_;
                  _loc8_.playerRank = DominationModeManager.instance.dominanceRank;
                  _loc9_ = DominationModeManager.instance.getDominationEnemyUID();
                  _loc10_ = DominationModeManager.instance.getDominationInfo(_loc9_);
                  _loc8_.enemyRank = -1;
                  if(_loc10_)
                  {
                     _loc8_.enemyRank = _loc10_.dr;
                  }
                  _loc8_.alliance = true;
               }
               BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.BATTLE_POWERUP_CONSUMABLE_USED,_loc8_));
               StatsManager.count("game_actions","combat","use_consumable","",_loc6_.getFriendlyName(GameItem.MENU_FRIENDLYNAME));
            }
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_CONSUMABLES_UPDATED,{
               "fleet":this,
               "id":param2
            }));
            return true;
         }
         return false;
      }
      
      public function getRandomLiveUnitIndexFromFleet(param1:Boolean) : int
      {
         if(param1)
         {
            return this.getRandomLiveUnitIndexFromDamagedFleet();
         }
         return this.getRandomLiveUnitIndexFromEntireFleet();
      }
      
      private function getRandomLiveUnitIndexFromDamagedFleet() : int
      {
         var _loc2_:Unit = null;
         var _loc3_:UnitItem = null;
         var _loc4_:Number = NaN;
         var _loc1_:Array = new Array();
         for each(_loc2_ in this.m_units)
         {
            if(!_loc2_.dead)
            {
               _loc3_ = ZGlobal.gameSettings.getItemByCode(_loc2_.code,UnitItem) as UnitItem;
               _loc4_ = _loc3_.getStrength(this);
               if(_loc2_.strength < _loc4_)
               {
                  _loc1_.push(_loc2_.id);
               }
            }
         }
         if(_loc1_.length > 0)
         {
            return this.getRandomUnitIndexFromList(_loc1_);
         }
         return this.getRandomLiveUnitIndexFromEntireFleet();
      }
      
      private function getRandomLiveUnitIndexFromEntireFleet() : int
      {
         var _loc2_:Unit = null;
         var _loc1_:Array = new Array();
         for each(_loc2_ in this.m_units)
         {
            if(!_loc2_.dead)
            {
               _loc1_.push(_loc2_.id);
            }
         }
         return this.getRandomUnitIndexFromList(_loc1_);
      }
      
      private function getRandomUnitIndexFromList(param1:Array) : int
      {
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         if(param1.length > 0)
         {
            if(param1.length == 1)
            {
               return param1[0];
            }
            _loc2_ = ZGameRandom.instance.randBetween(0,param1.length - 1);
            _loc3_ = int(Math.round(_loc2_));
            return param1[_loc3_];
         }
         return 0;
      }
      
      public function startConsumables() : void
      {
         this.m_battleConsumableIndex = 0;
      }
      
      public function getBattleObject(param1:int, param2:Array) : BattleObject
      {
         var _loc3_:BattleObject = null;
         for each(_loc3_ in param2)
         {
            if(_loc3_.unit.id == param1)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function triggerDOTConsumables(param1:Array, param2:BattleObject) : Number
      {
         return this.triggerConsumables(param1,param2,"dot");
      }
      
      public function triggerDIConsumables(param1:Array, param2:BattleObject, param3:int, param4:ConsumableItem) : Number
      {
         return this.triggerConsumable(param4,"di",param2,param1,param3);
      }
      
      private function triggerConsumables(param1:Array, param2:BattleObject, param3:String) : Number
      {
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:ConsumableItem = null;
         var _loc4_:Number = 0;
         if(null != this.m_consumables)
         {
            _loc5_ = this.m_battleConsumableIndex;
            while(_loc5_ < this.m_consumables.length)
            {
               _loc6_ = this.m_consumables[_loc5_];
               _loc7_ = ZGlobal.gameSettings.getItemByCode(_loc6_.code,ConsumableItem) as ConsumableItem;
               if(_loc7_[param3] != 0)
               {
                  this.m_battleConsumableIndex = _loc5_ + 1;
                  _loc4_ = Math.max(_loc4_,this.triggerConsumable(_loc7_,param3,param2,param1,_loc6_.id));
               }
               _loc5_++;
            }
         }
         return _loc4_;
      }
      
      private function triggerConsumable(param1:ConsumableItem, param2:String, param3:BattleObject, param4:Array, param5:int) : Number
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:BattleObject = null;
         var _loc10_:Number = NaN;
         var _loc6_:BattleObject = null;
         if(param1.affectsAll)
         {
            _loc7_ = param1.percent;
            for each(_loc6_ in param4)
            {
               if(!_loc6_.unit.dead)
               {
                  if(_loc7_ != 1)
                  {
                     _loc8_ = ZGameRandom.instance.float();
                     if(_loc8_ > _loc7_)
                     {
                        BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_MISS,{
                           "attacker":param3,
                           "target":_loc6_,
                           "delay":param1.randomHitDelay,
                           "breakOut":true,
                           "subType":"sa"
                        }));
                        continue;
                     }
                  }
                  BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_DAMAGE_FROM_CONSUMABLE,{
                     "consumable":param1,
                     "target":_loc6_,
                     "type":param2,
                     "delay":param1.randomHitDelay
                  }));
               }
            }
         }
         else if(param1.hasChipDamage)
         {
            _loc9_ = this.getBattleObject(param5,param4);
            for each(_loc6_ in param4)
            {
               _loc10_ = ChipDamageManager.instance.getDamage(_loc9_,_loc6_,param1);
               if(_loc10_ > 0)
               {
                  BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_DAMAGE_FROM_CONSUMABLE,{
                     "consumable":param1,
                     "target":_loc6_,
                     "type":param2,
                     "chipDamage":_loc10_,
                     "delay":param1.randomHitDelay
                  }));
               }
            }
            _loc6_ = this.getBattleObject(param5,param4);
            if((Boolean(_loc6_)) && !_loc6_.unit.dead)
            {
               BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_DAMAGE_FROM_CONSUMABLE,{
                  "consumable":param1,
                  "target":_loc6_,
                  "type":param2,
                  "delay":param1.randomHitDelay
               }));
            }
         }
         else
         {
            _loc6_ = this.getBattleObject(param5,param4);
            if((Boolean(_loc6_)) && !_loc6_.unit.dead)
            {
               BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_DAMAGE_FROM_CONSUMABLE,{
                  "consumable":param1,
                  "target":_loc6_,
                  "type":param2,
                  "delay":param1.randomHitDelay
               }));
            }
         }
         return param1.postWait;
      }
      
      private function isOwnedByAI() : Boolean
      {
         if(this.hasStatus(CAMPAIGN))
         {
            return true;
         }
         if(this.hasStatus(QUEST))
         {
            return true;
         }
         if(this.hasStatus(MECHLAB))
         {
            return true;
         }
         return false;
      }
      
      public function isOwnedByPlayer(param1:String) : Boolean
      {
         if(this.isOwnedByAI())
         {
            return false;
         }
         if(this.hasStatus(SURVIVAL_ENEMY))
         {
            return false;
         }
         if(this.m_uid != param1)
         {
            return false;
         }
         return true;
      }
      
      public function die() : void
      {
         this.dispose();
      }
      
      public function contain(param1:String) : Boolean
      {
         return true;
      }
      
      public function addFleet(param1:Object) : void
      {
      }
      
      public function addUnit(param1:Object, param2:int = -1) : Unit
      {
         var _loc5_:Unit = null;
         var _loc6_:Unit = null;
         var _loc3_:int = int(this.m_units.length);
         var _loc4_:int = -1;
         for each(_loc5_ in this.m_units)
         {
            if(_loc4_ < _loc5_.id)
            {
               _loc4_ = _loc5_.id;
            }
         }
         if(_loc3_ < MAX_UNITS)
         {
            _loc6_ = new Unit(param1,_loc4_ + 1,this);
            if(param2 < 0)
            {
               this.m_units.push(_loc6_);
            }
            else
            {
               this.m_units.splice(param2,0,_loc6_);
            }
            return _loc6_;
         }
         return null;
      }
      
      public function get numUnits() : Number
      {
         return this.m_units ? this.m_units.length : 0;
      }
      
      public function addConsumableToInventory(param1:String) : void
      {
         if(this.m_inventory == null)
         {
            this.m_inventory = new Array();
         }
         this.m_inventory.push(param1);
         ZGlobal.player.removeInventoryItem(param1);
      }
      
      private function removeConsumableFromInventory(param1:String) : Boolean
      {
         var _loc2_:Fleet = null;
         var _loc3_:int = 0;
         if(this.m_inventory != null)
         {
            _loc3_ = this.m_inventory.indexOf(param1);
            if(_loc3_ >= 0)
            {
               this.m_inventory.splice(_loc3_,1);
               return true;
            }
         }
         if(this.hasStatus(CAMPAIGN))
         {
            _loc2_ = Fleet.getFleet(ZGlobal.player.campaign.currentMap.fleets[0]);
            return _loc2_.removeConsumableFromInventory(param1);
         }
         return false;
      }
      
      public function addAlly(param1:String) : void
      {
         if(null == this.m_allies)
         {
            this.m_orderedAllies = new Array();
            this.m_allies = new Dictionary();
         }
         this.m_allies[param1] = FLEET_ALLY_UNUSED;
         this.m_orderedAllies.push(param1);
      }
      
      public function setAllyUsed(param1:String) : void
      {
         this.m_allies[param1] = FLEET_ALLY_USED;
      }
      
      public function hasAlly(param1:String) : Boolean
      {
         return null != this.m_allies[param1];
      }
      
      public function removeUnitObject(param1:Unit) : void
      {
         var _loc2_:int = this.m_units.indexOf(param1);
         if(_loc2_ >= 0)
         {
            if(param1.source == FLEET_UNIT_IN_WAREHOUSE)
            {
               WarehouseUnitManager.instance.remove(param1.code);
            }
            this.addToLost(param1.code);
            this.m_units.splice(_loc2_,1);
         }
      }
      
      public function retreatUnitObject(param1:Unit) : void
      {
         var _loc2_:int = this.m_units.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.modifyUnitInventory(param1,ADD_TO_INVENTORY);
            this.m_units.splice(_loc2_,1);
         }
      }
      
      public function countUnits(param1:String) : int
      {
         var _loc3_:Unit = null;
         var _loc2_:int = 0;
         for each(_loc3_ in this.m_units)
         {
            if(_loc3_.code == param1)
            {
               _loc2_++;
            }
         }
         return _loc2_;
      }
      
      public function canDeploy() : Boolean
      {
         var _loc2_:Unit = null;
         var _loc1_:Dictionary = new Dictionary();
         for each(_loc2_ in this.m_units)
         {
            if(null == _loc1_[_loc2_.code])
            {
               _loc1_[_loc2_.code] = 0;
            }
            _loc1_[_loc2_.code] += 1;
         }
         if(this.playerHasUnits(_loc1_))
         {
            FleetDispatcher.instance.dispatchEvent(new WorldEvent(Fleet.TARGET_CHANGED,this));
            return true;
         }
         return false;
      }
      
      public function deployContainedFleets(param1:Pt) : void
      {
      }
      
      public function teleport(param1:Pt) : void
      {
      }
      
      public function deploy() : void
      {
         this.setStatus(DEPLOYED);
         this.modifyInventory(REMOVE_FROM_INVENTORY);
         StrategicDispatcher.instance.dispatchEvent(new WorldEvent(StrategicDispatcher.DEPLOY,this));
      }
      
      public function undeploy(param1:int) : void
      {
         this.clearStatus(DEPLOYED);
         this.modifyInventory(ADD_TO_INVENTORY,param1);
      }
      
      public function finishedWithAllies() : void
      {
         var _loc1_:String = null;
         for(_loc1_ in this.m_allies)
         {
            ZGlobal.player.allies.startAllyTimer(_loc1_);
         }
      }
      
      public function finishedWithConsumables() : void
      {
         var _loc1_:int = 0;
         if(this.m_inventory != null)
         {
            _loc1_ = 0;
            while(_loc1_ < this.m_inventory.length)
            {
               ZGlobal.player.addToInventory(this.m_inventory[_loc1_]);
               _loc1_++;
            }
         }
      }
      
      public function serialisableObject(param1:Array = null) : Object
      {
         var _loc4_:Unit = null;
         var _loc5_:Object = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc2_:Array = new Array();
         var _loc3_:int = 0;
         for each(_loc4_ in this.units)
         {
            _loc2_.push(_loc4_.serialisableObject(null != param1 ? Number(param1[_loc3_]) : -1));
            _loc3_++;
         }
         _loc5_ = new Object();
         _loc5_.name = this.m_name;
         _loc5_.type = this.m_type;
         _loc5_.uid = this.m_uid;
         _loc5_.status = this.m_status;
         _loc5_.units = _loc2_;
         if(null != this.m_allies)
         {
            _loc5_.allies = new Array();
            for(_loc6_ in this.m_allies)
            {
               _loc5_.allies.push(_loc6_);
            }
         }
         if(null != this.m_inventory)
         {
            _loc5_.inventory = new Array();
            _loc7_ = 0;
            while(_loc7_ < this.m_inventory.length)
            {
               _loc5_.inventory.push(this.m_inventory[_loc7_]);
               _loc7_++;
            }
         }
         return _loc5_;
      }
      
      private function addToLost(param1:String) : void
      {
         if(!this.hasStatus(QUEST))
         {
            if(null == this.m_lost)
            {
               this.m_lost = new Dictionary();
            }
            if(null == this.m_lost[param1])
            {
               this.m_lost[param1] = 0;
            }
            this.m_lost[param1] += 1;
         }
      }
      
      private function reviveFromLost() : Unit
      {
         var _loc1_:Unit = this.addUnit(this.m_lastUnitLost,this.m_lastIndexLost);
         if(_loc1_)
         {
            if(null != this.m_lost && null != this.m_lost[this.m_lastUnitLost] && this.m_lost[this.m_lastUnitLost] > 0)
            {
               this.m_lost[this.m_lastUnitLost] = this.m_lost[this.m_lastUnitLost] - 1;
            }
            this.m_fleetHasRevivedUnits = true;
            return _loc1_;
         }
         return null;
      }
      
      public function reviveUnits(param1:Array) : Boolean
      {
         var _loc3_:BattleObject = null;
         var _loc4_:Unit = null;
         if(null == this.m_lastUnitLost)
         {
            return false;
         }
         var _loc2_:UnitItem = ZGlobal.gameSettings.getItemByCode(this.m_lastUnitLost,UnitItem) as UnitItem;
         if(_loc2_.hasType(UnitItem.MEGA_UNIT_CONTROLLER))
         {
            this.removeUnitObject(this.units[this.m_lastIndexLost]);
         }
         _loc4_ = this.reviveFromLost();
         _loc4_.source = FLEET_UNIT_IN_INVENTORY;
         _loc3_ = new BattleObject(_loc4_,this,new Array());
         BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.REVIVE_UNITS,_loc3_));
         return true;
      }
      
      public function get hasRevivedUnits() : Boolean
      {
         return this.m_fleetHasRevivedUnits;
      }
      
      private function modifyUnitInventory(param1:Unit, param2:Boolean) : void
      {
         var _loc3_:String = MegaUnitUtils.getMegaUnitTemplateCode(param1.code);
         if(param2 == ADD_TO_INVENTORY)
         {
            switch(param1.source)
            {
               case FLEET_UNIT_IN_INVENTORY:
                  ZGlobal.player.addToInventory(_loc3_);
                  break;
               case FLEET_UNIT_IN_WORLD:
                  WorldUnitManager.instance.releaseUnit(_loc3_,WorldUnitManager.UNIT_IN_FLEET);
                  break;
               case FLEET_UNIT_IN_WAREHOUSE:
                  WarehouseUnitManager.instance.releaseUnit(_loc3_);
            }
         }
         else if(ZGlobal.player.removeInventoryItem(_loc3_))
         {
            param1.source = FLEET_UNIT_IN_INVENTORY;
         }
         else if(WorldUnitManager.instance.holdUnit(_loc3_,WorldUnitManager.UNIT_IN_FLEET))
         {
            param1.source = FLEET_UNIT_IN_WORLD;
         }
         else if(WarehouseUnitManager.instance.holdUnit(_loc3_,false))
         {
            param1.source = FLEET_UNIT_IN_WAREHOUSE;
         }
         else
         {
            Logger.error(this,"modifyUnitInventory","unable to hold unit");
         }
      }
      
      private function modifyInventory(param1:Boolean, param2:int = 0) : void
      {
         var _loc3_:Unit = null;
         var _loc4_:String = null;
         var _loc5_:MercenaryItem = null;
         if(this.hasStatus(CAMPAIGN) || this.hasStatus(FREE) || this.hasStatus(QUEST) || this.m_uid != ZGlobal.player.uid)
         {
            return;
         }
         if(null != this.m_units)
         {
            if(!(param1 == ADD_TO_INVENTORY && param2 == Battle.BATTLE_RESULT_LOST))
            {
               for each(_loc3_ in this.m_units)
               {
                  this.modifyUnitInventory(_loc3_,param1);
               }
            }
         }
         if(null != this.m_allies)
         {
            for(_loc4_ in this.m_allies)
            {
               _loc5_ = ZGlobal.gameSettings.getItemByCode(_loc4_,MercenaryItem) as MercenaryItem;
               if(null != _loc5_)
               {
                  if(param1 == ADD_TO_INVENTORY)
                  {
                     if(param2 == Battle.BATTLE_RESULT_RETREAT)
                     {
                        if(this.m_allies[_loc4_] == FLEET_ALLY_UNUSED)
                        {
                           ZGlobal.player.addToInventory(_loc4_);
                        }
                     }
                  }
                  else if(!ZGlobal.player.removeInventoryItem(_loc4_))
                  {
                     Logger.error(this,"modifyInventory","unable to remove mercenary " + _loc4_ + " from inventory");
                  }
               }
            }
         }
      }
      
      public function hasFlameConsumable() : Boolean
      {
         var _loc1_:ConsumableItem = null;
         var _loc2_:Number = 0;
         var _loc3_:Object = null;
         if(this.m_consumables)
         {
            for each(_loc3_ in this.m_consumables)
            {
               _loc1_ = ZGlobal.gameSettings.getItemByCode(_loc3_.code,ConsumableItem) as ConsumableItem;
               if(_loc1_.givesFlameAbilty)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      private function getModifier(param1:Fleet, param2:int, param3:int, param4:String, param5:String) : Number
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc6_:ConsumableItem = null;
         var _loc7_:Number = 0;
         var _loc8_:Object = null;
         if(this.m_consumables)
         {
            for each(_loc8_ in this.m_consumables)
            {
               _loc6_ = ZGlobal.gameSettings.getItemByCode(_loc8_.code,ConsumableItem) as ConsumableItem;
               if(_loc6_.affectsAll || _loc8_.id == param3)
               {
                  _loc9_ = Number(_loc6_[param4]);
                  if(_loc9_ != 0)
                  {
                     _loc7_ += _loc9_;
                  }
               }
            }
         }
         if(Boolean(param1) && Boolean(param1.m_consumables))
         {
            for each(_loc8_ in param1.m_consumables)
            {
               _loc6_ = ZGlobal.gameSettings.getItemByCode(_loc8_.code,ConsumableItem) as ConsumableItem;
               if(_loc6_.affectsAll || _loc8_.id == param2)
               {
                  _loc10_ = Number(_loc6_[param5]);
                  if(_loc10_ != 0)
                  {
                     _loc7_ -= _loc10_;
                  }
               }
            }
         }
         return _loc7_;
      }
      
      private function onBattleSequenceComplete(param1:WorldEvent) : void
      {
         this.updateConsumables(param1.eventData.endTurn);
      }
      
      private function updateConsumables(param1:Boolean) : void
      {
         var _loc3_:* = 0;
         var _loc2_:Boolean = false;
         if(null != this.m_consumables)
         {
            _loc2_ = this.m_consumables.length > 0;
            _loc3_ = 0;
            while(_loc3_ < this.m_consumables.length)
            {
               if(param1)
               {
                  --this.m_consumables[_loc3_].duration;
               }
               if(this.m_consumables[_loc3_].duration <= 0)
               {
                  if(this.m_consumables[_loc3_].code == ConsumableItem.DOUBLE_SHOT_ITEM_CODE && this.m_consumables[_loc3_].duration <= 0)
                  {
                     this.m_consumables[_loc3_].duration = 1;
                     this.m_doubleShot = new Object();
                     this.m_doubleShot = this.m_consumables[_loc3_];
                  }
                  this.m_consumables.splice(_loc3_,1);
                  _loc3_--;
                  if(this.m_consumables.length == 0)
                  {
                     this.m_consumables = null;
                     break;
                  }
               }
               _loc3_++;
            }
         }
         if(Boolean(this.m_doubleShot) && this.m_doubleShot.duration == 0)
         {
            this.m_doubleShot = null;
            _loc2_ = true;
         }
         else if(this.m_doubleShot)
         {
            this.m_doubleShot.duration = 0;
            _loc2_ = true;
         }
         if(_loc2_)
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.UNIT_CONSUMABLES_UPDATED,{"fleet":this}));
         }
      }
      
      public function get doubleShot() : Object
      {
         return this.m_doubleShot;
      }
      
      public function resetDoubleShot() : void
      {
         if(this.m_doubleShot)
         {
            this.m_doubleShot = null;
         }
      }
      
      public function getConsumables(param1:int) : Array
      {
         var _loc3_:Object = null;
         var _loc4_:ConsumableItem = null;
         var _loc2_:Array = new Array();
         if(null != this.m_consumables)
         {
            for each(_loc3_ in this.m_consumables)
            {
               _loc4_ = ZGlobal.gameSettings.getItemByCode(_loc3_.code,ConsumableItem) as ConsumableItem;
               if(_loc4_.affectsAll || _loc3_.id == param1 || _loc4_.hasChipDamage && ChipDamageManager.instance.isAdjacent(_loc3_.id,param1))
               {
                  _loc2_.push(_loc3_);
               }
            }
         }
         return _loc2_;
      }
      
      public function getDamageModifier(param1:Fleet, param2:int, param3:int) : Number
      {
         return this.getModifier(param1,param2,param3,"damageBonus","shieldBonus");
      }
      
      public function getToHitModifier(param1:Fleet, param2:int, param3:int) : Number
      {
         return this.getModifier(param1,param2,param3,"attackBonus","defenseBonus");
      }
      
      public function getStrengthModifier(param1:int) : Number
      {
         return this.getModifier(null,-1,param1,"strengthBonus",null);
      }
      
      private function playerHasUnits(param1:Dictionary) : Boolean
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         for(_loc2_ in param1)
         {
            _loc3_ = getAvailableCount(_loc2_);
            if(_loc3_ < param1[_loc2_])
            {
               return false;
            }
         }
         return true;
      }
      
      private function useConsumable(param1:ConsumableItem, param2:Boolean) : Boolean
      {
         if(param2)
         {
            return true;
         }
         if(param1.secondary)
         {
            return true;
         }
         if(this.removeConsumableFromInventory(param1.code))
         {
            BattleDispatcher.instance.dispatchEvent(new WorldEvent(BattleDispatcher.FLEET_CONSUMABLES_UPDATED));
            return true;
         }
         if(ZGlobal.player.removeInventoryItem(param1.code))
         {
            return true;
         }
         return false;
      }
      
      public function addUpgrades(param1:String, param2:Array) : void
      {
         var _loc3_:UnitItem = ZGlobal.gameSettings.getItemByCode(param1,UnitItem) as UnitItem;
         if(Boolean(_loc3_) && Boolean(_loc3_.hasType(UnitItem.MEGA_UNIT)) && Boolean(_loc3_.megaTemplate))
         {
            param1 = _loc3_.megaTemplate;
         }
         if(null != param2 && param2.length > 0)
         {
            if(null == this.m_upgrades)
            {
               this.m_upgrades = new Dictionary();
            }
            if(null == this.m_upgrades[param1])
            {
               this.m_upgrades[param1] = param2;
            }
         }
      }
      
      public function clearAllies() : void
      {
         this.m_allies = null;
      }
      
      public function get ransomRandom() : Number
      {
         return this.m_ransomRandom;
      }
      
      public function set ransomRandom(param1:Number) : void
      {
         this.m_ransomRandom = param1;
      }
      
      public function get ransomResource() : String
      {
         return this.m_ransomResource;
      }
      
      public function set ransomResource(param1:String) : void
      {
         this.m_ransomResource = param1;
      }
      
      public function get ransomAmount() : Number
      {
         return this.m_ransomAmount;
      }
      
      public function set ransomAmount(param1:Number) : void
      {
         this.m_ransomAmount = param1;
      }
   }
}

