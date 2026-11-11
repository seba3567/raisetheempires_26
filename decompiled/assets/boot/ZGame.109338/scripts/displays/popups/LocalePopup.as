package displays.popups
{
   import core.ZGlobal;
   import core.ui.ZGameButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.zflex.ZCanvas;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.WindowManager;
   
   public class LocalePopup extends GallantPopup
   {
      
      private var m_newUserMsg1:String = null;
      
      private var m_newUserMsg2:String = null;
      
      private var m_existingUserMsg1:String = null;
      
      private var m_existingUserMsg2:String = null;
      
      private var m_numLanguages:int;
      
      private var m_closeBtn:ZGameButton = null;
      
      private var m_showMeBtn:ZGameButton = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_screenOverlay:ZCanvas;
      
      public function LocalePopup(param1:String, param2:String, param3:String, param4:String, param5:int = 1)
      {
         this.m_newUserMsg1 = param1;
         this.m_newUserMsg2 = param2;
         this.m_existingUserMsg1 = param3;
         this.m_existingUserMsg2 = param4;
         this.m_numLanguages = param5;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_NewLanguage.swf"));
      }
      
      override public function onShow() : void
      {
         super.onShow();
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      override protected function initializeScreen() : void
      {
         var _loc1_:String = null;
         m_origOffsetX = m_window.x;
         m_origOffsetY = m_window.y;
         super.initializeScreen();
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_closeBtn = new ZGameButton(m_window.cancel_btn,this.onCloseButton);
         this.m_closeBtn.text = ZGameUtils.ZlocT("Languages","ButtonClose");
         this.m_buttonSounds.addButton(this.m_closeBtn.m_overlay,ButtonSound.DEFAULT);
         this.m_showMeBtn = new ZGameButton(m_window.show_btn,this.onShowMeButton);
         this.m_showMeBtn.text = ZGameUtils.ZlocT("Languages","ButtonShowMe");
         this.m_buttonSounds.addButton(this.m_showMeBtn.m_overlay,ButtonSound.DEFAULT);
         m_window.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitButton,false,0,true);
         m_window.message_tf_2.visible = false;
         m_window.line.visible = false;
         if(Boolean(this.m_newUserMsg1) && this.m_newUserMsg1.length > 0)
         {
            TextFieldUtil.processTextField(m_window.title_tf,ZGameUtils.ZlocT("Languages","LocaleNewUserTitle"));
            if(Boolean(this.m_newUserMsg2) && this.m_newUserMsg2.length > 0)
            {
               TextFieldUtil.compactTextField(m_window.message_tf_1,this.m_newUserMsg2,{
                  "minScale":0.7,
                  "maxLines":3
               });
               TextFieldUtil.compactTextField(m_window.message_tf_2,this.m_newUserMsg1,{
                  "minScale":0.7,
                  "maxLines":3
               });
               m_window.message_tf_2.visible = true;
               m_window.line.visible = true;
            }
            else
            {
               TextFieldUtil.compactTextField(m_window.message_tf_1,this.m_newUserMsg1,{
                  "minScale":0.7,
                  "maxLines":3
               });
               m_window.message_tf_1.y += 40;
            }
         }
         else if(Boolean(this.m_existingUserMsg1) && this.m_existingUserMsg1.length > 0)
         {
            _loc1_ = this.m_numLanguages > 1 ? "LocaleExistingUserTitle_Many" : "LocaleExistingUserTitle_One";
            TextFieldUtil.processTextField(m_window.title_tf,ZGameUtils.ZlocT("Languages",_loc1_));
            if(Boolean(this.m_existingUserMsg2) && this.m_existingUserMsg2.length > 0)
            {
               TextFieldUtil.compactTextField(m_window.message_tf_1,this.m_existingUserMsg2,{
                  "minScale":0.7,
                  "maxLines":3
               });
               TextFieldUtil.compactTextField(m_window.message_tf_2,this.m_existingUserMsg1,{
                  "minScale":0.7,
                  "maxLines":3
               });
               m_window.message_tf_2.visible = true;
            }
            else
            {
               TextFieldUtil.compactTextField(m_window.message_tf_1,this.m_existingUserMsg1,{
                  "minScale":0.7,
                  "maxLines":3
               });
               m_window.message_tf_1.y += 40;
            }
         }
         initDialog();
         WindowManager.setFullScreen(false);
      }
      
      override protected function deinitDialog() : void
      {
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.m_closeBtn.dispose();
         this.m_showMeBtn.dispose();
         m_window.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitButton);
         super.deinitDialog();
      }
      
      override protected function close(param1:Event = null) : void
      {
         super.close(param1);
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.ACCEPT));
      }
      
      private function onExitButton(param1:MouseEvent) : void
      {
         this.close();
      }
      
      private function onCloseButton(param1:MouseEvent) : void
      {
         this.close();
      }
      
      private function onShowMeButton(param1:MouseEvent) : void
      {
         ExternalInterface.call("ZYFrameManager.showLanguageMenu");
         this.close();
      }
   }
}

