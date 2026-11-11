package core.ui.feedbacktext
{
   import core.entities.components.PVPAreaImmuneMarkerComponent;
   import utils.ZGameUtils;
   
   public class AreaImmuneFeedbackText extends QuantifiedFeedbackText
   {
      
      public function AreaImmuneFeedbackText(param1:int = 0)
      {
         super(param1);
      }
      
      override public function get friendlyName() : String
      {
         return ZGameUtils.ZlocT("Main","AreaProtected");
      }
      
      override public function get color() : int
      {
         return PVPAreaImmuneMarkerComponent.TEXT_COLOR;
      }
   }
}

