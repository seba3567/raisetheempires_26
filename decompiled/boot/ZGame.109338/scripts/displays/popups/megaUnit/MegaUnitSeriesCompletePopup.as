package displays.popups.megaUnit
{
   import core.ZGlobal;
   import core.ui.ZGameButton;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class MegaUnitSeriesCompletePopup extends GallantPopup
   {
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_button:ZGameButton = null;
      
      private var m_title:String = null;
      
      private var m_message:String = null;
      
      private var m_callback:Function = null;
      
      public function MegaUnitSeriesCompletePopup(param1:String, param2:String, param3:Function)
      {
         this.m_title = param1;
         this.m_message = param2;
         this.m_callback = param3;
         super(ZGlobal.getAssetURL("assets/displays/miniseries/008/Miniseries008_FinalPopup.swf"));
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.m_button = new ZGameButton(this.screen.accept_bt,this.onButtonClicked);
         this.m_button.text = ZGameUtils.ZlocT("Dialogs","Okay");
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.m_buttonSounds.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         TextFieldUtil.processTextField(this.screen.title_tf,this.m_title);
         TextFieldUtil.processTextField(this.screen.message_tf,this.m_message);
      }
      
      override protected function deinitDialog() : void
      {
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.m_button.dispose();
         this.m_button = null;
         this.m_callback = null;
         super.deinitDialog();
      }
      
      private function get screen() : MovieClip
      {
         return m_window.generic01_mc;
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         this.m_callback();
         close();
      }
   }
}

