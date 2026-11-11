package displays.popups
{
   import core.ZGlobal;
   import core.ui.ZGameButton;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.debug.Logger;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class GenericPopup extends ZGamePopUp
   {
      
      public static const WIDTH:int = 460;
      
      public static const HEIGHT:int = 285;
      
      public static const ACCEPTBTX:int = 61;
      
      public static const SHARE:int = 1;
      
      public static const ACCEPT:int = 1;
      
      public static const OK:int = 1;
      
      public static const YES:int = 1;
      
      public static const CANCEL:int = 0;
      
      public static const NO:int = 0;
      
      public static const ACCEPT2:int = 2;
      
      public static const TYPE_OK:int = 0;
      
      public static const TYPE_ACCEPTCANCEL:int = 1;
      
      public static const TYPE_YESNO:int = 2;
      
      public static const TYPE_MODAL:int = 3;
      
      public static const TYPE_SHARECANCEL:int = 4;
      
      public static const TYPE_CANCEL:int = 5;
      
      public static const TYPE_BONUS:int = 6;
      
      public static const TYPE_GORETURN:int = 7;
      
      public static const TYPE_REFRESH:int = 8;
      
      public static const TYPE_INVITE:int = 9;
      
      public static const TYPE_SELL:int = 10;
      
      public static const TYPE_SENDGIFTSCANCEL:int = 11;
      
      public static const TYPE_REPORTREFRESH:int = 12;
      
      public static const MOOD_DEFAULT:String = "_default";
      
      public static const MOOD_HAPPY:String = "_happy";
      
      public static const MOOD_SURPRISED:String = "_surprised";
      
      protected var m_message:String;
      
      protected var m_type:int;
      
      protected var m_closeCallback:Function;
      
      protected var m_accept:ZGameButton;
      
      protected var m_reject:ZGameButton;
      
      protected var m_acceptTextName:String = "Accept";
      
      protected var m_cancelTextName:String = "Cancel";
      
      private var m_setupComplete:Boolean = false;
      
      protected var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_userData:Object = null;
      
      protected var m_statsData:Array = null;
      
      protected var m_advisorMood:String = "_happy";
      
      public function GenericPopup(param1:String, param2:int = 0, param3:Function = null, param4:Array = null, param5:String = "assets/displays/dialogs/PU_GenericPopUp.swf")
      {
         super(ZGlobal.getAssetURL(param5));
         animation = null;
         this.m_type = param2;
         this.m_message = param1;
         this.m_statsData = param4;
         if(this.m_type == TYPE_OK)
         {
            this.m_acceptTextName = "OkButton";
         }
         else if(this.m_type == TYPE_YESNO)
         {
            this.m_acceptTextName = "Yes";
            this.m_cancelTextName = "No";
         }
         else if(this.m_type == TYPE_REPORTREFRESH)
         {
            this.m_acceptTextName = "ReportBug";
            this.m_cancelTextName = "RefreshButton";
         }
         else if(this.m_type == TYPE_ACCEPTCANCEL)
         {
            this.m_acceptTextName = "Accept";
            this.m_cancelTextName = "Cancel";
         }
         else if(this.m_type == TYPE_SHARECANCEL)
         {
            this.m_acceptTextName = "Share";
            this.m_cancelTextName = "Cancel";
         }
         else if(this.m_type == TYPE_GORETURN)
         {
            this.m_acceptTextName = "GoButton";
            this.m_cancelTextName = "ReturnButton";
         }
         else if(this.m_type == TYPE_REFRESH)
         {
            this.m_acceptTextName = "RefreshButton";
         }
         else if(this.m_type == TYPE_BONUS)
         {
            this.m_acceptTextName = "Collect";
         }
         else if(this.m_type == TYPE_INVITE)
         {
            this.m_acceptTextName = "InviteButton";
         }
         else if(this.m_type == TYPE_SELL)
         {
            this.m_acceptTextName = "SellButton";
            this.m_cancelTextName = "Skip";
         }
         else if(this.m_type == TYPE_SENDGIFTSCANCEL)
         {
            this.m_acceptTextName = "SendGifts";
         }
         if(param3 != null)
         {
            this.m_closeCallback = param3;
            addEventListener(GenericPopupEvent.SELECTED,param3,false,0,true);
         }
      }
      
      public function set userData(param1:Object) : void
      {
         this.m_userData = param1;
      }
      
      protected function get setupComplete() : Boolean
      {
         return this.m_setupComplete;
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         if(Boolean(param1) && !m_window)
         {
            m_window = param1.clip as MovieClip;
         }
         PopupManager.instance.notifyLoadComplete(this);
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      override public function onShow() : void
      {
         super.onShow();
         this.setUpScreen();
      }
      
      protected function hideAllDialogs() : void
      {
         m_window.popupBox_mc.welcomeBox_mc.visible = false;
         m_window.popupBox_mc.popupBox_tf.visible = false;
         m_window.popupBox_mc.panel.visible = false;
         m_window.popupBox_mc.generic01_mc.visible = false;
         m_window.popupBox_mc.generic02_mc.visible = false;
         m_window.popupBox_mc.generic03_mc.visible = false;
         m_window.popupBox_mc.generic04_mc.visible = false;
         m_window.popupBox_mc.genericBox.visible = false;
         m_window.popupBox_mc.genericBox.welcome_tf.visible = false;
         m_window.popupBox_mc.welcomeBox_mc.welcome_tf.visible = false;
         m_window.popupBox_mc.feed_mc.visible = false;
         m_window.popupBox_mc.feed2_mc.visible = false;
         m_window.popupBox_mc.visitBonus_mc.visible = false;
         m_window.popupBox_mc.energy_mc.visible = false;
         m_window.popupBox_mc.obtain_mc.visible = false;
         m_window.popupBox_mc.inviteIdle_mc.visible = false;
         m_window.popupBox_mc.welcomeBox_mc.exit_bt.visible = false;
         m_window.popupBox_mc.cash.visible = false;
      }
      
      protected function setUpLook() : void
      {
         this.hideAllDialogs();
         m_window.popupBox_mc.welcomeBox_mc.visible = true;
         m_window.popupBox_mc.popupBox_tf.visible = true;
         m_window.popupBox_mc.panel.visible = true;
         this.visualizeAdvisorMood();
      }
      
      protected function getOkButtonClip() : DisplayObject
      {
         return m_window.popupBox_mc.accept_bt;
      }
      
      protected function getCancelButtonClip() : DisplayObject
      {
         return m_window.popupBox_mc.cancel_bt;
      }
      
      protected function initButtons() : void
      {
         this.setupButtons(this.getOkButtonClip(),this.getCancelButtonClip());
      }
      
      protected function get messageTextField() : TextField
      {
         return m_window.popupBox_mc.popupBox_tf;
      }
      
      protected function get messageAnchor() : MovieClip
      {
         return m_window.popupBox_mc.popupBoxAnchor_mc;
      }
      
      public function get statsData() : Array
      {
         return this.m_statsData;
      }
      
      protected function setUpScreen() : void
      {
         var _loc1_:TextField = null;
         if(m_window != null)
         {
            if(!this.m_setupComplete)
            {
               this.setUpLook();
               if(this.m_message != null)
               {
                  _loc1_ = this.messageTextField;
                  TextFieldUtil.compactTextField(_loc1_,this.m_message,{
                     "minScale":0.6,
                     "fontSize":20
                  });
                  if(this.messageAnchor != null)
                  {
                     _loc1_.y = this.messageAnchor.y - _loc1_.textHeight * 0.5;
                  }
               }
               this.initButtons();
               m_window.x = 0;
               m_window.y = 0;
               addChild(m_window);
               this.contentWidth = WIDTH;
               this.contentHeight = HEIGHT;
               m_origOffsetX = m_window.x;
               m_origOffsetY = m_window.y;
               initDialog();
               this.m_setupComplete = true;
            }
            dispatchEvent(new Event(Event.COMPLETE));
         }
      }
      
      private function onFailedLoad(param1:SWFResource) : void
      {
         Logger.error(this,"onFailedLoad","Failed to load: " + param1.filename);
      }
      
      protected function setupButtons(param1:DisplayObject, param2:DisplayObject) : void
      {
         var _loc3_:MovieClip = param1 as MovieClip;
         var _loc4_:MovieClip = param2 as MovieClip;
         var _loc5_:SimpleButton = param1 as SimpleButton;
         var _loc6_:SimpleButton = param2 as SimpleButton;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         var _loc7_:Boolean = false;
         switch(this.m_type)
         {
            case TYPE_OK:
            case TYPE_BONUS:
               param1.visible = true;
               if(_loc3_)
               {
                  if(m_window.popupBox_mc.panel)
                  {
                     param1.x = (m_window.popupBox_mc.panel.width - param1.width) / 2;
                  }
                  else
                  {
                     param1.x = (m_window.width - param1.width) / 2;
                  }
               }
               break;
            case TYPE_CANCEL:
               param1.visible = false;
               _loc7_ = true;
               break;
            case TYPE_MODAL:
               param1.visible = false;
               break;
            case TYPE_REFRESH:
               param1.visible = true;
               break;
            case TYPE_YESNO:
               param1.x = ACCEPTBTX;
            default:
               param1.visible = true;
               _loc7_ = true;
         }
         if(Boolean(param1) && param1.visible)
         {
            if(_loc3_)
            {
               this.m_accept = new ZGameButton(_loc3_,this.onAccept);
               this.m_accept.compactText(ZGameUtils.ZlocT("Dialogs",this.m_acceptTextName),{
                  "maxLines":1,
                  "minScale":0.5,
                  "onFail":"return"
               });
               this.m_buttonSounds.addButton(this.m_accept.m_overlay,ButtonSound.DEFAULT);
            }
            else if(_loc5_)
            {
               param1.addEventListener(MouseEvent.CLICK,this.onAccept,false,0,true);
               this.m_buttonSounds.addButton(param1,ButtonSound.DEFAULT);
            }
         }
         if(param2)
         {
            param2.visible = _loc7_;
            if(_loc7_)
            {
               if(_loc4_)
               {
                  this.m_reject = new ZGameButton(_loc4_,this.onCancel);
                  this.m_reject.compactText(ZGameUtils.ZlocT("Dialogs",this.m_cancelTextName),{
                     "maxLines":1,
                     "minScale":0.5,
                     "onFail":"return"
                  });
                  this.m_buttonSounds.addButton(this.m_reject.m_overlay,ButtonSound.DEFAULT);
               }
               else if(_loc6_)
               {
                  param2.addEventListener(MouseEvent.CLICK,this.onCancel,false,0,true);
                  this.m_buttonSounds.addButton(param2,ButtonSound.DEFAULT);
               }
            }
         }
      }
      
      public function setAcceptTextName(param1:String) : void
      {
         this.m_acceptTextName = param1;
      }
      
      public function setCancelTextName(param1:String) : void
      {
         this.m_cancelTextName = param1;
      }
      
      protected function onAccept(param1:MouseEvent) : void
      {
         close();
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,YES,this.m_userData));
         if(this.m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
         }
      }
      
      protected function onCancel(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,NO,this.m_userData));
         if(this.m_closeCallback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_closeCallback);
         }
         close();
      }
      
      protected function removeButtonClickListeners(param1:Object, param2:Object) : void
      {
         param1.removeEventListener(MouseEvent.CLICK,this.onAccept);
         if(null != param2)
         {
            param2.removeEventListener(MouseEvent.CLICK,this.onCancel);
         }
      }
      
      protected function deinitButtons() : void
      {
         this.removeButtonClickListeners(this.getOkButtonClip(),this.getCancelButtonClip());
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         if(m_window)
         {
            this.deinitButtons();
         }
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         if(this.m_accept)
         {
            this.m_accept.dispose();
            this.m_accept = null;
         }
         if(this.m_reject)
         {
            this.m_reject.dispose();
            this.m_reject = null;
         }
      }
      
      public function closeWindow() : void
      {
         close();
      }
      
      public function setAdvisorMood(param1:String) : void
      {
         this.m_advisorMood = param1;
      }
      
      protected function visualizeAdvisorMood() : void
      {
         var _loc1_:MovieClip = this.advisorClip();
         if(_loc1_)
         {
            _loc1_.gotoAndPlay(this.m_advisorMood);
         }
      }
      
      protected function advisorClip() : MovieClip
      {
         return null;
      }
   }
}

