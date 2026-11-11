package core.ui.feedbacktext
{
   import utils.ZGameUtils;
   
   public class CashFeedbackText extends QuantifiedFeedbackText
   {
      
      public static const MEDIUM_ICON_URL:String = "assets/game/GeneralAssetGroup_UI.swf/Cash_24.png";
      
      public function CashFeedbackText(param1:int)
      {
         super(param1);
      }
      
      override public function get friendlyName() : String
      {
         return ZGameUtils.ZlocT("Main","CashAction",ZGameUtils.CashTokenReplacements(amount));
      }
      
      override public function get color() : int
      {
         return 6901969;
      }
   }
}

