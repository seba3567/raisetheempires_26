package core.ui
{
   import flash.display.*;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.DropShadowFilter;
   import flash.text.*;
   import flash.utils.*;
   
   public class Tooltip extends Sprite
   {
      
      private static var instance:Tooltip;
      
      private static var delayTimer:Timer;
      
      public static const SHADOW_NONE:int = 0;
      
      public static const SHADOW_HOLLOW:int = 1;
      
      public static const SHADOW_FULL:int = 2;
      
      public static const COLOR_TEXT:int = -1;
      
      public static const COLOR_NONE:int = -2;
      
      public static const MARGIN:String = "margin";
      
      public static const STAGE_RECT:Object = {};
      
      private static var allowInstantiation:Boolean = false;
      
      private var options:Object;
      
      private var defOptions:Object;
      
      private var globalOptions:Object;
      
      private var keys:Dictionary;
      
      private var currentProps:Object;
      
      private var background:Sprite;
      
      private var tipText:TextField;
      
      private var tipWidth:Number;
      
      private var tipHeight:Number;
      
      private var chunk:Number;
      
      public function Tooltip()
      {
         super();
         if(!allowInstantiation)
         {
            throw new Error("Tooltip: Singleton Class - use Tooltip.show() or Tooltip.subscribe()");
         }
         this.keys = new Dictionary(true);
         this.defOptions = {
            "delay":0.2,
            "width":400,
            "alpha":0.8,
            "corner":10,
            "margin":4,
            "marginLeft":Tooltip.MARGIN,
            "marginRight":Tooltip.MARGIN,
            "marginTop":Tooltip.MARGIN,
            "marginBottom":Tooltip.MARGIN,
            "color":"#f6f2e9",
            "backgroundColor":6305811,
            "shadowColor":Tooltip.COLOR_TEXT,
            "shadowType":Tooltip.SHADOW_HOLLOW,
            "lineColor":Tooltip.COLOR_TEXT,
            "customBackground":null,
            "styleSheet":null,
            "fontFamily":"Futura Std Medium",
            "fontSize":14,
            "fontWeight":"Medium",
            "leading":2,
            "textAlign":TextFormatAlign.LEFT,
            "embedFonts":true,
            "followMouse":true,
            "duration":0.1,
            "offsetX":20,
            "offsetY":25,
            "fixedPosition":false,
            "fixedWidth":false,
            "boundingRect":Tooltip.STAGE_RECT
         };
         this.resetDefaultOptions();
         mouseEnabled = false;
         mouseChildren = false;
      }
      
      public static function getInstance(param1:DisplayObject = null) : Tooltip
      {
         if(Tooltip.instance == null)
         {
            allowInstantiation = true;
            Tooltip.instance = new Tooltip();
            allowInstantiation = false;
            delayTimer = new Timer(options.delay,1);
            delayTimer.addEventListener(TimerEvent.TIMER,instance.doShow);
         }
         if(param1 != null)
         {
            if(Tooltip.instance.stage == null)
            {
               if(param1.stage != null)
               {
                  param1.stage.addChild(Tooltip.instance);
                  param1.stage.addEventListener(Event.MOUSE_LEAVE,Tooltip.instance.hideListener);
                  Tooltip.instance.removeStageEvent();
               }
               else
               {
                  param1.addEventListener(Event.ADDED_TO_STAGE,instance.stageListener);
               }
            }
         }
         return Tooltip.instance;
      }
      
      public static function isInstanced() : Boolean
      {
         return Tooltip.instance != null;
      }
      
      public static function show(param1:String = "", param2:Object = null, param3:DisplayObject = null) : void
      {
         var _loc5_:Number = NaN;
         var _loc4_:Tooltip = Tooltip.getInstance(param3);
         if(_loc4_.stage != null && param1 != "" && param1 != null)
         {
            Tooltip.hide();
            _loc4_.currentProps = {
               "tooltip":param1,
               "options":param2,
               "target":param3
            };
            _loc5_ = param2 != null && param2.delay != undefined ? Number(param2.delay) : Number(options.delay);
            delayTimer.delay = _loc5_ * 1000;
            delayTimer.start();
         }
      }
      
      public static function hide() : void
      {
         delayTimer.stop();
         instance.doHide();
      }
      
      public static function isCurrDisplayObject(param1:DisplayObject = null) : Boolean
      {
         if(Tooltip.instance.currentProps != null)
         {
            return Tooltip.instance.currentProps.target == param1;
         }
         return false;
      }
      
      public static function get options() : Object
      {
         return instance.globalOptions;
      }
      
      public static function set options(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:* = undefined;
         for(_loc2_ in param1)
         {
            _loc3_ = param1[_loc2_];
            if(_loc3_ !== undefined)
            {
               instance.globalOptions[_loc2_] = _loc3_;
            }
         }
      }
      
      public static function setOption(param1:String, param2:*) : void
      {
         instance.globalOptions[param1] = param2;
      }
      
      public static function getOption(param1:String) : *
      {
         return instance.globalOptions[param1];
      }
      
      public static function getDefaultOption(param1:String) : *
      {
         return instance.defOptions[param1];
      }
      
      public static function resetDefaults() : void
      {
         instance.resetDefaultOptions();
      }
      
      public static function subscribe(param1:DisplayObject, param2:String = "", param3:Object = null, param4:Boolean = true) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc5_:Tooltip = getInstance(param1);
         if(_loc5_.stage == null)
         {
            param1.addEventListener(Event.ADDED_TO_STAGE,_loc5_.stageListener,false,0,true);
         }
         _loc5_.addTargetProps(param1,param2,param3);
         param1.addEventListener(MouseEvent.ROLL_OVER,_loc5_.showListener,false,0,true);
         param1.addEventListener(MouseEvent.ROLL_OUT,_loc5_.hideListener,false,0,true);
         if(param4)
         {
            param1.addEventListener(MouseEvent.MOUSE_DOWN,_loc5_.hideListener,false,0,true);
            param1.addEventListener(MouseEvent.CLICK,_loc5_.hideListener,false,0,true);
         }
      }
      
      public static function unsubscribe(param1:DisplayObject) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:Tooltip = getInstance(param1);
         if(_loc2_.getProps(param1) == null)
         {
            return;
         }
         param1.removeEventListener(MouseEvent.ROLL_OVER,_loc2_.showListener);
         param1.removeEventListener(MouseEvent.ROLL_OUT,_loc2_.hideListener);
         param1.removeEventListener(MouseEvent.MOUSE_DOWN,_loc2_.hideListener);
         param1.removeEventListener(MouseEvent.CLICK,_loc2_.hideListener);
         param1.removeEventListener(Event.ADDED_TO_STAGE,_loc2_.stageListener);
         param1.removeEventListener(Event.MOUSE_LEAVE,_loc2_.hideListener);
         if(Boolean(_loc2_.currentProps) && _loc2_.getProps(param1).target == _loc2_.currentProps.target)
         {
            Tooltip.hide();
         }
         _loc2_.removeTargetProps(param1);
      }
      
      public function getLocalOptions() : Object
      {
         return instance.options;
      }
      
      public function getDimensions() : Object
      {
         return {
            "width":this.tipWidth,
            "height":this.tipHeight
         };
      }
      
      private function showListener(param1:MouseEvent) : void
      {
         if(param1.buttonDown)
         {
            return;
         }
         var _loc2_:DisplayObject = param1.target as DisplayObject;
         var _loc3_:Object = Tooltip.instance.getProps(_loc2_);
         if(_loc3_ != null)
         {
            if(_loc3_.tooltip != "")
            {
               Tooltip.show(_loc3_.tooltip,_loc3_.options,_loc2_);
            }
         }
      }
      
      private function hideListener(param1:Event) : void
      {
         if(Tooltip.instance.currentProps != null && param1.target == Tooltip.instance.currentProps.target)
         {
            Tooltip.hide();
         }
      }
      
      private function stageListener(param1:Event) : void
      {
         Tooltip.getInstance(param1.target as DisplayObject);
         this.removeStageEvent();
      }
      
      protected function doShow(param1:TimerEvent) : void
      {
         var _loc3_:String = null;
         if(stage == null)
         {
            return;
         }
         var _loc2_:Object = this.currentProps.options;
         this.options = new Object();
         for(_loc3_ in this.globalOptions)
         {
            this.options[_loc3_] = _loc2_ == null || _loc2_[_loc3_] === undefined ? this.globalOptions[_loc3_] : _loc2_[_loc3_];
         }
         this.createText();
         this.placeTip();
         if(this.background != null && contains(this.background))
         {
            removeChild(this.background);
         }
         if(this.options.customBackground == null)
         {
            this.drawBackground();
         }
         else
         {
            this.attachBackground();
         }
         addChild(this.background);
         addChild(this.tipText);
         stage.setChildIndex(this,stage.numChildren - 1);
         visible = true;
         if(Boolean(this.options.followMouse) && !this.options.fixedPosition)
         {
            addEventListener(Event.ENTER_FRAME,this.placeTip);
         }
         this.animate();
      }
      
      protected function doHide() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.placeTip);
         removeEventListener(Event.ENTER_FRAME,this.fadeIn);
         if(Boolean(this.options) && Boolean(this.options.duration))
         {
            addEventListener(Event.ENTER_FRAME,this.fadeOut);
         }
         else
         {
            visible = false;
         }
      }
      
      public function createText() : void
      {
         var _loc1_:String = null;
         if(this.currentProps != null)
         {
            _loc1_ = this.currentProps.tooltip;
            if(_loc1_ == null)
            {
               return;
            }
         }
         if(this.tipText != null && contains(this.tipText))
         {
            removeChild(this.tipText);
         }
         this.tipText = new TextField();
         this.autoEmbed();
         this.updateText();
      }
      
      public function updateText() : void
      {
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:String = null;
         if(this.currentProps != null)
         {
            _loc7_ = this.currentProps.tooltip;
            if(_loc7_ == null)
            {
               return;
            }
         }
         if(_loc7_.indexOf("<tooltip") == -1)
         {
            _loc7_ = "<tooltip>" + _loc7_ + "</tooltip>";
         }
         this.setStyles();
         this.tipText.htmlText = _loc7_;
         var _loc1_:Number = this.tipWidth;
         var _loc2_:Number = this.tipHeight;
         this.tipText.autoSize = "left";
         if(visible)
         {
            this.tipWidth = this.tipText.width;
         }
         else
         {
            this.tipWidth = this.tipText.width + 1;
         }
         if(this.tipWidth > this.options.width)
         {
            this.tipText.wordWrap = true;
         }
         var _loc3_:Array = ["marginRight","marginLeft","marginTop","marginBottom"];
         for each(_loc4_ in _loc3_)
         {
            if(this.options[_loc4_] == Tooltip.MARGIN)
            {
               this.options[_loc4_] = this.options.margin;
            }
         }
         _loc5_ = this.options.marginLeft + this.options.marginRight;
         _loc6_ = this.options.marginTop + this.options.marginBottom;
         this.tipText.width = this.options.width - _loc5_;
         if(!this.options.fixedWidth)
         {
            this.tipWidth = Math.min(this.tipWidth,this.tipText.width);
            this.tipText.width = this.tipWidth;
         }
         this.tipWidth += _loc5_;
         this.tipHeight = this.tipText.height + _loc6_;
         this.tipText.x = this.options.marginLeft;
         this.tipText.y = this.options.marginTop;
         if(visible && (_loc1_ != this.tipWidth || _loc2_ != this.tipHeight))
         {
            if(this.background != null && contains(this.background))
            {
               removeChild(this.background);
            }
            if(this.options.customBackground == null)
            {
               this.drawBackground();
            }
            else
            {
               this.attachBackground();
            }
            addChild(this.background);
            if(this.tipText != null && contains(this.tipText))
            {
               removeChild(this.tipText);
            }
            addChild(this.tipText);
         }
      }
      
      protected function autoEmbed() : void
      {
         var _loc1_:Array = null;
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:Font = null;
         if(this.options.embedFonts)
         {
            _loc1_ = Font.enumerateFonts();
            _loc2_ = this.options.fontFamily.split(",");
            _loc3_ = 0;
            loop0:
            while(_loc3_ < _loc2_.length)
            {
               _loc4_ = GlobalEngine.fontMapper.mapFontName("",_loc2_[_loc3_]);
               var _loc6_:int = 0;
               var _loc7_:* = _loc1_;
               do
               {
                  for each(_loc5_ in _loc7_)
                  {
                  }
                  _loc3_++;
                  continue loop0;
               }
               while(_loc5_.fontName != _loc4_);
               this.tipText.embedFonts = true;
               this.options.fontFamily = _loc4_;
               return;
            }
            this.tipText.embedFonts = false;
         }
         this.tipText.embedFonts = false;
      }
      
      protected function setStyles() : void
      {
         var _loc1_:StyleSheet = null;
         var _loc3_:String = null;
         if(!this.options)
         {
            this.options = new Object();
         }
         if(this.options.styleSheet is StyleSheet)
         {
            _loc1_ = this.options.styleSheet;
         }
         else
         {
            _loc1_ = new StyleSheet();
         }
         var _loc2_:Object = _loc1_.getStyle("tooltip");
         if(_loc2_ == null)
         {
            _loc2_ = new Object();
         }
         if(_loc2_.color == null)
         {
            if(this.options.color is String)
            {
               _loc2_.color = this.options.color;
            }
            else
            {
               _loc3_ = this.options.color.toString(16);
               while(_loc3_.length < 6)
               {
                  _loc3_ = "0" + _loc3_;
               }
               _loc3_ = "#" + _loc3_;
               _loc2_.color = _loc3_;
            }
         }
         if(_loc2_.fontFamily == null || this.tipText.embedFonts)
         {
            _loc2_.fontFamily = this.options.fontFamily;
         }
         if(_loc2_.fontSize == null)
         {
            _loc2_.fontSize = this.options.fontSize.toString();
         }
         if(_loc2_.textAlign == null)
         {
            _loc2_.textAlign = this.options.textAlign;
         }
         if(_loc2_.fontWeight == null)
         {
            _loc2_.fontWeight = this.options.fontWeight;
         }
         if(_loc2_.leading == null)
         {
            _loc2_.leading = this.options.leading;
         }
         _loc1_.setStyle("tooltip",_loc2_);
         this.tipText.styleSheet = _loc1_;
      }
      
      protected function drawBackground() : void
      {
         var _loc1_:Shape = null;
         var _loc2_:DropShadowFilter = null;
         var _loc3_:Sprite = null;
         if(this.options.lineColor == Tooltip.COLOR_TEXT)
         {
            this.options.lineColor = this.options.color;
         }
         if(this.options.shadowColor == Tooltip.COLOR_TEXT)
         {
            this.options.shadowColor = this.options.color;
         }
         if(this.options.alpha)
         {
            this.background = new Sprite();
            _loc1_ = new Shape();
            _loc1_.graphics.beginFill(this.options.backgroundColor,this.options.alpha);
            if(this.options.lineColor != Tooltip.COLOR_NONE)
            {
               _loc1_.graphics.lineStyle(1,this.options.lineColor,this.options.alpha,true);
            }
            _loc1_.graphics.drawRoundRect(0,0,this.tipWidth,this.tipHeight,this.options.corner,this.options.corner);
            if(this.options.shadowType != Tooltip.SHADOW_NONE && this.options.shadowColor != Tooltip.COLOR_NONE)
            {
               _loc2_ = new DropShadowFilter();
               _loc2_.quality = 2;
               _loc2_.alpha = this.options.alpha;
               _loc2_.distance = 2;
               _loc2_.knockout = true;
               _loc2_.color = this.options.shadowColor;
               if(this.options.shadowType == Tooltip.SHADOW_HOLLOW)
               {
                  _loc3_ = new Sprite();
                  _loc3_.graphics.beginFill(0);
                  _loc3_.graphics.drawRoundRect(0,0,this.tipWidth,this.tipHeight,this.options.corner,this.options.corner);
                  _loc2_.knockout = true;
                  _loc3_.filters = [_loc2_];
                  this.background.addChild(_loc3_);
               }
               else if(this.options.shadowType == Tooltip.SHADOW_FULL)
               {
                  _loc1_.filters = [_loc2_];
               }
            }
            this.background.addChild(_loc1_);
         }
      }
      
      protected function attachBackground() : void
      {
         this.background = new this.options.customBackground();
         this.background.width = this.tipWidth;
         this.background.height = this.tipHeight;
      }
      
      protected function placeTip(param1:Event = null) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(this.options.boundingRect == Tooltip.STAGE_RECT)
         {
            _loc2_ = 0;
            _loc3_ = stage.stageWidth;
            _loc4_ = 0;
            _loc5_ = stage.stageHeight;
         }
         else
         {
            _loc2_ = Number(this.options.boundingRect.x);
            _loc3_ = this.options.boundingRect.x + this.options.boundingRect.width;
            _loc4_ = Number(this.options.boundingRect.y);
            _loc5_ = this.options.boundingRect.y + this.options.boundingRect.height;
         }
         if(this.options.fixedPosition)
         {
            x = this.options.offsetX;
            y = this.options.offsetY;
         }
         else
         {
            x = stage.mouseX + this.options.offsetX;
            y = stage.mouseY + this.options.offsetY;
            _loc6_ = width + x;
            _loc7_ = height + y;
            if(_loc3_ < _loc6_)
            {
               x -= _loc6_ - _loc3_;
               x = Math.max(_loc2_,x);
            }
            if(_loc5_ < _loc7_)
            {
               y -= height + this.options.offsetY;
               y = Math.max(_loc4_,y);
            }
         }
      }
      
      protected function animate() : void
      {
         removeEventListener(Event.ENTER_FRAME,this.fadeOut);
         if(this.options.duration)
         {
            alpha = 0;
            this.chunk = 1 / stage.frameRate / this.options.duration;
            addEventListener(Event.ENTER_FRAME,this.fadeIn);
         }
         else
         {
            alpha = 1;
         }
      }
      
      private function addTargetProps(param1:DisplayObject, param2:String = "", param3:Object = null) : void
      {
         var _loc4_:Object = {
            "target":param1,
            "tooltip":param2,
            "options":param3
         };
         this.keys[param1] = _loc4_;
      }
      
      private function removeTargetProps(param1:DisplayObject) : void
      {
         delete this.keys[param1];
      }
      
      private function getProps(param1:DisplayObject) : Object
      {
         return this.keys[param1];
      }
      
      public function setCurrentProps(param1:String = "", param2:Object = null, param3:DisplayObject = null) : void
      {
         this.currentProps = {
            "tooltip":param1,
            "options":param2,
            "target":param3
         };
      }
      
      private function resetDefaultOptions() : void
      {
         var _loc1_:String = null;
         this.globalOptions = new Object();
         for(_loc1_ in this.defOptions)
         {
            this.globalOptions[_loc1_] = this.defOptions[_loc1_];
         }
      }
      
      private function removeStageEvent() : void
      {
         var _loc1_:Object = null;
         for each(_loc1_ in this.keys)
         {
            _loc1_.target.removeEventListener(Event.ADDED_TO_STAGE,this.stageListener);
         }
      }
      
      private function fadeIn(param1:Event) : void
      {
         alpha += this.chunk;
         if(alpha >= 1)
         {
            alpha = 1;
            removeEventListener(Event.ENTER_FRAME,this.fadeIn);
         }
      }
      
      private function fadeOut(param1:Event) : void
      {
         alpha -= this.chunk;
         if(alpha <= 0)
         {
            alpha = 0;
            visible = false;
            removeEventListener(Event.ENTER_FRAME,this.fadeOut);
         }
      }
   }
}

