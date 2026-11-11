package displays.popups
{
   import Engine.Managers.TransactionManager;
   import core.ZGlobal;
   import core.ui.ZGameButton;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.StyleSheet;
   import transactions.TAcknowledgeTOSStatus;
   import utils.TextFieldUtil;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   
   public class TOSPPPopup extends GallantPopup
   {
      
      private static const REPLACEMENT_TOKEN:String = "REPLACEME";
      
      private static const HYPERLINK_COLOR:String = "#000055";
      
      private var m_okBtn:ZGameButton = null;
      
      public function TOSPPPopup()
      {
         super(ZGlobal.getAssetURL("assets/displays/dialogs/PU_TOS.swf"));
      }
      
      override protected function initializeScreen() : void
      {
         var _loc1_:MovieClip = null;
         _loc1_ = m_window.tos_mc;
         contentWidth = _loc1_.panel_mc.width;
         contentHeight = _loc1_.panel_mc.height;
         super.initializeScreen();
         TextFieldUtil.processTextField(_loc1_.generic_tf,REPLACEMENT_TOKEN);
         var _loc2_:String = _loc1_.generic_tf.htmlText;
         var _loc3_:StyleSheet = new StyleSheet();
         _loc3_.setStyle("a:link",{"color":HYPERLINK_COLOR});
         _loc3_.setStyle("a:hover",{
            "textDecoration":"underline",
            "color":HYPERLINK_COLOR
         });
         _loc1_.generic_tf.styleSheet = _loc3_;
         var _loc4_:String = "<a href=\"{URL}\" target=\"_blank\">{title}</a>";
         var _loc5_:String = ZGlobal.gameSettings.getString("zyngaTOSURL","http://www.zynga.com/about/terms-of-service.php");
         var _loc6_:String = ZGameUtils.ZlocT("Dialogs","TOSPolicyTOSTitle");
         var _loc7_:String = ZGameUtils.strTokenReplace(_loc4_,{
            "URL":_loc5_,
            "title":_loc6_
         });
         var _loc8_:String = ZGlobal.gameSettings.getString("zyngaPPURL","http://www.zynga.com/about/privacy-policy.php");
         var _loc9_:String = ZGameUtils.ZlocT("Dialogs","TOSPolicyPPTitle");
         var _loc10_:String = ZGameUtils.strTokenReplace(_loc4_,{
            "URL":_loc8_,
            "title":_loc9_
         });
         _loc2_ = _loc2_.replace(REPLACEMENT_TOKEN,ZGameUtils.ZlocT("Dialogs","TOSPolicyMessageBody",{
            "TOSLink":_loc7_,
            "PPLink":_loc10_
         }));
         _loc1_.generic_tf.htmlText = _loc2_;
         this.m_okBtn = new ZGameButton(_loc1_.green_btn,this.onOkButton);
         this.m_okBtn.text = ZGameUtils.localizedStringForToken("Dialogs:OkButton");
      }
      
      override protected function deinitDialog() : void
      {
         this.m_okBtn.dispose();
         super.deinitDialog();
      }
      
      private function onOkButton(param1:MouseEvent) : void
      {
         dispatchEvent(new GenericPopupEvent(GenericPopupEvent.SELECTED,GenericPopup.ACCEPT));
         TransactionManager.addTransaction(new TAcknowledgeTOSStatus());
         close();
      }
   }
}

