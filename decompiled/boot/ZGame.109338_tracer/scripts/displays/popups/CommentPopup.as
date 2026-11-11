package displays.popups
{
   import core.ZGlobal;
   import core.managers.ChallengeModeManager;
   import core.managers.MatchMakingManager;
   import core.managers.PVPManager;
   import core.player.IPVPPlayer;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.battlebase.BattleBasePopup;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class CommentPopup extends ZGamePopUp
   {
      
      private static const MAX_INPUT_LENGTH:int = 70;
      
      protected var m_initialized:Boolean = false;
      
      private var m_callback:Function = null;
      
      protected var m_sendBtn:ZGameButton = null;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = null;
      
      protected var m_loaders:Array = null;
      
      private var m_textfield:TextField = null;
      
      private var m_data:Object = null;
      
      protected var m_maxChars:int = 70;
      
      public function CommentPopup(param1:Function = null, param2:Object = null, param3:String = "assets/displays/dialogs/PU_Comment.swf")
      {
         this.m_callback = param1;
         this.m_data = param2;
         if(this.m_callback != null)
         {
            addEventListener(GenericPopupEvent.SELECTED,this.m_callback,false,0,true);
         }
         super(ZGlobal.getAssetURL(param3));
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
      
      protected function setUpScreen() : void
      {
         var _loc1_:String = null;
         var _loc2_:Function = null;
         var _loc3_:ImageLoader = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:IPVPPlayer = null;
         if(!m_window || this.m_initialized)
         {
            return;
         }
         this.m_initialized = true;
         this.m_buttonSounds = new ButtonMouseEventSoundContainer();
         if(MatchMakingManager.MMNeighborCodeFlow(ZGlobal.hostPlayer.uid))
         {
            if(MatchMakingManager.IsAddFBButtonExpON())
            {
               _loc1_ = "MM_AddFBFriendButton";
               _loc2_ = this.onAddFriend;
            }
            else
            {
               _loc1_ = "Okay";
               _loc2_ = this.onExitButton;
            }
         }
         else
         {
            _loc1_ = "PostComment";
            _loc2_ = this.onAcceptButton;
         }
         this.m_sendBtn = new ZGameButton(m_window.popup_mc.send_bt,_loc2_);
         this.m_sendBtn.compactText(ZGameUtils.ZlocT("Dialogs",_loc1_),{
            "maxLines":1,
            "minScale":0.5,
            "onFail":"return"
         });
         this.m_buttonSounds.addButton(this.m_sendBtn.m_overlay,ButtonSound.DEFAULT);
         m_window.popup_mc.exit_bt.addEventListener(MouseEvent.CLICK,this.onExitButton);
         this.m_buttonSounds.addButton(m_window.popup_mc.exit_bt,ButtonSound.DEFAULT);
         this.m_maxChars = ZGlobal.gameSettings.getInt("maxCommentLength",MAX_INPUT_LENGTH);
         this.setupText();
         this.m_textfield = m_window.popup_mc.input_tf;
         if(MatchMakingManager.MMNeighborCodeFlow(ZGlobal.hostPlayer.uid))
         {
            this.m_textfield.type = TextFieldType.DYNAMIC;
         }
         else
         {
            if(stage != null)
            {
               stage.focus = this.m_textfield;
            }
            TextFieldUtil.processTextField(this.m_textfield,"");
            this.m_textfield.selectable = true;
            this.m_textfield.setSelection(0,this.m_textfield.text.length);
            this.m_textfield.maxChars = this.m_maxChars;
            this.m_textfield.wordWrap = true;
            this.m_textfield.addEventListener(TextEvent.TEXT_INPUT,this.textInput);
         }
         this.m_loaders = new Array();
         if(m_window.popup_mc.icon_0)
         {
            _loc3_ = ImageLoaderFactory.CreateImageLoader(ZGlobal.player.snUser.picture,m_window.popup_mc.icon_0.portrait_mc);
            _loc3_.smooth = true;
            this.m_loaders.push(_loc3_);
         }
         if(m_window.popup_mc.icon_1)
         {
            _loc4_ = ZGlobal.hostPlayer.snUser.picture;
            if(Boolean(this.m_data) && Boolean(this.m_data.recipientIcon))
            {
               _loc4_ = this.m_data.recipientIcon;
            }
            else if(ZGlobal.isHome() && ChallengeModeManager.instance.isInChallengeBattle())
            {
               _loc5_ = ChallengeModeManager.instance.currentChallengerID();
               _loc6_ = PVPManager.instance.getPVPPlayer(_loc5_);
               _loc4_ = _loc6_.portraitURL;
            }
            _loc3_ = ImageLoaderFactory.CreateImageLoader(_loc4_,m_window.popup_mc.icon_1.portrait_mc);
            if(_loc3_)
            {
               _loc3_.smooth = true;
               this.m_loaders.push(_loc3_);
            }
         }
         addChild(m_window);
         WindowManager.setFullScreen(false);
         initDialog();
      }
      
      protected function onAddFriend(param1:MouseEvent) : void
      {
         MatchMakingManager.ShowFBFriendRequestDialog(ZGlobal.hostPlayer.uid);
         this.onExitButton(null);
      }
      
      override protected function deinitDialog() : void
      {
         var _loc1_:ImageLoader = null;
         this.m_buttonSounds.release();
         this.m_buttonSounds = null;
         this.m_sendBtn.dispose();
         m_window.popup_mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExitButton);
         this.m_textfield.removeEventListener(TextEvent.TEXT_INPUT,this.textInput);
         if(this.m_callback != null)
         {
            removeEventListener(GenericPopupEvent.SELECTED,this.m_callback);
         }
         for each(_loc1_ in this.m_loaders)
         {
            _loc1_.destroy();
         }
         this.m_loaders = null;
         removeChild(m_window);
         super.deinitDialog();
      }
      
      protected function setupText() : void
      {
         var _loc1_:String = "CommentTitle";
         var _loc2_:String = "CommentDesc";
         if(ZGlobal.isHome())
         {
            if(ChallengeModeManager.instance.isInChallengeBattle())
            {
               if(!ChallengeModeManager.instance.isPVEChallenge())
               {
                  _loc1_ += "Lose";
                  _loc2_ += "Lose";
               }
            }
            else
            {
               _loc1_ += "ThankWhiteKnight";
               _loc2_ += "ThankWhiteKnight";
            }
         }
         else if(ChallengeModeManager.instance.isInChallengeBattle())
         {
            if(ChallengeModeManager.instance.isNeighborAssist())
            {
               _loc1_ += "WhiteKnightLose";
               _loc2_ += "WhiteKnightLose";
            }
            else
            {
               _loc1_ += "Lose";
               _loc2_ += "Lose";
            }
         }
         if(MatchMakingManager.MMNeighborCodeFlow(ZGlobal.hostPlayer.uid))
         {
            _loc2_ = "MM_BattleLooseCommentDesc";
         }
         TextFieldUtil.compactTextField(m_window.popup_mc.title_tf,ZGameUtils.ZlocT("Dialogs",_loc1_));
         TextFieldUtil.compactTextField(m_window.popup_mc.description_tf,ZGameUtils.ZlocT("Dialogs",_loc2_,{"num":this.m_maxChars}));
      }
      
      private function onAcceptButton(param1:MouseEvent) : void
      {
         if(this.m_data == null)
         {
            this.m_data = new Object();
         }
         this.m_data.comment = this.m_textfield.text;
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,BattleBasePopup.AUTOSHARE_COMMENT,this.m_data));
         close();
      }
      
      private function onExitButton(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,BattleBasePopup.EXIT));
         close();
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

