package displays.screens.friendFlash
{
   import core.ZGlobal;
   import core.managers.promoManager.PromoManager;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.resource.SWFResource;
   
   public class FriendFlashThankYouReceived extends ZGamePopUp
   {
      
      private static const ASSETPATH:String = "assets/displays/dialogs/PU_Ep_Gift_Thanks.swf";
      
      private static const ASSETCLASS:String = "Screen_mc";
      
      private var m_dialog:MovieClip;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      private var m_loader:ImageLoader;
      
      private var m_friendInfo:Object;
      
      private var m_msg:String;
      
      public function FriendFlashThankYouReceived(param1:Object, param2:String)
      {
         this.m_friendInfo = param1;
         this.m_msg = param2;
         super(ZGlobal.getAssetURL(ASSETPATH));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         var _loc2_:Class = param1.getAssetClass(ASSETCLASS);
         this.m_dialog = new _loc2_();
         contentWidth = this.m_dialog.width;
         contentHeight = this.m_dialog.height;
         centerWithinStage(Zlab.mainStage);
         this.m_dialog.exit_bt.addEventListener(MouseEvent.CLICK,this.onCloseClicked);
         this.m_buttonSounds.addButton(this.m_dialog.exit_bt,ButtonSound.DEFAULT);
         TextFieldUtil.compactTextField(this.m_dialog.title_tf,ZGameUtils.ZlocT("Dialogs","EPGiftThankYouReceivedTitle"),{"maxLines":1});
         TextFieldUtil.compactTextField(this.m_dialog.info_tf,ZGameUtils.ZlocT("Dialogs","EPGIftThankYouReceivedMsg",{"user":this.m_friendInfo.first_name}),{"maxLines":5});
         TextFieldUtil.compactTextField(this.m_dialog.name_tf,this.m_friendInfo.first_name);
         TextFieldUtil.compactTextField(this.m_dialog.message_tf,this.m_msg);
         this.m_loader = ImageLoaderFactory.CreateImageLoader(this.m_friendInfo.pic_square,this.m_dialog.player_mc.icon);
         addChild(this.m_dialog);
      }
      
      private function onCloseClicked(param1:Event) : void
      {
         close();
         PromoManager.instance.EPGiftThankYouClosed();
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_loader)
         {
            this.m_loader.destroy();
            this.m_loader = null;
         }
         this.m_dialog.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClicked);
         this.m_buttonSounds.release();
         super.deinitDialog();
         if(this.m_dialog)
         {
            if(this.m_dialog.parent)
            {
               this.m_dialog.parent.removeChild(this.m_dialog);
            }
            this.m_dialog = null;
         }
      }
   }
}

