package zlabs.core
{
   public interface IQueuedObject extends IPrioritizable
   {
      
      function get nextThinkTime() : Number;
      
      function get nextThinkCallback() : Function;
   }
}

