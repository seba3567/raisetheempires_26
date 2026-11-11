package utils
{
   import core.ZGlobal;
   import core.managers.ExperimentsManager;
   import core.managers.LEUnitDiscountManager;
   import core.managers.ZRTManager;
   import zlabs.debug.Logger;
   import zlabs.utils.TimeUtil;
   
   public class ZGameTimeUtil
   {
      
      public static var instance:ZGameTimeUtil = new ZGameTimeUtil();
      
      public static const DATE_STATUS_NONE:int = 0;
      
      public static const DATE_STATUS_EARLY:int = 1;
      
      public static const DATE_STATUS_ACTIVE:int = 2;
      
      public static const DATE_STATUS_LATE:int = 3;
      
      private const MILLISECONDS_TO_MINUTES:Number = 60000;
      
      private var timeTypes:Array = ["ms","m","s","h","d"];
      
      private var timeMults:Array = [0.001,60,1,3600,86400];
      
      private var m_multiplier:Number = 1;
      
      private var m_days:int = 0;
      
      private var m_hours:int = 0;
      
      private var m_minutes:int = 0;
      
      private var m_seconds:int = 0;
      
      public function ZGameTimeUtil()
      {
         super();
         var _loc1_:Number = ZGlobal.gameSettings.getNumber("millisecondsToMinutes");
         this.m_multiplier = _loc1_ / this.MILLISECONDS_TO_MINUTES;
      }
      
      public function get devMultiplier() : Number
      {
         return this.m_multiplier;
      }
      
      public function parseTimeAsSeconds(param1:String, param2:Number) : Number
      {
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         if(param1)
         {
            _loc3_ = 0;
            for each(_loc4_ in this.timeTypes)
            {
               _loc5_ = param1.lastIndexOf(_loc4_);
               if(_loc5_ >= 0)
               {
                  _loc6_ = param1.substring(0,_loc5_);
                  return parseFloat(_loc6_) * this.timeMults[_loc3_];
               }
               _loc3_++;
            }
            Logger.error("ZGameTimeUtil","ZGameTimeUtil","time type not found in duration: " + param1 + ", add d,h,m,s,ms as qualifier");
         }
         return param2;
      }
      
      private function calculateValues(param1:int, param2:Boolean = false) : void
      {
         var _loc3_:int = int(param1);
         this.m_days = int(_loc3_ / this.timeMults[4]);
         _loc3_ -= this.m_days * this.timeMults[4];
         this.m_hours = int(_loc3_ / this.timeMults[3]);
         _loc3_ -= this.m_hours * this.timeMults[3];
         this.m_minutes = int(_loc3_ / this.timeMults[1]);
         _loc3_ -= this.m_minutes * this.timeMults[1];
         this.m_seconds = _loc3_;
         if(param2 && Boolean(this.m_days))
         {
            this.m_hours += this.m_days * 24;
            this.m_days = 0;
         }
      }
      
      public function getTimeString(param1:Number, param2:Boolean = false) : String
      {
         this.calculateValues(int(param1),param2);
         var _loc3_:String = "";
         if(this.m_days > 0 && this.m_hours > 0)
         {
            _loc3_ = ZGameUtils.ZlocT("Main","DaysAndHoursDuration",{
               "numDays":this.m_days,
               "numHours":this.m_hours,
               "day":ZGameUtils.ZlocTk("Objects","day","",this.m_days),
               "hr":ZGameUtils.ZlocTk("Objects","hr","",this.m_hours)
            });
         }
         else if(this.m_days > 0)
         {
            _loc3_ = ZGameUtils.ZlocT("Main","DaysDuration",{
               "numDays":this.m_days,
               "day":ZGameUtils.ZlocTk("Objects","day","",this.m_days)
            });
         }
         else if(this.m_hours > 0 && this.m_minutes > 0)
         {
            _loc3_ = ZGameUtils.ZlocT("Main","HoursAndMinutesDuration",{
               "numHours":this.m_hours,
               "numMinutes":this.m_minutes,
               "hr":ZGameUtils.ZlocTk("Objects","hr","",this.m_hours),
               "min":ZGameUtils.ZlocTk("Objects","min","",this.m_minutes)
            });
         }
         else if(this.m_hours > 0)
         {
            _loc3_ = ZGameUtils.ZlocT("Main","HoursDuration",{
               "numHours":this.m_hours,
               "hr":ZGameUtils.ZlocTk("Objects","hr","",this.m_hours)
            });
         }
         else if(this.m_minutes > 0 && this.m_seconds > 0)
         {
            _loc3_ = ZGameUtils.ZlocT("Main","MinutesAndSecondsDuration",{
               "numMinutes":this.m_minutes,
               "numSeconds":this.m_seconds,
               "min":ZGameUtils.ZlocTk("Objects","min","",this.m_minutes),
               "sec":ZGameUtils.ZlocTk("Objects","sec","",this.m_seconds)
            });
         }
         else if(this.m_minutes)
         {
            _loc3_ = ZGameUtils.ZlocT("Main","MinutesDuration",{
               "numMinutes":this.m_minutes,
               "min":ZGameUtils.ZlocTk("Objects","min","",this.m_minutes)
            });
         }
         else
         {
            _loc3_ = ZGameUtils.ZlocT("Main","SecondsDuration",{
               "numSeconds":this.m_seconds,
               "sec":ZGameUtils.ZlocTk("Objects","sec","",this.m_seconds)
            });
         }
         return _loc3_;
      }
      
      public function getClockString(param1:int, param2:Boolean = false, param3:Boolean = true, param4:Boolean = true) : String
      {
         var _loc5_:String = null;
         this.calculateValues(int(param1),param2);
         if(param4 && this.m_days > 0)
         {
            return this.getTimeString(param1,param3);
         }
         _loc5_ = this.getClockTime("",this.m_days,false);
         _loc5_ = _loc5_ + this.getClockTime(_loc5_,this.m_hours,false);
         _loc5_ = _loc5_ + this.getClockTime(_loc5_,this.m_minutes,false);
         return _loc5_ + this.getClockTime(_loc5_,this.m_seconds,true);
      }
      
      public function getTimeObject(param1:Number, param2:Boolean = false) : Object
      {
         this.calculateValues(int(param1),param2);
         var _loc3_:Object = new Object();
         _loc3_["days"] = this.m_days;
         _loc3_["hours"] = this.m_hours;
         _loc3_["minutes"] = this.m_minutes;
         _loc3_["seconds"] = this.m_seconds;
         _loc3_["days.1"] = this.m_days % 10;
         _loc3_["days.10"] = int(this.m_days / 10) % 10;
         _loc3_["hours.1"] = this.m_hours % 10;
         _loc3_["hours.10"] = int(this.m_hours / 10) % 10;
         _loc3_["minutes.1"] = this.m_minutes % 10;
         _loc3_["minutes.10"] = int(this.m_minutes / 10);
         _loc3_["seconds.1"] = this.m_seconds % 10;
         _loc3_["seconds.10"] = int(this.m_seconds / 10);
         _loc3_["total"] = int(param1);
         return _loc3_;
      }
      
      public function getDateStatus(param1:Object, param2:XML, param3:Boolean = true) : int
      {
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         if(param2.requiredDate == undefined)
         {
            return DATE_STATUS_NONE;
         }
         LEUnitDiscountManager.instance.leUnitHasValidDiscount(param2,param3);
         this.overrideTime(param2);
         var _loc4_:String = param2.requiredDate ? param2.requiredDate.@start : null;
         if(_loc4_)
         {
            _loc5_ = TimeUtil.dateToNumber(_loc4_,param3) / 1000;
            _loc6_ = GlobalEngine.getTimer() / 1000;
            _loc6_ = _loc6_ + ZGlobal.player.timeWarpSeconds;
            if(_loc6_ < _loc5_)
            {
               if(param1)
               {
                  param1.delta = _loc5_ - _loc6_;
                  if(!param1.stringNotUsed)
                  {
                     param1.string = ZGameTimeUtil.instance.getClockString(param1.delta,false,false);
                  }
               }
               return DATE_STATUS_EARLY;
            }
            _loc8_ = param2.requiredDate.@end;
            _loc9_ = this.getEndSeconds(param2,param3);
            if(_loc6_ < _loc9_)
            {
               if(param1)
               {
                  param1.delta = _loc9_ - _loc6_;
                  if(!param1.stringNotUsed)
                  {
                     param1.string = ZGameTimeUtil.instance.getClockString(param1.delta,false,false);
                  }
               }
               return DATE_STATUS_ACTIVE;
            }
            return DATE_STATUS_LATE;
         }
         return DATE_STATUS_NONE;
      }
      
      public function getStartSeconds(param1:XML, param2:Boolean = false) : Number
      {
         if(param1.requiredDate == undefined)
         {
            return DATE_STATUS_NONE;
         }
         LEUnitDiscountManager.instance.leUnitHasValidDiscount(param1,param2);
         this.overrideTime(param1);
         var _loc3_:String = param1.requiredDate ? param1.requiredDate.@start : null;
         if(_loc3_)
         {
            return TimeUtil.dateToNumber(_loc3_,param2) / 1000;
         }
         return 0;
      }
      
      public function getEndSeconds(param1:XML, param2:Boolean = false) : Number
      {
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:Array = null;
         var _loc7_:Number = NaN;
         if(param1.requiredDate == undefined)
         {
            return DATE_STATUS_NONE;
         }
         LEUnitDiscountManager.instance.leUnitHasValidDiscount(param1,param2);
         this.overrideTime(param1);
         var _loc3_:String = param1.requiredDate ? param1.requiredDate.@end : null;
         if(_loc3_)
         {
            _loc4_ = TimeUtil.dateToNumber(_loc3_,param2) / 1000;
            if(param1.requiredDate.experiment != undefined)
            {
               _loc5_ = ExperimentsManager.instance.getExperimentVariant(param1.requiredDate.experiment.@id.toString());
               _loc6_ = param1.requiredDate.experiment.@values.toString().split(",");
               _loc7_ = this.parseTimeAsSeconds(_loc6_[_loc5_],0);
               _loc4_ += _loc7_;
            }
            return _loc4_;
         }
         return 0;
      }
      
      public function isLimitedEdition(param1:XML) : Boolean
      {
         if(this.getDateStatus(null,param1) != DATE_STATUS_NONE)
         {
            return true;
         }
         return false;
      }
      
      private function digit(param1:int) : String
      {
         var _loc2_:String = null;
         if(param1 < 10)
         {
            _loc2_ = "0";
         }
         else
         {
            _loc2_ = "";
         }
         return _loc2_ + param1.toString();
      }
      
      private function getClockTime(param1:String, param2:int, param3:Boolean) : String
      {
         var _loc4_:String = null;
         var _loc5_:Boolean = param1.length > 0;
         if(_loc5_)
         {
            _loc4_ = ":";
         }
         else if(param3)
         {
            _loc4_ = "00:";
         }
         else
         {
            _loc4_ = "";
         }
         if(_loc5_ || param2 > 0 || param3)
         {
            _loc4_ += this.digit(param2);
         }
         return _loc4_;
      }
      
      public function overrideTime(param1:XML) : void
      {
         var _loc2_:Object = null;
         if(param1.requiredDate != undefined && param1.requiredDate.@overrideKey != undefined)
         {
            _loc2_ = ZRTManager.instance.getDateRange(param1.requiredDate.@overrideKey.toString());
            if(_loc2_ != null)
            {
               param1.requiredDate.@start = _loc2_.start;
               param1.requiredDate.@end = _loc2_.end;
               delete param1.requiredDate["overrideKey"];
            }
         }
      }
   }
}

