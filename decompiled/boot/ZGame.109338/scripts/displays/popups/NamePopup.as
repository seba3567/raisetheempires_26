package displays.popups
{
   import core.ZGlobal;
   import core.ui.ZGameButton;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class NamePopup extends ZGamePopUp
   {
      
      private static const MAX_INPUT_LENGTH:int = 30;
      
      private var m_initialized:Boolean = false;
      
      private var m_initialName:String;
      
      private var m_callback:Function = null;
      
      private var m_viralBtn:ZGameButton = null;
      
      private var m_textfield:TextField = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      public function NamePopup(param1:String, param2:Function = null)
      {
         this.m_initialName = param1;
         this.m_callback = param2;
         if(this.m_callback != null)
         {
            addEventListener(GenericPopupEvent.SELECTED,this.m_callback,false,0,true);
         }
         super(this.assetURL);
      }
      
      public function get assetURL() : String
      {
         return "";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override public function onShow() : void
      {
         this.setUpScreen();
         super.onShow();
      }
      
      private function setUpScreen() : void
      {
         if(!m_window || this.m_initialized)
         {
            return;
         }
         this.m_initialized = true;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         if(ZGlobal.player.isCIP == true && ZGlobal.player.acceptedTOS == false)
         {
            this.m_viralBtn = new ZGameButton(m_window.popup_mc.viral_bt,this.onAcceptButton);
         }
         else
         {
            this.m_viralBtn = new ZGameButton(m_window.popup_mc.viral_bt,this.onViralButton);
         }
         this.m_viralBtn.text = ZGameUtils.ZlocT("Dialogs","Save");
         this.m_buttonSounds.addButton(this.m_viralBtn.m_overlay,ButtonSound.DEFAULT);
         TextFieldUtil.processTextField(m_window.popup_mc.title_tf,this.greeting);
         TextFieldUtil.processTextField(m_window.popup_mc.subtitle_tf,this.title);
         TextFieldUtil.processTextField(m_window.popup_mc.detail_tf,this.detail);
         this.m_textfield = m_window.popup_mc.input_tf;
         if(stage != null)
         {
            stage.focus = this.m_textfield;
         }
         TextFieldUtil.processTextField(this.m_textfield,this.m_initialName);
         this.m_textfield.selectable = true;
         this.m_textfield.setSelection(0,this.m_textfield.text.length);
         this.m_textfield.maxChars = this.maxChars;
         this.m_textfield.addEventListener(TextEvent.TEXT_INPUT,this.textInput);
         m_window.addEventListener(MouseEvent.CLICK,this.onClick);
         addChild(m_window);
         initDialog();
         WindowManager.setFullScreen(false);
      }
      
      protected function get maxChars() : int
      {
         return ZGlobal.gameSettings.getInt("maxWorldNameLength",MAX_INPUT_LENGTH);
      }
      
      protected function get greeting() : String
      {
         return "";
      }
      
      protected function get title() : String
      {
         return "";
      }
      
      protected function get detail() : String
      {
         return "";
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.m_viralBtn.dispose();
         this.m_textfield.removeEventListener(TextEvent.TEXT_INPUT,this.textInput);
         m_window.removeEventListener(MouseEvent.CLICK,this.onClick);
         if(this.m_callback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_callback);
         }
         removeChild(m_window);
         super.deinitDialog();
      }
      
      override protected function close(param1:Event = null) : void
      {
         super.close(param1);
      }
      
      private function onAcceptButton(param1:MouseEvent) : void
      {
         this.dispatchNameUpdatedEvent(false);
         this.close();
      }
      
      private function onViralButton(param1:MouseEvent) : void
      {
         this.dispatchNameUpdatedEvent(true);
         this.close();
      }
      
      private function dispatchNameUpdatedEvent(param1:Boolean) : void
      {
         var _loc2_:Object = new Object();
         _loc2_.newName = this.m_textfield.text;
         _loc2_.share = param1;
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,0,_loc2_));
      }
      
      protected function textInput(param1:TextEvent) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc2_:String = ZGlobal.gameSettings.getString("invalidNameCharacters");
         var _loc3_:String = param1.text;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            if(_loc3_ == _loc2_.substr(_loc4_,1))
            {
               param1.preventDefault();
            }
            _loc4_++;
         }
         if(ZGlobal.localizer.localeCode == "ja_JP")
         {
            _loc5_ = ZGlobal.gameSettings.getInt("maxWorldNameLength",MAX_INPUT_LENGTH);
            _loc6_ = TextFieldUtil.mb_strwidth(this.m_textfield.text) + TextFieldUtil.mb_strwidth(_loc3_);
            if(_loc6_ > _loc5_)
            {
               param1.preventDefault();
            }
         }
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(stage != null)
         {
            stage.focus = this.m_textfield;
         }
      }
   }
}

