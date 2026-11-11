package core.ui.feedbacktext
{
   import utils.ZGameUtils;
   
   public class ProtectedFeedbackText extends QuantifiedFeedbackText
   {
      
      public function ProtectedFeedbackText(param1:int = 0)
      {
         super(param1);
      }
      
      override public function get friendlyName() : String
      {
         return ZGameUtils.ZlocT("Main","Protected");
      }
      
      override public function get color() : int
      {
         return 4934655;
      }
   }
}

