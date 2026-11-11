package core.managers.mayhemManager
{
   import Engine.Classes.TimerUtil;
   import Engine.Managers.TransactionManager;
   import as3isolib.geom.Pt;
   import core.ZGlobal;
   import core.entities.components.BuildingFSMComponent;
   import core.entities.components.UIControllerComponent;
   import core.entities.components.behaviors.BehaviorStateMachine;
   import core.entities.components.behaviors.states.BehaviorState;
   import core.entities.components.states.FSMComponent;
   import core.entities.components.states.IState;
   import core.managers.CrewManager;
   import core.managers.ExperimentsManager;
   import core.managers.MOTDManager.MessageOfTheDayManager;
   import core.managers.MatchMakingManager;
   import core.managers.autoActionsManager.AutoActionCallFunction;
   import core.managers.autoActionsManager.AutoActionEndFirstMayhemEvent;
   import core.managers.autoActionsManager.AutoActionPanToEntity;
   import core.managers.autoActionsManager.AutoActionPlaceItem;
   import core.managers.autoActionsManager.AutoActionPlayAnimationAtEntity;
   import core.managers.autoActionsManager.AutoActionPlayAnimationAtSprite;
   import core.managers.autoActionsManager.AutoActionSetStateDirectHit;
   import core.managers.autoActionsManager.AutoActionSetStateGlancingBlow;
   import core.managers.autoActionsManager.AutoActionShowSpeechPopup;
   import core.managers.autoActionsManager.AutoActionStartMayhemEvent;
   import core.managers.visitorManager.VisitorManager;
   import entity.GameDataComponent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import transactions.TFixParliamentTimeWarpBug;
   import transactions.TResetParliament;
   import utils.ZGameUtils;
   import zlabs.ZGameBase;
   import zlabs.core.InputManager;
   import zlabs.debug.Logger;
   import zlabs.entity.IEntity;
   import zlabs.events.WorldEvent;
   
   public class MayhemManager extends EventDispatcher
   {
      
      private static var m_instance:MayhemManager;
      
      public static const FIRST_ATTACK:String = "IslandMayhemBuildAMS";
      
      public static const FIRST_STAGE_DURATION:Number = 4;
      
      public static const SECOND_STAGE_DURATION:Number = 7;
      
      public static const PARLIAMENT_DESTROYED:String = "PARLIAMENT_DESTROYED";
      
      public static const DRAMA_STARTED:String = "DramaStarted";
      
      public static const AMS_QUEST:String = "QMLS1";
      
      public static const PARLIAMENT_QUEST:String = "QMLS2";
      
      private var m_parliamentDestroyed:Boolean = false;
      
      private var m_mayhemEvents:Object;
      
      private var m_offset:Number = 0;
      
      public function MayhemManager()
      {
         super();
         this.m_mayhemEvents = {};
      }
      
      public static function get instance() : MayhemManager
      {
         if(!m_instance)
         {
            m_instance = new MayhemManager();
         }
         return m_instance;
      }
      
      public function get offset() : Number
      {
         return this.m_offset;
      }
      
      public function getMayhemEvent(param1:String) : Object
      {
         return this.m_mayhemEvents[param1];
      }
      
      public function setMayhemEvent(param1:String, param2:String) : void
      {
         Logger.print(this,"JMR: setMayhemEvent key: " + param1 + ", endTime: " + param2);
         this.m_mayhemEvents[param1] = {"endTime":param2};
      }
      
      public function init(param1:Object) : void
      {
         this.m_mayhemEvents = param1.mayhemEvents;
         if(!this.m_mayhemEvents)
         {
            this.m_mayhemEvents = {};
         }
         var _loc2_:Boolean = ZGlobal.player.getSeenFlag("motd_RavenMayhem") > 0 || ZGlobal.player.hasMotdBeenAccepted("motd_RavenMayhem") || ZGlobal.player.hasMotdBeenViewed("motd_RavenMayhem");
         var _loc3_:Boolean = ExperimentsManager.instance.getExperimentVariant("empire_buildable_mayhem_master") == 3;
         if(this.m_mayhemEvents[FIRST_ATTACK])
         {
            MayhemClock.instance.init(this.m_mayhemEvents[FIRST_ATTACK]["endTime"],this.initiateSecondAttack);
         }
         else if(_loc3_ && _loc2_ && !this.m_mayhemEvents[DRAMA_STARTED])
         {
            TimerUtil.callLater(this.initiateMayhemEvents,10000);
         }
         this.doMayhemTimeWarpFix();
      }
      
      public function initiateSecondAttack(param1:Event) : void
      {
         var _loc2_:Boolean = ExperimentsManager.instance.getExperimentVariant("empire_buildable_mayhem_master") == 3;
         if(!ZGlobal.isVisiting() && _loc2_)
         {
            this.doSecondAttack();
         }
         else
         {
            VisitorManager.instance.addEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded,false,0,true);
         }
      }
      
      private function onWorldLoaded(param1:Event) : void
      {
         if(!ZGlobal.isVisiting())
         {
            VisitorManager.instance.removeEventListener(VisitorManager.WORLD_LOADED,this.onWorldLoaded);
            this.doSecondAttack(false);
         }
      }
      
      private function doSecondAttack(param1:Boolean = false) : void
      {
         delete this.m_mayhemEvents[FIRST_ATTACK];
         Logger.print(this,"Clock Timer finished, launch second attack!");
         var _loc2_:Boolean = this.isAMSBuilt();
         if(_loc2_)
         {
            this.saveParliament(param1);
         }
         else
         {
            this.blowUpParliament(param1);
         }
      }
      
      private function cleanUpProgressBar(param1:BehaviorStateMachine) : void
      {
         var _loc2_:IState = null;
         var _loc3_:String = null;
         _loc2_ = param1.getCurrentState();
         _loc3_ = param1.getStateName(_loc2_);
         Logger.print(this,"curStateName: " + _loc3_);
         BehaviorState(_loc2_).cleanupProgressBar();
      }
      
      private function doDisableInput() : void
      {
         InputManager.disableInput();
         InputManager.disableButtonInput();
      }
      
      private function doEnableInput() : void
      {
         InputManager.enableInput();
         InputManager.enableButtonInput();
      }
      
      public function get isParliamentDestroyed() : Boolean
      {
         return this.m_mayhemEvents.hasOwnProperty(PARLIAMENT_DESTROYED) ? Boolean(this.m_mayhemEvents[PARLIAMENT_DESTROYED]) : false;
      }
      
      public function set isParliamentDestroyed(param1:Boolean) : void
      {
         this.m_mayhemEvents[PARLIAMENT_DESTROYED] = param1;
         var _loc2_:Object = new Object();
         _loc2_.mayhem = true;
         this.dispatchEvent(new WorldEvent(UIControllerComponent.EVENT_TOOLTIP_UPDATE,_loc2_));
      }
      
      public function resetParliament() : void
      {
         var _loc3_:TResetParliament = null;
         var _loc4_:BehaviorStateMachine = null;
         var _loc5_:String = null;
         this.doDisableInput();
         var _loc1_:IEntity = this.getBuildingByCode("CA2");
         var _loc2_:FSMComponent = _loc1_.lookupComponentByType(FSMComponent) as FSMComponent;
         _loc3_ = new TResetParliament(_loc1_,this.isParliamentDestroyed);
         if(_loc2_)
         {
            _loc4_ = _loc2_.stateMachine as BehaviorStateMachine;
            this.cleanUpProgressBar(_loc4_);
            _loc5_ = _loc4_.builtState;
            Logger.print(this,"Final state for paliament at end of Island Mayhem: " + _loc5_);
            _loc2_.stateMachine.setCurrentState(_loc5_);
            TransactionManager.addTransaction(_loc3_);
         }
         this.doEnableInput();
      }
      
      public function initiateMayhemEvents() : void
      {
         var _loc1_:AutoActionPlayAnimationAtSprite = null;
         var _loc2_:AutoActionShowSpeechPopup = null;
         var _loc3_:AutoActionPanToEntity = null;
         var _loc4_:AutoActionPlayAnimationAtEntity = null;
         var _loc5_:AutoActionSetStateGlancingBlow = null;
         var _loc6_:AutoActionShowSpeechPopup = null;
         var _loc7_:AutoActionStartMayhemEvent = null;
         var _loc8_:AutoActionShowSpeechPopup = null;
         var _loc9_:AutoActionPlaceItem = null;
         var _loc10_:IEntity = null;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         _loc10_ = this.getFullyCrewedParliament();
         if((Boolean(_loc10_)) && !MatchMakingManager.instance.isActive())
         {
            _loc11_ = Math.floor(GlobalEngine.serverTime / 1000) + ZGlobal.player.timeWarpSeconds;
            _loc12_ = _loc11_ + 60 * 60 * 24 * MayhemManager.FIRST_STAGE_DURATION;
            _loc7_ = new AutoActionStartMayhemEvent();
            _loc7_.data = {
               "eventKey":MayhemManager.FIRST_ATTACK,
               "endTime":_loc12_
            };
            _loc1_ = new AutoActionPlayAnimationAtSprite();
            _loc1_.data = {"target":ZGameBase.layerUI};
            _loc1_.offset = new Pt(0,0,0);
            _loc1_.anchor = new Point(GlobalEngine.stage.stageWidth * 0.5,-500);
            _loc1_.animId = "RedAlert";
            _loc1_.soundId = "RedAlert";
            _loc1_.nextActionTimeDelay = 0;
            _loc1_.disableInput = true;
            _loc2_ = new AutoActionShowSpeechPopup();
            _loc2_.data = {"speechId":"Speech_Mayhem_Sarah_01"};
            _loc3_ = new AutoActionPanToEntity();
            _loc3_.data = {
               "target":_loc10_,
               "entityGetter":this.getFullyCrewedParliament
            };
            _loc3_.nextActionTimeDelay = 1000;
            _loc3_.disableInput = true;
            _loc4_ = new AutoActionPlayAnimationAtEntity();
            _loc4_.data = {
               "target":_loc10_,
               "entityGetter":this.getFullyCrewedParliament
            };
            _loc4_.animId = "VillianBallisticMissileHit";
            _loc4_.soundId = "VillianBallisticMissileHit";
            _loc4_.nextActionTimeDelay = 3000;
            _loc4_.disableInput = true;
            _loc5_ = new AutoActionSetStateGlancingBlow();
            _loc5_.data = {
               "target":_loc10_,
               "entityGetter":this.getFullyCrewedParliament
            };
            _loc5_.nextActionTimeDelay = 3000;
            _loc5_.disableInput = true;
            _loc6_ = new AutoActionShowSpeechPopup();
            _loc6_.data = {"speechId":"Speech_Mayhem_V06_01"};
            _loc8_ = new AutoActionShowSpeechPopup();
            _loc8_.data = {"speechId":"Speech_Mayhem_Sarah_02"};
            _loc9_ = new AutoActionPlaceItem();
            _loc9_.data = {"item":"AMS"};
            _loc1_.setNextAction(_loc2_);
            _loc2_.setNextAction(_loc3_);
            _loc3_.setNextAction(_loc4_);
            _loc4_.setNextAction(_loc5_);
            _loc5_.setNextAction(_loc6_);
            _loc6_.setNextAction(_loc7_);
            _loc7_.setNextAction(_loc8_);
            _loc8_.setNextAction(_loc9_);
            this.doDisableInput();
            _loc1_.startAction();
            this.doEnableInput();
         }
      }
      
      public function blowUpParliament(param1:Boolean = false) : void
      {
         var _loc2_:AutoActionPlayAnimationAtSprite = null;
         var _loc3_:AutoActionShowSpeechPopup = null;
         var _loc4_:AutoActionShowSpeechPopup = null;
         var _loc5_:AutoActionShowSpeechPopup = null;
         var _loc6_:AutoActionPanToEntity = null;
         var _loc7_:AutoActionPlayAnimationAtEntity = null;
         var _loc8_:AutoActionSetStateDirectHit = null;
         var _loc9_:AutoActionEndFirstMayhemEvent = null;
         var _loc10_:IEntity = null;
         var _loc11_:AutoActionCallFunction = null;
         _loc10_ = this.getFullyCrewedParliament();
         if(_loc10_)
         {
            _loc11_ = new AutoActionCallFunction();
            _loc11_.data = {"func":this.noOp};
            if(param1)
            {
               _loc11_.nextActionTimeDelay = 0;
            }
            else if(!MessageOfTheDayManager.instance.firstMOTDShown)
            {
               _loc11_.nextActionTimeDelay = 30000;
            }
            else
            {
               _loc11_.nextActionTimeDelay = 15000;
            }
            _loc2_ = new AutoActionPlayAnimationAtSprite();
            _loc2_.data = {"target":ZGameBase.layerUI};
            _loc2_.offset = new Pt(0,0,0);
            _loc2_.anchor = new Point(GlobalEngine.stage.stageWidth * 0.5,-500);
            _loc2_.animId = "RedAlert";
            _loc2_.soundId = "RedAlert";
            _loc2_.nextActionTimeDelay = 0;
            _loc2_.disableInput = true;
            _loc3_ = new AutoActionShowSpeechPopup();
            _loc3_.data = {"speechId":"Speech_Mayhem_Sarah_03"};
            _loc6_ = new AutoActionPanToEntity();
            _loc6_.data = {
               "target":_loc10_,
               "entityGetter":this.getFullyCrewedParliament
            };
            _loc6_.nextActionTimeDelay = 1000;
            _loc6_.disableInput = true;
            _loc7_ = new AutoActionPlayAnimationAtEntity();
            _loc7_.data = {
               "target":_loc10_,
               "entityGetter":this.getFullyCrewedParliament
            };
            _loc7_.animId = "VillianBallisticMissileHit";
            _loc7_.soundId = "VillianBallisticMissileHit";
            _loc7_.nextActionTimeDelay = 3000;
            _loc7_.disableInput = true;
            _loc8_ = new AutoActionSetStateDirectHit();
            _loc8_.data = {
               "target":_loc10_,
               "entityGetter":this.getFullyCrewedParliament
            };
            _loc8_.nextActionTimeDelay = 3000;
            _loc8_.disableInput = true;
            _loc4_ = new AutoActionShowSpeechPopup();
            _loc4_.data = {"speechId":"Speech_Mayhem_V06_02"};
            _loc5_ = new AutoActionShowSpeechPopup();
            _loc5_.data = {"speechId":"Speech_Mayhem_Sarah_04"};
            _loc9_ = new AutoActionEndFirstMayhemEvent(null,false);
            _loc11_.setNextAction(_loc2_);
            _loc2_.setNextAction(_loc3_);
            _loc3_.setNextAction(_loc6_);
            _loc6_.setNextAction(_loc7_);
            _loc7_.setNextAction(_loc8_);
            _loc8_.setNextAction(_loc4_);
            _loc4_.setNextAction(_loc5_);
            _loc5_.setNextAction(_loc9_);
            this.doDisableInput();
            _loc11_.startAction();
            this.doEnableInput();
         }
      }
      
      public function noOp() : void
      {
      }
      
      public function saveParliament(param1:Boolean = false) : void
      {
         var _loc2_:AutoActionShowSpeechPopup = null;
         var _loc3_:AutoActionPanToEntity = null;
         var _loc4_:AutoActionPlayAnimationAtEntity = null;
         var _loc5_:AutoActionPlayAnimationAtSprite = null;
         var _loc6_:AutoActionShowSpeechPopup = null;
         var _loc7_:AutoActionPlayAnimationAtSprite = null;
         var _loc8_:AutoActionEndFirstMayhemEvent = null;
         var _loc9_:IEntity = null;
         var _loc10_:AutoActionCallFunction = null;
         _loc9_ = this.getBuildingByCode("AMS");
         if(_loc9_)
         {
            _loc10_ = new AutoActionCallFunction();
            _loc10_.data = {"func":this.noOp};
            if(param1)
            {
               _loc10_.nextActionTimeDelay = 0;
            }
            else if(!MessageOfTheDayManager.instance.firstMOTDShown)
            {
               _loc10_.nextActionTimeDelay = 20000;
            }
            else
            {
               _loc10_.nextActionTimeDelay = 15000;
            }
            _loc2_ = new AutoActionShowSpeechPopup();
            _loc2_.data = {"speechId":"Speech_Mayhem_Sarah_03"};
            _loc3_ = new AutoActionPanToEntity();
            _loc3_.data = {
               "target":_loc9_,
               "entityGetter":this.getAMS
            };
            _loc3_.nextActionTimeDelay = 1000;
            _loc3_.disableInput = true;
            _loc7_ = new AutoActionPlayAnimationAtSprite();
            _loc7_.data = {"target":ZGameBase.layerUI};
            _loc7_.offset = new Pt(0,0,0);
            _loc7_.anchor = new Point(GlobalEngine.stage.stageWidth * 0.5,-500);
            _loc7_.animId = "RedAlert";
            _loc7_.soundId = "RedAlert";
            _loc7_.nextActionTimeDelay = 0;
            _loc7_.disableInput = true;
            _loc4_ = new AutoActionPlayAnimationAtEntity();
            _loc4_.data = {
               "target":_loc9_,
               "entityGetter":this.getAMS
            };
            _loc4_.offset = new Pt(0,0,0);
            _loc4_.anchor = new Point(-2,89.1);
            _loc4_.animId = "AntiBallisticMissileFire";
            _loc4_.soundId = "AntiBallisticMissileFire";
            _loc4_.nextActionTimeDelay = 4000;
            _loc4_.disableInput = true;
            _loc5_ = new AutoActionPlayAnimationAtSprite();
            _loc5_.data = {"target":ZGameBase.layerUI};
            _loc5_.offset = new Pt(0,0,0);
            _loc5_.anchor = new Point(GlobalEngine.stage.stageWidth * 0.5,0);
            _loc5_.animId = "AntiBallisticMissileHit";
            _loc5_.soundId = "AntiBallisticMissileHit";
            _loc5_.nextActionTimeDelay = 4000;
            _loc5_.disableInput = true;
            _loc6_ = new AutoActionShowSpeechPopup();
            _loc6_.data = {"speechId":"Speech_Mayhem_Sarah_05"};
            _loc8_ = new AutoActionEndFirstMayhemEvent(null,true);
            _loc10_.setNextAction(_loc7_);
            _loc7_.setNextAction(_loc2_);
            _loc2_.setNextAction(_loc3_);
            _loc3_.setNextAction(_loc4_);
            _loc4_.setNextAction(_loc5_);
            _loc5_.setNextAction(_loc6_);
            _loc6_.setNextAction(_loc8_);
            _loc10_.startAction();
         }
      }
      
      public function endMayhemEvent(param1:Event) : void
      {
         Logger.print(this,"Clock Timer finished, mayhem event ends!");
         this.onMayhemEnd();
      }
      
      public function onMayhemEnd(param1:Boolean = false) : void
      {
         this.resetParliament();
      }
      
      public function onParliamentRecrew() : void
      {
         this.onMayhemEnd();
      }
      
      private function getFullyCrewedParliament() : IEntity
      {
         var _loc1_:IEntity = null;
         _loc1_ = this.getBuildingByCode("CA2");
         if(CrewManager.isCrewBuilding(_loc1_) && CrewManager.isCrewBuildingFull(_loc1_))
         {
            return _loc1_;
         }
         return null;
      }
      
      private function isAMSBuilt() : Boolean
      {
         var _loc2_:BuildingFSMComponent = null;
         var _loc1_:IEntity = this.getBuildingByCode("AMS");
         if(_loc1_)
         {
            _loc2_ = _loc1_.lookupComponentByType(BuildingFSMComponent) as BuildingFSMComponent;
            return _loc2_.isBuilt;
         }
         return false;
      }
      
      public function getBuildingByCode(param1:String) : IEntity
      {
         return ZGameUtils.getBuildingByCode(param1);
      }
      
      private function getAMS() : IEntity
      {
         return this.getBuildingByCode("AMS");
      }
      
      public function doMayhemTimeWarpFix() : void
      {
         var _loc1_:IEntity = null;
         var _loc2_:GameDataComponent = null;
         var _loc3_:IState = null;
         var _loc4_:String = null;
         var _loc5_:BehaviorStateMachine = null;
         var _loc6_:FSMComponent = null;
         var _loc7_:String = null;
         var _loc8_:TFixParliamentTimeWarpBug = null;
         if(this.isParliamentDestroyed)
         {
            _loc1_ = this.getBuildingByCode("CA2");
            if(_loc1_)
            {
               _loc2_ = GameDataComponent(_loc1_.lookupComponentByType(GameDataComponent));
               _loc6_ = _loc1_.lookupComponentByType(FSMComponent) as FSMComponent;
               if(_loc6_)
               {
                  _loc5_ = _loc6_.stateMachine as BehaviorStateMachine;
                  _loc3_ = _loc5_.getCurrentState();
                  _loc4_ = _loc5_.getStateName(_loc3_);
                  if(_loc4_)
                  {
                     _loc7_ = "9,10,11,54,55,56";
                     if(_loc7_.indexOf(_loc4_) != -1)
                     {
                        if(_loc2_.userData.oldCrewInfo)
                        {
                           _loc2_.userData.crewInfo = _loc2_.userData.oldCrewInfo;
                           _loc2_.userData.oldCrewInfo = null;
                        }
                        this.isParliamentDestroyed = false;
                        _loc8_ = new TFixParliamentTimeWarpBug(_loc1_);
                        TransactionManager.addTransaction(_loc8_);
                     }
                  }
               }
            }
         }
      }
   }
}

