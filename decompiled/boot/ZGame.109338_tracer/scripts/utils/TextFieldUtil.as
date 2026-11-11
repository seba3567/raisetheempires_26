package utils
{
   import core.ZGlobal;
   import flash.display.Stage;
   import flash.display.StageQuality;
   import flash.filters.BitmapFilter;
   import flash.filters.GlowFilter;
   import flash.filters.GradientGlowFilter;
   import flash.text.AntiAliasType;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import zlabs.Zlab;
   
   public class TextFieldUtil
   {
      
      private static const ABSURDLY_LONG_TEXTFIELD_LENGTH:Number = 1024;
      
      private static const COMPACT_TEXTFIELD_DEFAULT_MINSCALE:Number = 0.8;
      
      public function TextFieldUtil()
      {
         super();
      }
      
      public static function processTextField(param1:TextField, param2:String = "") : void
      {
         var _loc5_:TextFormat = null;
         var _loc6_:String = null;
         var _loc7_:TextFormat = null;
         var _loc8_:Boolean = false;
         if(param1 == null)
         {
            return;
         }
         param1.mouseEnabled = false;
         var _loc3_:Stage = Zlab.mainStage;
         var _loc4_:String = _loc3_.quality;
         if(_loc4_.toLowerCase() != StageQuality.HIGH)
         {
            _loc3_.quality = StageQuality.HIGH;
         }
         if(!param1.embedFonts)
         {
            _loc5_ = param1.defaultTextFormat;
            _loc6_ = _loc5_.font;
            _loc7_ = GlobalEngine.fontMapper.mapTextFormat("",_loc5_);
            _loc8_ = GlobalEngine.fontMapper.mapFontEmbed("",_loc6_,true);
            param1.embedFonts = _loc8_;
            param1.setTextFormat(_loc7_);
            param1.defaultTextFormat = _loc7_;
            param1.selectable = false;
            param1.antiAliasType = AntiAliasType.ADVANCED;
         }
         param1.text = param2;
         if(_loc3_.quality != _loc4_)
         {
            _loc3_.quality = _loc4_;
         }
      }
      
      public static function processSingleLineTextField(param1:TextField, param2:String = "", param3:Number = 6) : void
      {
         if(param1 != null)
         {
            param1.width = ABSURDLY_LONG_TEXTFIELD_LENGTH;
            processTextField(param1,param2);
            param1.width = param1.textWidth + param3;
         }
      }
      
      public static function compactTextField(param1:TextField, param2:String = "", param3:Object = null) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:TextFormat = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:String = null;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:BitmapFilter = null;
         var _loc19_:Array = null;
         var _loc20_:* = 0;
         var _loc21_:GlowFilter = null;
         if(param1)
         {
            _loc4_ = param3 != null && param3.minScale != null ? Number(param3.minScale) : COMPACT_TEXTFIELD_DEFAULT_MINSCALE;
            _loc5_ = param3 != null && param3.maxLines != null ? int(param3.maxLines) : param1.numLines;
            _loc6_ = param3 != null && param3.filter != null ? param3.filter : "leave";
            _loc7_ = param3 != null && param3.onFail != null ? param3.onFail : "return";
            if(param3 != null && param3.fontSize != null && param3.fontSize > 0)
            {
               setTextFieldFontSize(param1,param3.fontSize);
            }
            processTextField(param1,"");
            _loc8_ = param1.defaultTextFormat;
            _loc10_ = _loc9_ = _loc8_.size ? Number(_loc8_.size) : 12;
            _loc11_ = 1;
            _loc12_ = ZGlobal.localizer.langCode;
            _loc13_ = 1;
            if(_loc6_ != "ignore" && _loc6_ != "remove")
            {
               for each(_loc18_ in param1.filters)
               {
                  if(_loc18_ is GlowFilter || _loc18_ is GradientGlowFilter)
                  {
                     _loc13_ = 1.05;
                     break;
                  }
               }
            }
            param1.multiline = true;
            param1.text = "";
            param1.text = param2;
            _loc14_ = param1.numLines > 1 ? _loc8_.leading as Number : 0;
            if(_loc14_ < 0)
            {
               _loc14_ = Math.min(1,Math.abs(_loc14_));
            }
            _loc15_ = param1.rotation;
            _loc16_ = param1.height;
            _loc17_ = param1.width;
            if(_loc15_ != 0)
            {
               param1.rotation = 0;
               _loc16_ = param1.height;
               _loc17_ = param1.width;
               param1.rotation = _loc15_;
            }
            while(_loc11_ >= _loc4_ && (param1.numLines > _loc5_ || param1.textWidth * _loc13_ > _loc17_ || param1.textHeight * _loc13_ + param1.numLines * _loc14_ > _loc16_ || param2.search(getWordWrapBreaks()) < 0 && param1.numLines > 1))
            {
               _loc9_ -= 0.5;
               _loc8_.size = _loc9_;
               param1.defaultTextFormat = _loc8_;
               param1.text = param2;
               _loc11_ = _loc9_ / _loc10_;
            }
            if(param1.numLines > _loc5_ && _loc7_ == "restore")
            {
               _loc8_.size = _loc10_;
               param1.defaultTextFormat = _loc8_;
               param1.text = param2;
               return;
            }
            if(_loc11_ < 1)
            {
               switch(_loc6_)
               {
                  case "scale":
                     _loc19_ = param1.filters;
                     _loc20_ = int(_loc19_.length - 1);
                     while(_loc20_ >= 0)
                     {
                        _loc21_ = _loc19_[_loc20_] as GlowFilter;
                        if(_loc21_)
                        {
                           _loc21_.blurX *= _loc11_;
                           _loc21_.blurY *= _loc11_;
                        }
                        _loc20_--;
                     }
                     param1.filters = _loc19_;
                     break;
                  case "remove":
                     param1.filters = null;
               }
            }
         }
      }
      
      public static function setMouseEnabled(param1:Array, param2:Boolean = true) : void
      {
         var _loc3_:TextField = null;
         for each(_loc3_ in param1)
         {
            if(_loc3_)
            {
               _loc3_.mouseEnabled = param2;
            }
         }
      }
      
      public static function setTextFieldColor(param1:TextField, param2:Object) : void
      {
         var _loc3_:TextFormat = null;
         if(param1)
         {
            _loc3_ = param1.defaultTextFormat;
            _loc3_.color = param2;
            param1.setTextFormat(_loc3_);
            param1.defaultTextFormat = _loc3_;
         }
      }
      
      public static function setTextFieldFontSize(param1:TextField, param2:Number) : void
      {
         var _loc3_:TextFormat = null;
         if(param1)
         {
            _loc3_ = param1.defaultTextFormat;
            _loc3_.size = param2;
            param1.setTextFormat(_loc3_);
            param1.defaultTextFormat = _loc3_;
         }
      }
      
      public static function getWordWrapBreaks() : RegExp
      {
         return /\s|-|，|。|！|、/;
      }
      
      public static function mb_strwidth(param1:String) : int
      {
         var _loc4_:Number = NaN;
         var _loc2_:int = param1.length;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = param1.substr(_loc3_,1).charCodeAt();
            if(_loc4_ >= 8192 && _loc4_ <= 65376)
            {
               _loc2_++;
            }
            else if(_loc4_ >= 65440)
            {
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
   }
}

