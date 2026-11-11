package displays.popups
{
   import core.ZGlobal;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class SurveillanceScanResultPopup extends ZGamePopUp
   {
      
      private var m_titleText:String;
      
      private var m_descText:String;
      
      private var m_okText:String;
      
      private var m_okButton:ZGameButton = null;
      
      private var m_initialized:Boolean = false;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      private var m_imageLoader:ImageLoader = null;
      
      public function SurveillanceScanResultPopup(param1:String, param2:String, param3:String)
      {
         this.m_titleText = param1;
         this.m_descText = param2;
         this.m_okText = param3;
         var _loc4_:String = ZGlobal.getAssetURL("assets/displays/screens/PU_MysteryUnit_Popup.swf");
         super(_loc4_);
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
         addChild(m_window);
         this.initDialog();
      }
      
      override protected function initDialog() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         super.initDialog();
         TextFieldUtil.compactTextField(this.screen.title_tf,this.m_titleText);
         TextFieldUtil.compactTextField(this.screen.description_tf,this.m_descText);
         this.m_okButton = new ZGameButton(this.screen.add_bt,this.onOk);
         this.m_okButton.compactText(this.m_okText,null);
         this.m_buttonSounds.addButton(this.m_okButton.m_overlay,ButtonSound.DEFAULT);
         this.m_imageLoader = ImageLoaderFactory.CreateImageLoader(ZGlobal.gameSettings.getImageByName("SurveillanceTower","icon"),this.screen.icon);
         this.m_imageLoader.smooth = true;
         this.screen.exit_bt.visible = false;
      }
      
      override protected function deinitDialog() : void
      {
         this.m_okButton.dispose();
         this.m_okButton = null;
         if(this.m_imageLoader)
         {
            this.m_imageLoader.destroy();
            this.m_imageLoader = null;
         }
      }
      
      private function get screen() : MovieClip
      {
         return window.popup_mc;
      }
      
      private function onOk(param1:MouseEvent) : void
      {
         close();
      }
   }
}

