package displays.popups
{
   import flash.events.Event;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   import utils.ZGameTimeUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   
   public class ViralCountdownPopup extends GenericPopup
   {
      
      private var m_resetTime:Number = 0;
      
      public function ViralCountdownPopup(param1:Number)
      {
         this.m_resetTime = param1;
         super(this.getMessage(),GenericPopup.TYPE_OK);
      }
      
      override protected function close(param1:Event = null) : void
      {
         Zlab.processManager.removeScheduledObject(this);
         super.close(param1);
      }
      
      override protected function setUpScreen() : void
      {
         if(m_window != null)
         {
            super.setUpScreen();
            this.onUpdateMessage();
         }
      }
      
      private function onUpdateMessage() : void
      {
         var _loc1_:TextField = messageTextField;
         TextFieldUtil.processTextField(_loc1_,this.getMessage());
         Zlab.processManager.schedule(1000,this,this.onUpdateMessage);
      }
      
      private function getMessage() : String
      {
         var _loc1_:Number = this.m_resetTime - GlobalEngine.serverTime / 1000;
         return _loc1_ > 0 ? ZGameUtils.ZlocT("Dialogs","ViralCountdownPopupWait",{"time":ZGameTimeUtil.instance.getClockString(_loc1_ + 1)}) : ZGameUtils.ZlocT("Dialogs","ViralCountdownPopupReady");
      }
   }
}

