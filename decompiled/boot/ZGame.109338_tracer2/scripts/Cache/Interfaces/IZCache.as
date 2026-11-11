package Cache.Interfaces
{
   public interface IZCache
   {
      
      function get initError() : Error;
      
      function get lastFlushError() : Error;
      
      function get inactivityFlushTimeout() : int;
      
      function set inactivityFlushTimeout(param1:int) : void;
      
      function get namespace() : String;
      
      function init(param1:String) : Boolean;
      
      function flush() : Boolean;
      
      function get allowed() : Boolean;
      
      function promptForStorage(param1:Function, param2:Function) : void;
      
      function put(param1:String, param2:*, param3:uint) : Boolean;
      
      function get(param1:String) : *;
      
      function containsKey(param1:String) : Boolean;
      
      function clear() : Boolean;
      
      function remove(param1:String) : *;
      
      function get stats() : Object;
   }
}

