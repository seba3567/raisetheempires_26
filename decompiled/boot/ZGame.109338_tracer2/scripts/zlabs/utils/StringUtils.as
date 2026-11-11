package zlabs.utils
{
   import flash.geom.Point;
   
   public class StringUtils
   {
      
      public function StringUtils()
      {
         super();
      }
      
      public static function getFriendlyPosition(param1:int) : String
      {
         if(param1 <= 1)
         {
            return "1st";
         }
         if(param1 >= 11 && param1 <= 19)
         {
            return param1 + "th";
         }
         if(param1 % 10 == 1)
         {
            return param1 + "st";
         }
         if(param1 % 10 == 2)
         {
            return param1 + "nd";
         }
         if(param1 % 10 == 3)
         {
            return param1 + "rd";
         }
         return param1 + "th";
      }
      
      public static function secondsToTime(param1:int) : String
      {
         var _loc2_:Number = Math.floor(param1 / 3600);
         var _loc3_:Number = Math.floor(param1 % 3600 / 60);
         var _loc4_:Number = Math.floor(param1 % 3600 % 60);
         return (_loc2_ == 0 ? "" : (_loc2_ < 10 ? "0" + _loc2_.toString() + ":" : _loc2_.toString() + ":")) + (_loc3_ < 10 ? _loc3_.toString() : _loc3_.toString()) + ":" + (_loc4_ < 10 ? "0" + _loc4_.toString() : _loc4_.toString());
      }
      
      public static function formatAsDollars(param1:int) : String
      {
         var _loc6_:Number = NaN;
         var _loc2_:String = "";
         if(param1 < 0)
         {
            _loc2_ += "-";
         }
         param1 = Math.abs(param1);
         if(isNaN(param1))
         {
            return "$0";
         }
         param1 = Math.round(param1 * 100) / 100;
         var _loc3_:String = String(param1);
         var _loc4_:Array = _loc3_.split(".");
         var _loc5_:Array = new Array();
         var _loc7_:Number = Number(_loc4_[0].length);
         while(_loc7_ > 0)
         {
            _loc6_ = Math.max(_loc7_ - 3,0);
            _loc5_.unshift(_loc4_[0].slice(_loc6_,_loc7_));
            _loc7_ = _loc6_;
         }
         _loc4_[0] = _loc5_.join(",");
         return _loc2_ + "$" + _loc4_[0];
      }
      
      public static function numberToPercentage(param1:Number) : String
      {
         return param1 * 100 < 1 && param1 != 0 ? "<1" : "" + Math.floor(param1 * 100);
      }
      
      public static function stringToMoney(param1:Number, param2:Boolean = false, param3:int = 4, param4:Boolean = true, param5:Number = 1) : String
      {
         var _loc10_:Number = NaN;
         var _loc14_:String = null;
         var _loc15_:String = null;
         var _loc16_:Number = NaN;
         var _loc17_:String = null;
         var _loc18_:String = null;
         var _loc19_:String = null;
         var _loc20_:String = null;
         var _loc21_:String = null;
         var _loc22_:String = null;
         var _loc23_:String = null;
         var _loc24_:String = null;
         var _loc25_:String = null;
         var _loc26_:String = null;
         var _loc27_:String = null;
         var _loc6_:String = "";
         if(param1 < 0)
         {
            _loc6_ = "-";
            param1 = Math.abs(param1);
         }
         if(isNaN(param1))
         {
            return "0";
         }
         param1 = Math.floor(param1);
         param1 = Math.round(param1 * 100) / 100;
         var _loc7_:String = String(param1);
         var _loc8_:Array = _loc7_.split(".");
         if(_loc8_[1] == undefined)
         {
            _loc8_[1] = "00";
         }
         if(_loc8_[1].length == 1)
         {
            _loc8_[1] += "0";
         }
         var _loc9_:Array = new Array();
         var _loc11_:Number = Number(_loc8_[0].length);
         while(_loc11_ > 0)
         {
            _loc10_ = Math.max(_loc11_ - 3,0);
            _loc9_.unshift(_loc8_[0].slice(_loc10_,_loc11_));
            _loc11_ = _loc10_;
         }
         _loc8_[0] = _loc9_.join(",");
         var _loc12_:String = _loc8_.join(".");
         var _loc13_:String = _loc12_.substr(0,_loc12_.length - 3);
         if(param2 == true)
         {
            if(_loc13_.length < param3 + 1)
            {
               return _loc13_;
            }
            _loc14_ = param4 ? " " : "";
            if(_loc13_.length > param3)
            {
               _loc16_ = param1;
               if(_loc16_ >= 1000 && _loc16_ < 1000000)
               {
                  _loc18_ = _loc16_.toString();
                  _loc19_ = _loc18_.substr(0,_loc18_.length - 2);
                  _loc20_ = _loc19_.substr(0,_loc19_.length - 1);
                  _loc21_ = _loc19_.substr(_loc19_.length - 1,_loc19_.length);
                  if(_loc21_ == "0")
                  {
                     _loc15_ = _loc20_;
                  }
                  else
                  {
                     _loc15_ = _loc20_ + "." + _loc21_;
                  }
                  _loc15_ += _loc14_;
                  switch(param5)
                  {
                     case 0:
                        break;
                     case 1:
                        _loc15_ += "K";
                        break;
                     case 3:
                        _loc15_ += "K";
                        break;
                     default:
                        _loc15_ += "K";
                  }
               }
               else if(_loc16_ >= 1000000 && _loc16_ < 1000000000)
               {
                  _loc22_ = _loc16_.toString();
                  _loc23_ = _loc22_.substr(0,_loc22_.length - 5);
                  _loc17_ = _loc23_.substr(_loc23_.length - 1,_loc23_.length) != "0" ? "." + _loc23_.substr(_loc23_.length - 1,_loc23_.length) : "";
                  _loc15_ = _loc23_.substr(0,_loc23_.length - 1) + _loc17_;
                  _loc15_ = _loc15_ + _loc14_;
                  switch(param5)
                  {
                     case 0:
                        break;
                     case 1:
                        _loc15_ += "M";
                        break;
                     case 3:
                        _loc15_ += "Mil";
                        break;
                     default:
                        _loc15_ += "Million";
                  }
               }
               else if(_loc16_ >= 1000000000 && _loc16_ < 1000000000000)
               {
                  _loc24_ = _loc16_.toString();
                  _loc25_ = _loc24_.substr(0,_loc24_.length - 8);
                  _loc17_ = _loc25_.substr(_loc25_.length - 1,_loc25_.length) != "0" ? "." + _loc25_.substr(_loc25_.length - 1,_loc25_.length) : "";
                  _loc15_ = _loc25_.substr(0,_loc25_.length - 1) + _loc17_;
                  _loc15_ = _loc15_ + _loc14_;
                  switch(param5)
                  {
                     case 0:
                        break;
                     case 1:
                        _loc15_ += "B";
                        break;
                     case 3:
                        _loc15_ += "Bil";
                        break;
                     default:
                        _loc15_ += "Billion";
                  }
               }
               else if(_loc16_ >= 1000000000000 && _loc16_ < 1000000000000000)
               {
                  _loc26_ = _loc16_.toString();
                  _loc27_ = _loc26_.substr(0,_loc26_.length - 11);
                  _loc17_ = _loc27_.substr(_loc27_.length - 1,_loc27_.length) != "0" ? "." + _loc27_.substr(_loc27_.length - 1,_loc27_.length) : "";
                  _loc15_ = _loc27_.substr(0,_loc27_.length - 1) + _loc17_;
                  _loc15_ = _loc15_ + _loc14_;
                  switch(param5)
                  {
                     case 0:
                        break;
                     case 1:
                        _loc15_ += "T";
                        break;
                     case 3:
                        _loc15_ += "Tril";
                        break;
                     default:
                        _loc15_ += "Trillion";
                  }
               }
               _loc13_ = _loc15_;
            }
         }
         return _loc6_ + _loc13_;
      }
      
      public static function formatNumber(param1:int) : String
      {
         var _loc4_:Number = NaN;
         var _loc2_:String = param1.toString();
         var _loc3_:Array = new Array();
         var _loc5_:Number = _loc2_.length;
         while(_loc5_ > 0)
         {
            _loc4_ = Math.max(_loc5_ - 3,0);
            _loc3_.unshift(_loc2_.slice(_loc4_,_loc5_));
            _loc5_ = _loc4_;
         }
         return _loc3_.join(",");
      }
      
      public static function getFormattedTimeString(param1:Number = 0) : String
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc2_:Object = new Object();
         if(param1 == 0)
         {
            _loc6_ = 0;
         }
         else
         {
            _loc6_ = param1;
         }
         if(_loc6_ > 0)
         {
            _loc7_ = _loc6_ / 60 / 60 / 24;
            _loc2_.tDays = Math.floor(_loc7_);
            if(_loc2_.tDays >= 1)
            {
               if(_loc7_ - _loc2_.tDays >= 0.5)
               {
                  _loc2_.tDays += 1;
               }
               else
               {
                  _loc2_.tDays += 0.5;
               }
            }
            if(_loc2_.tDays > 1)
            {
               return _loc2_.tDays.toString() + " DAYS";
            }
            if(_loc2_.tDays == 1)
            {
               return _loc2_.tDays.toString() + " DAY";
            }
            _loc2_.tHours = Math.floor(_loc6_ / 60 / 60 % 24);
            _loc2_.tMinutes = Math.floor(_loc6_ / 60 % 60);
            _loc2_.tSeconds = _loc6_ % 60;
         }
         else
         {
            _loc2_.tDays = 0;
            _loc2_.tHours = 0;
            _loc2_.tMinutes = 0;
            _loc2_.tSeconds = 0;
         }
         _loc3_ = _loc2_.tHours < 10 ? "0" + _loc2_.tHours.toString() : _loc2_.tHours.toString();
         _loc4_ = _loc2_.tMinutes < 10 ? "0" + _loc2_.tMinutes.toString() : _loc2_.tMinutes.toString();
         _loc5_ = _loc2_.tSeconds < 10 ? "0" + _loc2_.tSeconds.toString() : _loc2_.tSeconds.toString();
         return _loc3_ + ":" + _loc4_ + ":" + _loc5_;
      }
      
      public static function parsePoint(param1:String) : Point
      {
         var _loc2_:Array = param1.split(",");
         return new Point(parseInt(_loc2_[0]),parseInt(_loc2_[1]));
      }
      
      public static function getFilenameFromPath(param1:String) : String
      {
         var _loc2_:Array = param1.split("/");
         return _loc2_[_loc2_.length - 1];
      }
      
      public static function upperCaseFirstChar(param1:String) : String
      {
         var _loc2_:String = param1.substr(0,1);
         var _loc3_:String = param1.substr(1,param1.length);
         return _loc2_.toUpperCase() + _loc3_;
      }
      
      public static function stringPad(param1:String, param2:int = 0, param3:String = " ", param4:String = "PAD_RIGHT") : String
      {
         var _loc5_:String = param1;
         if(param4 == "PAD_LEFT")
         {
            while(_loc5_.length < param2)
            {
               _loc5_ = param3 + _loc5_;
            }
         }
         else
         {
            while(_loc5_.length < param2)
            {
               _loc5_ += param3;
            }
         }
         return _loc5_;
      }
   }
}

