package com.zynga.ads.w2e
{
   import com.zynga.ads.zac_internal;
   import flash.events.Event;
   
   use namespace zac_internal;
   
   public class SlotEvent extends Event
   {
      
      zac_internal static const VERSION:String = "#{VERSION}";
      
      public static const ACTIVITY_COMPLETE:String = "activityComplete";
      
      public static const PAUSE_GAME:String = "pauseGame";
      
      public static const RESUME_GAME:String = "resumeGame";
      
      private var _slot:ISlot;
      
      private var _payload:String;
      
      private var _reward:IReward;
      
      public function SlotEvent(param1:String, param2:ISlot, param3:String = null, param4:IReward = null)
      {
         super(param1);
         this._slot = param2;
         this._payload = param3;
         this._reward = param4;
      }
      
      public function get slot() : ISlot
      {
         return this._slot;
      }
      
      public function get payload() : String
      {
         return this._payload;
      }
      
      public function get reward() : IReward
      {
         return this._reward;
      }
      
      override public function toString() : String
      {
         var _loc1_:Array = ["[SlotEvent ","type: ",type,", ","slot: ",this.slot || "null",", ","payload: ",this.payload || "null",", ","reward: ",this.reward || "null","]"];
         return _loc1_.join("");
      }
   }
}

