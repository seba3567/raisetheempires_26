package eDpLib.events
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.FocusEvent;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public class EventDispatcherProxy implements IEventDispatcher, IEventDispatcherProxy
   {
      
      private var _proxyTarget:IEventDispatcher;
      
      private var _proxy:IEventDispatcher;
      
      private var listenerHashTable:Object = {};
      
      public var interceptedEventTypes:Array = this.generateEventTypes();
      
      public var deleteQueueAfterUpdate:Boolean = true;
      
      private var _proxyTargetListenerQueue:Array = [];
      
      private var eventDispatcher:EventDispatcher;
      
      public function EventDispatcherProxy()
      {
         super();
         this.proxy = this;
      }
      
      public function get proxyTarget() : IEventDispatcher
      {
         return this._proxyTarget;
      }
      
      public function set proxyTarget(param1:IEventDispatcher) : void
      {
         if(this._proxyTarget != param1)
         {
            this._proxyTarget = param1;
            this.updateProxyListeners();
         }
      }
      
      public function get proxy() : IEventDispatcher
      {
         return this._proxy;
      }
      
      public function set proxy(param1:IEventDispatcher) : void
      {
         if(this._proxy != param1)
         {
            this._proxy = param1;
            this.eventDispatcher = new EventDispatcher(this._proxy);
         }
      }
      
      private function setListenerHashProperty(param1:String, param2:Function) : void
      {
         var _loc3_:ListenerHash = null;
         if(!this.listenerHashTable.hasOwnProperty(param1))
         {
            _loc3_ = new ListenerHash();
            _loc3_.addListener(param2);
            this.listenerHashTable[param1] = _loc3_;
         }
         else
         {
            _loc3_ = ListenerHash(this.listenerHashTable[param1]);
            _loc3_.addListener(param2);
         }
      }
      
      private function hasListenerHashProperty(param1:String) : Boolean
      {
         return this.listenerHashTable.hasOwnProperty(param1);
      }
      
      private function getListenersForEventType(param1:String) : Array
      {
         if(this.listenerHashTable.hasOwnProperty(param1))
         {
            return ListenerHash(this.listenerHashTable[param1]).listeners;
         }
         return [];
      }
      
      private function removeListenerHashProperty(param1:String) : Boolean
      {
         if(this.listenerHashTable.hasOwnProperty(param1))
         {
            this.listenerHashTable[param1] = null;
            delete this.listenerHashTable[param1];
            return true;
         }
         return false;
      }
      
      protected function generateEventTypes() : Array
      {
         var _loc1_:Array = [];
         _loc1_.push(Event.ADDED,Event.ADDED_TO_STAGE,Event.ENTER_FRAME,Event.REMOVED,Event.REMOVED_FROM_STAGE,Event.RENDER,Event.TAB_CHILDREN_CHANGE,Event.TAB_ENABLED_CHANGE,Event.TAB_INDEX_CHANGE,FocusEvent.FOCUS_IN,FocusEvent.FOCUS_OUT,FocusEvent.KEY_FOCUS_CHANGE,FocusEvent.MOUSE_FOCUS_CHANGE,MouseEvent.CLICK,MouseEvent.DOUBLE_CLICK,MouseEvent.MOUSE_DOWN,MouseEvent.MOUSE_MOVE,MouseEvent.MOUSE_OUT,MouseEvent.MOUSE_OVER,MouseEvent.MOUSE_UP,MouseEvent.MOUSE_WHEEL,MouseEvent.ROLL_OUT,MouseEvent.ROLL_OVER,KeyboardEvent.KEY_DOWN,KeyboardEvent.KEY_UP);
         return _loc1_;
      }
      
      private function checkForInteceptedEventType(param1:String) : Boolean
      {
         var _loc2_:String = null;
         for each(_loc2_ in this.interceptedEventTypes)
         {
            if(param1 == _loc2_)
            {
               return true;
            }
         }
         return false;
      }
      
      protected function eventDelegateFunction(param1:Event) : void
      {
         var _loc3_:Function = null;
         var _loc4_:Array = null;
         param1.stopImmediatePropagation();
         var _loc2_:ProxyEvent = new ProxyEvent(this.proxy,param1);
         _loc2_.proxyTarget = this.proxyTarget;
         if(this.hasListenerHashProperty(param1.type))
         {
            _loc4_ = this.getListenersForEventType(param1.type);
            for each(_loc3_ in _loc4_)
            {
               _loc3_.call(this,_loc2_);
            }
         }
      }
      
      protected function updateProxyListeners() : void
      {
         var _loc1_:Object = null;
         for each(_loc1_ in this._proxyTargetListenerQueue)
         {
            this.proxyTarget.addEventListener(_loc1_.type,this.eventDelegateFunction,_loc1_.useCapture,_loc1_.priority,_loc1_.useWeakReference);
         }
         if(this.deleteQueueAfterUpdate)
         {
            this._proxyTargetListenerQueue = [];
         }
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         if(this.checkForInteceptedEventType(param1))
         {
            if(this.proxyTarget)
            {
               return this.proxyTarget.hasEventListener(param1);
            }
            return false;
         }
         return this.eventDispatcher.hasEventListener(param1);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         if(this.checkForInteceptedEventType(param1))
         {
            if(this.proxyTarget)
            {
               return this.proxyTarget.willTrigger(param1);
            }
            return false;
         }
         return this.eventDispatcher.willTrigger(param1);
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         var _loc6_:Object = null;
         if(this.checkForInteceptedEventType(param1))
         {
            this.setListenerHashProperty(param1,param2);
            if(this.proxyTarget)
            {
               this.proxyTarget.addEventListener(param1,this.eventDelegateFunction,param3,param4,param5);
            }
            else
            {
               _loc6_ = {
                  "type":param1,
                  "useCapture":param3,
                  "priority":param4,
                  "useWeakReference":param5
               };
               this._proxyTargetListenerQueue.push(_loc6_);
            }
         }
         else
         {
            this.eventDispatcher.addEventListener(param1,param2,param3,param4,param5);
         }
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         var _loc4_:Object = null;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         if(this.checkForInteceptedEventType(param1))
         {
            if(this.hasListenerHashProperty(param1))
            {
               this.removeListenerHashProperty(param1);
               if(this.proxyTarget)
               {
                  this.proxyTarget.removeEventListener(param1,this.eventDelegateFunction,param3);
               }
               else
               {
                  _loc6_ = this._proxyTargetListenerQueue.length;
                  while(_loc5_ < _loc6_)
                  {
                     _loc4_ = this._proxyTargetListenerQueue[_loc5_];
                     if(_loc4_.type == param1)
                     {
                        this._proxyTargetListenerQueue.splice(_loc5_,1);
                        return;
                     }
                     _loc5_++;
                  }
               }
            }
         }
         else
         {
            this.eventDispatcher.removeEventListener(param1,param2,param3);
         }
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         if(param1.bubbles || this.checkForInteceptedEventType(param1.type))
         {
            return this.proxyTarget.dispatchEvent(new ProxyEvent(this,param1));
         }
         return this.eventDispatcher.dispatchEvent(param1);
      }
   }
}

