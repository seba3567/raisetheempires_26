package displays.popups
{
   import core.ZGlobal;
   import core.player.Player;
   import core.ui.ZGameButton;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.displays.popups.IWindow;
   import zlabs.managers.PopupManager;
   
   public class ReactivationGiftPopup extends GallantPopup
   {
      
      private var m_uid:String;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer;
      
      private var m_sendButton:ZGameButton;
      
      private var m_validSend:Boolean;
      
      public function ReactivationGiftPopup(param1:String)
      {
         this.m_uid = param1;
         this.m_validSend = ZGlobal.isEligibleGiftRecipient(this.m_uid);
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_Gift.swf"));
      }
      
      public static function show(param1:String) : void
      {
         var _loc2_:IWindow = new ReactivationGiftPopup(param1);
         PopupManager.instance.push(_loc2_);
      }
      
      override protected function initializeScreen() : void
      {
         var _loc3_:String = null;
         if(this.clip.directRelief_mc)
         {
            this.clip.directRelief_mc.visible = false;
         }
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         this.clip.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitButton,false,0,true);
         this.m_buttonSounds.addButton(this.clip.exit_bt,ButtonSound.DEFAULT);
         this.m_sendButton = new ZGameButton(this.clip.green_bt,this.onSendClicked);
         if(this.m_validSend)
         {
            this.m_sendButton.text = ZGameUtils.ZlocT("Dialogs","Send");
         }
         else
         {
            this.m_sendButton.text = ZGameUtils.ZlocT("Dialogs","Continue");
         }
         this.m_buttonSounds.addButton(this.m_sendButton.m_overlay,ButtonSound.DEFAULT);
         var _loc1_:Player = ZGlobal.player.findFriendById(this.m_uid);
         var _loc2_:String = "";
         if(_loc1_)
         {
            _loc3_ = this.m_validSend ? "ReactivationGift" : "ReactivationGiftCantSend";
            _loc2_ = ZGameUtils.ZlocT("FeedPopups",_loc3_,{"friend":_loc1_.localizationName});
         }
         TextFieldUtil.processTextField(this.clip.description_tf,_loc2_);
         TextFieldUtil.processTextField(this.clip.title_tf,ZGameUtils.ZlocT("Gifts","SendGift"));
         contentWidth = this.clip.panel_mc.width;
         contentHeight = this.clip.panel_mc.height;
         super.initializeScreen();
      }
      
      private function get clip() : MovieClip
      {
         return m_window.gift_mc;
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_sendButton)
         {
            this.m_sendButton.dispose();
            this.m_sendButton = null;
         }
         if(this.m_buttonSounds)
         {
            this.m_buttonSounds.release();
            this.m_buttonSounds = null;
         }
         this.clip.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitButton);
         super.deinitDialog();
      }
      
      private function onExitButton(param1:MouseEvent) : void
      {
         close();
      }
      
      private function onSendClicked(param1:MouseEvent) : void
      {
         if(this.m_validSend)
         {
            ZGlobal.navigateImmediatelyTo("gifts.php?targetId=" + this.m_uid);
         }
         close();
      }
   }
}

