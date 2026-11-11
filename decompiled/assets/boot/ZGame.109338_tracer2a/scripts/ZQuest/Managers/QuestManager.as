package ZQuest.Managers
{
   import Engine.Events.TransactionEvent;
   import Engine.Managers.TransactionManager;
   import Engine.Transactions.Transaction;
   import ZQuest.Classes.Quest;
   import ZQuest.Events.QuestEvent;
   import ZQuest.Init.QuestSettingsInit;
   import flash.events.EventDispatcher;
   
   public class QuestManager extends EventDispatcher
   {
      
      private static var m_instance:QuestManager;
      
      private var m_initialized:Boolean = false;
      
      protected var m_activeQuests:Vector.<Object> = new Vector.<Object>();
      
      public function QuestManager()
      {
         super();
      }
      
      public static function getInstance(param1:Class = null) : QuestManager
      {
         if(m_instance == null)
         {
            if(param1 == null)
            {
               param1 = QuestManager;
            }
            m_instance = new param1();
         }
         return m_instance;
      }
      
      public function initialize() : void
      {
         if(this.m_initialized == false)
         {
            this.m_initialized = true;
            TransactionManager.getInstance().addEventListener(TransactionEvent.ADDED,this.onTransactionAdded);
            TransactionManager.getInstance().addEventListener(TransactionEvent.COMPLETED,this.onTransactionComplete);
         }
      }
      
      public function getActiveQuests() : Vector.<Quest>
      {
         var _loc2_:Object = null;
         var _loc3_:Quest = null;
         var _loc1_:Vector.<Quest> = new Vector.<Quest>();
         for each(_loc2_ in this.m_activeQuests)
         {
            _loc3_ = QuestSettingsInit.getInstance().getItemByName(_loc2_.name);
            if(_loc3_ != null)
            {
               _loc1_.push(_loc3_);
            }
         }
         return _loc1_;
      }
      
      public function getQuestProgressByName(param1:String) : Object
      {
         var _loc2_:int = this.getQuestProgressIndexByName(param1);
         return _loc2_ >= 0 ? this.m_activeQuests[_loc2_] : null;
      }
      
      public function setQuestTaskProgress(param1:String, param2:int, param3:int) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:Quest = null;
         if(QuestSettingsInit.getInstance().isClientPredictionEnabled)
         {
            _loc4_ = this.getQuestProgressIndexByName(param1);
            _loc5_ = this.m_activeQuests[_loc4_];
            _loc5_.progress[param2] = param3;
            _loc6_ = QuestSettingsInit.getInstance().getItemByName(param1);
            this.performClientProgressUpdate(_loc6_,_loc5_,{
               "progressChange":true,
               "taskCompleted":param2
            });
         }
      }
      
      protected function onTransactionAdded(param1:TransactionEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Quest = null;
         var _loc5_:Object = null;
         if(QuestSettingsInit.getInstance().isClientPredictionEnabled)
         {
            GlobalEngine.log("QuestManager","Transaction added: " + param1.transaction);
            _loc2_ = 0;
            while(_loc2_ < this.m_activeQuests.length)
            {
               _loc3_ = this.m_activeQuests[_loc2_];
               _loc4_ = QuestSettingsInit.getInstance().getItemByName(_loc3_.name);
               if(!(_loc4_ == null || Boolean(_loc3_.complete)))
               {
                  _loc5_ = this.updateProgress(_loc4_,_loc3_,param1.transaction);
                  this.performClientProgressUpdate(_loc4_,_loc3_,_loc5_);
               }
               _loc2_++;
            }
         }
      }
      
      protected function performClientProgressUpdate(param1:Quest, param2:Object, param3:Object) : void
      {
         var _loc4_:QuestEvent = null;
         if(param3.progressChange)
         {
            if(this.checkQuestCompletion(param2,param1))
            {
               param2.complete = true;
               dispatchEvent(new QuestEvent(QuestEvent.COMPLETED,param1));
            }
            else
            {
               _loc4_ = new QuestEvent(QuestEvent.PROGRESS,param1);
               _loc4_.taskCompleted = param3.taskCompleted;
               dispatchEvent(_loc4_);
            }
         }
      }
      
      protected function mergeProgress(param1:int, param2:Quest, param3:Object) : int
      {
         var _loc4_:int = -1;
         var _loc5_:Boolean = QuestSettingsInit.getInstance().isClientPredictionEnabled;
         if(!_loc5_)
         {
            if(param1 >= 0)
            {
               _loc4_ = this.checkTaskCompletion(this.m_activeQuests[param1].progress,param3.progress,param2);
               this.m_activeQuests[param1] = param3;
            }
         }
         return _loc4_;
      }
      
      protected function onTransactionComplete(param1:TransactionEvent) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:Quest = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:QuestEvent = null;
         var _loc2_:Boolean = QuestSettingsInit.getInstance().isClientPredictionEnabled;
         var _loc3_:Object = param1.transaction.rawResult.metadata.QuestComponent;
         GlobalEngine.log("QuestManager","Transaction complete: " + param1.transaction);
         if(_loc3_ != null)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc5_ = _loc3_[_loc4_];
               _loc6_ = QuestSettingsInit.getInstance().getItemByName(_loc5_.name);
               _loc7_ = this.getQuestProgressIndexByName(_loc5_.name);
               _loc8_ = this.mergeProgress(_loc7_,_loc6_,_loc5_);
               if(_loc5_.expired == true)
               {
                  dispatchEvent(new QuestEvent(QuestEvent.EXPIRED,_loc6_));
               }
               else if(_loc5_.complete == true && !_loc2_)
               {
                  dispatchEvent(new QuestEvent(QuestEvent.COMPLETED,_loc6_));
               }
               else
               {
                  if(_loc7_ < 0)
                  {
                     this.m_activeQuests.push(_loc5_);
                     if(_loc2_)
                     {
                        dispatchEvent(new QuestEvent(QuestEvent.PROGRESS,_loc6_));
                     }
                  }
                  if(!_loc2_ || param1.transaction.isInitTransaction())
                  {
                     _loc9_ = new QuestEvent(QuestEvent.PROGRESS,_loc6_);
                     _loc9_.taskCompleted = _loc8_;
                     dispatchEvent(_loc9_);
                  }
               }
               _loc4_++;
            }
         }
      }
      
      protected function getQuestProgressIndexByName(param1:String) : int
      {
         var _loc2_:int = -1;
         var _loc3_:int = 0;
         while(_loc3_ < this.m_activeQuests.length)
         {
            if(this.m_activeQuests[_loc3_].name == param1)
            {
               _loc2_ = _loc3_;
               break;
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      protected function checkTaskCompletion(param1:Array, param2:Array, param3:Quest) : int
      {
         var _loc6_:int = 0;
         var _loc4_:int = -1;
         var _loc5_:int = 0;
         while(_loc5_ < param3.tasks.length)
         {
            _loc6_ = int(param3.tasks[_loc5_].total);
            if(param1[_loc5_] != _loc6_ && param2[_loc5_] == _loc6_)
            {
               _loc4_ = _loc5_;
            }
            _loc5_++;
         }
         return _loc4_;
      }
      
      protected function checkQuestCompletion(param1:Object, param2:Quest) : Boolean
      {
         var _loc5_:Object = null;
         var _loc3_:Boolean = true;
         var _loc4_:int = 0;
         while(_loc4_ < param2.tasks.length)
         {
            _loc5_ = param2.tasks[_loc4_];
            if(param1.progress[_loc4_] < _loc5_.total)
            {
               _loc3_ = false;
               break;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      protected function callTaskPredictionHandler(param1:Transaction, param2:Quest, param3:int) : Number
      {
         var _loc4_:Object = param2.tasks[param3];
         var _loc5_:Function = QuestSettingsInit.getInstance().getClientPredictionClass[_loc4_.action];
         return _loc5_.apply(null,[param1,_loc4_.type]);
      }
      
      protected function updateProgress(param1:Quest, param2:Object, param3:Transaction) : Object
      {
         var newProgress:Array = null;
         var progressChange:Boolean = false;
         var taskCompleted:int = 0;
         var questX:int = 0;
         var task:Object = null;
         var value:Number = NaN;
         var quest:Quest = param1;
         var status:Object = param2;
         var transaction:Transaction = param3;
         var result:Object = {};
         if(transaction != null && status != null && status.expired != true && status.complete != true)
         {
            newProgress = new Array(quest.tasks.length);
            progressChange = false;
            taskCompleted = -1;
            questX = 0;
            while(questX < quest.tasks.length)
            {
               task = quest.tasks[questX];
               if(task.action != null)
               {
                  value = 0;
                  try
                  {
                     value = this.callTaskPredictionHandler(transaction,quest,questX);
                  }
                  catch(err:Error)
                  {
                     trace(err);
                  }
                  if(this.isQuestTaskCompleted(status,questX))
                  {
                     newProgress[questX] = status.progress[questX];
                  }
                  else
                  {
                     newProgress[questX] = value;
                     if(task.sticky == true)
                     {
                        newProgress[questX] += status.progress[questX];
                        if(value > 0)
                        {
                           progressChange = true;
                        }
                     }
                     else if(newProgress[questX] > status.progress[questX])
                     {
                        progressChange = true;
                     }
                     if(status.progress[questX] < task.total && newProgress[questX] == task.total)
                     {
                        taskCompleted = questX;
                     }
                  }
               }
               questX++;
            }
            if(progressChange)
            {
               status.progress = newProgress;
            }
            result = {
               "progressChange":progressChange,
               "taskCompleted":taskCompleted
            };
         }
         return result;
      }
      
      protected function setQuestTaskCompleted(param1:Object, param2:int) : void
      {
         if(isNaN(param1.completedTasks))
         {
            param1.completedTasks = 0;
         }
         param1.completedTasks |= 1 << param2;
      }
      
      protected function isQuestTaskCompleted(param1:Object, param2:int) : Boolean
      {
         if(!isNaN(param1.completedTasks))
         {
            if(param1.completedTasks & 1 << param2)
            {
               return true;
            }
         }
         return false;
      }
   }
}

