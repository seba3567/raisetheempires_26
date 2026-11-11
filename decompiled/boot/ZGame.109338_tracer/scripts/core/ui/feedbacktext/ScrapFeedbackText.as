package core.ui.feedbacktext
{
   import utils.ZGameUtils;
   
   public class ScrapFeedbackText extends QuantifiedFeedbackText
   {
      
      public function ScrapFeedbackText(param1:int = 0)
      {
         super(param1);
      }
      
      override public function get friendlyName() : String
      {
         return ZGameUtils.ZlocT("Main","ScrapAction",{"num":amount});
      }
      
      override public function get color() : int
      {
         return 16737792;
      }
   }
}

