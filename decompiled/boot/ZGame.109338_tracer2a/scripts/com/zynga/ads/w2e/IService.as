package com.zynga.ads.w2e
{
   import flash.events.IEventDispatcher;
   
   public interface IService extends IEventDispatcher
   {
      
      function getSlot(param1:String) : ISlot;
   }
}

