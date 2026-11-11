package zlabs
{
   import flash.display.DisplayObject;
   import flash.external.ExternalInterface;
   import flash.geom.Matrix;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import zlabs.debug.Logger;
   
   public class ZlabUtil
   {
      
      public static const FLIP_HORIZONTAL:String = "flipHorizontal";
      
      public static const FLIP_VERTICAL:String = "flipVertical";
      
      public static const TWO_PI:Number = 2 * Math.PI;
      
      private static var m_idCounter:Number = 0;
      
      public function ZlabUtil()
      {
         super();
      }
      
      public static function getDegreesFromRadians(param1:Number) : Number
      {
         return param1 * 180 / Math.PI;
      }
      
      public static function getRadiansFromDegrees(param1:Number) : Number
      {
         return param1 * Math.PI / 180;
      }
      
      public static function clamp(param1:Number, param2:Number = 0, param3:Number = 1) : Number
      {
         if(param1 < param2)
         {
            return param2;
         }
         if(param1 > param3)
         {
            return param3;
         }
         return param1;
      }
      
      public static function cloneArray(param1:Array) : Array
      {
         var _loc3_:* = undefined;
         var _loc2_:Array = [];
         for each(_loc3_ in param1)
         {
            _loc2_.push(_loc3_);
         }
         return _loc2_;
      }
      
      public static function cloneObject(param1:Object) : Object
      {
         var _loc3_:* = undefined;
         var _loc2_:Object = new Object();
         for(_loc3_ in param1)
         {
            _loc2_[_loc3_] = param1[_loc3_];
         }
         return _loc2_;
      }
      
      public static function unwrapRadian(param1:Number) : Number
      {
         param1 %= Math.PI;
         if(param1 > Math.PI)
         {
            param1 -= TWO_PI;
         }
         if(param1 < -Math.PI)
         {
            param1 += TWO_PI;
         }
         return param1;
      }
      
      public static function unwrapDegrees(param1:Number) : Number
      {
         param1 %= 360;
         if(param1 > 180)
         {
            param1 -= 360;
         }
         if(param1 < -180)
         {
            param1 += 360;
         }
         return param1;
      }
      
      public static function getRadianShortDelta(param1:Number, param2:Number) : Number
      {
         param1 = unwrapRadian(param1);
         param2 = unwrapRadian(param2);
         var _loc3_:Number = param2 - param1;
         if(_loc3_ > Math.PI)
         {
            _loc3_ -= Math.PI * 2;
         }
         if(_loc3_ < -Math.PI)
         {
            _loc3_ += Math.PI * 2;
         }
         return _loc3_;
      }
      
      public static function getDegreesShortDelta(param1:Number, param2:Number) : Number
      {
         param1 = unwrapDegrees(param1);
         param2 = unwrapDegrees(param2);
         var _loc3_:Number = param2 - param1;
         if(_loc3_ > 180)
         {
            _loc3_ -= 360;
         }
         if(_loc3_ < -180)
         {
            _loc3_ += 360;
         }
         return _loc3_;
      }
      
      public static function getBitCountForRange(param1:int) : int
      {
         return Math.ceil(Math.log(param1) / Math.log(2));
      }
      
      public static function pickWithBias(param1:int, param2:int, param3:Number = 0) : int
      {
         return clamp((Math.random() + param3) * (param2 - param1) + param1,param1,param2);
      }
      
      public static function duckAssign(param1:Object, param2:Object, param3:Boolean = false) : void
      {
         var field:String = null;
         var source:Object = param1;
         var destination:Object = param2;
         var abortOnMismatch:Boolean = param3;
         for(field in source)
         {
            try
            {
               destination[field] = source[field];
            }
            catch(e:Error)
            {
               if(abortOnMismatch)
               {
                  throw new Error("Field \'" + field + "\' in source was not present in destination.");
               }
            }
         }
      }
      
      public static function xyLength(param1:Number, param2:Number) : Number
      {
         return Math.sqrt(param1 * param1 + param2 * param2);
      }
      
      public static function escapeHTMLText(param1:String) : String
      {
         var _loc2_:Array = [{
            "char":"&",
            "repl":"|amp|"
         },{
            "char":"<",
            "repl":"&lt;"
         },{
            "char":">",
            "repl":"&gt;"
         },{
            "char":"\'",
            "repl":"&apos;"
         },{
            "char":"\"",
            "repl":"&quot;"
         },{
            "char":"|amp|",
            "repl":"&amp;"
         }];
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            while(param1.indexOf(_loc2_[_loc3_].char) != -1)
            {
               param1 = param1.replace(_loc2_[_loc3_].char,_loc2_[_loc3_].repl);
            }
            _loc3_++;
         }
         return param1;
      }
      
      public static function getFileExtension(param1:String) : String
      {
         var _loc2_:Number = param1.lastIndexOf(".");
         if(_loc2_ == -1)
         {
            return "";
         }
         return param1.substr(_loc2_ + 1,param1.length);
      }
      
      public static function flipDisplayObject(param1:DisplayObject, param2:String) : void
      {
         var _loc3_:Matrix = param1.transform.matrix;
         switch(param2)
         {
            case FLIP_HORIZONTAL:
               _loc3_.a = -1;
               _loc3_.tx = param1.width + param1.x;
               break;
            case FLIP_VERTICAL:
               _loc3_.d = -1;
               _loc3_.ty = param1.height + param1.y;
         }
         param1.transform.matrix = _loc3_;
      }
      
      public static function dumpObjectToLogger(param1:*, param2:*, param3:int = 0, param4:String = "") : String
      {
         var _loc7_:* = undefined;
         var _loc8_:String = null;
         var _loc5_:String = "";
         var _loc6_:int = 0;
         while(_loc6_ < param3)
         {
            _loc5_ += "\t";
            _loc6_++;
         }
         for(_loc7_ in param2)
         {
            param4 += _loc5_ + "[" + _loc7_ + "] => " + param2[_loc7_];
            _loc8_ = dumpObjectToLogger(param1,param2[_loc7_],param3 + 1);
            if(_loc8_ != "")
            {
               param4 += " {\n" + _loc8_ + _loc5_ + "}";
            }
            param4 += "\n";
         }
         if(param3 == 0)
         {
            Logger.print(param1,param4);
            return "";
         }
         return param4;
      }
      
      public static function launchURL(param1:String, param2:String = "_blank", param3:Object = null) : void
      {
         var browser:String = null;
         var url:String = param1;
         var target:String = param2;
         var variables:Object = param3;
         var request:URLRequest = new URLRequest(url);
         var useNavigateToURL:Boolean = true;
         if(variables)
         {
            request.data = variables;
         }
         try
         {
            if(ExternalInterface.available)
            {
               browser = ExternalInterface.call("function a() {return navigator.userAgent;}");
               if(browser != null && browser.indexOf("Firefox") < 1)
               {
                  useNavigateToURL = true;
               }
               else
               {
                  ExternalInterface.call("window.open",url,target,"");
                  useNavigateToURL = false;
               }
            }
            else
            {
               useNavigateToURL = true;
            }
         }
         catch(error:SecurityError)
         {
            useNavigateToURL = true;
         }
         if(useNavigateToURL)
         {
            navigateToURL(request,target);
         }
      }
      
      public static function generateUniqueId() : Number
      {
         ++m_idCounter;
         return m_idCounter;
      }
   }
}

