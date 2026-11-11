package core.ui.UIDirector
{
   import core.managers.tutorialManager.TutorialManager;
   import zlabs.events.WorldEvent;
   
   public class CampaignV2DirectorScript extends UIDirectorScript
   {
      
      public static const SCRIPT_ID:String = "LAUNCH_CAMPAIGN_V2_TUTORIAL";
      
      public static const SEEN_FLAG:String = "CAMPAIGN_V2_TUTORIAL_SEEN";
      
      public function CampaignV2DirectorScript()
      {
         super();
      }
      
      override public function begin() : void
      {
         TutorialManager.instance.addEventListener(TutorialManager.CAMPAIGN_SELECTOR_OPENED,this.onSelectorOpened,false,0,true);
         TutorialManager.instance.sendEvent(TutorialManager.UI_CAMPAIGN_SELECTOR_OPENER,true);
      }
      
      private function onSelectorOpened(param1:WorldEvent) : void
      {
         TutorialManager.instance.sendEvent(TutorialManager.UI_CLEAR_STENCIL);
         TutorialManager.instance.removeArrows();
         TutorialManager.instance.removeEventListener(TutorialManager.CAMPAIGN_SELECTOR_OPENED,this.onSelectorOpened);
         TutorialManager.instance.addEventListener(TutorialManager.CAMPAIGN_MAP_SELECTED,this.onCampaignMapSelected,false,0,true);
         TutorialManager.instance.sendEvent(TutorialManager.UI_CAMPAIGN_SELECTOR_NEWMAP);
      }
      
      private function onCampaignMapSelected(param1:WorldEvent) : void
      {
         TutorialManager.instance.removeEventListener(TutorialManager.CAMPAIGN_MAP_SELECTED,this.onCampaignMapSelected);
         this.exitScript();
      }
      
      override protected function exitScript() : void
      {
         TutorialManager.instance.sendEvent(TutorialManager.UI_CLEAR_STENCIL);
         TutorialManager.instance.removeArrows();
         TutorialManager.instance.sendEvent(TutorialManager.UI_DISABLE);
         TutorialManager.instance.sendEvent(TutorialManager.UI_ENABLE);
         super.exitScript();
      }
   }
}

