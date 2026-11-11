package Engine.Transactions
{
   import Engine.Managers.TransactionManager;
   import Engine.Utilities;
   import flash.events.EventDispatcher;
   
   public class Transaction extends EventDispatcher
   {
      
      public static const NO_ERROR:int = 0;
      
      public static const ERROR_AUTH:int = 1;
      
      public static const OUTDATED_GAME_VERSION:int = 10;
      
      public static const AUTH_NO_USER_ID:int = 26;
      
      public static const AUTH_NO_SESSION:int = 27;
      
      public static const RETRY_TRANSACTION:int = 28;
      
      public static const FORCE_RELOAD:int = 29;
      
      protected static var m_transactionId:uint = 1;
      
      protected const ERROR_USER_DATA_MISSING:int = 2;
      
      protected const ERROR_INVALID_STATE:int = 3;
      
      protected const INVALID_DATA:int = 4;
      
      protected const MISSING_DATA:int = 5;
      
      protected const ACTION_CLASS_ERROR:int = 6;
      
      protected const ACTION_METHOD_ERROR:int = 7;
      
      protected const ERROR_RESOURCE_DATA_MISSING:int = 8;
      
      protected const NOT_ENOUGH_MONEY:int = 9;
      
      protected const TRANSPORT_FAILURE_GENERAL:int = 25;
      
      protected var m_id:int;
      
      private var m_canPerform:Boolean = true;
      
      protected var m_functionName:String;
      
      protected var m_rawResult:Object = null;
      
      public function Transaction()
      {
         super(this);
         this.m_id = Utilities.generateUniqueId();
      }
      
      public function getId() : Number
      {
         return this.m_id;
      }
      
      protected function signedCall(param1:String, ... rest) : void
      {
         this.m_functionName = param1;
         this.logEvent("Batching AMF call");
         TransactionManager.batchCall(this,param1,rest,this.onAmfComplete,this.onAmfFault);
      }
      
      public function perform() : void
      {
      }
      
      public function set canPerform(param1:Boolean) : void
      {
         this.m_canPerform = param1;
      }
      
      public function get canPerform() : Boolean
      {
         return this.m_canPerform;
      }
      
      public function get rawResult() : Object
      {
         return this.m_rawResult;
      }
      
      protected function onAmfComplete(param1:Object) : void
      {
         this.m_rawResult = param1;
         if(param1)
         {
            if(param1.serverTime != null)
            {
               GlobalEngine.setInternalServerTime(param1.serverTime);
            }
            if(param1.errorType == NO_ERROR)
            {
               this.logEvent("Complete");
               if(param1.data != null)
               {
                  this.onComplete(param1.data);
               }
            }
            else
            {
               if(param1.errorData)
               {
                  this.logEvent("Error " + param1.errorType + " " + param1.errorData);
               }
               else
               {
                  this.logEvent("Error " + param1.errorType);
               }
               this.onFault(param1.errorType,param1.errorData);
            }
         }
      }
      
      protected function logEvent(param1:String) : void
      {
         GlobalEngine.log("Transaction",this.getId() + " (" + this.m_functionName + "): " + param1);
      }
      
      final protected function onAmfFault(param1:Object, param2:int = 25, param3:String = "onAmfFault was called") : void
      {
         var _loc4_:String = null;
         this.logEvent("Fault " + param1);
         for(_loc4_ in param1)
         {
            GlobalEngine.log("Transaction",_loc4_ + " : " + param1[_loc4_]);
         }
         this.onFault(param2,param3);
      }
      
      protected function onComplete(param1:Object) : void
      {
      }
      
      public function isFaultable() : Boolean
      {
         return true;
      }
      
      protected function onFault(param1:int, param2:String) : void
      {
      }
      
      public function isInitTransaction() : Boolean
      {
         return false;
      }
      
      public function getBatchCallParams() : Object
      {
         return {};
      }
      
      public function preAddTransaction() : void
      {
      }
      
      public function postAddTransaction() : void
      {
      }
   }
}

