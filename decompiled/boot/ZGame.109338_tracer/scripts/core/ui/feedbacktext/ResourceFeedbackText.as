package core.ui.feedbacktext
{
   import core.gameobjects.GameItem;
   import core.managers.WorldResourceManager;
   import utils.ZGameUtils;
   
   public class ResourceFeedbackText extends QuantifiedFeedbackText
   {
      
      private var m_type:String = null;
      
      public function ResourceFeedbackText(param1:String, param2:int)
      {
         super(param2);
         this.m_type = param1;
      }
      
      override public function get friendlyName() : String
      {
         return ZGameUtils.ZlocT("Main","ResourceAction",{
            "num":amount,
            "resource":WorldResourceManager.instance.getResourceFriendlyNameFromType(this.m_type,GameItem.SENTENCE_FRIENDLYNAME,Math.abs(m_amount) > 1 ? true : false)
         });
      }
      
      override public function get color() : int
      {
         return WorldResourceManager.instance.getResourceColor(this.m_type);
      }
   }
}

