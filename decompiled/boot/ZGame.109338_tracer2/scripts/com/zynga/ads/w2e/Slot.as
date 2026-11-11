package com.zynga.ads.w2e
{
   import com.zynga.ads.zac_internal;
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   
   use namespace zac_internal;
   
   internal class Slot extends EventDispatcher implements ISlot
   {
      
      zac_internal static const VERSION:String = "#{VERSION}";
      
      private static const SERVICE:String = "zynga.ads.WatchToEarn.service";
      
      private var _id:String;
      
      public function Slot(param1:String)
      {
         super();
         this._id = param1;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get available() : Boolean
      {
         return ExternalInterface.call(SERVICE + ".available",this._id) as Boolean;
      }
      
      public function get reward() : IReward
      {
         var _loc1_:Object = ExternalInterface.call(SERVICE + ".getReward",this._id) as Object;
         return new Reward(_loc1_);
      }
      
      public function reportStatus() : void
      {
         ExternalInterface.call(SERVICE + ".reportStatus",this._id);
      }
      
      public function startActivity() : void
      {
         ExternalInterface.call(SERVICE + ".startActivity",this._id);
      }
      
      public function get status() : String
      {
         return ExternalInterface.call(SERVICE + ".status",this._id) as String;
      }
      
      internal function dispatchExternalEvent(param1:*) : void
      {
         var _loc2_:IReward = null;
         if(param1.reward)
         {
            _loc2_ = new Reward(param1.reward);
         }
         var _loc3_:SlotEvent = new SlotEvent(param1.type,this,param1.payload,_loc2_);
         dispatchEvent(_loc3_);
      }
      
      override public function toString() : String
      {
         var _loc1_:Array = ["[Slot ","id: ",this.id,", ","available: ",this.available,", ","status: ",this.status,"]"];
         return _loc1_.join("");
      }
   }
}

