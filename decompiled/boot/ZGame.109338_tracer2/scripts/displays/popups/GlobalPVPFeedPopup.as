package displays.popups
{
   import core.ZGlobal;
   import core.managers.PVPManager;
   import core.ui.ZGameButton;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   
   public class GlobalPVPFeedPopup extends GallantPopup
   {
      
      private var m_clip:MovieClip;
      
      private var m_button:ZGameButton;
      
      private var m_soundContainer:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      private var m_title:String;
      
      private var m_desc:String;
      
      private var m_buttonText:String;
      
      private var m_iconURL:String;
      
      private var m_won:Boolean = false;
      
      private var m_closeCallback:Function = null;
      
      public function GlobalPVPFeedPopup(param1:String, param2:String, param3:String, param4:String, param5:Function = null, param6:Boolean = false)
      {
         super(ZGlobal.getAssetURL("assets/displays/screens/PVP_GlobalFeedPopup.swf"));
         this.m_title = param1;
         this.m_desc = param2;
         this.m_buttonText = param3;
         this.m_iconURL = param4;
         this.m_closeCallback = param5;
         this.m_won = param6;
      }
      
      override protected function initializeScreen() : void
      {
         this.m_clip = m_window.globalPVPReminder_mc;
         this.m_clip.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitClicked,false,0,true);
         this.m_soundContainer.addButton(this.m_clip.exit_bt,ButtonSound.DEFAULT);
         TextFieldUtil.compactTextField(this.m_clip.title_tf,this.m_title,{"maxLines":1});
         TextFieldUtil.processTextField(this.m_clip.generic_tf,this.m_desc);
         this.m_button = new ZGameButton(this.m_clip.ask_bt,this.onMainButtonClicked);
         this.m_button.text = this.m_buttonText;
         this.m_soundContainer.addButton(this.m_button.m_overlay,ButtonSound.DEFAULT);
         var _loc1_:String = "x" + String(PVPManager.spinPurchaseKeyCost);
         TextFieldUtil.processTextField(this.m_clip.value_tf,_loc1_);
         this.m_clip.panel_win.visible = this.m_won;
         this.m_clip.value_tf.visible = this.m_won;
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
         this.m_clip.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitClicked);
      }
      
      private function onExitClicked(param1:MouseEvent) : void
      {
         close();
      }
      
      private function onMainButtonClicked(param1:Event) : void
      {
         close();
         if(this.m_closeCallback != null)
         {
            this.m_closeCallback(param1);
         }
      }
   }
}

