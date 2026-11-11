package core.entities.components.behaviors.states
{
   import core.ZGlobal;
   import core.entities.components.behaviors.BehaviorStateInit;
   import core.entities.components.states.IMachine;
   import core.managers.prisoncamp.PrisonCampManager;
   import core.managers.viralsManager.ViralsManager;
   import displays.popups.FeedPopup;
   import displays.popups.GenericPopup;
   import displays.screens.PrisonCampActivationDialog;
   import utils.ZGameUtils;
   import zlabs.events.GenericPopupEvent;
   import zlabs.events.WorldEvent;
   import zlabs.managers.PopupManager;
   
   public class PrisonCampDialogState extends DialogState
   {
      
      public function PrisonCampDialogState(param1:BehaviorStateInit)
      {
         super(param1);
      }
      
      override protected function showDialog() : void
      {
         if(ZGlobal.isHome())
         {
            window = PrisonCampActivationDialog.display();
         }
      }
      
      private function onActivateClick(param1:WorldEvent) : void
      {
         clickNextState();
         this.showActivatedDialog(param1.eventData.potentialMult);
      }
      
      private function showActivatedDialog(param1:Number) : void
      {
         var _loc2_:String = param1 == PrisonCampManager.MULTIPLIER_15_FLOAT ? "Prison_Camp_Activation_Body_15" : "Prison_Camp_Activation_Body_20";
         var _loc3_:FeedPopup = new FeedPopup(ZGameUtils.ZlocT("Dialogs",_loc2_),ZGameUtils.ZlocT("Dialogs","Prison_Camp_Activation_Title"),ZGameUtils.ZlocT("Dialogs","Prison_Camp_Activation_Button"),GenericPopup.TYPE_SHARECANCEL,this.onActivatedDialogClosed,ZGlobal.getAssetURL("assets/game/quests/Quests_Icons_0.swf/PrisonCamp_01_96.png"),FeedPopup.LARGE_IMAGE);
         PopupManager.instance.push(_loc3_);
      }
      
      private function onActivatedDialogClosed(param1:GenericPopupEvent) : void
      {
         if(param1.button == GenericPopup.ACCEPT)
         {
            ViralsManager.instance.sendFeed("prison_camp_activated",new Object());
         }
      }
      
      override protected function addWindowListeners() : void
      {
         super.addWindowListeners();
         window.addEventListener(PrisonCampActivationDialog.ACTIVATE_BUFF_EVENT,this.onActivateClick,false,0,true);
      }
      
      override protected function removeWindowListeners() : void
      {
         super.removeWindowListeners();
         window.removeEventListener(PrisonCampActivationDialog.ACTIVATE_BUFF_EVENT,this.onActivateClick);
      }
      
      private function performUpdate() : void
      {
         ZGlobal.player.xpMultiplier = PrisonCampManager.instance.getPotentialXPMultiplier();
      }
      
      override protected function performExitActions(param1:IMachine) : void
      {
         super.performExitActions(param1);
         this.performUpdate();
      }
   }
}

