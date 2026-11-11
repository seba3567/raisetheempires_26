package core.entities.components.states
{
   import events.TransitionEvent;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.entity.IPropertyBag;
   import zlabs.events.WorldEvent;
   
   public class Machine implements IMachine
   {
      
      public static var ENABLE_TICK:String = "enablemachinetick";
      
      public var states:Dictionary = new Dictionary();
      
      public var stateOrder:Array = new Array();
      
      private var _defaultState:String = null;
      
      private var _currentState:IState = null;
      
      private var _previousState:IState = null;
      
      private var _setNewState:Boolean = false;
      
      private var _enteredStateTime:Number = 0;
      
      private var _propertyBag:IPropertyBag = null;
      
      public function Machine()
      {
         super();
      }
      
      public function get enteredStateTime() : Number
      {
         return this._enteredStateTime;
      }
      
      public function get propertyBag() : IPropertyBag
      {
         return this._propertyBag;
      }
      
      public function set propertyBag(param1:IPropertyBag) : void
      {
         this._propertyBag = param1;
      }
      
      public function setCurrentToFirstState() : void
      {
         this.setCurrentState(this.stateOrder[0]);
      }
      
      public function tick() : void
      {
         var _loc1_:String = null;
         this._setNewState = false;
         if(!this._currentState)
         {
            this.setCurrentState(this._defaultState);
         }
         if(this._currentState)
         {
            _loc1_ = getQualifiedClassName(this._currentState);
            this._currentState.tick(this);
         }
         if(this._setNewState == false && Boolean(this._currentState))
         {
            this._previousState = this._currentState;
         }
      }
      
      public function getCurrentState() : IState
      {
         if(!this._currentState)
         {
            this.setCurrentState(this._defaultState);
         }
         return this._currentState;
      }
      
      public function get currentState() : IState
      {
         return this.getCurrentState();
      }
      
      public function get currentStateName() : String
      {
         return this.getStateName(this.getCurrentState());
      }
      
      public function set currentStateName(param1:String) : void
      {
         if(!this.setCurrentState(param1))
         {
            Logger.warn(this,"set currentStateName","Could not transition to state \'" + param1 + "\'");
         }
      }
      
      public function getPreviousState() : IState
      {
         return this._previousState;
      }
      
      public function addState(param1:String, param2:IState) : void
      {
         this.states[param1] = param2;
         this.stateOrder.push(param1);
      }
      
      public function getState(param1:String) : IState
      {
         return this.states[param1] as IState;
      }
      
      public function getStateName(param1:IState) : String
      {
         var _loc2_:String = null;
         for(_loc2_ in this.states)
         {
            if(this.states[_loc2_] == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getStateIndex(param1:String) : int
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         for each(_loc3_ in this.stateOrder)
         {
            if(_loc3_ == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return 0;
      }
      
      public function setCurrentState(param1:String) : Boolean
      {
         var _loc4_:TransitionEvent = null;
         var _loc2_:IState = this.getState(param1);
         if(!_loc2_)
         {
            return false;
         }
         var _loc3_:IState = this._currentState;
         this._setNewState = true;
         this._previousState = this._currentState;
         this._currentState = _loc2_;
         if(_loc3_)
         {
            _loc3_.exit(this);
         }
         _loc2_.enter(this);
         this._enteredStateTime = Zlab.processManager.virtualTime;
         if(this._propertyBag)
         {
            _loc4_ = new TransitionEvent(TransitionEvent.TRANSITION);
            _loc4_.oldState = _loc3_;
            _loc4_.oldStateName = this.getStateName(_loc3_);
            _loc4_.newState = _loc2_;
            _loc4_.newStateName = this.getStateName(_loc2_);
            this._propertyBag.eventDispatcher.dispatchEvent(_loc4_);
            this._propertyBag.eventDispatcher.dispatchEvent(new WorldEvent(ENABLE_TICK,_loc2_.registerForTick()));
         }
         return true;
      }
      
      public function loadToState(param1:int) : void
      {
         var _loc2_:IState = this.getState(this.stateOrder[param1]);
         var _loc3_:int = 0;
         while(_loc3_ < param1)
         {
            if(_loc3_ == param1)
            {
               break;
            }
            this.getState(this.stateOrder[_loc3_]).load(this,_loc2_);
            _loc3_++;
         }
         this.currentStateName = this.stateOrder[param1];
      }
      
      public function destroy() : void
      {
         var _loc1_:IState = this.getCurrentState();
         if(_loc1_)
         {
            _loc1_.stop();
         }
         this.propertyBag = null;
      }
   }
}

