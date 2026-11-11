package core.ui.feedbacktext
{
   import utils.ZGameUtils;
   
   public class ProtectorFeedbackText extends QuantifiedFeedbackText
   {
      
      public function ProtectorFeedbackText(param1:int = 0)
      {
         super(param1);
      }
      
      override public function get friendlyName() : String
      {
         return ZGameUtils.ZlocT("Main","Protector");
      }
      
      override public function get color() : int
      {
         return 16711680;
      }
   }
}

