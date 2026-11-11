package core.ui.feedbacktext
{
   import utils.ZGameUtils;
   
   public class ExperienceFeedbackText extends QuantifiedFeedbackText
   {
      
      public function ExperienceFeedbackText(param1:int)
      {
         super(param1);
      }
      
      override public function get friendlyName() : String
      {
         return ZGameUtils.ZlocT("Main","XPAction",{"num":amount});
      }
      
      override public function get color() : int
      {
         return 5353717;
      }
   }
}

