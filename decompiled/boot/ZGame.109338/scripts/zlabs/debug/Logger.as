package zlabs.debug
{
   import zlabs.Zlab;
   import zlabs.serialization.TypeUtility;
   
   public class Logger
   {
      
      protected static var listeners:Array = [];
      
      protected static var started:Boolean = false;
      
      protected static var pendingEntries:Array = [];
      
      protected static var disabled:Boolean = false;
      
      public var enabled:Boolean;
      
      protected var owner:Class;
      
      public function Logger(param1:Class, param2:Boolean = true)
      {
         super();
         this.owner = param1;
         this.enabled = param2;
      }
      
      public static function registerListener(param1:ILogAppender) : void
      {
         listeners.push(param1);
      }
      
      public static function startup() : void
      {
         var _loc1_:int = 0;
         if(!Zlab.IS_SHIPPING_BUILD)
         {
            registerListener(new TraceAppender());
            registerListener(new UIAppender());
            started = true;
            _loc1_ = 0;
            while(_loc1_ < pendingEntries.length)
            {
               processEntry(pendingEntries[_loc1_]);
               _loc1_++;
            }
            pendingEntries.length = 0;
            pendingEntries = null;
         }
      }
      
      public static function disable() : void
      {
         pendingEntries = null;
         started = false;
         listeners = null;
         disabled = true;
      }
      
      protected static function processEntry(param1:LogEntry) : void
      {
         if(disabled)
         {
            return;
         }
         if(!started)
         {
            pendingEntries.push(param1);
            return;
         }
         var _loc2_:int = 0;
         while(_loc2_ < listeners.length)
         {
            (listeners[_loc2_] as ILogAppender).addLogMessage(param1.type,TypeUtility.getObjectClassName(param1.reporter),param1.message);
            _loc2_++;
         }
      }
      
      public static function print(param1:*, param2:String) : void
      {
         if(disabled)
         {
            return;
         }
         var _loc3_:LogEntry = new LogEntry();
         _loc3_.reporter = TypeUtility.getClass(param1);
         _loc3_.message = param2;
         _loc3_.type = LogEntry.MESSAGE;
         processEntry(_loc3_);
      }
      
      public static function info(param1:*, param2:String, param3:String) : void
      {
         if(disabled)
         {
            return;
         }
         var _loc4_:LogEntry = new LogEntry();
         _loc4_.reporter = TypeUtility.getClass(param1);
         _loc4_.method = param2;
         _loc4_.message = param2 + " - " + param3;
         _loc4_.type = LogEntry.INFO;
         processEntry(_loc4_);
      }
      
      public static function debug(param1:*, param2:String, param3:String) : void
      {
         if(disabled)
         {
            return;
         }
         var _loc4_:LogEntry = new LogEntry();
         _loc4_.reporter = TypeUtility.getClass(param1);
         _loc4_.method = param2;
         _loc4_.message = param2 + " - " + param3;
         _loc4_.type = LogEntry.DEBUG;
         processEntry(_loc4_);
      }
      
      public static function warn(param1:*, param2:String, param3:String) : void
      {
         if(disabled)
         {
            return;
         }
         var _loc4_:LogEntry = new LogEntry();
         _loc4_.reporter = TypeUtility.getClass(param1);
         _loc4_.method = param2;
         _loc4_.message = param2 + " - " + param3;
         _loc4_.type = LogEntry.WARNING;
         processEntry(_loc4_);
      }
      
      public static function error(param1:*, param2:String, param3:String) : void
      {
         if(disabled)
         {
            return;
         }
         var _loc4_:LogEntry = new LogEntry();
         _loc4_.reporter = TypeUtility.getClass(param1);
         _loc4_.method = param2;
         _loc4_.message = param2 + " - " + param3;
         _loc4_.type = LogEntry.ERROR;
         processEntry(_loc4_);
      }
      
      public static function printCustom(param1:*, param2:String, param3:String, param4:String) : void
      {
         if(disabled)
         {
            return;
         }
         var _loc5_:LogEntry = new LogEntry();
         _loc5_.reporter = TypeUtility.getClass(param1);
         _loc5_.method = param2;
         _loc5_.message = param2 + " - " + param3;
         _loc5_.type = param4;
         processEntry(_loc5_);
      }
      
      public static function getCallStack() : String
      {
         var e:Error = null;
         try
         {
            e = new Error();
            return e.getStackTrace();
         }
         catch(e:Error)
         {
         }
         return "[no callstack available]";
      }
      
      public static function printHeader(param1:*, param2:String) : void
      {
         print(param1,param2);
      }
      
      public static function printFooter(param1:*, param2:String) : void
      {
         print(param1,param2);
      }
      
      public function info(param1:String, param2:String) : void
      {
         if(this.enabled)
         {
            Logger.info(this.owner,param1,param2);
         }
      }
      
      public function warn(param1:String, param2:String) : void
      {
         if(this.enabled)
         {
            Logger.warn(this.owner,param1,param2);
         }
      }
      
      public function error(param1:String, param2:String) : void
      {
         if(this.enabled)
         {
            Logger.error(this.owner,param1,param2);
         }
      }
      
      public function print(param1:String) : void
      {
         if(this.enabled)
         {
            Logger.print(this.owner,param1);
         }
      }
   }
}

