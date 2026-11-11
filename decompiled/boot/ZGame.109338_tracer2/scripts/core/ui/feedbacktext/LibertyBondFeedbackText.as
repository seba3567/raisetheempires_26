package core.ui.feedbacktext
{
   import utils.ZGameUtils;
   
   public class LibertyBondFeedbackText extends QuantifiedFeedbackText
   {
      
      public static const ICON_URL:String = "assets/game/quests/Quests_Icons_0.swf/LibertyBond_96.png";
      
      public function LibertyBondFeedbackText(param1:int)
      {
         super(param1);
      }
      
      override public function get friendlyName() : String
      {
         return amount.toString() + " " + ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk("Items","expansionkey01_sentenceName",amount > 1 ? "plural" : "singular"));
      }
      
      override public function get color() : int
      {
         return 16443410;
      }
   }
}

