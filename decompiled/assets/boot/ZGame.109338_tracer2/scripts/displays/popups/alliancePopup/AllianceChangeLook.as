package displays.popups.alliancePopup
{
   import Engine.Managers.StatsManager;
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.managers.AlliancesManager;
   import core.managers.ExperimentsManager;
   import core.managers.viralsManager.ViralsManager;
   import core.ui.ZGameButton;
   import displays.ImageLoader;
   import displays.ImageLoaderFactory;
   import displays.popups.GallantPopup;
   import displays.screens.requests.RequestAllianceInviteDialog;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import transactions.clans.TUpdateClanName;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.managers.PopupManager;
   
   public class AllianceChangeLook extends GallantPopup
   {
      
      private static const MAX_INPUT_LENGTH:int = 16;
      
      protected var m_xadjusted:Number;
      
      protected var m_yadjusted:Number;
      
      private var m_allianceManager:AlliancesManager = AlliancesManager.instance;
      
      private var m_textfield:TextField = null;
      
      private var m_initialName:String = null;
      
      private var m_crest:ImageLoader;
      
      private var m_exitbutton:ZGameButton = null;
      
      private var m_selectbutton:ZGameButton = null;
      
      private var m_acceptbutton:ZGameButton = null;
      
      private var m_viraltbutton:ZGameButton = null;
      
      private var m_callback1:Function;
      
      private var m_callback2:Function;
      
      private var m_fbGroupPrivacy:int = 2;
      
      private var m_firstTime:Boolean = false;
      
      public function AllianceChangeLook(param1:Function = null, param2:Function = null, param3:Boolean = false)
      {
         this.m_callback1 = param1;
         this.m_callback2 = param2;
         this.m_firstTime = param3;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_NameAllianceP3.swf"));
      }
      
      override protected function initializeScreen() : void
      {
         super.initializeScreen();
         this.m_selectbutton = new ZGameButton(this.screen.edit_bt,this.onCrestSelect);
         this.m_acceptbutton = new ZGameButton(this.screen.accept_bt,this.onSave);
         this.m_viraltbutton = new ZGameButton(this.screen.viral_bt,this.onAcceptShare);
         this.screen.radio_mc.visible = false;
         this.screen.condition_mc.visible = false;
         if(this.m_allianceManager.fbGroupID != "" && this.m_allianceManager.fbGroupCreated == true)
         {
            this.screen.condition_mc.visible = false;
         }
         if(this.m_allianceManager.fbGroupID == "" && this.m_allianceManager.fbGroupCreated == false && ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_FB_GROUP_MASTER) == 3)
         {
            this.screen.condition_mc.checkBox_mc.addEventListener(MouseEvent.CLICK,this.onCheckBoxClicked);
            this.screen.condition_mc.visible = true;
            TextFieldUtil.compactTextField(this.screen.condition_mc.generic_tf,ZGameUtils.ZlocT("Dialogs","GroupCreateNotice"));
         }
         this.screen.invite_bt.visible = false;
         this.screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         m_window.addEventListener(MouseEvent.CLICK,this.onClickOutside);
         this.m_initialName = this.m_allianceManager.clanName;
         this.m_textfield = this.screen.input_tf;
         if(stage != null)
         {
            stage.focus = this.m_textfield;
         }
         TextFieldUtil.processTextField(this.m_textfield,this.m_initialName);
         this.setupText();
         this.m_textfield.selectable = true;
         this.m_textfield.setSelection(0,this.m_textfield.text.length);
         this.m_textfield.maxChars = MAX_INPUT_LENGTH;
         this.m_textfield.addEventListener(TextEvent.TEXT_INPUT,this.onInputTitle);
         centerWithinStage(Zlab.mainStage);
         this.setCrestIcon();
      }
      
      private function setCrestIcon() : void
      {
         if(this.screen.icon)
         {
            this.m_crest = ImageLoaderFactory.CreateImageLoader(ZGlobal.getAssetURL(this.m_allianceManager.getPath(this.m_allianceManager.crestId,96)),this.screen.icon);
         }
      }
      
      private function get screen() : MovieClip
      {
         return m_window.screen_mc;
      }
      
      private function clearEvents() : void
      {
         this.screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         this.screen.edit_bt.removeEventListener(MouseEvent.CLICK,this.onCrestSelect);
         this.screen.accept_bt.removeEventListener(MouseEvent.CLICK,this.onSave);
         this.screen.viral_bt.removeEventListener(MouseEvent.CLICK,this.onAcceptShare);
         m_window.removeEventListener(MouseEvent.CLICK,this.onClickOutside);
         this.screen.condition_mc.checkBox_mc.removeEventListener(MouseEvent.CLICK,this.onCheckBoxClicked);
      }
      
      protected function setupText() : void
      {
         var _loc1_:String = "";
         TextFieldUtil.compactTextField(this.screen.label1_tf,_loc1_);
         var _loc2_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Name_input2");
         TextFieldUtil.compactTextField(this.screen.label2_tf,_loc2_);
         var _loc3_:String = "";
         TextFieldUtil.compactTextField(this.screen.subtitle_tf,_loc3_);
         var _loc4_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Name_max");
         TextFieldUtil.compactTextField(this.screen.detail_tf,_loc4_);
         var _loc5_:String = this.m_allianceManager.clanName;
         TextFieldUtil.compactTextField(this.screen.input_tf,_loc5_);
         var _loc6_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Name_Save");
         TextFieldUtil.compactTextField(this.screen.accept_bt.generic_tf,_loc6_);
         var _loc7_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Name_InviteShare");
         TextFieldUtil.compactTextField(this.screen.viral_bt.generic_tf,_loc7_);
         var _loc8_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Name_Invite");
         TextFieldUtil.compactTextField(this.screen.invite_bt.generic_tf,_loc8_);
         var _loc9_:String = ZGameUtils.ZlocT("Dialogs","Alliance_Phase3_Name_edit");
         TextFieldUtil.compactTextField(this.screen.edit_bt.generic_tf,_loc9_);
      }
      
      private function beforeClose() : void
      {
         if(this.m_textfield.text != this.m_allianceManager.clanName)
         {
            this.m_allianceManager.clanName = this.m_textfield.text;
         }
         if(this.m_callback2 != null)
         {
            this.m_callback2();
         }
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         this.beforeClose();
         this.clearEvents();
         close();
      }
      
      private function onInputTitle(param1:TextEvent) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
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
         if(ZGlobal.localizer.localeCode == "ja_JP")
         {
            _loc5_ = ZGlobal.gameSettings.getInt("maxWorldNameLength",MAX_INPUT_LENGTH);
            _loc6_ = TextFieldUtil.mb_strwidth(this.m_textfield.text) + TextFieldUtil.mb_strwidth(_loc3_);
            if(_loc6_ > _loc5_)
            {
               param1.preventDefault();
            }
         }
      }
      
      private function onCrestSelect(param1:MouseEvent) : void
      {
         PopupManager.instance.push(new AllianceCrestSelect(this.setCrestIcon,this.m_callback1),0,false);
      }
      
      private function onAccept(param1:MouseEvent) : void
      {
         this.beforeClose();
         this.clearEvents();
         close();
         PopupManager.instance.push(new RequestAllianceInviteDialog(),0,false);
      }
      
      private function onClickOutside(param1:MouseEvent) : void
      {
         if(stage != null)
         {
            stage.focus = this.m_textfield;
         }
         param1.stopPropagation();
         this.m_textfield.selectable = true;
         this.m_textfield.setSelection(0,this.m_textfield.text.length);
         this.m_textfield.maxChars = MAX_INPUT_LENGTH;
      }
      
      private function onSave(param1:MouseEvent) : void
      {
         var _loc2_:TUpdateClanName = null;
         if(this.screen.condition_mc.checkBox_mc.currentFrame == 1 && this.m_allianceManager.fbGroupID == "" && this.m_allianceManager.fbGroupCreated == false && ExperimentsManager.instance.getExperimentVariant(ExperimentsManager.EXPERIMENT_FB_GROUP_MASTER) == 3)
         {
            this.m_allianceManager.setClanName(this.m_textfield.text);
            _loc2_ = new TUpdateClanName(this.m_textfield.text,{
               "makeGroup":true,
               "groupPrivacy":"closed",
               "isNew":this.m_firstTime
            });
            TransactionManager.addTransaction(_loc2_);
         }
         this.beforeClose();
         this.clearEvents();
         close();
      }
      
      private function onAcceptShare(param1:MouseEvent) : void
      {
         this.beforeClose();
         this.clearEvents();
         close();
         StatsManager.count("alliances","invite","feed");
         ViralsManager.instance.sendFeed("allianceInvite",{
            "name":"alliance",
            "allianceName":this.m_textfield.text
         });
         PopupManager.instance.push(new RequestAllianceInviteDialog(),0,false);
      }
      
      private function onCheckBoxClicked(param1:MouseEvent) : void
      {
         if(this.screen.condition_mc.checkBox_mc.currentFrame == 1)
         {
            this.screen.condition_mc.checkBox_mc.gotoAndStop(2);
         }
         else
         {
            this.screen.condition_mc.checkBox_mc.gotoAndStop(1);
         }
      }
      
      private function onRadioButton1Clicked(param1:MouseEvent) : void
      {
         if(this.screen.radio_mc.radio1_mc.currentFrame == 1)
         {
            this.screen.radio_mc.radio1_mc.gotoAndStop(2);
            this.screen.radio_mc.radio2_mc.gotoAndStop(1);
            this.screen.radio_mc.radio3_mc.gotoAndStop(1);
            this.m_fbGroupPrivacy = 1;
         }
      }
      
      private function onRadioButton2Clicked(param1:MouseEvent) : void
      {
         if(this.screen.radio_mc.radio2_mc.currentFrame == 1)
         {
            this.screen.radio_mc.radio2_mc.gotoAndStop(2);
            this.screen.radio_mc.radio1_mc.gotoAndStop(1);
            this.screen.radio_mc.radio3_mc.gotoAndStop(1);
            this.m_fbGroupPrivacy = 2;
         }
      }
      
      private function onRadioButton3Clicked(param1:MouseEvent) : void
      {
         if(this.screen.radio_mc.radio3_mc.currentFrame == 1)
         {
            this.screen.radio_mc.radio3_mc.gotoAndStop(2);
            this.screen.radio_mc.radio1_mc.gotoAndStop(1);
            this.screen.radio_mc.radio2_mc.gotoAndStop(1);
            this.m_fbGroupPrivacy = 3;
         }
      }
      
      private function getFBPrivacyIndex() : String
      {
         return this.screen.radio_mc.radio1_mc.currentFrame == 2 ? "open" : (this.screen.radio_mc.radio2_mc.currentFrame == 2 ? "closed" : "secret");
      }
   }
}

