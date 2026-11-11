package displays.screens.dominationMode
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGameStats;
   import core.ZGlobal;
   import core.ui.ZGameButton;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import sound.ButtonMouseEventSoundContainer;
   import sound.ButtonSound;
   import transactions.TAddDominationChat;
   import transactions.clans.TSendTaunt;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   import zlabs.managers.WindowManager;
   import zlabs.resource.SWFResource;
   
   public class DominationModeChatInput extends ZGamePopUp
   {
      
      private static const MAX_INPUT_LENGTH:int = 70;
      
      private static const ASSETPATH:String = "assets/displays/dialogs/PU_Pvp_Comment.swf";
      
      private static const ASSETCLASS:String = "Screen";
      
      private var m_dialog:MovieClip;
      
      private var m_enemyID:String;
      
      private var m_statsSource:String;
      
      private var m_buttonSounds:ButtonMouseEventSoundContainer = new ButtonMouseEventSoundContainer();
      
      private var m_sendButton:ZGameButton;
      
      private var m_textField:TextField;
      
      private var m_isAlliance:Boolean = false;
      
      protected var m_maxChars:int = ZGlobal.gameSettings.getInt("maxCommentLength",MAX_INPUT_LENGTH);
      
      public function DominationModeChatInput(param1:String, param2:String, param3:Boolean = false)
      {
         this.m_enemyID = param1;
         this.m_isAlliance = param3;
         this.m_statsSource = param2;
         super(ZGlobal.getAssetURL(ASSETPATH));
      }
      
      public static function show(param1:String, param2:String, param3:Boolean = false) : void
      {
         var _loc4_:DominationModeChatInput = new DominationModeChatInput(param1,param2,param3);
         PopupManager.instance.push(_loc4_,0,false);
      }
      
      public function get statsClass() : String
      {
         return this.m_statsSource;
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
         this.m_sendButton = new ZGameButton(this.m_dialog.send_bt,this.onSendClicked);
         this.m_sendButton.text = ZGameUtils.ZlocT("Dialogs","Send");
         this.m_buttonSounds.addButton(this.m_sendButton.m_overlay,ButtonSound.DEFAULT);
         this.m_dialog.exit_bt.addEventListener(MouseEvent.CLICK,this.onCloseClicked);
         this.m_buttonSounds.addButton(this.m_dialog.exit_bt,ButtonSound.DEFAULT);
         TextFieldUtil.processTextField(this.m_dialog.header_tf,ZGameUtils.ZlocT("Dialogs","DominationChatInputTitle"));
         this.m_textField = this.m_dialog.input_tf;
         if(stage != null)
         {
            stage.focus = this.m_textField;
         }
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
         this.trackAction("no");
         close();
      }
      
      private function onSendClicked(param1:MouseEvent) : void
      {
         if(this.m_isAlliance)
         {
            TransactionManager.addTransaction(new TSendTaunt(this.m_textField.text,this.m_enemyID),true);
            StatsManager.count("alliances","alliances.battle","taunt",this.m_statsSource,"-1","-1");
            close();
         }
         else
         {
            TransactionManager.addTransaction(new TAddDominationChat(this.m_textField.text,this.m_enemyID),true);
            this.trackAction("post");
            close();
         }
      }
      
      private function trackAction(param1:String) : void
      {
         var _loc2_:Object = {
            "counter":"dialog",
            "kingdom":"DominationModeChatInput",
            "phylum":param1,
            "zclass":this.m_statsSource
         };
         ZGameStats.instance.dispatchEvent(new WorldEvent(ZGameStats.STATS_GENERIC_DIALOG_ACTION,_loc2_));
      }
      
      override protected function deinitDialog() : void
      {
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

