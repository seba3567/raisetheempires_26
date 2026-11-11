package core.ui.feedbacktext
{
   public class SocialExperienceGoodFeedbackText extends SocialExperienceFeedbackText
   {
      
      public function SocialExperienceGoodFeedbackText(param1:int)
      {
         super("redheart_sentenceName",param1);
      }
      
      override public function get color() : int
      {
         return 16729156;
      }
   }
}

