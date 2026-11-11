package core.managers
{
   import Engine.Classes.TimerUtil;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.entities.components.BountyPickComponent;
   import core.gamemode.battle.Battle;
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleHost;
   import core.gameobjects.GameItem;
   import core.managers.domination.DominationModeManager;
   import core.ui.PlayerFeedbackManager;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import transactions.TActivateBountyCenter;
   import utils.ZGameUtils;
   import zlabs.entity.IEntity;
   import zlabs.entity.IEntityComponent;
   import zlabs.entity.PropertyReference;
   import zlabs.events.WorldEvent;
   
   public class BountyCenterManager extends EventDispatcher
   {
      
      private static var m_instance:BountyCenterManager;
      
      public static const STATE_DOESNT_EXIST:int = 0;
      
      public static const STATE_READY:int = 1;
      
      public static const STATE_ACTIVE:int = 2;
      
      public static const STATE_COOLING:int = 3;
      
      public static const EVENT_STATE_CHANGE:String = "STATE_CHANGE";
      
      public static const REWARD_ITEM:String = "xk01";
      
      public static const LEVEL_DIFF_THRESHOLD:int = 10;
      
      public static const BUILDING_CODE:String = "BCB";
      
      private var m_lastActivated:int;
      
      private var m_entity:IEntity;
      
      private var m_bountyBonds:int;
      
      private var m_timer:Timer;
      
      private var m_energyRequiredPerLevel:Object = null;
      
      public function BountyCenterManager()
      {
         super();
         this.initEnergyPerLevel();
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onBattleComplete);
      }
      
      public static function get instance() : BountyCenterManager
      {
         if(!m_instance)
         {
            m_instance = new BountyCenterManager();
         }
         return m_instance;
      }
      
      protected function get isActive() : Boolean
      {
         if(!this.m_lastActivated)
         {
            return false;
         }
         return GlobalEngine.serverTime / 1000 + ZGlobal.player.timeWarpSeconds < this.m_lastActivated + this.activePeriod;
      }
      
      public function calculateAndAwardPayout(param1:String, param2:BattleHost) : Object
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(this.isActive)
         {
            _loc3_ = 0;
            _loc4_ = null;
            switch(true)
            {
               case param2.isDominationMode:
                  _loc4_ = DominationModeManager.instance.getDominationInfo(param1,true);
                  _loc3_ = int(_loc4_.u_info.level);
                  break;
               case param2.isGlobalPVP:
                  _loc4_ = PVPManager.instance.getGlobalPVPStrangerInfo(param1);
                  _loc3_ = (Boolean(_loc4_)) && Boolean(_loc4_.friendInfo) ? int(_loc4_.friendInfo.level) : 0;
                  break;
               case param2.isChallenge:
                  _loc4_ = PVPManager.instance.getPVPPlayer(param1);
                  if(_loc4_ == null || _loc4_.level == 0)
                  {
                     _loc4_ = ZGlobal.player.neighbors[param1];
                  }
                  _loc3_ = int(_loc4_.level);
            }
            if(_loc3_ > 0 && this.isLevelEligible(_loc3_) && param2.battleResult == Battle.BATTLE_RESULT_WON)
            {
               this.m_bountyBonds += this.bountyPayout;
               return {
                  "item":REWARD_ITEM,
                  "count":this.bountyPayout
               };
            }
         }
         return null;
      }
      
      public function isLevelEligible(param1:int) : Boolean
      {
         return ZGlobal.player.level - param1 <= LEVEL_DIFF_THRESHOLD;
      }
      
      protected function get isCoolingPeriodExpired() : Boolean
      {
         if(!this.m_lastActivated)
         {
            return true;
         }
         return GlobalEngine.serverTime / 1000 + ZGlobal.player.timeWarpSeconds > this.m_lastActivated + this.activePeriod + this.coolingDownPeriod;
      }
      
      public function get entity() : IEntity
      {
         return this.m_entity;
      }
      
      public function onActivationExpired(param1:Event) : void
      {
         this.m_timer = TimerUtil.callHandlerLater(this.onCoolingExpired,this.coolingDownPeriod * 1000);
         dispatchEvent(new Event(EVENT_STATE_CHANGE));
      }
      
      public function onCoolingExpired(param1:Event) : void
      {
         this.m_timer = null;
         dispatchEvent(new Event(EVENT_STATE_CHANGE));
      }
      
      public function activate(param1:Boolean) : void
      {
         if(this.m_lastActivated == 0)
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Dialogs","BountyCenterToasterTitle"),this.m_entity,ZGameUtils.ZlocT("Dialogs","BountyCenterToasterMessage"));
         }
         this.m_lastActivated = GlobalEngine.serverTime / 1000 + ZGlobal.player.timeWarpSeconds;
         TransactionManager.addTransaction(new TActivateBountyCenter(this.m_entity,param1));
         this.m_timer = TimerUtil.callHandlerLater(this.onActivationExpired,this.activePeriod * 1000);
         dispatchEvent(new Event(EVENT_STATE_CHANGE));
      }
      
      public function init(param1:Object) : void
      {
         this.m_lastActivated = param1.bountyCenter["lastActivated"];
         this.m_bountyBonds = param1.bountyCenter["bountyBonds"];
         this.m_entity = this.getBuildingByCode(BUILDING_CODE);
         if(this.m_entity)
         {
            if(this.isActive == true)
            {
               this.m_timer = TimerUtil.callHandlerLater(this.onActivationExpired,(this.m_lastActivated + this.activePeriod - GlobalEngine.serverTime / 1000 - ZGlobal.player.timeWarpSeconds) * 1000);
            }
            else if(this.isCoolingPeriodExpired == false)
            {
               this.m_timer = TimerUtil.callHandlerLater(this.onCoolingExpired,this.coolingTimeRemaining * 1000);
            }
         }
         this.refreshPicks();
      }
      
      public function get coolingTimeRemaining() : int
      {
         if(this.isCoolingPeriodExpired)
         {
            return 0;
         }
         return this.m_lastActivated + this.activePeriod + this.coolingDownPeriod - GlobalEngine.serverTime / 1000 - ZGlobal.player.timeWarpSeconds;
      }
      
      public function get activatedTimeRemaining() : int
      {
         if(this.isActive)
         {
            return this.m_lastActivated + this.activePeriod - GlobalEngine.serverTime / 1000 - ZGlobal.player.timeWarpSeconds;
         }
         return 0;
      }
      
      public function get currentState() : int
      {
         if(!this.m_lastActivated && WorldObjectManager.instance.getNumberBuiltObjectsWithCode(BUILDING_CODE) == 0)
         {
            return STATE_DOESNT_EXIST;
         }
         if(this.isActive)
         {
            return STATE_ACTIVE;
         }
         if(this.isCoolingPeriodExpired)
         {
            return STATE_READY;
         }
         return STATE_COOLING;
      }
      
      public function get energyRequired() : int
      {
         var _loc1_:int = this.getEnergyRequiredByLevel(ZGlobal.player.level);
         if(_loc1_ == 0)
         {
            return 99999999999999;
         }
         var _loc2_:int = 0;
         var _loc3_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BOUNTY_ENERGYREQS);
         switch(_loc3_)
         {
            case 1:
               _loc2_ = -2;
               break;
            case 2:
               _loc2_ = 2;
               break;
            case 3:
               _loc2_ = 4;
               break;
            case 0:
            default:
               _loc2_ = 0;
         }
         return _loc1_ + _loc2_;
      }
      
      private function getEnergyRequiredByLevel(param1:int) : int
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(this.m_energyRequiredPerLevel)
         {
            _loc3_ = 0;
            while(_loc3_ < this.m_energyRequiredPerLevel.levels.length && param1 >= this.m_energyRequiredPerLevel.levels[_loc3_])
            {
               _loc3_++;
            }
            if(_loc3_ > 0)
            {
               _loc2_ = int(this.m_energyRequiredPerLevel.energies[_loc3_ - 1]);
            }
         }
         return _loc2_;
      }
      
      public function get skipCost() : int
      {
         return 12;
      }
      
      public function get activePeriod() : int
      {
         return 1 * 3600;
      }
      
      public function get coolingDownPeriod() : int
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BOUNTY_COOLDOWN_PERIOD);
         switch(_loc1_)
         {
            case 2:
               return 12 * 3600;
            case 3:
               return 47 * 3600;
            case 0:
            case 1:
         }
         return 23 * 3600;
      }
      
      public function get displayLibertyHUDIcons() : Boolean
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BOUNTY_HUD_CHANGE);
         switch(_loc1_)
         {
            case 1:
               return true;
            case 0:
         }
         return false;
      }
      
      public function get bountyPayout() : int
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_BOUNTY_PAYOUT);
         switch(_loc1_)
         {
            case 2:
               return 2;
            case 3:
               return 3;
            case 0:
            case 1:
         }
         return 1;
      }
      
      public function hasSufficientEnergy() : Boolean
      {
         if(ZGlobal.player.m_energy.checkEnergy(this.energyRequired))
         {
            return true;
         }
         return false;
      }
      
      public function hasSufficientCash() : Boolean
      {
         if(ZGlobal.player.canBuyCash(this.skipCost,true))
         {
            return true;
         }
         return false;
      }
      
      public function deductEnergy() : Boolean
      {
         if(this.hasSufficientEnergy())
         {
            ZGlobal.player.m_energy.energy -= this.energyRequired;
            return true;
         }
         return false;
      }
      
      public function deductCash() : Boolean
      {
         if(this.hasSufficientCash())
         {
            ZGlobal.player.cash -= this.skipCost;
            return true;
         }
         return false;
      }
      
      public function getBuildingByCode(param1:String) : IEntity
      {
         var _loc4_:Dictionary = null;
         var _loc5_:Object = null;
         var _loc6_:GameDataComponent = null;
         var _loc2_:GameItem = ZGlobal.gameSettings.getItemByCode(param1,GameItem) as GameItem;
         var _loc3_:IEntity = null;
         if(_loc2_)
         {
            _loc4_ = WorldObjectManager.instance.getObjectsBySubType(_loc2_.type,_loc2_.subType);
            for each(_loc5_ in _loc4_)
            {
               _loc6_ = GameDataComponent(_loc5_.lookupComponentByType(GameDataComponent));
               if((Boolean(_loc6_)) && _loc6_.gameData.code == param1)
               {
                  _loc3_ = _loc6_.owner;
                  break;
               }
            }
         }
         return _loc3_;
      }
      
      private function onBattleComplete(param1:WorldEvent) : void
      {
         var _loc2_:Object = param1.eventData;
         var _loc3_:Object = this.calculateAndAwardPayout(_loc2_.enemyUID,_loc2_.battle);
         if(_loc3_ != null)
         {
            (_loc2_.battle as BattleHost).libertyBondUI(_loc3_.count);
            ZGlobal.player.addToInventory(_loc3_.item,_loc3_.count,true);
         }
      }
      
      private function initEnergyPerLevel() : void
      {
         var energyGatesString:String = null;
         var energyPerLevelParts:Array = null;
         var levels:Array = null;
         var energies:Array = null;
         var gameItem:GameItem = ZGlobal.gameSettings.getItemByCode(BUILDING_CODE,GameItem) as GameItem;
         if(gameItem.xml.@energyRequiredPerLevel)
         {
            energyGatesString = gameItem.xml.@energyRequiredPerLevel.toString();
            energyPerLevelParts = energyGatesString.split("|");
            levels = (energyPerLevelParts[0] as String).split(",");
            energies = (energyPerLevelParts[1] as String).split(",");
            levels = levels.map(function(param1:String, param2:int, param3:Array):int
            {
               return parseInt(param1);
            });
            energies = energies.map(function(param1:String, param2:int, param3:Array):int
            {
               return parseInt(param1);
            });
            this.m_energyRequiredPerLevel = {
               "levels":levels,
               "energies":energies
            };
         }
      }
      
      public function refreshPicks(param1:Event = null) : void
      {
         this.m_entity = this.getBuildingByCode(BUILDING_CODE);
         this.removeActivatedPick();
         var _loc2_:XML = null;
         switch(this.currentState)
         {
            case STATE_ACTIVE:
               this.showActivatedPick();
               _loc2_ = null;
               break;
            case STATE_COOLING:
               _loc2_ = <data icon="assets/game/PvpGeneralAssetGroup_UI.swf/CoolDownTime_32.png" background="Bubble_Gov.png" backgroundOffset="-25,-170" iconOffset="10,10"/>;
               break;
            case STATE_READY:
               _loc2_ = <data icon="assets/game/GeneralAssetGroup_UI.swf/LibertyBond_24.png" background="Bubble_bounty_90.png" backgroundOffset="-25,-170" iconOffset="18,18"/>;
               break;
            case STATE_DOESNT_EXIST:
            default:
               _loc2_ = null;
         }
         if(this.m_entity)
         {
            this.m_entity.setProperty(new PropertyReference("@Overlay.overlayData"),{"xml":_loc2_});
         }
      }
      
      public function showActivatedPick() : void
      {
         if(this.m_entity)
         {
            this.m_entity.addComponent(new BountyPickComponent(),"BountyCenterPick");
         }
      }
      
      public function removeActivatedPick() : void
      {
         var _loc1_:IEntityComponent = null;
         if(this.m_entity)
         {
            _loc1_ = this.m_entity.lookupComponentByName("BountyCenterPick");
            if(_loc1_)
            {
               this.m_entity.removeComponent(_loc1_);
            }
         }
      }
   }
}

