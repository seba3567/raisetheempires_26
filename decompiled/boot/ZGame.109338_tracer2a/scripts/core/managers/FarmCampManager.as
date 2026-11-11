package core.managers
{
   import core.gamemode.battle.BattleDispatcher;
   import core.gamemode.battle.BattleHost;
   import core.ui.PlayerFeedbackManager;
   import entity.GameDataComponent;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class FarmCampManager extends EventDispatcher
   {
      
      public static const STATE_ACCUMULATING:int = 22;
      
      public static const STATE_ACTIVE:int = 23;
      
      public static const STATE_COOLING:int = 24;
      
      public static const FIGHTS_GATE_1:int = 5;
      
      public static const FIGHTS_GATE_2:int = 10;
      
      public static const FIGHTS_GATE_3:int = 15;
      
      private static var m_instance:FarmCampManager = null;
      
      private var m_shiftBackTime:Boolean = false;
      
      private var m_fightsAccumulated:int = 0;
      
      private var m_effectPercentage:int = 0;
      
      private var m_currentState:int = 0;
      
      public var isInited:Boolean = false;
      
      public function FarmCampManager(param1:IEventDispatcher = null)
      {
         super(param1);
      }
      
      public static function get instance() : FarmCampManager
      {
         if(m_instance == null)
         {
            m_instance = new FarmCampManager();
         }
         return m_instance;
      }
      
      public function get effectPercentage() : int
      {
         return this.m_effectPercentage;
      }
      
      public function getPossibleAcceleration() : int
      {
         var _loc1_:int = 0;
         if(this.m_fightsAccumulated >= FIGHTS_GATE_3)
         {
            _loc1_ = 3;
         }
         else if(this.m_fightsAccumulated >= FIGHTS_GATE_2)
         {
            _loc1_ = 2;
         }
         else if(this.m_fightsAccumulated >= FIGHTS_GATE_1)
         {
            _loc1_ = 1;
         }
         else
         {
            _loc1_ = 0;
         }
         return _loc1_ * this.getBaseAcceleration();
      }
      
      public function get fightsAccumulated() : int
      {
         return this.m_fightsAccumulated;
      }
      
      public function setTimeShiftFlag(param1:Boolean) : void
      {
         this.m_shiftBackTime = param1;
      }
      
      public function setCurrentState(param1:int) : void
      {
         this.m_currentState = param1;
         if(this.timeShiftFlag && param1 == STATE_COOLING)
         {
            this.setTimeShiftFlag(false);
            this.m_effectPercentage = 0;
         }
         if(!this.timeShiftFlag && param1 == STATE_ACTIVE)
         {
            this.setTimeShiftFlag(true);
         }
         if(param1 == STATE_ACTIVE && this.m_effectPercentage == 0 && this.m_fightsAccumulated != 0)
         {
            this.m_effectPercentage = this.getPossibleAcceleration();
            this.m_fightsAccumulated = 0;
         }
      }
      
      public function get currentState() : int
      {
         return this.m_currentState;
      }
      
      public function get timeShiftFlag() : Boolean
      {
         return this.m_shiftBackTime;
      }
      
      public function init(param1:GameDataComponent) : void
      {
         if(param1.userData.fightsAccumulated != null)
         {
            this.m_fightsAccumulated = int(param1.userData.fightsAccumulated);
         }
         if(param1.userData.effectPercentage != null)
         {
            this.m_effectPercentage = int(param1.userData.effectPercentage);
         }
         BattleDispatcher.instance.addEventListener(BattleDispatcher.BATTLE_COMPLETE_HOST,this.onBattleComplete);
         this.isInited = true;
      }
      
      public function isAccumulating() : Boolean
      {
         return this.m_currentState == STATE_ACCUMULATING;
      }
      
      public function isActive() : Boolean
      {
         return this.m_currentState == STATE_ACTIVE;
      }
      
      protected function onBattleComplete(param1:WorldEvent) : void
      {
         this.incrementFights(param1.eventData.battle);
      }
      
      public function incrementFights(param1:BattleHost) : void
      {
         if(param1.isDominationMode || param1.isGlobalPVP)
         {
            if(this.m_fightsAccumulated >= FIGHTS_GATE_3)
            {
               return;
            }
            if(!this.isAccumulating())
            {
               return;
            }
            ++this.m_fightsAccumulated;
            if(this.m_fightsAccumulated == FIGHTS_GATE_1 || this.m_fightsAccumulated == FIGHTS_GATE_2 || this.m_fightsAccumulated == FIGHTS_GATE_3)
            {
               this.showToaster();
            }
         }
      }
      
      public function showToaster() : void
      {
         var _loc1_:Object = {};
         var _loc2_:Boolean = true;
         if(this.m_fightsAccumulated >= FIGHTS_GATE_3)
         {
            _loc1_.count = this.m_fightsAccumulated;
            _loc1_.amount = this.getBaseAcceleration() * 3;
         }
         else if(this.m_fightsAccumulated >= FIGHTS_GATE_2)
         {
            _loc1_.count = this.m_fightsAccumulated;
            _loc1_.amount = this.getBaseAcceleration() * 2;
         }
         else if(this.m_fightsAccumulated >= FIGHTS_GATE_1)
         {
            _loc1_.count = this.m_fightsAccumulated;
            _loc1_.amount = this.getBaseAcceleration() * 1;
         }
         else
         {
            _loc2_ = false;
         }
         if(_loc2_)
         {
            PlayerFeedbackManager.instance.displayFeedback(ZGameUtils.ZlocT("Dialogs","Farm_Camp_toaster",_loc1_));
         }
      }
      
      public function getBaseAcceleration() : int
      {
         var _loc1_:int = ExperimentsManager.instance.getExperimentVariant("empire_buildable_farmcamp_accelerate");
         switch(_loc1_)
         {
            case 1:
               return 15;
            case 2:
               return 20;
            default:
               return 15;
         }
      }
   }
}

