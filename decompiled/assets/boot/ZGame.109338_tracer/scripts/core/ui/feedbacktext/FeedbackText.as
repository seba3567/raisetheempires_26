package core.ui.feedbacktext
{
   public class FeedbackText
   {
      
      private var m_text:String = "";
      
      public function FeedbackText(param1:String = "")
      {
         super();
         this.m_text = param1;
      }
      
      public function get friendlyName() : String
      {
         return this.m_text;
      }
      
      public function get color() : int
      {
         return 16777215;
      }
   }
}

