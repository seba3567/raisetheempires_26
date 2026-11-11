package displays.popups
{
   import core.ZGlobal;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   
   public class RequirementsPopupInfoPopCap implements RequirementsPopupInterface
   {
      
      private var m_newConstruction:Boolean;
      
      public function RequirementsPopupInfoPopCap(param1:Boolean = true)
      {
         super();
         this.m_newConstruction = param1;
      }
      
      public function callback(param1:GenericPopupEvent) : void
      {
      }
      
      public function get mainButtonText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","OkButton");
      }
      
      public function get titleText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","RequirementsTitlePopCap");
      }
      
      public function get bubbleText() : String
      {
         var _loc1_:String = null;
         if(this.m_newConstruction)
         {
            _loc1_ = "RequirementsBubblePopCapNewBuilding";
         }
         else
         {
            _loc1_ = "RequirementsBubblePopCapFinishBuilding";
         }
         return ZGameUtils.ZlocT("Dialogs",_loc1_);
      }
      
      public function get descriptionText() : String
      {
         return ZGameUtils.ZlocT("Dialogs","RequirementsDescPopCap");
      }
      
      public function get iconArray() : Array
      {
         return [ZGlobal.gameSettings.getString("popCapDialogIcon1"),ZGlobal.gameSettings.getString("popCapDialogIcon2"),ZGlobal.gameSettings.getString("popCapDialogIcon3")];
      }
   }
}

