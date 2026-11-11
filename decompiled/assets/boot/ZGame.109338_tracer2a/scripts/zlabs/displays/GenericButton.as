package zlabs.displays
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.*;
   import zlabs.Zlab;
   
   public class GenericButton
   {
      
      public static var UPSTATE:String = "up";
      
      public static var OVERSTATE:String = "over";
      
      public static var DOWNSTATE:String = "down";
      
      public static var HITSTATE:String = "hit";
      
      private var m_overStateScale:Number = 1.14;
      
      private var m_currentScaling:Number = 1;
      
      private var m_buttonValue:String = "";
      
      private var m_target:MovieClip;
      
      private var m_text:String;
      
      private var m_disabled:Boolean = false;
      
      private var m_callback:Function = null;
      
      public var m_overlay:MovieClip = new MovieClip();
      
      private var m_tfOver:TextFormat;
      
      private var m_tfNormal:TextFormat;
      
      private var m_state:String = "up";
      
      private var m_enableHitState:Boolean = false;
      
      private var m_hitFrameNumber:int = 3;
      
      private var m_curFrame:int = 1;
      
      private var m_enterFrameOn:Boolean = false;
      
      private var normalTransform:Matrix;
      
      private var scaledTransform:Matrix;
      
      private var targetTransform:Matrix;
      
      public function GenericButton(param1:MovieClip, param2:Function = null, param3:String = "", param4:String = "")
      {
         var _loc7_:MovieClip = null;
         super();
         this.m_tfOver = new TextFormat();
         this.m_tfOver.size = 15;
         this.m_tfNormal = new TextFormat();
         this.m_tfNormal.size = 14;
         this.m_target = param1;
         var _loc5_:Rectangle = this.m_target.getBounds(this.m_target.parent);
         this.m_overlay.graphics.beginFill(255,0);
         this.m_overlay.graphics.drawRect(0,0,_loc5_.width,_loc5_.height);
         this.m_overlay.graphics.endFill();
         var _loc6_:MovieClip = this.m_target.parent as MovieClip;
         if(param4 != "")
         {
            _loc7_ = _loc6_.getChildByName(param4) as MovieClip;
            if(_loc7_ != null)
            {
               _loc6_.removeChild(_loc7_);
            }
         }
         else
         {
            param4 = "gb_Overlay";
         }
         this.m_target.parent.addChild(this.m_overlay);
         this.m_overlay.x = _loc5_.x;
         this.m_overlay.y = _loc5_.y;
         this.m_overlay.buttonMode = true;
         this.m_overlay.name = param4;
         this.m_overlay.buttonPointer = this;
         param1.buttonMode = true;
         param1.useHandCursor = true;
         param1.gotoAndStop(1);
         this.m_overlay.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown,false,0,true);
         this.m_overlay.addEventListener(MouseEvent.MOUSE_OUT,this.onOut,false,0,true);
         this.m_overlay.addEventListener(MouseEvent.MOUSE_OVER,this.onOver,false,0,true);
         if(param2 != null)
         {
            this.m_callback = param2;
            this.m_overlay.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         }
         param1.addFrameScript(0,this.frameScriptTextUpdate);
         param1.addFrameScript(1,this.frameScriptTextUpdate);
         param1.addFrameScript(2,this.frameScriptTextUpdate);
         param1.addFrameScript(3,this.frameScriptTextUpdate);
         this.m_text = "";
         if(Boolean(this.m_target.generic_tf) && Boolean(this.m_target.generic_tf.text))
         {
            this.m_text = this.m_target.generic_tf.text;
            this.normalTransform = this.m_target.generic_tf.transform.matrix.clone();
            this.calcScaledTransform();
            this.targetTransform = this.normalTransform;
         }
         this.buttonValue = param3;
      }
      
      private function calcScaledTransform() : void
      {
         var _loc1_:Number = this.m_target.generic_tf.x + this.m_target.generic_tf.width / 2;
         var _loc2_:Number = this.m_target.generic_tf.y + this.m_target.generic_tf.height / 2;
         this.scaledTransform = this.normalTransform.clone();
         this.scaledTransform.translate(-_loc1_,-_loc2_);
         this.scaledTransform.scale(this.m_overStateScale,this.m_overStateScale);
         this.scaledTransform.translate(_loc1_,_loc2_);
      }
      
      private function onOver(param1:MouseEvent) : void
      {
         if(!this.disabled)
         {
            this.m_target.addFrameScript(1,this.frameScriptTextUpdate);
            this.m_enterFrameOn = false;
            if(!this.m_enableHitState || this.m_enableHitState && this.m_state != HITSTATE)
            {
               this.targetTransform = this.scaledTransform;
               this.m_currentScaling = this.m_overStateScale;
               this.m_state = OVERSTATE;
               this.m_target.gotoAndStop(this.m_target.totalFrames);
               this.m_target.gotoAndStop(2);
               Zlab.mainStage.invalidate();
               this.m_target.addEventListener(Event.RENDER,this.updateText,false,0,true);
            }
         }
      }
      
      private function onDown(param1:MouseEvent) : void
      {
         this.m_target.addFrameScript(2,this.frameScriptTextUpdate);
         this.m_enterFrameOn = false;
         this.targetTransform = this.normalTransform;
         if(!this.m_enableHitState || this.m_enableHitState && this.m_state != HITSTATE)
         {
            this.m_state = DOWNSTATE;
            Zlab.mainStage.invalidate();
            this.m_target.addEventListener(Event.RENDER,this.updateText,false,0,true);
            this.m_target.gotoAndStop(this.m_target.totalFrames);
            this.m_target.gotoAndStop(3);
         }
      }
      
      public function onOut(param1:MouseEvent) : void
      {
         this.targetTransform = this.normalTransform;
         this.m_target.addFrameScript(0,this.frameScriptTextUpdate);
         this.m_enterFrameOn = false;
         if(!this.m_enableHitState || this.m_enableHitState && this.m_state != HITSTATE)
         {
            this.m_state = UPSTATE;
            Zlab.mainStage.invalidate();
            this.m_target.addEventListener(Event.RENDER,this.updateText,false,0,true);
            this.m_target.gotoAndStop(this.m_target.totalFrames);
            this.m_target.gotoAndStop(1);
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(!this.disabled)
         {
            this.m_target.addFrameScript(this.m_hitFrameNumber - 1,this.frameScriptTextUpdate);
            this.m_enterFrameOn = false;
            this.targetTransform = this.normalTransform;
            this.m_state = HITSTATE;
            Zlab.mainStage.invalidate();
            this.m_target.addEventListener(Event.RENDER,this.updateText,false,0,true);
            this.m_target.gotoAndStop(this.m_target.totalFrames);
            this.m_target.gotoAndStop(this.m_hitFrameNumber);
            if(this.m_callback != null)
            {
               this.m_callback(param1);
            }
         }
      }
      
      public function set name(param1:String) : void
      {
         this.m_overlay.name = param1;
      }
      
      public function get name() : String
      {
         return this.m_overlay.name;
      }
      
      public function set text(param1:String) : void
      {
         this.m_curFrame = this.m_target.currentFrame;
         this.m_target.gotoAndStop(this.m_target.totalFrames);
         this.m_target.gotoAndStop(this.m_curFrame);
         if(this.m_target.generic_tf)
         {
            this.m_target.generic_tf.text = param1;
            this.m_text = param1;
         }
         else
         {
            this.m_target.addFrameScript(this.m_curFrame,this.frameScriptTextUpdate);
         }
      }
      
      public function set tfOver(param1:TextFormat) : void
      {
         this.m_tfOver = param1;
      }
      
      public function set tfNormal(param1:TextFormat) : void
      {
         this.m_tfNormal = param1;
      }
      
      public function set state(param1:String) : void
      {
         switch(param1)
         {
            case UPSTATE:
               this.m_target.gotoAndStop(1);
               this.m_state = UPSTATE;
               break;
            case OVERSTATE:
               this.m_target.gotoAndStop(2);
               this.m_state = OVERSTATE;
               break;
            case DOWNSTATE:
               this.m_target.gotoAndStop(3);
               this.m_state = DOWNSTATE;
               break;
            case HITSTATE:
               this.m_target.gotoAndStop(this.m_hitFrameNumber);
               this.m_state = HITSTATE;
         }
      }
      
      public function get state() : String
      {
         return this.m_state;
      }
      
      public function enableHitState(param1:Boolean) : void
      {
         this.m_enableHitState = param1;
      }
      
      public function setHitFrameNumber(param1:int) : void
      {
         if(param1 > 0 && param1 <= this.m_target.totalFrames)
         {
            this.m_hitFrameNumber = param1;
         }
      }
      
      public function turnOff() : void
      {
         this.m_target.buttonMode = false;
         this.m_target.useHandCursor = false;
         this.m_target.visible = false;
         this.m_overlay.buttonMode = false;
         this.m_overlay.visible = false;
         this.m_overlay.removeEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
         this.m_overlay.removeEventListener(MouseEvent.MOUSE_OUT,this.onOut);
         this.m_overlay.removeEventListener(MouseEvent.MOUSE_OVER,this.onOver);
         if(this.m_callback != null)
         {
            this.m_overlay.removeEventListener(MouseEvent.CLICK,this.onClick);
         }
      }
      
      public function turnOn() : void
      {
         this.turnOff();
         this.m_target.visible = true;
         this.m_target.buttonMode = true;
         this.m_target.useHandCursor = true;
         this.m_overlay.buttonMode = true;
         this.m_overlay.visible = true;
         this.m_overlay.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown,false,0,true);
         this.m_overlay.addEventListener(MouseEvent.MOUSE_OUT,this.onOut,false,0,true);
         this.m_overlay.addEventListener(MouseEvent.MOUSE_OVER,this.onOver,false,0,true);
         if(this.m_callback != null)
         {
            this.m_overlay.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         }
      }
      
      public function toggleDisable(param1:Boolean) : void
      {
         this.disabled = !param1;
      }
      
      private function frameScriptTextUpdate() : void
      {
         if(Boolean(this.m_target.generic_tf) && this.m_text != "")
         {
            this.m_target.generic_tf.setTextFormat(this.m_tfOver);
            this.m_target.generic_tf.text = this.m_text;
            this.m_enterFrameOn = false;
            this.m_target.generic_tf.transform.matrix = this.targetTransform;
         }
         else if(!this.m_enterFrameOn)
         {
            this.m_target.addEventListener(Event.ENTER_FRAME,this.updateText,false,0,true);
            this.m_enterFrameOn = true;
         }
      }
      
      private function updateText(param1:Event) : void
      {
         if(Boolean(this.m_target.generic_tf) && this.m_text != "")
         {
            this.m_target.generic_tf.setTextFormat(this.m_tfOver);
            this.m_target.generic_tf.text = this.m_text;
            this.calcScaledTransform();
            this.m_target.removeEventListener(Event.ENTER_FRAME,this.updateText);
         }
      }
      
      public function getButton() : MovieClip
      {
         return this.m_target;
      }
      
      public function set disabled(param1:Boolean) : void
      {
         this.m_disabled = param1;
         if(param1)
         {
            this.m_overlay.buttonMode = false;
            this.m_overlay.visible = false;
         }
         else
         {
            this.m_overlay.buttonMode = true;
            this.m_overlay.visible = true;
         }
      }
      
      public function get disabled() : Boolean
      {
         return this.m_disabled;
      }
      
      public function set buttonValue(param1:String) : void
      {
         this.m_overlay.buttonValue = param1;
         this.m_buttonValue = param1;
      }
      
      public function get buttonValue() : String
      {
         return this.m_buttonValue;
      }
   }
}

