package zlabs.debug
{
   public class TraceAppender implements ILogAppender
   {
      
      public function TraceAppender()
      {
         super();
      }
      
      public function addLogMessage(param1:String, param2:String, param3:String) : void
      {
         trace(param1 + ": " + param2 + " - " + param3);
      }
   }
}

