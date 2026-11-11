package interfaces
{
   import flash.system.ApplicationDomain;
   
   public interface IGame
   {
      
      function startPreloaderInit() : void;
      
      function initQuest(param1:*) : void;
      
      function initLocale(param1:*, param2:ApplicationDomain) : void;
      
      function initGameSettings(param1:*) : void;
      
      function initTInit(param1:*) : void;
   }
}

