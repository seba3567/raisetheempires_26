package displays.popups
{
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   
   public class HudsonPopup extends GenericPopup
   {
      
      private var m_title:String = null;
      
      public function HudsonPopup(param1:String, param2:String, param3:int = 0, param4:Function = null)
      {
         super(param1,param3,param4);
         this.m_title = param2;
      }
      
      override protected function setUpLook() : void
      {
         super.setUpLook();
         m_window.popupBox_mc.welcomeBox_mc.visible = true;
         m_window.popupBox_mc.welcomeBox_mc.welcome_tf.visible = true;
         m_window.popupBox_mc.welcomeBox_mc.exit_bt.visible = true;
         TextFieldUtil.processTextField(m_window.popupBox_mc.welcomeBox_mc.welcome_tf,this.m_title);
      }
      
      protected function onClose(param1:MouseEvent) : void
      {
         close();
      }
      
      override protected function initButtons() : void
      {
         super.initButtons();
         m_window.popupBox_mc.welcomeBox_mc.exit_bt.addEventListener(MouseEvent.CLICK,onCancel);
         m_buttonSounds.addButton(m_window.popupBox_mc.welcomeBox_mc.exit_bt,ButtonSound.DEFAULT);
      }
      
      override protected function deinitButtons() : void
      {
         super.deinitButtons();
         m_window.popupBox_mc.welcomeBox_mc.exit_bt.removeEventListener(MouseEvent.CLICK,onCancel);
      }
   }
}

