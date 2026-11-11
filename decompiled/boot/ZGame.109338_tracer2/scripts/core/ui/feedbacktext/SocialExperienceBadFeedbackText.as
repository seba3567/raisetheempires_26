package core.ui.feedbacktext
{
   public class SocialExperienceBadFeedbackText extends SocialExperienceFeedbackText
   {
      
      public function SocialExperienceBadFeedbackText(param1:int)
      {
         super("blackheart_sentenceName",param1);
      }
      
      override public function get color() : int
      {
         return 13421772;
      }
   }
}

