package com.zynga.zap.w2e
{
   import com.zynga.zap.w2e.json.JSON;
   import flash.external.ExternalInterface;
   import flash.utils.Dictionary;
   
   use namespace w2e_internal;
   
   public class WatchToEarnService
   {
      
      w2e_internal static const VERSION:String = "2.2.5-21-g9ffba2e";
      
      private var facade:IWatchToEarnGameFacade;
      
      private var completedActivities:Dictionary = new Dictionary();
      
      private var dailyWatchCount:int = -1;
      
      private var dailyWatchStartTime:int = -1;
      
      private var lastNoAdsErrorCode:int = NoAdsErrorCodes.NO_ERROR;
      
      public function WatchToEarnService(param1:IWatchToEarnGameFacade)
      {
         super();
         this.facade = param1;
         this.initialize();
      }
      
      public function countPrompt() : void
      {
         this.facade.log("WatchToEarnService.countPrompt");
         var _loc1_:String = this.getNetworkId();
         switch(this.lastNoAdsErrorCode)
         {
            case NoAdsErrorCodes.NO_INVENTORY:
               this.facade.count(Counter.PROMPTS,Kingdom.OUT_OF_ENERGY,Phylum.WATCH_TO_EARN,ZClass.UNAVAILABLE_NO_INVENTORY,_loc1_);
               break;
            case NoAdsErrorCodes.DAILY_CAP:
               this.facade.count(Counter.PROMPTS,Kingdom.OUT_OF_ENERGY,Phylum.WATCH_TO_EARN,ZClass.UNAVAILABLE_DAILY_CAP,_loc1_);
               break;
            case NoAdsErrorCodes.PAYER:
               this.facade.count(Counter.PROMPTS,Kingdom.OUT_OF_ENERGY,Phylum.WATCH_TO_EARN,ZClass.UNAVAILABLE_PAYER,_loc1_);
               break;
            default:
               this.facade.count(Counter.PROMPTS,Kingdom.OUT_OF_ENERGY,Phylum.WATCH_TO_EARN,ZClass.PROMPTED,_loc1_);
         }
      }
      
      public function startActivity() : void
      {
         var reward:int;
         var activityJSON:String;
         var activity:IWatchToEarnActivity;
         this.facade.pauseGame();
         reward = this.getBounty();
         activityJSON = null;
         try
         {
            if(ExternalInterface.available)
            {
               activityJSON = ExternalInterface.call(Callbacks.START_ACTIVITY,reward);
            }
            else
            {
               this.facade.error("startActivity: ExternalInterface not available.");
            }
         }
         catch(error:Error)
         {
            facade.error("startActivity: ExternalInterface error: " + error);
         }
         activity = WatchToEarnActivity.fromJSON(activityJSON);
         this.facade.log("WatchToEarnService.startActivity: " + activity);
         if(activity)
         {
            this.facade.count(Counter.PROMPTS,Kingdom.OUT_OF_ENERGY,Phylum.WATCH_TO_EARN,ZClass.ACTIVITY_STARTED,activity.networkId,activity.id);
         }
      }
      
      public function loadObject(param1:Object) : void
      {
         this.facade.log("WatchToEarnService.loadObject: " + com.zynga.zap.w2e.json.JSON.encode(param1));
         this.dailyWatchCount = param1.dailyWatchCount;
         this.dailyWatchStartTime = param1.dailyWatchStartTime;
      }
      
      public function get available() : Boolean
      {
         this.facade.log("WatchToEarnService.available");
         var _loc1_:Boolean = this.getHasActivities();
         var _loc2_:String = this.getNetworkId();
         this.facade.log("network: " + _loc2_);
         if(!_loc1_)
         {
            this.lastNoAdsErrorCode = NoAdsErrorCodes.NO_INVENTORY;
            return false;
         }
         var _loc3_:int = this.getWatchToEarnCap();
         if(_loc3_ === 0)
         {
            this.lastNoAdsErrorCode = NoAdsErrorCodes.PAYER;
            return false;
         }
         var _loc4_:int = 24 * 60 * 60;
         var _loc5_:int = new Date().getTime() / 1000;
         var _loc6_:int = _loc5_ - this.dailyWatchStartTime;
         if(this.dailyWatchStartTime === -1 || _loc6_ > _loc4_)
         {
            this.dailyWatchStartTime = _loc5_;
            this.dailyWatchCount = 0;
         }
         if(this.dailyWatchCount === -1)
         {
            this.dailyWatchCount = 0;
         }
         if(this.dailyWatchCount >= _loc3_)
         {
            this.lastNoAdsErrorCode = NoAdsErrorCodes.DAILY_CAP;
            return false;
         }
         this.lastNoAdsErrorCode = NoAdsErrorCodes.NO_ERROR;
         return true;
      }
      
      public function getBounty() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = this.facade.getBountyExperimentVariant();
         var _loc3_:Boolean = this.facade.isPayingUser;
         switch(_loc2_)
         {
            case ExperimentDefinitions.LOW_CAP_ONE:
            case ExperimentDefinitions.LOW_CAP_TWO:
            case ExperimentDefinitions.LOW_CAP_THREE:
               _loc1_ = _loc3_ ? 0 : 3;
               break;
            case ExperimentDefinitions.MED_CAP_ONE:
            case ExperimentDefinitions.MED_CAP_TWO:
            case ExperimentDefinitions.MED_CAP_THREE:
               _loc1_ = _loc3_ ? 0 : 5;
               break;
            case ExperimentDefinitions.HIGH_CAP_ONE:
            case ExperimentDefinitions.HIGH_CAP_TWO:
            case ExperimentDefinitions.HIGH_CAP_THREE:
               _loc1_ = _loc3_ ? 0 : 7;
               break;
            case ExperimentDefinitions.LOW_CAP_ONE_INC_PAYER:
               _loc1_ = 3;
               break;
            case ExperimentDefinitions.LOW_CAP_TWO_INC_PAYER:
            case ExperimentDefinitions.LOW_CAP_THREE_INC_PAYER:
               _loc1_ = 7;
         }
         return _loc1_;
      }
      
      private function initialize() : void
      {
         this.facade.log("WatchToEarnService.VERSION: " + w2e_internal::VERSION);
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.addCallback(Callbacks.START,this.watchToEarnStartHandler);
               ExternalInterface.addCallback(Callbacks.FINISH,this.watchToEarnFinishHandler);
            }
            else
            {
               this.facade.error("initialize: ExternalInterface not available.");
            }
         }
         catch(error:Error)
         {
            facade.error("ExternalInterface: " + error.toString());
         }
      }
      
      private function getWatchToEarnCap() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = this.facade.getBountyExperimentVariant();
         var _loc3_:Boolean = this.facade.isPayingUser;
         switch(_loc2_)
         {
            case ExperimentDefinitions.LOW_CAP_ONE:
            case ExperimentDefinitions.MED_CAP_ONE:
            case ExperimentDefinitions.HIGH_CAP_ONE:
               _loc1_ = _loc3_ ? 0 : 1;
               break;
            case ExperimentDefinitions.LOW_CAP_TWO:
            case ExperimentDefinitions.MED_CAP_TWO:
            case ExperimentDefinitions.HIGH_CAP_TWO:
               _loc1_ = _loc3_ ? 0 : 2;
               break;
            case ExperimentDefinitions.LOW_CAP_THREE:
            case ExperimentDefinitions.MED_CAP_THREE:
            case ExperimentDefinitions.HIGH_CAP_THREE:
               _loc1_ = _loc3_ ? 0 : 3;
               break;
            case ExperimentDefinitions.LOW_CAP_ONE_INC_PAYER:
               _loc1_ = 1;
               break;
            case ExperimentDefinitions.LOW_CAP_TWO_INC_PAYER:
               _loc1_ = 2;
               break;
            case ExperimentDefinitions.LOW_CAP_THREE_INC_PAYER:
               _loc1_ = 3;
         }
         return _loc1_;
      }
      
      private function getNetworkId() : String
      {
         var networkId:String = Network.UNKNOWN;
         try
         {
            if(ExternalInterface.available)
            {
               networkId = ExternalInterface.call(Callbacks.GET_NETWORK_ID);
            }
            else
            {
               this.facade.error("getNetworkId: ExternalInterface not available.");
            }
         }
         catch(error:Error)
         {
            facade.error("getNetworkId: ExternalInterface error: " + error);
            networkId = Network.UNKNOWN;
         }
         return networkId;
      }
      
      private function getHasActivities() : Boolean
      {
         var result:Boolean = false;
         try
         {
            if(ExternalInterface.available)
            {
               result = ExternalInterface.call(Callbacks.HAS_ACTIVITIES);
            }
            else
            {
               this.facade.error("getNetworkId: ExternalInterface not available.");
            }
         }
         catch(error:Error)
         {
            facade.error("getHasActivities: ExternalInterface error: " + error);
            result = false;
         }
         return result;
      }
      
      private function watchToEarnStartHandler(param1:String) : void
      {
         var _loc2_:IWatchToEarnActivity = WatchToEarnActivity.fromJSON(param1);
         this.facade.log("onWatchToEarnStart: activity: " + _loc2_);
         if(!_loc2_ || !_loc2_.valid)
         {
            this.facade.error("onWatchToEarnStart: Invalid activity: " + _loc2_);
            return;
         }
         var _loc3_:int = _loc2_.loadEnd.getTime() - _loc2_.loadStart.getTime();
         _loc3_ = Math.round(_loc3_ / 1000);
         this.facade.count(Counter.PROMPTS,Kingdom.OUT_OF_ENERGY,Phylum.WATCH_TO_EARN,ZClass.ACTIVITY_LAUNCH_TIME,_loc2_.networkId,_loc2_.id,_loc3_);
      }
      
      private function watchToEarnFinishHandler(param1:String) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc2_:IWatchToEarnActivity = WatchToEarnActivity.fromJSON(param1);
         this.facade.log("onWatchToEarnFinish: activity: " + _loc2_);
         if(!_loc2_ || !_loc2_.valid)
         {
            this.facade.error("onWatchToEarnStart: Invalid activity: " + _loc2_);
            return;
         }
         this.facade.resumeGame();
         if(Boolean(_loc2_) && !this.completedActivities[_loc2_.id])
         {
            if(_loc2_.completed)
            {
               this.completedActivities[_loc2_.id] = true;
               this.dailyWatchCount += 1;
               this.facade.verifyActivity(_loc2_);
            }
            else if(!_loc2_.loaded)
            {
               _loc3_ = new Date().getTime();
               _loc4_ = Math.round((_loc3_ - _loc2_.loadStart.getTime()) / 1000);
               this.facade.count(Counter.PROMPTS,Kingdom.OUT_OF_ENERGY,Phylum.WATCH_TO_EARN,ZClass.ACTIVITY_DROP_OFF_TIME,_loc2_.networkId,_loc2_.id,_loc4_);
            }
         }
      }
   }
}

