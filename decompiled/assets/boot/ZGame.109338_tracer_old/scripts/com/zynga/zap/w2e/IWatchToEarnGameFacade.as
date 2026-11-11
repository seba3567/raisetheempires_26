package com.zynga.zap.w2e
{
   public interface IWatchToEarnGameFacade
   {
      
      function log(param1:String) : void;
      
      function error(param1:String) : void;
      
      function count(param1:String, param2:String = "", param3:String = "", param4:String = "", param5:String = "", param6:String = "", param7:int = 1) : void;
      
      function pauseGame() : void;
      
      function resumeGame() : void;
      
      function verifyActivity(param1:IWatchToEarnActivity) : void;
      
      function getBountyExperimentVariant() : int;
      
      function get isPayingUser() : Boolean;
   }
}

