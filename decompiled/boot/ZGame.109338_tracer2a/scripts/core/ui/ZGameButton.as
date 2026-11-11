package core.ui
{
   import core.ZGlobal;
   import core.gameobjects.SoundItem;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.*;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class ZGameButton
   {
      
      public static var UPSTATE:String = "up";
      
      public static var OVERSTATE:String = "over";
      
      public static var DOWNSTATE:String = "down";
      
      public static var HITSTATE:String = "hit";
      
      private static var UPFRAME:int = 1;
      
      private static var OVERFRAME:int = 2;
      
      private static var DOWNFRAME:int = 3;
      
      private static var HITFRAME:int = 3;
      
      private static var DISABLEDFRAME:int = 5;
      
      private var m_overStateScale:Number;
      
      private var m_userData:String = "";
      
      private var m_userDataObj:Object = null;
      
      protected var m_target:MovieClip;
      
      private var m_callback:Function = null;
      
      private var m_onMouseOutCallback:Function = null;
      
      private var m_onMouseOverCallback:Function = null;
      
      public var m_overlay:MovieClip = new MovieClip();
      
      private var m_state:String = "up";
      
      private var m_lastHandledFrame:int = -1;
      
      private var originalTransform:Matrix;
      
      private var scaledTransform:Matrix;
      
      private var m_buttonSound:SoundItem = null;
      
      private var m_disabledWithTooltip:Boolean = false;
      
      private var m_disabledEatInput:Boolean = false;
      
      public function ZGameButton(param1:MovieClip, param2:Function = null, param3:Number = 1.1, param4:Boolean = false, param5:Function = null, param6:Function = null)
      {
         super();
         this.m_overStateScale = 1;
         this.m_target = param1;
         this.m_onMouseOutCallback = param5;
         this.m_onMouseOverCallback = param6;
         if(this.m_target == null)
         {
            return;
         }
         if(this.m_target.generic_tf == null)
         {
            throw new Error("Error, ZGameButton got a movie clip that\'s missing a \'generic_tf\' TextField!");
         }
         this.m_target.generic_tf.mouseEnabled = false;
         if(param4)
         {
            this.m_target.addChild(this.m_overlay);
         }
         else
         {
            this.m_target.parent.addChild(this.m_overlay);
         }
         this.m_target.buttonMode = true;
         this.m_target.useHandCursor = true;
         this.gotoFrame(this.getUpFrame());
         this.m_target.addEventListener(Event.RENDER,this.onFrameRender,false,0,true);
         var _loc7_:Rectangle = this.m_target.getBounds(this.m_target.parent);
         this.m_overlay.graphics.beginFill(255,0);
         this.m_overlay.graphics.drawRect(0,0,_loc7_.width,_loc7_.height);
         this.m_overlay.graphics.endFill();
         if(param4)
         {
            this.m_overlay.x = 0;
            this.m_overlay.y = 0;
         }
         else
         {
            this.m_overlay.x = _loc7_.x;
            this.m_overlay.y = _loc7_.y;
         }
         this.m_overlay.buttonMode = true;
         this.m_overlay.buttonPointer = this;
         this.m_overlay.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown,false,0,true);
         this.m_overlay.addEventListener(MouseEvent.MOUSE_OUT,this.onOut,false,0,true);
         this.m_overlay.addEventListener(MouseEvent.MOUSE_OVER,this.onOver,false,0,true);
         this.m_overlay.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         if(param2 != null)
         {
            this.m_callback = param2;
         }
         this.originalTransform = this.m_target.generic_tf.transform.matrix.clone();
         this.scaledTransform = this.calcScaledTransform();
      }
      
      public function set text(param1:String) : void
      {
         if(this.m_target == null)
         {
            return;
         }
         TextFieldUtil.processTextField(this.m_target.generic_tf,param1);
         this.updateTextScale();
      }
      
      public function set textColor(param1:Object) : void
      {
         var _loc2_:TextFormat = this.m_target.generic_tf.getTextFormat();
         _loc2_.color = param1;
         this.m_target.generic_tf.setTextFormat(_loc2_);
      }
      
      public function get textColor() : Object
      {
         return (this.m_target.generic_tf.getTextFormat() as TextFormat).color;
      }
      
      public function compactText(param1:String, param2:Object) : void
      {
         TextFieldUtil.compactTextField(this.m_target.generic_tf,param1,param2);
         this.updateTextScale();
      }
      
      public function set sounds(param1:String) : void
      {
         this.m_buttonSound = ZGlobal.gameSettings.getButtonSoundByName(param1,SoundItem) as SoundItem;
      }
      
      public function set upFrame(param1:int) : void
      {
         UPFRAME = param1;
         this.gotoFrame(this.getUpFrame());
      }
      
      public function dispose() : void
      {
         if(this.m_target != null)
         {
            this.m_target.generic_tf.transform.matrix = this.originalTransform;
            this.m_target.removeEventListener(Event.RENDER,this.onFrameRender);
            this.m_target = null;
         }
         this.removeTooltip();
         if(this.m_overlay != null)
         {
            this.m_overlay.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
            this.m_overlay.removeEventListener(MouseEvent.MOUSE_OUT,this.onOut);
            this.m_overlay.removeEventListener(MouseEvent.MOUSE_OVER,this.onOver);
            this.m_overlay.removeEventListener(MouseEvent.CLICK,this.onClick);
            if(this.m_overlay.parent != null)
            {
               this.m_overlay.parent.removeChild(this.m_overlay);
            }
            this.m_overlay = null;
         }
         this.m_buttonSound = null;
         this.m_callback = null;
      }
      
      public function set buttonValue(param1:String) : void
      {
         this.m_overlay.buttonValue = param1;
         this.m_userData = param1;
      }
      
      public function get buttonValue() : String
      {
         return this.m_userData;
      }
      
      public function set buttonObject(param1:Object) : void
      {
         this.m_overlay.buttonObject = param1;
         this.m_userDataObj = param1;
      }
      
      public function get buttonObject() : Object
      {
         return this.m_userDataObj;
      }
      
      public function get hit() : MovieClip
      {
         return this.m_overlay;
      }
      
      public function enable() : void
      {
         if(this.m_disabledWithTooltip)
         {
            this.m_disabledWithTooltip = false;
            this.m_target.buttonMode = true;
            this.m_target.useHandCursor = true;
            this.removeTooltip();
         }
         this.m_disabledEatInput = false;
         this.m_overlay.mouseEnabled = true;
         this.m_target.filters = null;
         this.m_target.gotoAndStop(UPFRAME);
      }
      
      public function disable(param1:Boolean = false) : void
      {
         this.m_disabledEatInput = param1;
         if(!this.m_disabledEatInput)
         {
            this.m_overlay.mouseEnabled = false;
         }
         if(this.m_target.totalFrames >= DISABLEDFRAME)
         {
            this.m_target.gotoAndStop(DISABLEDFRAME);
         }
      }
      
      public function get enabled() : Boolean
      {
         return !this.m_disabledWithTooltip && !this.m_disabledEatInput && this.m_overlay.mouseEnabled && this.m_overlay.visible && this.m_target.visible;
      }
      
      public function disable_visual(param1:Boolean = false) : void
      {
         this.disable(param1);
         this.m_target.filters = [new ColorMatrixFilter(ZGameUtils.GRAYSCALE_ARRAY)];
      }
      
      public function disableWithTooltip(param1:String) : void
      {
         this.m_disabledWithTooltip = true;
         Tooltip.subscribe(this.m_overlay,param1,{},false);
         if(this.m_target.totalFrames >= DISABLEDFRAME)
         {
            this.m_target.gotoAndStop(DISABLEDFRAME);
         }
      }
      
      public function addTooltip(param1:String, param2:Object = null) : void
      {
         if(!param2)
         {
            param2 = {};
         }
         Tooltip.subscribe(this.m_overlay,param1,param2,false);
      }
      
      public function removeTooltip() : void
      {
         Tooltip.unsubscribe(this.m_overlay);
      }
      
      public function show() : void
      {
         this.m_target.visible = true;
         this.m_overlay.visible = true;
      }
      
      public function hide() : void
      {
         this.m_target.visible = false;
         this.m_overlay.visible = false;
      }
      
      public function set callback(param1:Function) : void
      {
         this.m_callback = param1;
      }
      
      public function get callback() : Function
      {
         return this.m_callback;
      }
      
      public function set pulse(param1:Boolean) : void
      {
      }
      
      private function calcScaledTransform() : Matrix
      {
         var _loc1_:Number = this.m_target.generic_tf.x + this.m_target.generic_tf.width / 2;
         var _loc2_:Number = this.m_target.generic_tf.y + this.m_target.generic_tf.height / 2;
         var _loc3_:Matrix = this.originalTransform.clone();
         _loc3_.translate(-_loc1_,-_loc2_);
         _loc3_.scale(this.m_overStateScale,this.m_overStateScale);
         _loc3_.translate(_loc1_,_loc2_);
         return _loc3_;
      }
      
      protected function get canTransformText() : Boolean
      {
         return true;
      }
      
      private function updateTextScale() : void
      {
         if(this.canTransformText)
         {
            if(this.showScaledText())
            {
               this.m_target.generic_tf.transform.matrix = this.scaledTransform;
            }
            else
            {
               this.m_target.generic_tf.transform.matrix = this.originalTransform;
            }
         }
      }
      
      private function onFrameRender(param1:Event) : void
      {
         if(this.m_lastHandledFrame != param1.currentTarget.currentFrame)
         {
            this.updateTextScale();
            this.m_lastHandledFrame = param1.currentTarget.currentFrame;
         }
      }
      
      private function showScaledText() : Boolean
      {
         switch(this.m_target.currentFrame)
         {
            case this.overFrame:
            case this.downFrame:
            case this.hitFrame:
               return true;
            default:
               return false;
         }
      }
      
      public function gotoFrame(param1:int) : void
      {
         this.m_target.gotoAndStop(param1);
      }
      
      private function onOut(param1:MouseEvent) : void
      {
         if(this.m_disabledWithTooltip || this.m_disabledEatInput)
         {
            return;
         }
         this.m_state = UPSTATE;
         Zlab.mainStage.invalidate();
         this.gotoFrame(this.getUpFrame());
         if(this.m_onMouseOutCallback != null)
         {
            this.m_onMouseOutCallback(param1);
         }
      }
      
      protected function getUpFrame() : int
      {
         return UPFRAME;
      }
      
      protected function get overFrame() : int
      {
         return OVERFRAME;
      }
      
      protected function get downFrame() : int
      {
         return DOWNFRAME;
      }
      
      protected function get hitFrame() : int
      {
         return HITFRAME;
      }
      
      protected function onOver(param1:MouseEvent) : void
      {
         if(this.m_disabledWithTooltip || this.m_disabledEatInput)
         {
            return;
         }
         this.m_state = OVERSTATE;
         this.gotoFrame(this.overFrame);
         this.playSound(ButtonSound.ON_ROLLOVER);
         Zlab.mainStage.invalidate();
         if(this.m_onMouseOutCallback != null)
         {
            this.m_onMouseOverCallback(param1);
         }
      }
      
      private function onDown(param1:MouseEvent) : void
      {
         if(this.m_disabledWithTooltip || this.m_disabledEatInput)
         {
            return;
         }
         this.m_state = DOWNSTATE;
         Zlab.mainStage.invalidate();
         this.gotoFrame(this.downFrame);
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(this.m_disabledWithTooltip)
         {
            return;
         }
         param1.stopImmediatePropagation();
         param1.stopPropagation();
         if(this.m_disabledEatInput)
         {
            return;
         }
         this.m_state = HITSTATE;
         Zlab.mainStage.invalidate();
         this.gotoFrame(this.hitFrame);
         this.playSound(ButtonSound.ON_CLICK);
         this.clickAction(param1);
      }
      
      protected function clickAction(param1:MouseEvent) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(param1);
         }
      }
      
      private function playSound(param1:int) : void
      {
         if(null != this.m_buttonSound)
         {
            ButtonSound.getButtonSound(this.m_buttonSound.name).play(param1);
         }
      }
   }
}

