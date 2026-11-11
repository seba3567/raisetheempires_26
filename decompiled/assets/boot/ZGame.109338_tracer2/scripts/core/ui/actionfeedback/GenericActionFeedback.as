package core.ui.actionfeedback
{
   import core.ui.FloatingText;
   import core.ui.feedbacktext.FeedbackText;
   import flash.display.DisplayObjectContainer;
   
   public class GenericActionFeedback extends ActionFeedback
   {
      
      public function GenericActionFeedback(param1:Object, param2:String)
      {
         m_feedbackText = new FeedbackText(param2);
         super(param1,null,0);
      }
      
      override protected function createFloatingText(param1:DisplayObjectContainer) : FloatingText
      {
         return new FloatingText(param1,GenericFeedbackTextCentered);
      }
   }
}

