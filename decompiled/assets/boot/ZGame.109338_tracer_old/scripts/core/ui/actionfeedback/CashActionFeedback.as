package core.ui.actionfeedback
{
   import core.ZGlobal;
   import core.ui.FloatingText;
   import core.ui.feedbacktext.CashFeedbackText;
   import core.ui.floatingtext.ImageFloatingText;
   import flash.display.DisplayObjectContainer;
   
   public class CashActionFeedback extends ActionFeedback
   {
      
      public function CashActionFeedback(param1:Object, param2:int, param3:int = 0)
      {
         m_feedbackText = new CashFeedbackText(param2);
         super(param1,null,param2,param3);
      }
      
      override protected function createFloatingText(param1:DisplayObjectContainer) : FloatingText
      {
         return new ImageFloatingText(param1,ZGlobal.getAssetURL(CashFeedbackText.MEDIUM_ICON_URL));
      }
   }
}