class Network
{
   
   public static const UNKNOWN:String = "unknown";
   
   public function Network()
   {
      super();
   }
}

class NoAdsErrorCodes
{
   
   public static const NO_ERROR:int = 0;
   
   public static const NO_INVENTORY:int = 1;
   
   public static const PAYER:int = 2;
   
   public static const DAILY_CAP:int = 3;
   
   public function NoAdsErrorCodes()
   {
      super();
   }
}

class Callbacks
{
   
   public static const START:String = "onWatchToEarnStart";
   
   public static const FINISH:String = "onWatchToEarnFinish";
   
   public static const GET_NETWORK_ID:String = "zynga.zap.wte.service.getNetworkId";
   
   public static const HAS_ACTIVITIES:String = "zynga.zap.wte.service.hasActivities";
   
   public static const START_ACTIVITY:String = "zynga.zap.wte.service.startActivity";
   
   public function Callbacks()
   {
      super();
   }
}

class ExperimentDefinitions
{
   
   public static const CONTROL_1:int = 1;
   
   public static const CONTROL_2:int = 2;
   
   public static const LOW_CAP_ONE:int = 3;
   
   public static const LOW_CAP_TWO:int = 4;
   
   public static const LOW_CAP_THREE:int = 5;
   
   public static const MED_CAP_ONE:int = 6;
   
