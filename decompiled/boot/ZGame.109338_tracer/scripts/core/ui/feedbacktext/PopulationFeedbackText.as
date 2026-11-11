package core.ui.feedbacktext
{
   import utils.ZGameUtils;
   
   public class PopulationFeedbackText extends QuantifiedFeedbackText
   {
      
      public function PopulationFeedbackText(param1:int)
      {
         super(param1);
      }
      
      override public function get friendlyName() : String
      {
         return amount + " " + ZGameUtils.ZlocTokenGetString(ZGameUtils.ZlocTk("Main","Population_sentenceName",amount > 1 ? "plural" : "singular"));
      }
   }
}

