package core.ui.feedbacktext
{
   import ZLocalization.LocalizationObjectToken;
   import utils.ZGameUtils;
   
   public class SocialExperienceFeedbackText extends QuantifiedFeedbackText
   {
      
      private var m_label:String;
      
      public function SocialExperienceFeedbackText(param1:String, param2:int)
      {
         super(param2);
         this.m_label = param1;
      }
      
      override public function get friendlyName() : String
      {
         var _loc1_:Boolean = Math.abs(m_amount) > 1 ? true : false;
         var _loc2_:LocalizationObjectToken = ZGameUtils.ZlocTk("Items",this.m_label,_loc1_ ? "plural" : "singular");
         var _loc3_:String = ZGameUtils.ZlocT("Main","Resource_ToolTip",{"resource":_loc2_});
         return ZGameUtils.ZlocT("Main","ResourceAction",{
            "num":amount,
            "resource":_loc3_
         });
      }
   }
}

