package displays.screens.friendFlash
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.managers.promoManager.PromoManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TFriendFlashSendThankYou;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class FriendFlashThankYouInput extends ZGamePopUp
   {
      
      private static const MAX_INPUT_LENGTH:int = 70;
      
      private static const ASSETPATH:String = "assets/displays/dialogs/PU_Ep_Gift_Notice.swf";
      
      private static const ASSETCLASS:String = "Screen_mc";
      
      private var m_dialog:MovieClip;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      private var m_sendButton:ZGameButton;
      
      private var m_textField:TextField;
      
      private var m_loader:ImageLoader;
      
      protected var m_maxChars:int = ZGlobal.gameSettings.getInt("maxCommentLength",MAX_INPUT_LENGTH);
      
      private var m_friendInfo:Object;
      
      private var m_amount:int;
      
      public function FriendFlashThankYouInput(param1:Object, param2:int)
      {
         this.m_friendInfo = param1;
         this.m_amount = param2;
         super(ZGlobal.getAssetURL(ASSETPATH));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         if(WindowManager.isFullScreen())
         {
            WindowManager.toggleFullScreen();
         }
         super.onLoadComplete(param1);
         var _loc2_:Class = param1.getAssetClass(ASSETCLASS);
         this.m_dialog = new _loc2_();
         contentWidth = this.m_dialog.width;
         contentHeight = this.m_dialog.height;
         centerWithinStage(Zlab.mainStage);
         this.m_sendButton = new ZGameButton(this.m_dialog.orangeButton_01,this.onSendClicked);
         this.m_sendButton.compactText(ZGameUtils.ZlocT("Dialogs","EPGIftSendThankYouSendButton"),{"maxLines":1});
         this.m_buttonSounds.addButton(this.m_sendButton.m_overlay,ButtonSound.DEFAULT);
         this.m_dialog.exit_bt.addEventListener(MouseEvent.CLICK,this.onCloseClicked);
         this.m_buttonSounds.addButton(this.m_dialog.exit_bt,ButtonSound.DEFAULT);
         var _loc3_:Object = {
            "user":this.m_friendInfo.first_name,
            "reward":this.m_amount
         };
         TextFieldUtil.compactTextField(this.m_dialog.title_tf,ZGameUtils.ZlocT("Dialogs","EPGIftSendThankYouTitle"),{"maxLines":1});
         TextFieldUtil.compactTextField(this.m_dialog.info_tf,ZGameUtils.ZlocT("Dialogs","EPGIftSendThankYouMsg",_loc3_),{"maxLines":3});
         TextFieldUtil.compactTextField(this.m_dialog.points_tf,ZGameUtils.ZlocT("Dialogs","WinRewardResult",_loc3_));
         TextFieldUtil.compactTextField(this.m_dialog.name_tf,this.m_friendInfo.first_name);
         TextFieldUtil.compactTextField(this.m_dialog.title01_tf,ZGameUtils.ZlocT("Dialogs","EPGIftSendThankYouTextBoxLabel"));
         this.m_loader = ImageLoaderFactory.CreateImageLoader(this.m_friendInfo.pic_square,this.m_dialog.player_mc.icon);
         this.m_textField = this.m_dialog.input_tf;
         if(stage != null)
         {
            stage.focus = this.m_textField;
         }
         this.m_dialog.addEventListener(MouseEvent.CLICK,this.onClick,false,0,true);
         TextFieldUtil.processTextField(this.m_textField,"");
         this.m_textField.selectable = true;
         this.m_textField.setSelection(0,this.m_textField.text.length);
         this.m_textField.maxChars = this.m_maxChars;
         this.m_textField.wordWrap = true;
         this.m_textField.addEventListener(TextEvent.TEXT_INPUT,this.textInput,false,0,true);
         addChild(this.m_dialog);
      }
      
      private function onCloseClicked(param1:Event) : void
      {
         close();
         PromoManager.instance.EPGiftThankYouClosed();
      }
      
      private function onSendClicked(param1:MouseEvent) : void
      {
         if(this.m_textField.text.length)
         {
            TransactionManager.addTransaction(new TFriendFlashSendThankYou(this.m_friendInfo.zid,this.m_textField.text),true);
         }
         close();
         PromoManager.instance.EPGiftThankYouClosed();
      }
      
      private function onClick(param1:MouseEvent) : void
      {
         if(stage != null)
         {
            stage.focus = this.m_textField;
         }
      }
      
      override protected function deinitDialog() : void
      {
         if(this.m_loader)
         {
            this.m_loader.destroy();
            this.m_loader = null;
         }
         this.m_dialog.removeEventListener(MouseEvent.CLICK,this.onClick);
         this.m_dialog.exit_bt.removeEventListener(MouseEvent.CLICK,this.onCloseClicked);
         this.m_textField.removeEventListener(TextEvent.TEXT_INPUT,this.textInput);
         this.m_sendButton.dispose();
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
      
      protected function textInput(param1:TextEvent) : void
      {
         var _loc2_:String = ZGlobal.gameSettings.getString("invalidNameCharacters");
         var _loc3_:String = param1.text;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            if(_loc3_ == _loc2_.substr(_loc4_,1))
            {
               param1.preventDefault();
            }
            _loc4_++;
         }
      }
   }
}

