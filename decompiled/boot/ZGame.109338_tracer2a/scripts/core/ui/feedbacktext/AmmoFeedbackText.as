package core.ui.feedbacktext
{
   import utils.ZGameUtils;
   
   public class AmmoFeedbackText extends QuantifiedFeedbackText
   {
      
      public static const SMALL_ICON_URL:String = "assets/game/GeneralAssetGroup_UI.swf/Ammo01_24.png";
      
      public static const MEDIUM_ICON_URL:String = "assets/game/GeneralAssetGroup_UI.swf/Ammo01_42.png";
      
      public function AmmoFeedbackText(param1:int = 0)
      {
         super(param1);
      }
      
      override public function get friendlyName() : String
      {
         return ZGameUtils.ZlocT("Main","AmmoAction",{"num":amount});
      }
      
      override public function get color() : int
      {
         return 16737792;
      }
   }
}

