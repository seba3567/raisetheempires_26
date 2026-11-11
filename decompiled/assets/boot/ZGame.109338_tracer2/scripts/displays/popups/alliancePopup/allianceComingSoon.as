package displays.popups.alliancePopup
{
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   import core.ui.ZGameButton;
   import displays.popups.AllianceQuestMain;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zgame.assets.ui.FriendBar.FriendBarMenu;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   
   public class allianceComingSoon extends GallantPopup
   {
      
      protected var m_displayObject:FriendBarMenu;
      
      protected var m_xadjusted:Number;
      
      protected var m_yadjusted:Number;
      
      protected var m_createButton:ZGameButton;
      
      public function allianceComingSoon(param1:FriendBarMenu, param2:Number, param3:Number)
      {
         this.m_displayObject = param1;
         this.m_xadjusted = param2;
         this.m_yadjusted = param3;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/Alliance_popup.swf"));
      }
      
      private function get screen() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      private function centerWithinStageAlliance(param1:Stage) : void
      {
         this.x = this.m_xadjusted + 50;
         this.y = this.m_yadjusted - contentHeight + 59;
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         this.m_createButton = new ZGameButton(this.screen.create_bt,this.onCreate);
         this.screen.description_tf.visible = false;
         this.setupText();
         this.centerWithinStageAlliance(Zlab.mainStage);
      }
      
      protected function setupText() : void
      {
         var _loc1_:String = ZGameUtils.ZlocT("Dialogs","AllianceButtonComingTitle");
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","AllianceButtonComingDesc");
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","AllianceButtonComingHint");
         TextFieldUtil.compactTextField(this.screen.title_tf,_loc1_);
         TextFieldUtil.compactTextField(this.screen.description_tf,_loc2_);
         TextFieldUtil.compactTextField(this.screen.hint_tf,_loc3_);
         if(AlliancesManager.isValid())
         {
            this.m_createButton.text = ZGameUtils.ZlocT("Dialogs","Alliance_Phase2_Create");
            this.m_createButton.enable();
         }
         else
         {
            this.m_createButton.text = ZGameUtils.ZlocT("Dialogs","AllianceButtonComingDesc");
            this.m_createButton.disable_visual();
         }
      }
      
      override protected function deinitDialog() : void
      {
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         if(this.m_createButton)
         {
            this.m_createButton.dispose();
         }
         super.deinitDialog();
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         this.m_displayObject.alliancesClose_btn.visible = true;
         this.m_displayObject.alliancesOpen_btn.visible = false;
         close();
      }
      
      private function onCreate(param1:Event) : void
      {
         close();
         PopupManager.instance.push(new AllianceQuestMain());
      }
   }
}

