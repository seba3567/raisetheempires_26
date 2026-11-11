package core.ui.feedbacktext
{
   import utils.ZGameUtils;
   
   public class EnergyFeedbackText extends QuantifiedFeedbackText
   {
      
      public static const SMALL_ICON_URL:String = "assets/game/GeneralAssetGroup_UI.swf/unitEnergy.png";
      
      public static const MEDIUM_ICON_URL:String = "assets/game/GeneralAssetGroup_UI.swf/icon_energy.png";
      
      public function EnergyFeedbackText(param1:int)
      {
         super(param1);
      }
      
      override public function get friendlyName() : String
      {
         return ZGameUtils.ZlocT("Main","EnergyAction",{"num":amount});
      }
      
      override public function get color() : int
      {
         return 16443410;
      }
   }
}

