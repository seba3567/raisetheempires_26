package core.ui.feedbacktext
{
   import utils.ZGameUtils;
   
   public class ManaFeedbackText extends QuantifiedFeedbackText
   {
      
      public function ManaFeedbackText(param1:int)
      {
         super(param1);
      }
      
      override public function get friendlyName() : String
      {
         return ZGameUtils.ZlocT("Main","ManaAction",{"num":amount});
      }
      
      override public function get color() : int
      {
         return 15762420;
      }
   }
}

