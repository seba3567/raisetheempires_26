package core.managers
{
   import com.adobe.serialization.json.JSON;
   import core.ZGlobal;
   import flash.utils.Dictionary;
   import zlabs.debug.Logger;
   import zlabs.utils.TimeUtil;
   
   public class ZRTManager
   {
      
      protected static var m_instance:ZRTManager = null;
      
      protected var m_dateRanges:Dictionary = new Dictionary();
      
      private var m_overridesKey:String = "DATE_RANGE_OVERRIDES";
      
      protected var m_mfsp2Data:Object;
      
      private var m_mfsp2Key:String = "MFSP2_DATA";
      
      protected var m_mfs_bundle:int;
      
      private var m_mfs_bundle_key:String = "MFS_BUNDLE";
      
      public function ZRTManager()
      {
         super();
      }
      
      public static function get instance() : ZRTManager
      {
         if(!m_instance)
         {
            m_instance = new ZRTManager();
         }
         return m_instance;
      }
      
      public function addDateRange(param1:String, param2:Object) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(Boolean(param2) && Boolean(param2.start != undefined) && param2.end != undefined)
         {
            _loc3_ = TimeUtil.dateToNumber(param2.start) / 1000;
            _loc4_ = TimeUtil.dateToNumber(param2.end) / 1000;
            _loc5_ = TimeUtil.dateToNumber("01/01/2200") / 1000;
            if(this.isValidDateFormat(param2.start) && this.isValidDateFormat(param2.end) && _loc3_ > 0 && _loc4_ > 0 && _loc3_ < _loc5_ && _loc4_ < _loc5_ && _loc3_ < _loc4_)
            {
               this.m_dateRanges[param1] = param2;
            }
         }
      }
      
      public function getDateRange(param1:String) : Object
      {
         return this.m_dateRanges[param1] ? this.m_dateRanges[param1] : null;
      }
      
      public function getMFSZRTData() : Object
      {
         return this.m_mfsp2Data ? this.m_mfsp2Data : null;
      }
      
      public function getMFSBundleData() : int
      {
         return this.m_mfs_bundle >= 25 && this.m_mfs_bundle <= 50 ? this.m_mfs_bundle : 25;
      }
      
      public function init(param1:Object) : void
      {
         var overrides:Object = null;
         var key:String = null;
         var result:Object = param1;
         if(result[this.m_overridesKey] != undefined)
         {
            try
            {
               overrides = com.adobe.serialization.json.JSON.decode(result[this.m_overridesKey]);
               if(overrides)
               {
                  for(key in overrides)
                  {
                     this.addDateRange(key,overrides[key]);
                  }
               }
            }
            catch(e:Error)
            {
            }
         }
         if(result[this.m_mfsp2Key] != undefined)
         {
            try
            {
               this.m_mfsp2Data = com.adobe.serialization.json.JSON.decode(result[this.m_mfsp2Key]);
            }
            catch(e:Error)
            {
               Logger.debug(this,result[m_overridesKey],e.message);
            }
         }
         if(result[this.m_mfs_bundle_key] != undefined)
         {
            try
            {
               this.m_mfs_bundle = com.adobe.serialization.json.JSON.decode(result[this.m_mfs_bundle_key]);
            }
            catch(e:Error)
            {
               m_mfs_bundle = 25;
               Logger.debug(this,result[m_mfs_bundle_key],e.message);
            }
         }
      }
      
      public function isValidDateFormat(param1:String) : Boolean
      {
         var _loc2_:Array = param1.split(" ");
         var _loc3_:int = Date.parse(param1) / 1000;
         var _loc4_:Date = new Date();
         _loc4_.setTime(_loc3_ * 1000);
         var _loc5_:String = null;
         if(!_loc4_)
         {
            return false;
         }
         var _loc6_:String = _loc4_.month + 1 <= 9 ? "0" + (_loc4_.month + 1).toString() : (_loc4_.month + 1).toString();
         var _loc7_:String = _loc4_.date <= 9 ? "0" + _loc4_.date.toString() : _loc4_.date.toString();
         var _loc8_:String = _loc4_.fullYear.toString();
         var _loc9_:String = _loc4_.hours <= 9 ? "0" + _loc4_.hours.toString() : _loc4_.hours.toString();
         var _loc10_:String = _loc4_.minutes <= 9 ? "0" + _loc4_.minutes.toString() : _loc4_.minutes.toString();
         var _loc11_:String = _loc4_.seconds <= 9 ? "0" + _loc4_.seconds.toString() : _loc4_.seconds.toString();
         if(_loc2_.length == 1)
         {
            _loc5_ = _loc6_ + "/" + _loc7_ + "/" + _loc8_;
         }
         else
         {
            _loc5_ = _loc6_ + "/" + _loc7_ + "/" + _loc8_ + " " + _loc9_ + ":" + _loc10_ + ":" + _loc11_;
         }
         if(_loc5_ != param1)
         {
            return false;
         }
         return true;
      }
      
      public function isZRTOn(param1:String, param2:Boolean = true) : Boolean
      {
         var zrtValueObj:Object = null;
         var startSeconds:Number = NaN;
         var endSeconds:Number = NaN;
         var dateString:String = param1;
         var isInUTC:Boolean = param2;
         zrtValueObj = com.adobe.serialization.json.JSON.decode(dateString);
         var currentSeconds:int = GlobalEngine.getTimer() / 1000;
         currentSeconds += ZGlobal.player.timeWarpSeconds;
         try
         {
            startSeconds = TimeUtil.dateToNumber(zrtValueObj["start"],isInUTC) / 1000;
         }
         catch(e:Error)
         {
            Logger.debug(this,zrtValueObj["start"],e.message);
         }
         try
         {
            endSeconds = TimeUtil.dateToNumber(zrtValueObj["end"],isInUTC) / 1000;
         }
         catch(e:Error)
         {
            Logger.debug(this,zrtValueObj["end"],e.message);
         }
         if(currentSeconds > endSeconds || currentSeconds < startSeconds)
         {
            return false;
         }
         return true;
      }
   }
}

