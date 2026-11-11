package Engine.Init
{
   import Engine.Managers.StatsManager;
   import Engine.Utilities;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.ProgressEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class InitializationManager extends EventDispatcher
   {
      
      protected static var m_instance:InitializationManager;
      
      protected static var m_doActionsLock:Boolean;
      
      public static var trackTime:Number;
      
      protected static var m_statsReporting:Boolean = false;
      
      private static const REPORT_DELAY:int = 10000;
      
      protected var m_actions:Array;
      
      protected var m_runningActions:Array;
      
      protected var m_completedActions:Array;
      
      protected var m_loadTimer:Timer;
      
      protected var m_CompleteTimeRecorded:Boolean = false;
      
      protected var m_startTime:Number;
      
      public var initTimes:Object = {};
      
      public function InitializationManager()
      {
         super(null);
         if(InitializationManager.m_instance == null)
         {
            InitializationManager.m_instance = this;
         }
         this.m_actions = new Array();
         this.m_runningActions = new Array();
         this.m_completedActions = new Array();
         m_doActionsLock = false;
         if(Math.floor(Utilities.randBetween(1,100)) == 50)
         {
            m_statsReporting = true;
         }
         this.m_startTime = GlobalEngine.getTimer();
         if(m_statsReporting)
         {
            StatsManager.count("Initialization","Begin");
            this.m_loadTimer = new Timer(REPORT_DELAY);
            this.m_loadTimer.addEventListener(TimerEvent.TIMER,this.onTimerCallback);
            this.m_loadTimer.start();
         }
      }
      
      public static function getInstance() : InitializationManager
      {
         return m_instance;
      }
      
      public function add(param1:InitializationAction) : void
      {
         this.m_actions.push(param1);
      }
      
      public function execute() : void
      {
         this._doActions();
      }
      
      public function hasActionCompleted(param1:String) : Boolean
      {
         return this.m_completedActions.indexOf(param1) >= 0;
      }
      
      public function getDependentActions(param1:String) : Array
      {
         var _loc4_:InitializationAction = null;
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         while(_loc3_ < this.m_actions.length)
         {
            _loc4_ = this.m_actions[_loc3_];
            if(_loc4_.getDependencies().indexOf(param1) >= 0)
            {
               _loc2_.push(_loc4_);
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function _getIncompleteActions() : Array
      {
         var _loc3_:InitializationAction = null;
         var _loc1_:Array = new Array();
         var _loc2_:int = 0;
         while(_loc2_ < this.m_actions.length)
         {
            _loc3_ = this.m_actions[_loc2_];
            if(!_loc3_.hasCompleted())
            {
               _loc1_.push(_loc3_);
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      private function _isActionRunning(param1:String) : Boolean
      {
         return this.m_runningActions.indexOf(param1) >= 0;
      }
      
      private function _doActions(param1:Event = null) : void
      {
         var _loc4_:Timer = null;
         var _loc5_:InitializationAction = null;
         if(m_doActionsLock)
         {
            _loc4_ = new Timer(100,1);
            _loc4_.addEventListener(TimerEvent.TIMER_COMPLETE,this._doActions);
            _loc4_.start();
            return;
         }
         m_doActionsLock = true;
         var _loc2_:Array = this._getIncompleteActions();
         if(this.m_runningActions.length <= 0 && _loc2_.length <= 0)
         {
            dispatchEvent(new Event(Event.COMPLETE));
            this.recordFinishTime();
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc5_ = _loc2_[_loc3_];
            if(!this._isActionRunning(_loc5_.getActionId()) && _loc5_.isReady())
            {
               GlobalEngine.msg("Init",_loc5_.getActionId() + " started");
               _loc5_.startTime = getTimer();
               _loc5_.addEventListener(Event.COMPLETE,this._onActionComplete);
               this.m_runningActions.push(_loc5_.getActionId());
               _loc5_.execute();
            }
            _loc3_++;
         }
         m_doActionsLock = false;
      }
      
      public function haveAllCompleted() : Boolean
      {
         return this.m_runningActions.length <= 0 && this._getIncompleteActions().length <= 0;
      }
      
      private function _onActionComplete(param1:Event) : void
      {
         var _loc7_:String = null;
         var _loc2_:InitializationAction = param1.target as InitializationAction;
         var _loc3_:Number = (getTimer() - _loc2_.startTime) / 1000;
         GlobalEngine.log("Init",_loc2_.getActionId() + " completed (" + _loc3_ + " sec)");
         this.initTimes[_loc2_.getActionId()] = getTimer() / 1000 - InitializationManager.trackTime;
         this.m_completedActions.push(_loc2_.getActionId());
         var _loc4_:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS);
         _loc4_.bytesLoaded = this.m_completedActions.length;
         _loc4_.bytesTotal = this.m_actions.length;
         dispatchEvent(_loc4_);
         var _loc5_:Array = new Array();
         var _loc6_:int = 0;
         while(_loc6_ < this.m_runningActions.length)
         {
            _loc7_ = this.m_runningActions[_loc6_];
            if(_loc7_ != _loc2_.getActionId())
            {
               _loc5_.push(_loc7_);
            }
            _loc6_++;
         }
         this.m_runningActions = _loc5_;
         this._doActions();
      }
      
      private function _actionById(param1:String) : InitializationAction
      {
         var _loc4_:InitializationAction = null;
         var _loc2_:InitializationAction = null;
         var _loc3_:int = 0;
         while(_loc2_ == null && _loc3_ < this.m_actions.length)
         {
            _loc4_ = this.m_actions[_loc3_] as InitializationAction;
            if(_loc4_.getActionId() == param1)
            {
               _loc2_ = _loc4_;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function onTimerCallback(param1:TimerEvent) : void
      {
         if(this.haveAllCompleted())
         {
            StatsManager.count("Initialization","Finished",this.m_loadTimer.currentCount * REPORT_DELAY / 1000 + " seconds");
            this.recordFinishTime();
            this.m_loadTimer.stop();
            this.m_loadTimer = null;
         }
         else
         {
            StatsManager.count("Initialization","Not Finished",this.m_loadTimer.currentCount * REPORT_DELAY / 1000 + " seconds","Actions running: " + this.m_runningActions.toString());
         }
      }
      
      private function recordFinishTime() : void
      {
         var _loc1_:Number = NaN;
         if(!this.m_CompleteTimeRecorded)
         {
            this.m_CompleteTimeRecorded = true;
            if(m_statsReporting)
            {
               _loc1_ = GlobalEngine.getTimer() - this.m_startTime;
               StatsManager.count("Initialization","Elapsed Time","","","","",Math.floor(_loc1_ / 1000));
            }
         }
      }
      
      public function getRunningActionsString() : String
      {
         var _loc1_:String = "initNoRunningActions";
         if(this.m_runningActions.length > 0)
         {
            _loc1_ = "init:" + this.m_runningActions.join(",");
         }
         return _loc1_;
      }
      
      public function addToCompleted(param1:String) : void
      {
         this.m_completedActions.push(param1);
      }
   }
}

