package core.ui.feedbacktext
{
   public class QuantifiedFeedbackText extends FeedbackText
   {
      
      protected var m_amount:int = 0;
      
      public function QuantifiedFeedbackText(param1:int = 0)
      {
         this.m_amount = param1;
         super();
      }
      
      override public function get friendlyName() : String
      {
         return null;
      }
      
      override public function get color() : int
      {
         return 16777215;
      }
      
      protected function get amount() : int
      {
         return this.m_amount;
      }
   }
}

