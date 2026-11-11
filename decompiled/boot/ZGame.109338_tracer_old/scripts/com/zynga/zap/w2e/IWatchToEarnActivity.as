package com.zynga.zap.w2e
{
   public interface IWatchToEarnActivity
   {
      
      function get networkId() : String;
      
      function get gameId() : int;
      
      function get id() : String;
      
      function get completed() : Boolean;
      
      function get algorithm() : String;
      
      function get payload() : String;
      
      function get signature() : String;
      
      function get loaded() : Boolean;
      
      function get loadStart() : Date;
      
      function get loadEnd() : Date;
      
      function get valid() : Boolean;
      
      function toString() : String;
      
      function toJSON() : String;
   }
}

