package displays.popups
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import sound.SoundEvent;
   import utils.TextFieldUtil;
   
   public class MOTDPopupPlopper extends EventDispatcher
   {
      
      public static const EVENT_OPENNED:String = "OPENNED";
      
      public static const EVENT_CLOSED:String = "CLOSED";
      
      private static const ANIM_STATE_OPENNING:String = "openning";
      
      private static const ANIM_STATE_OPENNED:String = "openned";
      
      private static const ANIM_STATE_CLOSING:String = "closing";
      
      private static const ANIM_STATE_CLOSED:String = "closed";
      
      private var m_clip:MovieClip;
      
      private var m_messageQueue:Array;
      
      private var m_timer:Timer;
      
      private var m_curMsgData:Object;
      
      private var m_animationState:String = "closed";
      
      private var m_overwritePending:Boolean;
      
      private var m_pendingNextFrameData:Object;
      
      private var m_pendingNextFrame:Array;
      
      private var m_pendingNextFrameTimer:Timer;
      
      private var m_pendingNextFrameTimerImmediateMode:Boolean;
      
      public function MOTDPopupPlopper(param1:MovieClip)
      {
         super();
         this.m_clip = param1;
         this.m_clip.addEventListener(EVENT_OPENNED,this.animOpen);
         this.m_clip.addEventListener(EVENT_CLOSED,this.animClose);
         this.m_clip.gotoAndStop(1);
         this.m_messageQueue = [];
      }
      
      public function addPendingMessage(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false, param5:int = 3000) : void
      {
         this.initNextFrameTimer(param3);
         if(param4)
         {
            this.m_messageQueue = [];
            this.m_pendingNextFrame = [];
         }
         this.m_pendingNextFrameTimerImmediateMode = param3;
         this.m_pendingNextFrame.push({
            "msg":param1,
            "persist":param2,
            "time":param5
         });
      }
      
      private function initNextFrameTimer(param1:Boolean) : void
      {
         if(!this.m_pendingNextFrameTimer)
         {
            this.m_pendingNextFrameTimerImmediateMode = param1;
            this.m_pendingNextFrame = [];
            this.m_pendingNextFrameTimer = new Timer(100);
            this.m_pendingNextFrameTimer.addEventListener(TimerEvent.TIMER,this.addNextFramePending);
            this.m_pendingNextFrameTimer.start();
         }
      }
      
      private function addNextFramePending(param1:TimerEvent) : void
      {
         this.m_pendingNextFrameTimer.removeEventListener(TimerEvent.TIMER,this.addNextFramePending);
         this.m_pendingNextFrameTimer = null;
         this.m_messageQueue = this.m_messageQueue.concat(this.m_pendingNextFrame);
         if(this.m_animationState == ANIM_STATE_CLOSED)
         {
            this.showMessage(this.m_messageQueue.shift());
         }
         else if(this.m_animationState == ANIM_STATE_OPENNED || this.m_animationState == ANIM_STATE_OPENNING)
         {
            if(this.m_pendingNextFrameTimerImmediateMode)
            {
               if(this.m_animationState == ANIM_STATE_OPENNED)
               {
                  this.disposeTimer();
                  this.closeCurrentMessage();
               }
               else if(this.m_animationState == ANIM_STATE_OPENNING)
               {
                  this.disposeTimer();
                  this.m_timer = new Timer(1000);
                  this.m_timer.addEventListener(TimerEvent.TIMER,this.timeUp);
               }
            }
            else if(this.m_curMsgData.persist)
            {
               this.m_curMsgData.persist = false;
               this.disposeTimer();
               this.m_timer = new Timer(1000);
               this.m_timer.addEventListener(TimerEvent.TIMER,this.timeUp);
               if(this.m_animationState == ANIM_STATE_OPENNED)
               {
                  this.m_timer.start();
               }
            }
         }
         this.m_pendingNextFrameTimerImmediateMode = false;
      }
      
      private function animOpen(param1:Event) : void
      {
         this.m_curMsgData.open = true;
         this.m_timer.start();
         this.m_animationState = ANIM_STATE_OPENNED;
      }
      
      private function animClose(param1:Event) : void
      {
      }
      
      private function showMessage(param1:Object) : void
      {
         var _loc2_:int = 3000;
         if(param1.time != null)
         {
            _loc2_ = int(param1.time);
         }
         this.m_animationState = ANIM_STATE_OPENNING;
         this.m_curMsgData = param1;
         this.m_timer = new Timer(_loc2_);
         if(param1.persist)
         {
            this.m_timer.addEventListener(TimerEvent.TIMER,this.timeUpPersist);
         }
         else
         {
            this.m_timer.addEventListener(TimerEvent.TIMER,this.timeUp);
         }
         TextFieldUtil.compactTextField(this.m_clip.panel_mc.message_tf,param1.msg);
         this.m_clip.gotoAndPlay("open");
         SoundEvent.getSoundEvent("ShowTab").play();
      }
      
      private function timeUpPersist(param1:Event) : void
      {
         this.m_timer.removeEventListener(TimerEvent.TIMER,this.timeUpPersist);
         this.m_timer.stop();
      }
      
      private function timeUp(param1:TimerEvent) : void
      {
         this.m_timer.removeEventListener(TimerEvent.TIMER,this.timeUp);
         this.closeCurrentMessage();
      }
      
      private function closeCurrentMessage() : void
      {
         this.m_animationState = ANIM_STATE_CLOSING;
         this.m_clip.gotoAndPlay("close");
         this.m_timer = new Timer(750);
         this.m_timer.start();
         this.m_timer.addEventListener(TimerEvent.TIMER,this.closeComplete);
      }
      
      private function closeComplete(param1:TimerEvent) : void
      {
         this.m_animationState = ANIM_STATE_CLOSED;
         this.m_timer.removeEventListener(TimerEvent.TIMER,this.closeComplete);
         this.m_timer = null;
         this.m_curMsgData = null;
         if(this.m_messageQueue.length > 0)
         {
            this.showMessage(this.m_messageQueue.shift());
         }
      }
      
      public function dispose() : void
      {
         this.m_clip.removeEventListener(EVENT_OPENNED,this.animOpen);
         this.m_clip.removeEventListener(EVENT_CLOSED,this.animClose);
         this.m_clip = null;
         this.disposeTimer();
         this.m_curMsgData = null;
         if(this.m_pendingNextFrameTimer)
         {
            this.m_pendingNextFrameTimer.removeEventListener(TimerEvent.TIMER,this.addNextFramePending);
            this.m_pendingNextFrameTimer = null;
         }
      }
      
      private function disposeTimer() : void
      {
         if(this.m_timer)
         {
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.timeUp);
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.timeUpPersist);
            this.m_timer.removeEventListener(TimerEvent.TIMER,this.closeComplete);
            this.m_timer = null;
         }
      }
   }
}

