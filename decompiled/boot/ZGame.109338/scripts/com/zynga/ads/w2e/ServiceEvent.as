package com.zynga.ads.w2e
{
   import com.zynga.ads.zac_internal;
   import flash.events.Event;
   
   use namespace zac_internal;
   
   public class ServiceEvent extends Event
   {
      
      zac_internal static const VERSION:String = "#{VERSION}";
      
      public static const PAUSE_GAME:String = "pauseGame";
      
      public static const RESUME_GAME:String = "resumeGame";
      
      private var _slot:ISlot;
      
      public function ServiceEvent(param1:String, param2:ISlot = null)
      {
         super(param1);
         this._slot = param2;
      }
      
      public function get slot() : ISlot
      {
         return this._slot;
      }
      
      override public function toString() : String
      {
         var _loc1_:Array = ["[ServiceEvent ","type: ",type,", ","slot: ",this.slot || "null","]"];
         return _loc1_.join("");
      }
   }
}

