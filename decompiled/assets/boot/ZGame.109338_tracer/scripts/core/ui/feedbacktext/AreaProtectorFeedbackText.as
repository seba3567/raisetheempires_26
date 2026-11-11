package core.ui.feedbacktext
{
   import core.entities.components.PVPAreaImmuneMarkerComponent;
   import utils.ZGameUtils;
   
   public class AreaProtectorFeedbackText extends QuantifiedFeedbackText
   {
      
      public function AreaProtectorFeedbackText(param1:int = 0)
      {
         super(param1);
      }
      
      override public function get friendlyName() : String
      {
         return ZGameUtils.ZlocT("Main","AreaProtector");
      }
      
      override public function get color() : int
      {
         return PVPAreaImmuneMarkerComponent.TEXT_COLOR;
      }
   }
}

