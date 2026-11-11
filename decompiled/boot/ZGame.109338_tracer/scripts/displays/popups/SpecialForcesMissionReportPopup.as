package displays.popups
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.ui.ZGameButton;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import transactions.TSetStrikeTeamComment;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.managers.WindowManager;
   
   public class SpecialForcesMissionReportPopup extends GallantPopup
   {
      
      private static const MAX_INPUT_LENGTH:int = 70;
      
      private var m_textfield:TextField = null;
      
      private var m_maxChars:int = 70;
      
      private var m_okButton:ZGameButton = null;
      
      private var m_missionCode:String = null;
      
      private var m_invaderID:String;
      
      public function SpecialForcesMissionReportPopup(param1:String, param2:String)
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_SpecialForces_Taunt.swf"));
         this.m_missionCode = param1;
         this.m_invaderID = param2;
      }
      
      private function get mc() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.contentWidth = this.mc.bg_mc.width;
         this.contentHeight = this.mc.bg_mc.height;
         WindowManager.setFullScreen(false);
         this.m_maxChars = ZGlobal.gameSettings.getInt("maxCommentLength",MAX_INPUT_LENGTH);
         this.m_textfield = this.mc.input_tf;
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
         TextFieldUtil.processTextField(this.mc.taunt_tf,ZGameUtils.ZlocT("Dialogs","StrikeTeamTauntMessage"));
         TextFieldUtil.processTextField(this.mc.title_tf,ZGameUtils.ZlocT("Dialogs","StrikeTeamTauntTitle"));
         TextFieldUtil.processTextField(this.mc.hint_tf,ZGameUtils.ZlocT("Dialogs","StrikeTeamTauntDescription",{"num":this.m_maxChars}));
         this.m_okButton = new ZGameButton(this.mc.green_bt,this.okButtonClicked);
         this.m_okButton.text = ZGameUtils.ZlocT("Dialogs","StrikeTeamTauntButton");
         this.mc.exit_bt.addEventListener(MouseEvent.CLICK,this.exitButtonClicked,false,0,true);
         StatsManager.count("dialog","specialforces","taunt_send",this.m_missionCode,"view");
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
      
      override protected function deinitDialog() : void
      {
         super.deinitDialog();
         this.mc.exit_bt.removeEventListener(MouseEvent.CLICK,this.exitButtonClicked);
         this.m_textfield.removeEventListener(TextEvent.TEXT_INPUT,this.textInput);
         if(this.m_okButton)
         {
            this.m_okButton.dispose();
            this.m_okButton = null;
         }
      }
      
      private function setDefaultComment() : void
      {
         TextFieldUtil.processTextField(this.m_textfield,ZGameUtils.ZlocT("Dialogs","StrikeTeamTauntDefault"));
      }
      
      private function okButtonClicked(param1:MouseEvent) : void
      {
         StatsManager.count("dialog","specialforces","taunt_send",this.m_missionCode,"yes");
         if(this.m_textfield.text == "")
         {
            this.setDefaultComment();
         }
         TransactionManager.addTransaction(new TSetStrikeTeamComment(this.m_missionCode,this.m_invaderID,this.m_textfield.text));
         close();
      }
      
      private function exitButtonClicked(param1:MouseEvent) : void
      {
         StatsManager.count("dialog","specialforces","taunt_send",this.m_missionCode,"no");
         this.setDefaultComment();
         TransactionManager.addTransaction(new TSetStrikeTeamComment(this.m_missionCode,this.m_invaderID,""));
         close();
      }
   }
}

