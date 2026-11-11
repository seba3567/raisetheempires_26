package Engine.Managers
{
   import Engine.Classes.AMFConnection;
   import Engine.Events.TransactionEvent;
   import Engine.Events.TransactionFaultEvent;
   import Engine.Transactions.Transaction;
   import Engine.Utilities;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getQualifiedClassName;
   
   public class TransactionManager extends EventDispatcher
   {
      
      private static var m_connection:AMFConnection;
      
      private static var m_instance:TransactionManager;
      
      public static const DEFAULT_MAX_QUEUED:int = 30;
      
      private static var m_maxQueued:int = DEFAULT_MAX_QUEUED;
      
      private static var m_amfMaxPerBatch:int = 8;
      
      private static var m_amfMaxWait:int = 5000;
      
      private static var m_amfMaxRetries:int = 4;
      
      private static const AMF_RETRY_ALERT_LIMIT:int = 1;
      
      private static var m_transactions:Array = [];
      
      private static var m_batchedAmfCalls:Array = [];
      
      private static var m_sequenceNumber:int = 0;
      
      private static var m_batchSequenceNumber:int = 0;
      
      private static var m_amfBatchTimer:Timer = null;
      
      private static var m_retryTimer:Timer = null;
      
      private static var m_inactivityTimer:Timer = null;
      
      private static var m_ageOfOldestCall:Number = 0;
      
      private static var m_numBatchCalls:int = 0;
      
      private static var m_retrySequence:int = 0;
      
      private static var m_retryCount:int = 0;
      
      protected static var m_lastFunc:String = "0";
      
      protected static var m_lastError:String = "0";
      
      protected static var m_inSync:Boolean = true;
      
      protected static var m_queueLimitExceeded:Boolean = false;
      
      private static var m_initialized:Boolean = false;
      
      private static var m_addtionalSignedParams:Object = {};
      
      public function TransactionManager()
      {
         super();
      }
      
      public static function initialize() : void
      {
         var _loc2_:String = null;
         var _loc1_:Object = GlobalEngine.zyParams;
         for(_loc2_ in _loc1_)
         {
            m_addtionalSignedParams[_loc2_] = _loc1_[_loc2_];
         }
         m_inactivityTimer = new Timer(Config.TRANSACTION_INACTIVITY_SECONDS);
         m_inactivityTimer.addEventListener(TimerEvent.TIMER,inactivityTimerComplete);
         m_inactivityTimer.start();
      }
      
      public static function getInstance() : TransactionManager
      {
         if(m_instance == null)
         {
            m_instance = new TransactionManager();
         }
         return m_instance;
      }
      
      public static function get lastError() : String
      {
         return m_lastError;
      }
      
      public static function get lastFunc() : String
      {
         return m_lastFunc;
      }
      
      public static function get inSync() : Boolean
      {
         return m_inSync;
      }
      
      public static function get sequenceNumber() : int
      {
         return m_sequenceNumber;
      }
      
      public static function set inSync(param1:Boolean) : void
      {
         m_inSync = param1;
         if(param1 == false)
         {
            getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.OUT_OF_SYNC));
         }
      }
      
      public static function set additionalSignedParams(param1:Object) : void
      {
         m_addtionalSignedParams = param1;
      }
      
      public static function get additionalSignedParams() : Object
      {
         return m_addtionalSignedParams;
      }
      
      public static function addTransaction(param1:Transaction, param2:Boolean = false) : void
      {
         if(param1.isInitTransaction() == true)
         {
            m_initialized = true;
         }
         if(!canSendTransactions() && Config.DEBUG_MODE)
         {
            trace("Error: transaction added before transactions have been initialized.  This will fail on the back end.");
         }
         if(m_amfBatchTimer == null)
         {
            m_amfBatchTimer = new Timer(1000);
            m_amfBatchTimer.addEventListener(TimerEvent.TIMER,onAmfBatchSend);
            m_amfBatchTimer.start();
         }
         if(inSync == true)
         {
            param1.preAddTransaction();
            if(m_transactions.length == 0)
            {
               m_ageOfOldestCall = GlobalEngine.serverTime;
            }
            GlobalEngine.log("TransactionManager","Adding transaction " + getQualifiedClassName(param1));
            m_transactions.push(param1);
            getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.ADDED,param1));
            if(param2 == true)
            {
               sendAllTransactions(false);
            }
            else if(m_transactions.length >= m_amfMaxPerBatch && m_batchedAmfCalls.length == 0)
            {
               sendAllTransactions(true);
            }
            if(m_transactions.length >= m_maxQueued && m_queueLimitExceeded == false)
            {
               getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.QUEUE_LIMIT_EXCEEDED));
               m_queueLimitExceeded = true;
            }
            param1.postAddTransaction();
         }
         else
         {
            GlobalEngine.log("TransactionManager","Suppressing transaction because we\'re oos");
         }
      }
      
      private static function incrementSequence() : int
      {
         ++m_sequenceNumber;
         return m_sequenceNumber;
      }
      
      private static function generateSignedParams() : Object
      {
         var _loc2_:* = undefined;
         var _loc3_:Object = null;
         var _loc1_:Object = new Object();
         for(_loc2_ in m_addtionalSignedParams)
         {
            _loc1_[_loc2_] = m_addtionalSignedParams[_loc2_];
         }
         _loc3_ = GlobalEngine.getFlashVar("flashRevision");
         _loc1_.flashRevision = null;
         if(_loc3_ != null)
         {
            _loc1_.flashRevision = parseInt(_loc3_.toString());
         }
         return _loc1_;
      }
      
      public static function batchCall(param1:Transaction, param2:String, param3:Array, param4:Function, param5:Function = null) : void
      {
         var _loc6_:Object = null;
         var _loc7_:Object = null;
         var _loc8_:String = null;
         if(inSync)
         {
            _loc6_ = {};
            _loc6_["stamp"] = GlobalEngine.serverTime;
            _loc6_["functionName"] = param2;
            _loc6_["params"] = param3;
            _loc6_["onSuccess"] = param4;
            _loc6_["onFailure"] = param5;
            _loc6_["transaction"] = param1;
            _loc6_["sequence"] = TransactionManager.incrementSequence();
            _loc7_ = param1.getBatchCallParams();
            for(_loc8_ in _loc7_)
            {
               _loc6_[_loc8_] = _loc7_[_loc8_];
            }
            m_batchedAmfCalls.push(_loc6_);
         }
         else
         {
            ErrorManager.addError("Unable to batch call because client is out-of-sync! (function: " + param2 + ")");
         }
      }
      
      private static function onAmfBatchSend(param1:Event = null, param2:Boolean = false, param3:Boolean = false) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Object = null;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:Transaction = null;
         var _loc9_:Object = null;
         if(m_batchedAmfCalls.length == 0 && m_transactions.length > 0 || param3)
         {
            _loc4_ = GlobalEngine.serverTime - m_ageOfOldestCall;
            if(m_ageOfOldestCall == 0 || _loc4_ >= m_amfMaxWait || param2 == true)
            {
               m_amfBatchTimer.stop();
               while(m_transactions.length > 0 && m_batchedAmfCalls.length < m_amfMaxPerBatch)
               {
                  _loc8_ = m_transactions.shift();
                  if(_loc8_.canPerform)
                  {
                     _loc8_.perform();
                  }
               }
               GlobalEngine.log("AMFBatch","Executing " + m_batchedAmfCalls.length + " in a batch");
               _loc5_ = TransactionManager.generateSignedParams();
               _loc6_ = new Array();
               _loc7_ = 0;
               while(_loc7_ < m_batchedAmfCalls.length)
               {
                  _loc9_ = Utilities.clone(m_batchedAmfCalls[_loc7_]);
                  _loc9_.transaction = null;
                  _loc6_.push(_loc9_);
                  _loc7_++;
               }
               if(m_connection == null)
               {
                  m_connection = new AMFConnection(onAmfBatchComplete,onAmfBatchFault);
               }
               m_connection.call.apply(m_connection,[GlobalEngine.engineOptions.baseService,_loc5_,_loc6_,m_retryCount]);
               getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.BATCH_SEND));
               m_ageOfOldestCall = GlobalEngine.serverTime;
               m_amfBatchTimer.start();
            }
         }
      }
      
      private static function onAmfBatchComplete(param1:Object) : void
      {
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         var _loc9_:Function = null;
         var _loc2_:Boolean = false;
         var _loc3_:int = Transaction.NO_ERROR;
         var _loc4_:String = "batch";
         var _loc5_:String = "";
         if(param1 != null && param1.errorType == Transaction.NO_ERROR)
         {
            m_inactivityTimer.stop();
            m_inactivityTimer.reset();
            m_inactivityTimer.start();
            _loc6_ = param1.data as Array;
            if(_loc6_ != null && _loc6_.length == m_batchedAmfCalls.length)
            {
               if(param1.zySig)
               {
                  GlobalEngine.zyParams = param1.zySig;
               }
               _loc7_ = 0;
               while(_loc7_ < _loc6_.length)
               {
                  param1 = _loc6_[_loc7_];
                  _loc8_ = {};
                  if(param1.errorType == Transaction.RETRY_TRANSACTION)
                  {
                     _loc3_ = int(param1.errorType);
                     _loc5_ = param1.errorData;
                     _loc8_ = m_batchedAmfCalls[0];
                     _loc4_ = _loc8_["functionName"];
                     _loc2_ = true;
                     break;
                  }
                  if(param1.errorType == Transaction.FORCE_RELOAD)
                  {
                     _loc3_ = int(param1.errorType);
                     _loc5_ = param1.errorData;
                     m_retryCount = m_amfMaxRetries + 1;
                     _loc2_ = true;
                  }
                  else
                  {
                     _loc8_ = m_batchedAmfCalls.shift();
                     _loc9_ = _loc8_["onSuccess"];
                     _loc9_.apply(_loc8_["transaction"],[param1]);
                     if(m_numBatchCalls > 0)
                     {
                        --m_numBatchCalls;
                     }
                     getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.COMPLETED,_loc8_["transaction"] as Transaction));
                  }
                  _loc7_++;
               }
               if(m_numBatchCalls > 0)
               {
                  onAmfBatchSend(null,true);
               }
               ++m_batchSequenceNumber;
            }
            else
            {
               GlobalEngine.log("AMFBatch","ERROR - batch results is not an array of length " + m_batchedAmfCalls.length);
            }
         }
         else if(param1 != null)
         {
            _loc3_ = int(param1.errorType);
            _loc5_ = param1.errorData;
            if(_loc3_ == Transaction.AUTH_NO_USER_ID || _loc3_ == Transaction.AUTH_NO_SESSION)
            {
               inSync = false;
            }
            else if(_loc3_ == Transaction.OUTDATED_GAME_VERSION)
            {
               inSync = false;
               getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.VERSION_MISMATCH));
            }
            else
            {
               _loc2_ = true;
            }
         }
         else
         {
            _loc3_ = Transaction.RETRY_TRANSACTION;
            _loc2_ = true;
         }
         if(_loc2_ == true)
         {
            m_lastError = _loc3_.toString();
            m_lastFunc = _loc4_;
            onAmfBatchFault(null,_loc3_,_loc5_);
         }
         else
         {
            if(m_retryCount > 0)
            {
               getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.RETRY_SUCCESS));
            }
            m_retrySequence = 0;
            m_retryCount = 0;
         }
         if(m_transactions.length < m_maxQueued && m_queueLimitExceeded)
         {
            getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.QUEUE_LIMIT_NORMAL));
            m_queueLimitExceeded = false;
         }
      }
      
      private static function onAmfBatchFault(param1:Object, param2:int, param3:String) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Transaction = null;
         var _loc6_:Function = null;
         var _loc7_:Boolean = false;
         if(m_batchedAmfCalls.length)
         {
            m_retrySequence = m_batchedAmfCalls[0].sequence;
            ++m_retryCount;
            if(m_retryCount <= m_amfMaxRetries)
            {
               onRetryPause();
               if(m_retryCount >= AMF_RETRY_ALERT_LIMIT)
               {
                  getInstance().dispatchEvent(new TransactionFaultEvent(TransactionFaultEvent.RETRY,null,param2,param3));
               }
            }
            else
            {
               _loc4_ = m_batchedAmfCalls.shift();
               _loc5_ = _loc4_["transaction"] as Transaction;
               if(_loc5_)
               {
                  _loc7_ = _loc5_.isFaultable();
                  if(_loc7_)
                  {
                     getInstance().dispatchEvent(new TransactionFaultEvent(TransactionFaultEvent.FAULT,_loc4_["transaction"],param2,param3));
                     inSync = false;
                  }
               }
               _loc6_ = _loc4_["onFailure"];
               _loc6_.apply(_loc4_["transaction"],[param1,param2,param3]);
            }
         }
         GlobalEngine.log("AMFBatch","Batch exec FAIL result = " + param1);
      }
      
      public static function sendAllTransactions(param1:Boolean) : void
      {
         if(param1)
         {
            m_numBatchCalls = m_transactions.length;
         }
         onAmfBatchSend(null,true);
      }
      
      private static function onRetryPause() : void
      {
         var _loc1_:Number = Math.pow(2,m_retryCount) * 1000;
         if(Config.DEBUG_MODE == true)
         {
            _loc1_ = 1;
         }
         if(m_retryTimer == null)
         {
            m_retryTimer = new Timer(_loc1_,1);
            m_retryTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onRetrySend);
            m_retryTimer.start();
            GlobalEngine.log("AMFBatch","Waiting " + _loc1_ + "ms before retry");
         }
      }
      
      private static function onRetrySend(param1:TimerEvent) : void
      {
         if(m_retryTimer != null)
         {
            m_retryTimer.stop();
            m_retryTimer = null;
         }
         GlobalEngine.log("AMFBatch","Retrying transaction #" + m_retrySequence + ". " + m_retryCount + " time(s)");
         onAmfBatchSend(null,true,true);
      }
      
      public static function setInitialized() : void
      {
         incrementSequence();
         m_initialized = true;
      }
      
      public static function canSendTransactions() : Boolean
      {
         return m_initialized;
      }
      
      public static function disable() : void
      {
         m_amfBatchTimer.stop();
      }
      
      public static function enable() : void
      {
         m_amfBatchTimer.start();
      }
      
      public static function getBatchSequenceNumber() : int
      {
         return m_batchSequenceNumber;
      }
      
      private static function inactivityTimerComplete(param1:TimerEvent) : void
      {
         getInstance().dispatchEvent(new TransactionEvent(TransactionEvent.INACTIVE));
      }
      
      public static function get transactionQueueLength() : int
      {
         return m_transactions.length;
      }
      
      public static function get maxQueued() : int
      {
         return m_maxQueued;
      }
      
      public static function get amfMaxPerBatch() : int
      {
         return m_amfMaxPerBatch;
      }
      
      public static function get amfMaxWait() : int
      {
         return m_amfMaxWait;
      }
      
      public static function get amfMaxRetries() : int
      {
         return m_amfMaxRetries;
      }
      
      public static function set maxQueued(param1:int) : void
      {
         m_maxQueued = param1;
      }
      
      public static function set amfMaxPerBatch(param1:int) : void
      {
         m_amfMaxPerBatch = param1;
      }
      
      public static function set amfMaxWait(param1:int) : void
      {
         m_amfMaxWait = param1;
      }
      
      public static function set amfMaxRetries(param1:int) : void
      {
         m_amfMaxRetries = param1;
      }
   }
}

