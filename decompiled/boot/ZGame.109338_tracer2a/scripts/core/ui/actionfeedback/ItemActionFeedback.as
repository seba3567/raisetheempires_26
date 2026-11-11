package core.ui.actionfeedback
{
   import core.ui.feedbacktext.ItemFeedbackText;
   import zlabs.entity.IEntity;
   
   public class ItemActionFeedback extends ActionFeedback
   {
      
      public function ItemActionFeedback(param1:IEntity, param2:String, param3:int, param4:int)
      {
         m_feedbackText = new ItemFeedbackText(param2,param3);
         super(param1,param2,param3,param4);
      }
   }
}

