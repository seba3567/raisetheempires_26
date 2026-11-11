package core.ui.menuitem
{
   import com.greensock.TweenLite;
   import core.ZGlobal;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.PlayerFeedbackManager;
   import dispatchers.UIDispatcher;
   import displays.ImageLoaderFactory;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.SoundEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.debug.Logger;
   import zlabs.events.WorldEvent;
   
   public class FriendsBarMessageTabUIItem
   {
      
      private static const MAX_QUEUE_LENGTH:int = 6;
      
      private static const TWEEN_TIME:Number = 0.5;
      
      private static var AUTO_DISMISS_TIME:int = 0;
      
      private static const TAB_MIN_WIDTH:int = 160;
      
      private static const TAB_MAX_WIDTH:int = 550;
      
      public static const NEW_MESSAGE:String = "newMessage";
      
      public static const FINISHED:String = "finished";
      
      public static const GET_NUM_VISIBLE:String = "getNumVisible";
      
      private var m_clip:MovieClip = null;
      
      private var m_toaster:MovieClip = null;
      
      private var m_maxWidth:Number;
      
      private var m_toasterMessageQueue:Vector.<ToasterMessage> = new Vector.<ToasterMessage>();
      
      private var m_currentMessage:ToasterMessage = null;
      
      public var m_combatToasterEnabled:Boolean = false;
      
      public function FriendsBarMessageTabUIItem(param1:MovieClip)
      {
         super();
         this.m_clip = param1;
         this.m_toaster = this.m_clip.tab_mc;
         this.m_toaster.messageTabR_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onClose,false,0,true);
         this.m_toaster.message_tf.addEventListener(MouseEvent.CLICK,this.onMessageClick,false,0,true);
         PlayerFeedbackManager.instance.addEventListener(PlayerFeedbackManager.DISPLAY_FEEDBACK,this.onDisplayFeedback);
         UIDispatcher.instance.addEventListener(GET_NUM_VISIBLE,this.onGetNumVisible,false,0,true);
         this.hide(true);
      }
      
      public function set combatToasterEnabled(param1:Boolean) : void
      {
         this.m_combatToasterEnabled = param1;
      }
      
      public function get combatToasterEnabled() : Boolean
      {
         return this.m_combatToasterEnabled;
      }
      
      public function setMaxWidth(param1:Number) : void
      {
         param1 = Math.min(TAB_MAX_WIDTH,Math.max(TAB_MIN_WIDTH,param1));
         this.m_maxWidth = param1;
         param1 -= this.m_toaster.messageTabL_mc.width + this.m_toaster.messageTabR_mc.width;
         this.m_toaster.messageTabC_mc.width = param1;
         this.m_toaster.messageTabR_mc.x = this.m_toaster.messageTabC_mc.x + this.m_toaster.messageTabC_mc.width - 0.5;
         this.m_toaster.message_tf.width = this.m_maxWidth - 40;
      }
      
      public function setDisplayString(param1:String) : void
      {
         TextFieldUtil.processTextField(this.m_toaster.message_tf,param1);
      }
      
      public function setToasterIcon(param1:String) : void
      {
         if(this.m_toaster.hasOwnProperty("feature_icon"))
         {
            ImageLoaderFactory.CreateImageLoader(param1,this.m_toaster.feature_icon);
            this.m_toaster.message_tf.width = this.m_maxWidth - 110;
            this.m_toaster.feature_icon.x = this.m_maxWidth - 70;
         }
         else
         {
            this.m_toaster.message_tf.width = this.m_maxWidth - 40;
         }
      }
      
      private function onGetNumVisible(param1:WorldEvent) : void
      {
         if(this.m_currentMessage)
         {
            ++param1.eventData.numVisible;
         }
      }
      
      private function show(param1:Boolean = false) : void
      {
         var _loc2_:Number = this.m_toaster.message_tf.numLines <= 1 ? Number(this.m_clip.anchor1_mc.y) : Number(this.m_clip.anchor2_mc.y);
         if(param1)
         {
            this.m_toaster.y = _loc2_;
         }
         else
         {
            TweenLite.killTweensOf(this.m_toaster);
            TweenLite.to(this.m_toaster,TWEEN_TIME,{"y":_loc2_});
            if(this.m_combatToasterEnabled || !ContextualBarUIItem(ContextualBarUIItem.getContextualBar()).getCombatBar().active)
            {
               SoundEvent.getSoundEvent("ShowTab").play();
            }
         }
      }
      
      private function hide(param1:Boolean = false) : void
      {
         if(param1)
         {
            this.m_toaster.y = this.m_clip.anchor0_mc.y;
            this.completeHide();
         }
         else if(this.m_currentMessage)
         {
            this.m_toaster.message_tf.removeEventListener(MouseEvent.CLICK,this.onMessageClick);
            TweenLite.killTweensOf(this.m_toaster);
            TweenLite.to(this.m_toaster,TWEEN_TIME,{
               "y":this.m_clip.anchor0_mc.y,
               "onComplete":this.completeHide
            });
            if(this.m_combatToasterEnabled || !ContextualBarUIItem(ContextualBarUIItem.getContextualBar()).getCombatBar().active)
            {
            }
         }
      }
      
      private function completeHide() : void
      {
         this.m_toaster.message_tf.addEventListener(MouseEvent.CLICK,this.onMessageClick,false,0,true);
         this.m_currentMessage = null;
         this.tryDisplayFromQueue();
         if(!this.m_currentMessage)
         {
            UIDispatcher.instance.dispatchEvent(new Event(FINISHED));
         }
      }
      
      private function get autoDismissTimeMilliseconds() : int
      {
         if(AUTO_DISMISS_TIME == 0)
         {
            AUTO_DISMISS_TIME = ZGlobal.gameSettings.getSeconds("friendBarMessageTimeout",6.5) * 1000;
         }
         return AUTO_DISMISS_TIME;
      }
      
      private function onDisplayFeedback(param1:WorldEvent) : void
      {
         var _loc2_:ToasterMessage = new ToasterMessage();
         _loc2_.text = param1.eventData.message as String;
         _loc2_.targetId = param1.eventData.targetId as String;
         _loc2_.doesQueue = param1.eventData.doesQueue as Boolean;
         _loc2_.imgURL = param1.eventData.imgURL as String;
         if(_loc2_.targetId)
         {
            _loc2_.text = _loc2_.text + " " + ZGameUtils.ZlocT("Main","FeedbackGiftSendString");
         }
         if(_loc2_.doesQueue)
         {
            this.addToQueue(_loc2_);
            this.tryDisplayFromQueue();
         }
         else if(this.canDisplay())
         {
            this.doDisplay(_loc2_);
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         Zlab.processManager.removeScheduledObject(this);
         this.hide();
      }
      
      private function onMessageClick(param1:MouseEvent) : void
      {
         ViralsManager.instance.giftRare(this.m_currentMessage.targetId);
      }
      
      private function addToQueue(param1:ToasterMessage) : void
      {
         var _loc2_:ToasterMessage = null;
         if(this.m_toasterMessageQueue.length > 0 && this.m_toasterMessageQueue[this.m_toasterMessageQueue.length - 1].text == param1.text)
         {
            return;
         }
         this.m_toasterMessageQueue.push(param1);
         if(this.m_toasterMessageQueue.length > MAX_QUEUE_LENGTH)
         {
            _loc2_ = this.m_toasterMessageQueue.shift();
            Logger.debug(this,"addToQueue","removing queued message: " + _loc2_.text);
         }
      }
      
      private function canDisplay() : Boolean
      {
         return this.m_currentMessage == null;
      }
      
      private function tryDisplayFromQueue() : void
      {
         if(this.canDisplay() && this.m_toasterMessageQueue.length > 0)
         {
            this.doDisplay(this.m_toasterMessageQueue.shift());
         }
      }
      
      private function doDisplay(param1:ToasterMessage) : void
      {
         this.m_currentMessage = param1;
         this.setDisplayString(this.m_currentMessage.text);
         if(this.m_currentMessage.imgURL != null && this.m_currentMessage.imgURL != "")
         {
            this.setToasterIcon(this.m_currentMessage.imgURL);
         }
         this.show();
         Zlab.processManager.removeScheduledObject(this);
         Zlab.processManager.schedule(this.autoDismissTimeMilliseconds,this,this.hide);
         UIDispatcher.instance.dispatchEvent(new Event(NEW_MESSAGE));
      }
   }
}

