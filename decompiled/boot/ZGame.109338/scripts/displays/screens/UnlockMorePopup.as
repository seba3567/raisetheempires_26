package displays.screens
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.permission.PermissionTypes;
   import core.ui.GenericButton;
   import core.ui.ZGameButton;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import transactions.TAcceptedGDP;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class UnlockMorePopup extends ZGamePopUp
   {
      
      public static const UPSELL:String = "cipUpsellDialog";
      
      public static const POLICY_REMINDER:String = "cipPolicyReminderDialog";
      
      public static const TYPE_INTRO:String = "main";
      
      public static const TYPE_DEFENSEFORCE:String = "defense_force";
      
      private var m_mc:MovieClip = null;
      
      private var m_button:ZGameButton = null;
      
      private var m_closeButton:GenericButton;
      
      private var m_type:String;
      
      public function UnlockMorePopup(param1:String = "cipUpsellDialog")
      {
         this.m_type = param1;
         var _loc2_:String = this.path;
         super(ZGlobal.getAssetURL(_loc2_));
      }
      
      private function get path() : String
      {
         return "assets/displays/dialogs/PU_StartNow.swf";
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         TextFieldUtil.processTextField(m_window.screen_mc.title_tf,ZGameUtils.ZlocT("Dialogs","CIP_UnlockMore_Headline"));
         TextFieldUtil.processTextField(m_window.screen_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","CIP_UnlockMore_Description"));
         if(m_window.screen_mc.start_bt)
         {
            this.m_button = new ZGameButton(m_window.screen_mc.start_bt,this.onAccept);
            this.m_button.text = ZGameUtils.ZlocT("Dialogs","CIP_UnlockMore_Button");
         }
         if(m_window.close_bt)
         {
            this.m_closeButton = new GenericButton(m_window.screen_mc.close_bt,this.onClose);
         }
         StatsManager.count("dialog","startnow","unlock_more");
         StatsManager.count("startnow","finish");
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
         ZGlobal.permissionGate.attempt(PermissionTypes.TYPE_GDP,this.onComplete,this.onFailure);
         close();
      }
      
      public function onClose(param1:Event) : void
      {
         close();
      }
      
      public function onComplete(param1:Event = null) : void
      {
         ZGlobal.player.setAcceptedGDP(true);
         ZGlobal.player.setAcceptedTOS(true);
         TransactionManager.addTransaction(new TAcceptedGDP(true),true);
         StatsManager.count("startnow","gdp","accpeted");
         close();
      }
      
      public function onFailure(param1:Event = null) : void
      {
         if(!ZGlobal.player.acceptedTOS)
         {
            PopupManager.instance.push(new AcceptTOSPopup());
         }
         StatsManager.count("startnow","gdp","cancelled");
         close();
      }
      
      override protected function deinitDialog() : void
      {
         this.m_closeButton = null;
         if(this.m_button)
         {
            this.m_button.dispose();
            this.m_button = null;
         }
         super.deinitDialog();
      }
   }
}

