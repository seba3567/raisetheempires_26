package Engine.Classes
{
   import Engine.Managers.PopupQueueManager;
   import flash.utils.getQualifiedClassName;
   
   public class IdleTaskQueue
   {
      
      protected static var m_instance:IdleTaskQueue;
      
      private static const UPDATE_INTERVAL:Number = 1000;
      
      private var m_Queue:Array = new Array();
      
      private var m_LastTaskExecuted:Number = 0;
      
      private var m_PopupQueueEmpty:Boolean = false;
      
      private var m_PopupQueueEmptySince:Number = 0;
      
      private var m_ActionQueueEmpty:Boolean = false;
      
      private var m_ActionQueueEmptySince:Number = 0;
      
      private var m_nextUpdateTime:Number = 0;
      
      private var m_queuePaused:Boolean = false;
      
      public function IdleTaskQueue()
      {
         super();
      }
      
      public static function getInstance() : IdleTaskQueue
      {
         var _loc1_:Class = null;
         if(m_instance == null)
         {
            _loc1_ = GlobalEngine.engineOptions.idleTaskQueue;
            m_instance = new _loc1_();
         }
         return m_instance;
      }
      
      public function addTask(param1:BaseIdleTask) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:BaseIdleTask = null;
         var _loc2_:Boolean = param1.shouldAdd;
         if(_loc2_ && param1.singleton)
         {
            _loc3_ = getQualifiedClassName(param1);
            _loc4_ = 0;
            while(_loc4_ < this.m_Queue.length)
            {
               _loc5_ = this.m_Queue[_loc4_];
               if(getQualifiedClassName(_loc5_) == _loc3_)
               {
                  if(param1.singletonClobber)
                  {
                     this.m_Queue.splice(_loc4_,1);
                     _loc2_ = true;
                  }
                  else
                  {
                     _loc2_ = false;
                  }
                  break;
               }
               _loc4_++;
            }
         }
         if(_loc2_)
         {
            this.m_Queue.push(param1);
         }
      }
      
      public function checkTasks() : void
      {
         var _loc1_:BaseIdleTask = null;
         var _loc2_:int = 0;
         var _loc3_:BaseIdleTask = null;
         if(GlobalEngine.currentTime > this.m_nextUpdateTime && !this.m_queuePaused)
         {
            this.m_nextUpdateTime = GlobalEngine.currentTime + IdleTaskQueue.UPDATE_INTERVAL;
            this.checkTimeStamps();
            if(this.m_Queue.length > 0)
            {
               _loc2_ = 0;
               while(_loc2_ < this.m_Queue.length)
               {
                  _loc3_ = this.m_Queue[_loc2_];
                  if(this.checkIfTaskCanRun(_loc3_))
                  {
                     _loc1_ = _loc3_;
                     this.m_Queue.splice(_loc2_,1);
                     break;
                  }
                  _loc2_++;
               }
               if(_loc1_ != null)
               {
                  this.m_LastTaskExecuted = GlobalEngine.currentTime;
                  _loc1_.fire();
               }
            }
         }
      }
      
      private function checkIfTaskCanRun(param1:BaseIdleTask) : Boolean
      {
         var _loc2_:Number = GlobalEngine.currentTime;
         var _loc3_:Boolean = true;
         if(param1.requireActionQueueIdle)
         {
            if(!this.m_ActionQueueEmpty || _loc2_ - this.m_ActionQueueEmptySince < param1.minActionIdleMilliseconds)
            {
               _loc3_ = false;
            }
         }
         if(_loc3_ && param1.requireMouseIdle)
         {
            if(_loc2_ - GlobalEngine.lastInputTick < param1.minMouseIdleMilliseconds)
            {
               _loc3_ = false;
            }
         }
         if(_loc3_ && param1.requirePopupQueueEmpty)
         {
            if(!this.m_PopupQueueEmpty || _loc2_ - this.m_PopupQueueEmptySince < param1.minPopupIdleMilliseconds)
            {
               _loc3_ = false;
            }
         }
         if(_loc3_ && _loc2_ - this.m_LastTaskExecuted < param1.queueCoolDownMilliseconds)
         {
            _loc3_ = false;
         }
         if(_loc3_ && !param1.canFire)
         {
            _loc3_ = false;
         }
         return _loc3_;
      }
      
      private function checkTimeStamps() : void
      {
         if(PopupQueueManager.getInstance().hasActiveDialog() == false)
         {
            if(!this.m_PopupQueueEmpty)
            {
               this.m_PopupQueueEmptySince = GlobalEngine.currentTime;
            }
            this.m_PopupQueueEmpty = true;
         }
         else
         {
            this.m_PopupQueueEmpty = false;
         }
         if(this.isQueuedActionsEmpty())
         {
            if(!this.m_ActionQueueEmpty)
            {
               this.m_ActionQueueEmptySince = GlobalEngine.currentTime;
            }
            this.m_ActionQueueEmpty = true;
         }
         else
         {
            this.m_ActionQueueEmpty = false;
         }
      }
      
      protected function isQueuedActionsEmpty() : Boolean
      {
         return true;
      }
      
      public function togglePause(param1:Boolean) : void
      {
         this.m_queuePaused = param1;
      }
      
      public function clearQueue() : void
      {
         this.m_Queue = new Array();
      }
   }
}

