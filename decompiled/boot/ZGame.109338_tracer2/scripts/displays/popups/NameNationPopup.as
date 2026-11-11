package displays.popups
{
   import core.ZGlobal;
   import core.managers.tutorialManager.TutorialManager;
   import flash.events.Event;
   import utils.ZGameUtils;
   import zlabs.events.WorldEvent;
   
   public class NameNationPopup extends NamePopup
   {
      
      public function NameNationPopup(param1:String, param2:Function = null)
      {
         super(param1,param2);
      }
      
      override public function get assetURL() : String
      {
         return ZGlobal.getAssetURL("assets/displays/dialogs/PU_NameNation.swf");
      }
      
      override protected function get greeting() : String
      {
         return ZGameUtils.ZlocT("Dialogs","NameNewNationGreeting");
      }
      
      override protected function get title() : String
      {
         return ZGameUtils.ZlocT("Dialogs","NameNewNationTitle");
      }
      
      override protected function get detail() : String
      {
         return ZGameUtils.ZlocT("Dialogs","NameNewNationDetail",{"num":maxChars});
      }
      
      override protected function close(param1:Event = null) : void
      {
         TutorialManager.instance.dispatchEvent(new WorldEvent(TutorialManager.NEW_NATION_CONTINUE));
         super.close(param1);
      }
   }
}

