package zlabs.core
{
   import flash.events.Event;
   import flash.utils.getTimer;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.serialization.TypeUtility;
   
   public class ProcessManager
   {
      
      public static var disableSlowWarning:Boolean = true;
      
      public static const TICKS_PER_SECOND:int = 30;
      
      public static const TICK_RATE:Number = 1 / Number(TICKS_PER_SECOND);
      
      public static const TICK_RATE_MS:Number = TICK_RATE * 1000;
      
      public static const MAX_TICKS_PER_FRAME:int = 1;
      
      protected var deferredMethodQueue:Array = [];
      
      protected var started:Boolean = false;
      
      protected var _virtualTime:int = 0;
      
      protected var _interpolationFactor:Number = 0;
      
      protected var _timeScale:Number = 1;
      
      protected var lastTime:int = -1;
      
      protected var elapsed:Number = 0;
      
      protected var animatedObjects:Array = new Array();
      
      protected var tickedObjects:Array = new Array();
      
      protected var needPurgeEmpty:Boolean = false;
      
      protected var _platformTime:int = 0;
      
      protected var duringAdvance:Boolean = false;
      
      protected var thinkHeap:SimplePriorityQueue = new SimplePriorityQueue(1024);
      
      public function ProcessManager()
      {
         super();
      }
      
      public function get timeScale() : Number
      {
         return this._timeScale;
      }
      
      public function set timeScale(param1:Number) : void
      {
         this._timeScale = param1;
      }
      
      public function set TimeScale(param1:Number) : void
      {
         this.timeScale = param1;
      }
      
      public function get TimeScale() : Number
      {
         return this.timeScale;
      }
      
      public function get interpolationFactor() : Number
      {
         return this._interpolationFactor;
      }
      
      public function get virtualTime() : Number
      {
         return this._virtualTime;
      }
      
      public function get platformTime() : Number
      {
         return this._platformTime;
      }
      
      public function start() : void
      {
         if(this.started)
         {
            Logger.warn(this,"start","The ProcessManager is already started.");
            return;
         }
         this.lastTime = -1;
         this.elapsed = 0;
         Zlab.mainStage.addEventListener(Event.ENTER_FRAME,this.onFrame);
         this.started = true;
      }
      
      public function stop() : void
      {
         if(!this.started)
         {
            Logger.warn(this,"stop","The ProcessManager isn\'t started.");
            return;
         }
         this.started = false;
         Zlab.mainStage.removeEventListener(Event.ENTER_FRAME,this.onFrame);
      }
      
      public function get isTicking() : Boolean
      {
         return this.started;
      }
      
      public function schedule(param1:Number, param2:Object, param3:Function, ... rest) : void
      {
         if(!this.started)
         {
            this.start();
         }
         var _loc5_:ScheduleObject = new ScheduleObject();
         _loc5_.dueTime = this._virtualTime + param1;
         _loc5_.thisObject = param2;
         _loc5_.callback = param3;
         _loc5_.arguments = rest;
         this.thinkHeap.enqueue(_loc5_);
      }
      
      public function removeScheduledObject(param1:Object, param2:Function = null) : void
      {
         var _loc3_:Array = null;
         var _loc4_:IPrioritizable = null;
         var _loc5_:ScheduleObject = null;
         if(this.thinkHeap.size)
         {
            _loc3_ = this.thinkHeap.toArray();
            for each(_loc4_ in _loc3_)
            {
               _loc5_ = _loc4_ as ScheduleObject;
               if((Boolean(_loc5_)) && Boolean(_loc5_.thisObject == param1) && (param2 == null || param2 == _loc5_.callback))
               {
                  this.thinkHeap.remove(_loc5_);
               }
            }
         }
      }
      
      public function addAnimatedObject(param1:IAnimatedObject, param2:Number = 0) : void
      {
         this.addObject(param1,param2,this.animatedObjects);
      }
      
      public function addTickedObject(param1:ITickedObject, param2:Number = 0) : void
      {
         this.addObject(param1,param2,this.tickedObjects);
      }
      
      public function queueObject(param1:IQueuedObject) : void
      {
         if(param1.nextThinkTime < this._virtualTime)
         {
            throw new Error("Tried to queue something into the past, but no flux capacitor is present!");
         }
         if(param1.nextThinkTime >= this._virtualTime && this.thinkHeap.contains(param1))
         {
            this.thinkHeap.remove(param1);
         }
         this.thinkHeap.enqueue(param1);
      }
      
      public function removeAnimatedObject(param1:IAnimatedObject) : void
      {
         this.removeObject(param1,this.animatedObjects);
      }
      
      public function removeTickedObject(param1:ITickedObject) : void
      {
         this.removeObject(param1,this.tickedObjects);
      }
      
      public function testAdvance(param1:Number) : void
      {
         this.advance(param1 * this._timeScale,true);
      }
      
      public function seek(param1:Number) : void
      {
         this._virtualTime += param1;
      }
      
      public function callLater(param1:Function, param2:Array = null) : void
      {
         var _loc3_:DeferredMethod = new DeferredMethod();
         _loc3_.method = param1;
         _loc3_.args = param2;
         this.deferredMethodQueue.push(_loc3_);
      }
      
      private function get listenerCount() : int
      {
         return this.tickedObjects.length + this.animatedObjects.length;
      }
      
      private function addObject(param1:*, param2:Number, param3:Array) : void
      {
         if(this.duringAdvance)
         {
            Zlab.callLater(this.addObject,[param1,param2,param3]);
            return;
         }
         if(!this.started)
         {
            this.start();
         }
         var _loc4_:int = -1;
         var _loc5_:int = 0;
         while(_loc5_ < param3.length)
         {
            if(param3[_loc5_])
            {
               if(param3[_loc5_].listener == param1)
               {
                  Logger.warn(param1,"AddProcessObject","This object has already been added to the process manager.");
                  return;
               }
               if(param3[_loc5_].priority < param2)
               {
                  _loc4_ = _loc5_;
                  break;
               }
            }
            _loc5_++;
         }
         var _loc6_:ProcessObject = new ProcessObject();
         _loc6_.listener = param1;
         _loc6_.priority = param2;
         _loc6_.profilerKey = TypeUtility.getObjectClassName(param1);
         if(_loc4_ < 0 || _loc4_ >= param3.length)
         {
            param3.push(_loc6_);
         }
         else
         {
            param3.splice(_loc4_,0,_loc6_);
         }
      }
      
      private function removeObject(param1:*, param2:Array) : void
      {
         if(this.listenerCount == 1 && this.thinkHeap.size == 0)
         {
            this.stop();
         }
         var _loc3_:int = 0;
         while(_loc3_ < param2.length)
         {
            if(param2[_loc3_])
            {
               if(param2[_loc3_].listener == param1)
               {
                  if(this.duringAdvance)
                  {
                     param2[_loc3_] = null;
                     this.needPurgeEmpty = true;
                  }
                  else
                  {
                     param2.splice(_loc3_,1);
                  }
                  return;
               }
            }
            _loc3_++;
         }
         Logger.warn(param1,"RemoveProcessObject","This object has not been added to the process manager.");
      }
      
      private function onFrame(param1:Event) : void
      {
         GlobalEngine.zaspManager.preUpdate();
         var _loc2_:Number = getTimer();
         if(this.lastTime < 0)
         {
            this.lastTime = _loc2_;
            return;
         }
         var _loc3_:Number = Number(_loc2_ - this.lastTime) * this._timeScale;
         this.advance(_loc3_);
         this.lastTime = _loc2_;
         GlobalEngine.zaspManager.postUpdate();
      }
      
      private function advance(param1:Number, param2:Boolean = false) : void
      {
         var _loc7_:uint = 0;
         var _loc8_:* = 0;
         var _loc9_:ProcessObject = null;
         var _loc10_:ProcessObject = null;
         var _loc11_:* = 0;
         this._platformTime = getTimer();
         var _loc3_:Number = this._virtualTime;
         this.elapsed += param1;
         var _loc4_:int = 0;
         while(this.elapsed >= TICK_RATE_MS && (param2 || _loc4_ < MAX_TICKS_PER_FRAME))
         {
            this._interpolationFactor = 0;
            this.processScheduledObjects();
            _loc7_ = this.tickedObjects.length;
            this.duringAdvance = true;
            _loc8_ = 0;
            while(_loc8_ < _loc7_)
            {
               _loc9_ = this.tickedObjects[_loc8_] as ProcessObject;
               if(_loc9_)
               {
                  (_loc9_.listener as ITickedObject).onTick(TICK_RATE);
               }
               _loc8_++;
            }
            this.duringAdvance = false;
            this._virtualTime += TICK_RATE_MS;
            this.elapsed -= TICK_RATE_MS;
            _loc4_++;
         }
         if(_loc4_ >= MAX_TICKS_PER_FRAME && !param2 && !disableSlowWarning)
         {
            Logger.warn(this,"advance","Exceeded maximum number of ticks for frame (" + this.elapsed.toFixed() + "ms dropped) .");
            this.elapsed = 0;
         }
         var _loc5_:uint = this.animatedObjects.length;
         this.duringAdvance = true;
         this._interpolationFactor = this.elapsed / TICK_RATE_MS;
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc10_ = this.animatedObjects[_loc6_] as ProcessObject;
            if(_loc10_)
            {
               (_loc10_.listener as IAnimatedObject).onFrame(param1 / 1000);
            }
            _loc6_++;
         }
         this.duringAdvance = false;
         if(this.needPurgeEmpty)
         {
            this.needPurgeEmpty = false;
            _loc5_ = this.animatedObjects.length;
            _loc8_ = 0;
            while(_loc8_ < _loc5_)
            {
               if(!this.animatedObjects[_loc8_])
               {
                  this.animatedObjects.splice(_loc8_,1);
                  _loc5_--;
                  _loc8_--;
               }
               _loc8_++;
            }
            _loc7_ = this.tickedObjects.length;
            _loc11_ = 0;
            while(_loc11_ < _loc7_)
            {
               if(!this.tickedObjects[_loc11_])
               {
                  this.tickedObjects.splice(_loc11_,1);
                  _loc7_--;
                  _loc11_--;
               }
               _loc11_++;
            }
         }
      }
      
      private function processScheduledObjects() : void
      {
         var _loc3_:uint = 0;
         var _loc4_:int = 0;
         var _loc5_:DeferredMethod = null;
         var _loc6_:IPrioritizable = null;
         var _loc7_:IQueuedObject = null;
         var _loc8_:ScheduleObject = null;
         var _loc9_:String = null;
         var _loc2_:Array = this.deferredMethodQueue;
         if(_loc2_.length)
         {
            this.deferredMethodQueue = [];
            _loc3_ = _loc2_.length;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc5_ = _loc2_[_loc4_] as DeferredMethod;
               _loc5_.method.apply(null,_loc5_.args);
               _loc4_++;
            }
            _loc2_.length = 0;
         }
         if(this.thinkHeap.size)
         {
            while(Boolean(this.thinkHeap.front) && this.thinkHeap.front.priority >= -this._virtualTime)
            {
               _loc6_ = this.thinkHeap.dequeue();
               _loc7_ = _loc6_ as IQueuedObject;
               _loc8_ = _loc6_ as ScheduleObject;
               _loc9_ = TypeUtility.getObjectClassName(_loc6_);
               if(_loc7_)
               {
                  if(_loc7_.nextThinkCallback != null)
                  {
                     _loc7_.nextThinkCallback();
                  }
               }
               else
               {
                  if(!(Boolean(_loc8_) && _loc8_.callback != null))
                  {
                     throw new Error("Unknown type found in thinkHeap.");
                  }
                  _loc8_.callback.apply(_loc8_.thisObject,_loc8_.arguments);
               }
            }
         }
      }
   }
}

final class ProcessObject
{
   
   public var profilerKey:String = null;
   
   public var listener:* = null;
   
   public var priority:Number = 0;
   
   public function ProcessObject()
   {
      super();
   }
}

final class DeferredMethod
{
   
   public var method:Function = null;
   
   public var args:Array = null;
   
   public function DeferredMethod()
   {
      super();
   }
}
