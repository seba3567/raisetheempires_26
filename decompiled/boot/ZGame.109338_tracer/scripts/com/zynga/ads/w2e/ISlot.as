package com.zynga.ads.w2e
{
   import flash.events.IEventDispatcher;
   
   public interface ISlot extends IEventDispatcher
   {
      
      function get id() : String;
      
      function get available() : Boolean;
      
      function get status() : String;
      
      function get reward() : IReward;
      
      function reportStatus() : void;
      
      function startActivity() : void;
   }
}

