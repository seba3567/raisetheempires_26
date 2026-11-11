package displays.screens.globalpvp
{
   import core.ZGlobal;
   import core.managers.PVPManager;
   import core.ui.ZGameButton;
   import displays.popups.GallantPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   
   public class GlobalPVPLegalPopup extends GallantPopup
   {
      
      private var m_clip:MovieClip;
      
      private var m_button:ZGameButton;
      
      private var m_soundContainer:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      public function GlobalPVPLegalPopup()
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_BattleBlitzOptin.swf"));
      }
      
      override protected function initializeScreen() : void
      {
         this.m_clip = m_window.optin_mc;
         var _loc1_:Object = {"hours":PVPManager.globalPVPDurationHours};
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","GlobalPVPLegalTitle",_loc1_);
         var _loc3_:String = ZGameUtils.ZlocT("Dialogs","GlobalPVPLegalDesc1",_loc1_);
         var _loc4_:String = ZGameUtils.ZlocT("Dialogs","GlobalPVPLegalDesc2",_loc1_);
         var _loc5_:String = ZGameUtils.ZlocT("Dialogs","Okay");
         TextFieldUtil.compactTextField(this.m_clip.title_tf,_loc2_,{"maxLines":1});
         TextFieldUtil.processTextField(this.m_clip.bubble_tf,_loc3_);
         TextFieldUtil.processTextField(this.m_clip.popup_tf,_loc4_);
         this.m_button = new ZGameButton(this.m_clip.green_bt,this.onMainButtonClicked);
         this.m_button.text = _loc5_;
         this.m_soundContainer.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         this.contentWidth = 656.7;
         super.initializeScreen();
      }
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         if(this.m_soundContainer)
         {
            this.m_soundContainer.release();
            this.m_soundContainer = null;
         }
         if(this.m_button)
         {
            this.m_button.dispose();
            this.m_button = null;
         }
      }
      
      private function onMainButtonClicked(param1:Event) : void
      {
         close();
         PVPManager.instance.globalPVPLegalScreenClosed();
      }
   }
}

