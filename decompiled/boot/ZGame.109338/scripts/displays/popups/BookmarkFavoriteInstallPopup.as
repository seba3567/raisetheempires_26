package displays.popups
{
   import core.ZGlobal;
   import core.managers.BookmarksIncentiveManager;
   import core.ui.ZGameButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.popups.PopUpBase;
   import zlabs.events.GenericPopupEvent;
   
   public class BookmarkFavoriteInstallPopup extends GallantPopup
   {
      
      private var m_button:ZGameButton = null;
      
      private var m_dialog:PopUpBase = null;
      
      private var m_sequentialLogins:int = 0;
      
      public function BookmarkFavoriteInstallPopup(param1:int)
      {
         this.m_sequentialLogins = param1;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_BookmarkReward.swf"));
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.setupUI();
      }
      
      protected function setupUI() : void
      {
         TextFieldUtil.compactTextField(m_window.screen_mc.title_tf,ZGameUtils.ZlocT("Dialogs","BookmarkFavInstallTitle"));
         TextFieldUtil.compactTextField(m_window.screen_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","BookmarkFavInstallDesc",{"amount":BookmarksIncentiveManager.FIRST_INSTALL_TOKEN_COUNT}));
         this.m_button = new ZGameButton(m_window.screen_mc.button_mc,this.onAccept);
         this.m_button.text = ZGameUtils.ZlocT("Dialogs","BookmarkFavInstallButton");
         this.m_button.show();
         this.m_button.enable();
         m_window.screen_mc.exit_mc.addEventListener(MouseEvent.CLICK,this.onExit,false,0,true);
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_button)
         {
            this.m_button.dispose();
            this.m_button = null;
         }
         super.deinitDialog();
      }
      
      override protected function close(param1:Event = null) : void
      {
         m_window.screen_mc.exit_mc.removeEventListener(MouseEvent.CLICK,this.onExit);
         super.close();
      }
      
      protected function onExit(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.CANCEL));
         this.close();
         BookmarksIncentiveManager.showIncentivePopup(this.m_sequentialLogins,true);
      }
      
      protected function onAccept(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.ACCEPT));
         this.close();
         BookmarksIncentiveManager.showIncentivePopup(this.m_sequentialLogins,true);
      }
   }
}

