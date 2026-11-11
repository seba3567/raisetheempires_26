package displays.popups.alliancePopup
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.ui.ZGameButton;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import transactions.clans.TPostGroupFeed;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.Zlab;
   import zlabs.events.WorldEvent;
   import zlabs.resource.SWFResource;
   
   public class FBGroupPostPopup extends ZGamePopUp
   {
      
      public static const POPUP_CLOSED:String = "ClosedFBPopup";
      
      private var m_screen:MovieClip;
      
      private var m_acceptBt:ZGameButton;
      
      private var m_exitBt:ZGameButton;
      
      private var m_clanName:String;
      
      private var m_message:String;
      
      private var m_source:String;
      
      public function FBGroupPostPopup(param1:String, param2:String, param3:String = "dashboard")
      {
         this.m_clanName = param1;
         this.m_message = param2;
         this.m_source = param3;
         super(ZGlobal.getAssetURL("assets/displays/dialogs/FB_Popup.swf"));
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         this.m_screen = m_window.screen_mc;
         this.m_acceptBt = new ZGameButton(this.m_screen.ok_bt,this.onAccept);
         if(this.m_source == "dashboard")
         {
            this.m_acceptBt.disable_visual();
         }
         this.m_screen.exit_bt.addEventListener(MouseEvent.CLICK,this.onExit);
         this.m_acceptBt.text = ZGameUtils.ZlocT("Dialogs","ShareButton");
         this.setupText();
         centerWithinStage(Zlab.mainStage);
      }
      
      private function onInputTitle(param1:TextEvent) : void
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
         var _loc5_:String = this.m_screen.input_tf.text;
         if(_loc5_.length == 0)
         {
            this.m_acceptBt.disable_visual();
         }
         else if(Boolean(this.m_acceptBt) && !this.m_acceptBt.enabled)
         {
            this.m_acceptBt.enable();
         }
      }
      
      private function onTextFieldChange(param1:Event) : void
      {
         if(param1.currentTarget.length == 0)
         {
            this.m_acceptBt.disable_visual();
         }
         else if(Boolean(this.m_acceptBt) && !this.m_acceptBt.enabled)
         {
            this.m_acceptBt.enable();
         }
      }
      
      private function setupText() : void
      {
         var _loc1_:TextField = null;
         TextFieldUtil.compactTextField(this.m_screen.label1_tf,ZGameUtils.ZlocT("Dialogs","GroupLabel"));
         TextFieldUtil.compactTextField(this.m_screen.value_tf,this.m_clanName);
         _loc1_ = this.m_screen.input_tf;
         stage.focus = _loc1_;
         TextFieldUtil.processTextField(this.m_screen.input_tf,this.m_message);
         this.m_screen.input_tf.selectable = true;
         this.m_screen.input_tf.type = "input";
         this.m_screen.input_tf.mouseEnabled = true;
         this.m_screen.input_tf.setSelection(0,this.m_message.length);
         this.m_screen.input_tf.addEventListener(TextEvent.TEXT_INPUT,this.onInputTitle);
         this.m_screen.input_tf.addEventListener(Event.CHANGE,this.onTextFieldChange);
         TextFieldUtil.compactTextField(this.m_screen.label2_tf,ZGameUtils.ZlocT("Dialogs","GroupMessageLabel"));
         TextFieldUtil.compactTextField(this.m_screen.detail_tf,ZGameUtils.ZlocT("Dialogs","GroupFeedNotice"));
         TextFieldUtil.compactTextField(this.m_screen.subtitle_tf,ZGameUtils.ZlocT("Dialogs","GroupPostPopupHeader"));
         initDialog();
         addChild(m_window);
      }
      
      public function onExit(param1:MouseEvent = null) : void
      {
         if(this.m_acceptBt)
         {
            this.m_acceptBt.dispose();
         }
         this.m_acceptBt = null;
         this.m_screen.exit_bt.removeEventListener(MouseEvent.CLICK,this.onExit);
         deinitDialog();
         dispatchEvent(new WorldEvent(POPUP_CLOSED));
         close();
      }
      
      public function onAccept(param1:Event) : void
      {
         var _loc2_:String = this.m_screen.input_tf.text;
         var _loc3_:TPostGroupFeed = new TPostGroupFeed(_loc2_,this.m_source);
         TransactionManager.addTransaction(_loc3_,true);
         this.onExit();
      }
   }
}

