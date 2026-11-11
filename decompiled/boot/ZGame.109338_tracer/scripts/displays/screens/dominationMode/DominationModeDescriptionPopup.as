package displays.screens.dominationMode
{
   import core.ZGlobal;
   import core.ui.GenericButton;
   import core.ui.ZGameButton;
   import displays.popups.zgamepopup.ZGamePopUp;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.managers.PopupManager;
   import zlabs.resource.SWFResource;
   
   public class DominationModeDescriptionPopup extends ZGamePopUp
   {
      
      public static const TYPE_INTRO:String = "main";
      
      public static const TYPE_DEFENSEFORCE:String = "defense_force";
      
      private var m_mc:MovieClip = null;
      
      private var m_button:ZGameButton = null;
      
      private var m_closeButton:GenericButton;
      
      private var m_type:String;
      
      public function DominationModeDescriptionPopup(param1:String)
      {
         this.m_type = param1;
         var _loc2_:String = this.path;
         super(ZGlobal.getAssetURL(_loc2_));
      }
      
      private function get path() : String
      {
         if(this.m_type == TYPE_INTRO)
         {
            return "assets/displays/dialogs/PU_WorldDomination_Instructions.swf";
         }
         return "assets/displays/dialogs/PU_WorldDomination_DefenseInstructions.swf";
      }
      
      private function get stringKeys() : Object
      {
         if(this.m_type == TYPE_INTRO)
         {
            return {
               "title":"DominationOTPU_Title",
               "m1":"DominationOTPU_Line1",
               "m2":"DominationOTPU_Line2",
               "m3":"DominationOTPU_Line3",
               "button":"Continue"
            };
         }
         return {
            "title":"DominationDefenseSetupTitle",
            "m1":"DominationDefenseSetupIntro1",
            "m2":"DominationDefenseSetupIntro2",
            "m3":"DominationDefenseSetupIntro3",
            "button":"Okay"
         };
      }
      
      override protected function getWindowInstance(param1:SWFResource) : MovieClip
      {
         var _loc2_:Class = param1.getAssetClass("Screen_mc");
         return new _loc2_();
      }
      
      override protected function onLoadComplete(param1:SWFResource) : void
      {
         super.onLoadComplete(param1);
         PopupManager.instance.notifyLoadComplete(this);
      }
      
      private function centerIfAnchorExists(param1:TextField, param2:MovieClip) : void
      {
         if(param1)
         {
            param1.y += Math.round((param1.height - param1.textHeight) / 2);
         }
      }
      
      override protected function initDialog() : void
      {
         super.initDialog();
         var _loc1_:Object = this.stringKeys;
         TextFieldUtil.processTextField(m_window.title_tf,ZGameUtils.ZlocT("Dialogs",_loc1_.title));
         TextFieldUtil.processTextField(m_window.line1_tf,ZGameUtils.ZlocT("Dialogs",_loc1_.m1));
         TextFieldUtil.processTextField(m_window.line2_tf,ZGameUtils.ZlocT("Dialogs",_loc1_.m2));
         TextFieldUtil.processTextField(m_window.line3_tf,ZGameUtils.ZlocT("Dialogs",_loc1_.m3));
         this.centerIfAnchorExists(m_window.line1_tf,m_window.anchor_mc_0);
         this.centerIfAnchorExists(m_window.line2_tf,m_window.anchor_mc_1);
         this.centerIfAnchorExists(m_window.line3_tf,m_window.anchor_mc_2);
         if(m_window.buy_bt)
         {
            this.m_button = new ZGameButton(m_window.buy_bt,this.onContinue);
            this.m_button.text = ZGameUtils.ZlocT("Dialogs",_loc1_.button);
         }
         else if(m_window.close_bt)
         {
            this.m_closeButton = new GenericButton(m_window.close_bt,this.onContinue);
         }
         addChild(m_window);
      }
      
      override public function onShow() : void
      {
         if(m_window)
         {
            super.onShow();
            this.initDialog();
         }
      }
      
      protected function onContinue(param1:Event) : void
      {
         close();
      }
      
      override protected function deinitDialog() : void
      {
         this.m_closeButton = null;
         if(this.m_button)
         {
            this.m_button.dispose();
            this.m_button = null;
         }
         super.deinitDialog();
      }
   }
}

