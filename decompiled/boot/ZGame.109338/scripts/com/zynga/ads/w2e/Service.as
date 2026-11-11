package com.zynga.ads.w2e
{
   import com.zynga.ads.zac_internal;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   use namespace zac_internal;
   
   internal class Service extends EventDispatcher implements IService
   {
      
      zac_internal static const VERSION:String = "#{VERSION}";
      
      private var _slots:Dictionary;
      
      public function Service(param1:*)
      {
         var slotIds:* = param1;
         super();
         if(slotIds === null)
         {
            throw ArgumentError("Argument \'slotIds\' cannot be null.");
         }
         if(!(slotIds is String || slotIds is Array))
         {
            throw ArgumentError("Argument \'slotIds\' must be a string or " + "array. Instead found: " + typeof slotIds);
         }
         if(slotIds is String)
         {
            slotIds = [slotIds];
         }
         this._slots = new Dictionary();
         slotIds.forEach(function(param1:String, ... rest):void
         {
            _slots[param1] = new Slot(param1);
         });
      }
      
      public function getSlot(param1:String) : ISlot
      {
         return this._slots[param1] as ISlot;
      }
      
      internal function dispatchExternalEvent(param1:*) : void
      {
         var _loc3_:ServiceEvent = null;
         if(param1.origin === "service" && (param1.type === ServiceEvent.PAUSE_GAME || param1.type === ServiceEvent.RESUME_GAME))
         {
            _loc3_ = new ServiceEvent(param1.type,this.getSlot(param1.slotId));
            dispatchEvent(_loc3_);
         }
         var _loc2_:Slot = this._slots[param1.slotId] as Slot;
         if(Boolean(_loc2_) && param1.origin === "slot")
         {
            _loc2_.dispatchExternalEvent(param1);
         }
      }
   }
}

