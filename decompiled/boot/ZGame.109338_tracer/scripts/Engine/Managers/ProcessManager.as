package Engine.Managers
{
   import Engine.Interfaces.IFramedObject;
   import Engine.Interfaces.ITickedObject;
   import flash.utils.getTimer;
   
   public class ProcessManager
   {
      
      private static var m_instance:ProcessManager = null;
      
      private static var m_canInstantiate:Boolean = false;
      
      public static const TICKS_PER_SECOND:int = 30;
      
      public static const TICK_RATE:Number = 1 / Number(TICKS_PER_SECOND);
      
      public static const TICK_RATE_MS:Number = TICK_RATE * 1000;
      
      public static const MAX_TICKS_PER_FRAME:int = 5;
      
      private var m_timeScale:Number = 1;
      
      private var m_virtualTime:int = 0;
      
      private var m_platformTime:int = 0;
      
      private var m_lastTime:int = -1;
      
      private var m_elapsed:Number = 0;
      
      private var m_needPurgeEmpty:Boolean = false;
      
      private var m_processing:Boolean = false;
      
      private var m_active:Boolean = false;
      
      private var m_framedObjects:Vector.<FramedProcessObject> = new Vector.<FramedProcessObject>();
      
      private var m_tickedObjects:Vector.<TickedProcessObject> = new Vector.<TickedProcessObject>();
      
      private var m_deferredFramedObjects:Vector.<FramedProcessObject> = new Vector.<FramedProcessObject>();
      
      private var m_deferredTickedObjects:Vector.<TickedProcessObject> = new Vector.<TickedProcessObject>();
      
      public function ProcessManager()
      {
         super();
         if(!m_canInstantiate)
         {
            throw new Error("Cannot call ProcessManager constructor directly - use ProcessManager.instance instead.");
         }
      }
      
      public static function get instance() : ProcessManager
      {
         if(null == m_instance)
         {
            m_canInstantiate = true;
            m_instance = new ProcessManager();
            m_canInstantiate = false;
         }
         return m_instance;
      }
      
      public function get timeScale() : Number
      {
         return this.m_timeScale;
      }
      
      public function set timeScale(param1:Number) : void
      {
         this.m_timeScale = param1;
      }
      
      public function get virtualTime() : Number
      {
         return this.m_virtualTime;
      }
      
      public function get platformTime() : Number
      {
         return this.m_platformTime;
      }
      
      public function activate() : void
      {
         if(!this.m_active)
         {
            this.m_lastTime = -1;
            this.m_elapsed = 0;
            this.m_active = true;
         }
      }
      
      public function deactivate() : void
      {
         if(this.m_active)
         {
            this.m_active = false;
         }
      }
      
      public function get isActive() : Boolean
      {
         return this.m_active;
      }
      
      public function addFramedObject(param1:IFramedObject, param2:Number = 0) : void
      {
         var _loc3_:FramedProcessObject = new FramedProcessObject();
         _loc3_.object = param1;
         _loc3_.priority = param2;
         this.pushFramedObject(_loc3_);
      }
      
      public function addTickedObject(param1:ITickedObject, param2:Number = 0) : void
      {
         var _loc3_:TickedProcessObject = new TickedProcessObject();
         _loc3_.object = param1;
         _loc3_.priority = param2;
         this.pushTickedObject(_loc3_);
      }
      
      public function removeFramedObject(param1:IFramedObject) : void
      {
         if(this.objectCount == 1)
         {
            this.deactivate();
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.m_framedObjects.length)
         {
            if(Boolean(this.m_framedObjects[_loc2_]) && this.m_framedObjects[_loc2_].object == param1)
            {
               if(this.m_processing)
               {
                  this.m_framedObjects[_loc2_] = null;
                  this.m_needPurgeEmpty = true;
               }
               else
               {
                  this.m_framedObjects.splice(_loc2_,1);
               }
               if(0 == this.m_framedObjects.length)
               {
                  this.m_framedObjects = new Vector.<FramedProcessObject>();
               }
               break;
            }
            _loc2_++;
         }
      }
      
      public function removeTickedObject(param1:ITickedObject) : void
      {
         if(this.objectCount == 1)
         {
            this.deactivate();
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.m_tickedObjects.length)
         {
            if(Boolean(this.m_tickedObjects[_loc2_]) && this.m_tickedObjects[_loc2_].object == param1)
            {
               if(this.m_processing)
               {
                  this.m_tickedObjects[_loc2_] = null;
                  this.m_needPurgeEmpty = true;
               }
               else
               {
                  this.m_tickedObjects.splice(_loc2_,1);
               }
               if(0 == this.m_tickedObjects.length)
               {
                  this.m_tickedObjects = new Vector.<TickedProcessObject>();
               }
               break;
            }
            _loc2_++;
         }
      }
      
      public function onFrame() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         if(this.m_active)
         {
            _loc1_ = getTimer();
            if(this.m_lastTime >= 0)
            {
               _loc2_ = Number(_loc1_ - this.m_lastTime) * this.m_timeScale;
               this.process(_loc2_);
            }
            this.m_lastTime = _loc1_;
         }
      }
      
      private function get objectCount() : int
      {
         return this.m_tickedObjects.length + this.m_framedObjects.length;
      }
      
      private function pushFramedObject(param1:FramedProcessObject) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this.m_processing)
         {
            this.m_deferredFramedObjects.push(param1);
         }
         else
         {
            if(!this.m_active)
            {
               this.activate();
            }
            if(-1 == this.m_framedObjects.indexOf(param1))
            {
               _loc2_ = -1;
               _loc3_ = 0;
               while(_loc3_ < this.m_framedObjects.length)
               {
                  if(Boolean(this.m_framedObjects[_loc3_]) && this.m_framedObjects[_loc3_].priority < param1.priority)
                  {
                     _loc2_ = _loc3_;
                     break;
                  }
                  _loc3_++;
               }
               if(_loc2_ < 0 || _loc2_ >= this.m_framedObjects.length)
               {
                  this.m_framedObjects.push(param1);
               }
               else
               {
                  this.m_framedObjects.splice(_loc2_,0,param1);
               }
            }
         }
      }
      
      private function pushTickedObject(param1:TickedProcessObject) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this.m_processing)
         {
            this.m_deferredTickedObjects.push(param1);
         }
         else
         {
            if(!this.m_active)
            {
               this.activate();
            }
            if(-1 == this.m_tickedObjects.indexOf(param1))
            {
               _loc2_ = -1;
               _loc3_ = 0;
               while(_loc3_ < this.m_tickedObjects.length)
               {
                  if(Boolean(this.m_tickedObjects[_loc3_]) && this.m_tickedObjects[_loc3_].priority < param1.priority)
                  {
                     _loc2_ = _loc3_;
                     break;
                  }
                  _loc3_++;
               }
               if(_loc2_ < 0 || _loc2_ >= this.m_tickedObjects.length)
               {
                  this.m_tickedObjects.push(param1);
               }
               else
               {
                  this.m_tickedObjects.splice(_loc2_,0,param1);
               }
            }
         }
      }
      
      private function process(param1:Number) : void
      {
         var _loc2_:uint = 0;
         var _loc4_:TickedProcessObject = null;
         var _loc6_:FramedProcessObject = null;
         var _loc7_:int = 0;
         this.m_platformTime = getTimer();
         this.m_elapsed += param1;
         var _loc3_:int = 0;
         while(this.m_elapsed >= TICK_RATE_MS && _loc3_ < MAX_TICKS_PER_FRAME)
         {
            this.processDeferredObjects();
            this.m_processing = true;
            _loc2_ = 0;
            while(_loc2_ < this.m_tickedObjects.length)
            {
               _loc4_ = this.m_tickedObjects[_loc2_];
               if(_loc4_)
               {
                  _loc4_.object.onTick(TICK_RATE);
               }
               _loc2_++;
            }
            this.m_processing = false;
            this.m_virtualTime += TICK_RATE_MS;
            this.m_elapsed -= TICK_RATE_MS;
            _loc3_++;
         }
         if(_loc3_ >= MAX_TICKS_PER_FRAME)
         {
            _loc7_ = this.m_elapsed / TICK_RATE_MS;
            this.m_elapsed -= TICK_RATE_MS * _loc7_;
         }
         this.m_processing = true;
         var _loc5_:Number = param1 / 1000;
         _loc2_ = 0;
         while(_loc2_ < this.m_framedObjects.length)
         {
            _loc6_ = this.m_framedObjects[_loc2_];
            if(_loc6_)
            {
               _loc6_.object.onFrame(_loc5_);
            }
            _loc2_++;
         }
         this.m_processing = false;
         if(this.m_needPurgeEmpty)
         {
            this.purgeEmpty();
         }
      }
      
      private function processDeferredObjects() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:Vector.<FramedProcessObject> = this.m_deferredFramedObjects;
         if(0 < _loc2_.length)
         {
            this.m_deferredFramedObjects = new Vector.<FramedProcessObject>();
            _loc1_ = 0;
            while(_loc1_ < _loc2_.length)
            {
               this.pushFramedObject(_loc2_[_loc1_]);
               _loc1_++;
            }
         }
         var _loc3_:Vector.<TickedProcessObject> = this.m_deferredTickedObjects;
         if(0 < _loc3_.length)
         {
            this.m_deferredTickedObjects = new Vector.<TickedProcessObject>();
            _loc1_ = 0;
            while(_loc1_ < _loc3_.length)
            {
               this.pushTickedObject(_loc3_[_loc1_]);
               _loc1_++;
            }
         }
      }
      
      private function purgeEmpty() : void
      {
         var _loc1_:uint = 0;
         _loc1_ = 0;
         while(_loc1_ < this.m_framedObjects.length)
         {
            if(!this.m_framedObjects[_loc1_])
            {
               this.m_framedObjects.splice(_loc1_,1);
               _loc1_--;
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < this.m_tickedObjects.length)
         {
            if(!this.m_tickedObjects[_loc1_])
            {
               this.m_tickedObjects.splice(_loc1_,1);
               _loc1_--;
            }
            _loc1_++;
         }
         if(0 == this.m_framedObjects.length)
         {
            this.m_framedObjects = new Vector.<FramedProcessObject>();
         }
         if(0 == this.m_tickedObjects.length)
         {
            this.m_tickedObjects = new Vector.<TickedProcessObject>();
         }
         this.m_needPurgeEmpty = false;
      }
   }
}

import Engine.Interfaces.IFramedObject;
import Engine.Interfaces.ITickedObject;

final class FramedProcessObject
{
   
   public var object:IFramedObject = null;
   
   public var priority:Number = 0;
   
   public function FramedProcessObject()
   {
      super();
   }
}

final class TickedProcessObject
{
   
   public var object:ITickedObject = null;
   
   public var priority:Number = 0;
   
   public function TickedProcessObject()
   {
      super();
   }
}
