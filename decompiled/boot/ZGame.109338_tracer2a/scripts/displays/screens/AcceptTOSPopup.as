package displays.screens
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.ui.GenericButton;
   import core.ui.ZGameButton;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import transactions.TAcceptedTOS;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class AcceptTOSPopup extends ZGamePopUp
   {
      
      private var m_mc:MovieClip = null;
      
      private var m_accept_button:ZGameButton = null;
      
      private var m_tos_button:ZGameButton = null;
      
      private var m_closeButton:GenericButton;
      
      public function AcceptTOSPopup()
      {
         var _loc1_:String = this.path;
         super(ZGlobal.getAssetURL(_loc1_));
      }
      
      private function get path() : String
      {
         return "assets/displays/dialogs/PU_TOSv2.swf";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         TextFieldUtil.processTextField(m_window.screen_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","CIP_TOS_Description"));
         if(m_window.screen_mc.accept_bt)
         {
            this.m_accept_button = new ZGameButton(m_window.screen_mc.accept_bt,this.onAccept);
            this.m_accept_button.text = ZGameUtils.ZlocT("Dialogs","Accept");
         }
         if(m_window.screen_mc.tos_bt)
         {
            this.m_tos_button = new ZGameButton(m_window.screen_mc.tos_bt,this.onTOS);
            this.m_tos_button.text = ZGameUtils.ZlocT("Dialogs","TOSPolicyTOSTitle");
         }
         if(m_window.close_bt)
         {
            this.m_closeButton = new GenericButton(m_window.screen_mc.close_bt,this.onClose);
         }
         StatsManager.count("dialog","startnow","TOS");
         addChild(m_window);
      }
      
      override public function onShow() : void
      {
         if(m_window)
         {
            super.onShow();
            this.initDialog();
         }
      }
      
      public function onAccept(param1:Event = null) : void
      {
         ZGlobal.player.setAcceptedTOS(true);
         TransactionManager.addTransaction(new TAcceptedTOS(true),true);
         close();
      }
      
      public function onTOS(param1:Event) : void
      {
         var _loc2_:String = "http://www.zynga.com/about/terms-of-service.php";
         ZGlobal.openURLInNewWindow(_loc2_);
      }
      
      public function onClose(param1:Event) : void
      {
         close();
      }
      
      public function onComplete(param1:Event = null) : void
      {
         close();
      }
      
      public function onFailure(param1:Event = null) : void
      {
         close();
      }
      
      override protected function deinitDialog() : void
      {
         this.m_closeButton = null;
         if(this.m_accept_button)
         {
            this.m_accept_button.dispose();
            this.m_accept_button = null;
         }
         super.deinitDialog();
      }
   }
}

