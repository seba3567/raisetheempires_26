package core.ui.actionfeedback
{
   import core.ui.feedbacktext.ResourceFeedbackText;
   
   public class ResourceActionFeedback extends ActionFeedback
   {
      
      public function ResourceActionFeedback(param1:Object, param2:String, param3:int, param4:int)
      {
         m_feedbackText = new ResourceFeedbackText(param2,param3);
         super(param1,param2,param3,param4);
      }
   }
}

