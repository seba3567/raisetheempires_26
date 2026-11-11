package displays.popups.genericPopup
{
   import displays.popups.GenericPopup;
   import flash.events.MouseEvent;
   import sound.ButtonSound;
   
   public class NotEnoughMasteryTokensPopup extends GenericPopup
   {
      
      public function NotEnoughMasteryTokensPopup(param1:String, param2:int = 0, param3:Function = null)
      {
         super(param1,param2,param3);
         setAcceptTextName("Okay");
      }
      
      override protected function setUpLook() : void
      {
         super.setUpLook();
         m_window.popupBox_mc.welcomeBox_mc.exit_bt.visible = true;
         m_window.popupBox_mc.cash.visible = false;
      }
      
      override protected function onAccept(param1:MouseEvent) : void
      {
         super.onAccept(param1);
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

