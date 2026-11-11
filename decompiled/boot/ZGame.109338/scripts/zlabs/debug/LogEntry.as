package zlabs.debug
{
   public class LogEntry
   {
      
      public static const ERROR:String = "ERROR";
      
      public static const WARNING:String = "WARNING";
      
      public static const DEBUG:String = "DEBUG";
      
      public static const INFO:String = "INFO";
      
      public static const MESSAGE:String = "MESSAGE";
      
      public var reporter:Class = null;
      
      public var method:String = "";
      
      public var message:String = "";
      
      public var type:String = null;
      
      public var depth:int = 0;
      
      public function LogEntry()
      {
         super();
      }
      
      public function get formattedMessage() : String
      {
         var _loc1_:String = "";
         var _loc2_:int = 0;
         while(_loc2_ < this.depth)
         {
            _loc1_ += "   ";
            _loc2_++;
         }
         var _loc3_:String = "";
         if(_loc3_)
         {
            _loc3_ += ": ";
         }
         var _loc4_:String = "";
         if(_loc4_ != null && _loc4_ != "")
         {
            _loc4_ += " - ";
         }
         return _loc1_ + _loc3_ + _loc4_ + this.message;
      }
   }
}