   public static const MED_CAP_TWO:int = 7;
   
   public static const MED_CAP_THREE:int = 8;
   
   public static const HIGH_CAP_ONE:int = 9;
   
   public static const HIGH_CAP_TWO:int = 10;
   
   public static const HIGH_CAP_THREE:int = 11;
   
   public static const LOW_CAP_ONE_INC_PAYER:int = 12;
   
   public static const LOW_CAP_TWO_INC_PAYER:int = 13;
   
   public static const LOW_CAP_THREE_INC_PAYER:int = 14;
   
   public function ExperimentDefinitions()
   {
      super();
   }
}

class Counter
{
   
   public static const PROMPTS:String = "user_prompts";
   
   public function Counter()
   {
      super();
   }
}

class Kingdom
{
   
   public static const OUT_OF_ENERGY:String = "out_of_energy";
   
   public function Kingdom()
   {
      super();
   }
}

class Phylum
{
   
   public static const WATCH_TO_EARN:String = "watch_to_earn";
   
   public function Phylum()
   {
      super();
   }
}

class ZClass
{
   
   public static const PROMPTED:String = "prompted";
   
   public static const ACTIVITY_DROP_OFF_TIME:String = "activity_dropoff_time";
   
   public static const ACTIVITY_LAUNCH_TIME:String = "activity_launch_time";
   
   public static const ACTIVITY_STARTED:String = "activity_started";
   
   public static const UNAVAILABLE_PAYER:String = "unavailable_payer";
   
   public static const UNAVAILABLE_DAILY_CAP:String = "unavailable_daily_cap";
   
   public static const UNAVAILABLE_NO_INVENTORY:String = "unavailable_no_inventory";
   
   public function ZClass()
   {
      super();
   }
}
